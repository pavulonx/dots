import { Plugin } from "@opencode/plugin"

type Event = "question" | "permission" | "error" | "done" | "subagent_done"

type Alert = {
  event: Event
  summary: string
  lines: string[]
}

/** Sound backend. Set to "off" to disable audio entirely. */
const SOUND: "freedesktop" | "off" = "freedesktop"

/**
 * Per-event sound file and volume, as a fraction of the system volume. Set an
 * event to `null` to silence it.
 *
 * `done` fires constantly across parallel sessions, so it is mixed well below
 * the events that actually need a response.
 */
const SOUNDS: Record<Event, { file: string; volume: number } | null> = {
  question: { file: "message-new-instant.oga", volume: 0.4 },
  permission: { file: "dialog-warning.oga", volume: 0.4 },
  error: { file: "dialog-error.oga", volume: 0.4 },
  done: { file: "complete.oga", volume: 0.2 },
  subagent_done: { file: "bell.oga", volume: 0.2 },
}

/** Best-effort WM urgency hint. Unverified on Alacritty; safe to turn off. */
const URGENCY_HINT = true

/**
 * Stay quiet when the session's own terminal window already has focus: you are
 * looking at it, so neither the bubble nor the sound tells you anything new.
 *
 * Only applies to TUI sessions. Headless `opencode run` has no window, so it
 * always alerts.
 */
const SKIP_WHEN_FOCUSED = true

const PLUGIN_DIR = import.meta.dir
const ICON_DIR = `${process.env.HOME}/.local/share/icons/opencode`

const ICONS: Record<Event, string> = {
  question: `${ICON_DIR}/opencode-question.png`,
  permission: `${ICON_DIR}/opencode-warning.png`,
  error: `${ICON_DIR}/opencode-error.png`,
  done: `${ICON_DIR}/opencode.png`,
  subagent_done: `${ICON_DIR}/opencode.png`,
}

const play = (event: Event) => {
  const sound = SOUNDS[event]
  if (SOUND === "off" || !sound) return
  // Not awaited: audio must never delay the notification.
  Bun.spawn(
    [
      "paplay",
      `--volume=${Math.round(sound.volume * 65536)}`,
      `/usr/share/sounds/freedesktop/stereo/${sound.file}`,
    ],
    { stdout: "ignore", stderr: "ignore" },
  )
}

/**
 * Flag the terminal window showing a session as urgent.
 *
 * Window resolution lives in the `opencode-urgency` wrapper beside this file so
 * it can also be run by hand; `./opencode-urgency list` shows what it sees.
 *
 * Fire and forget: the notification has already been delivered, and a missing
 * script, window manager, or window is not worth reporting.
 */
const raiseUrgency = (directory: string | undefined) => {
  if (!URGENCY_HINT || !directory) return
  try {
    Bun.spawn([`${PLUGIN_DIR}/opencode-urgency`, "urgency", directory], {
      stdout: "ignore",
      stderr: "ignore",
    })
  } catch {
    // Script not found, or no window manager.
  }
}

/**
 * True when the terminal showing this session is the active window. Any
 * failure counts as unfocused, so a broken check still alerts.
 */
const isFocused = async (directory: string | undefined) => {
  if (!SKIP_WHEN_FOCUSED || !directory) return false
  try {
    const proc = Bun.spawn(
      [`${PLUGIN_DIR}/opencode-urgency`, "focused", directory],
      { stdout: "ignore", stderr: "ignore" },
    )
    return (await proc.exited) === 0
  } catch {
    return false
  }
}

/** Generate the icon set on first run, or after the icons are deleted. */
const ensureIcons = async () => {
  try {
    const present = await Promise.all(
      Object.values(ICONS).map((path) => Bun.file(path).exists()),
    )
    if (present.every(Boolean)) return
    const proc = Bun.spawn([`${PLUGIN_DIR}/generate-icons.sh`], {
      stdout: "ignore",
      stderr: "pipe",
    })
    if ((await proc.exited) !== 0) {
      const stderr = await new Response(proc.stderr).text()
      console.error(`icon generation failed: ${stderr.trim()}`)
    }
  } catch (error) {
    console.error("icon generation skipped", error)
  }
}

const home = process.env.HOME ?? ""

const shortenDirectory = (directory: string | undefined) => {
  if (!directory) return undefined
  const tilde = home && directory.startsWith(home)
    ? `~${directory.slice(home.length)}`
    : directory
  return tilde.length > 40 ? (tilde.split("/").pop() ?? tilde) : tilde
}

const formatDuration = (ms: number | undefined) => {
  if (!ms || ms < 0) return undefined
  const total = Math.round(ms / 1000)
  if (total < 60) return `${total}s`
  const minutes = Math.floor(total / 60)
  const seconds = total % 60
  if (minutes < 60) return seconds ? `${minutes}m ${seconds}s` : `${minutes}m`
  return `${Math.floor(minutes / 60)}h ${minutes % 60}m`
}

// dunst replaces an existing notification when the stack tag matches, so a
// session that fires repeatedly updates one bubble instead of stacking them.
const notify = async (alert: Alert, sessionID: string, signal: AbortSignal) => {
  const proc = Bun.spawn(
    [
      "notify-send",
      "--app-name=opencode",
      `--icon=${ICONS[alert.event]}`,
      `--hint=string:x-dunst-stack-tag:opencode-${sessionID}`,
      `--category=opencode.${alert.event}`,
      alert.summary,
      alert.lines.filter(Boolean).join("\n"),
    ],
    { stdout: "ignore", stderr: "pipe", signal },
  )
  const code = await proc.exited
  if (code !== 0) {
    const stderr = await new Response(proc.stderr).text()
    console.error(`notify-send exited ${code}: ${stderr.trim()}`)
  }
  play(alert.event)
}

export default Plugin.define({
  id: "local.notify-send",
  setup(ctx) {
    const controller = new AbortController()
    const { signal } = controller

    void ensureIcons()

    // A failed execution is followed by a terminal event. Track failures so the
    // generic "done" alert does not overwrite the more specific error.
    const failed = new Set<string>()
    const forms = new Set<string>()
    const permissions = new Set<string>()

    const describe = async (sessionID: string) => {
      try {
        const session = await ctx.session.get({ sessionID })
        return {
          title: session.title,
          isChild: session.parentID !== undefined,
          directory: shortenDirectory(session.location?.directory),
          path: session.location?.directory,
          context: [session.agent, session.model?.id]
            .filter(Boolean)
            .join(" · "),
          duration: formatDuration(
            session.time?.updated && session.time?.created
              ? session.time.updated - session.time.created
              : undefined,
          ),
        }
      } catch {
        return {}
      }
    }

    const emit = async (
      sessionID: string,
      alert: Alert,
      path: string | undefined,
    ) => {
      if (await isFocused(path)) return
      await notify(alert, sessionID, signal)
      raiseUrgency(path)
    }

    const finish = async (sessionID: string) => {
      if (failed.delete(sessionID)) return
      const info = await describe(sessionID)
      const event: Event = info.isChild ? "subagent_done" : "done"
      const headline = info.isChild ? "Subagent done" : "Session done"
      await emit(sessionID, {
        event,
        summary: info.title ?? "opencode",
        lines: [
          info.duration ? `${headline} · ${info.duration}` : headline,
          info.directory ?? "",
          info.context ?? "",
        ],
      }, info.path)
    }

    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({ signal })) {
          const data = event.data as Record<string, any>
          switch (event.type) {
            case "form.created": {
              const id = data.form.id
              if (forms.has(id)) break
              forms.add(id)
              const info = await describe(data.form.sessionID)
              await emit(data.form.sessionID, {
                event: "question",
                summary: data.form.title ?? info.title ?? "opencode",
                lines: [
                  "Input needs response",
                  info.directory ?? "",
                  info.context ?? "",
                ],
              }, info.path)
              break
            }
            case "form.replied":
            case "form.cancelled":
              forms.delete(data.id)
              break

            case "permission.asked": {
              if (permissions.has(data.id)) break
              permissions.add(data.id)
              const info = await describe(data.sessionID)
              await emit(data.sessionID, {
                event: "permission",
                summary: info.title ?? "opencode",
                lines: [
                  "Permission needs input",
                  info.directory ?? "",
                  info.context ?? "",
                ],
              }, info.path)
              break
            }
            case "permission.replied":
              permissions.delete(data.requestID)
              break

            case "session.execution.failed": {
              const sessionID = data.sessionID
              failed.add(sessionID)
              const info = await describe(sessionID)
              await emit(sessionID, {
                event: "error",
                summary: info.title ?? "opencode",
                lines: [
                  data.error?.message ?? "Session failed",
                  info.directory ?? "",
                  info.context ?? "",
                ],
              }, info.path)
              break
            }

            case "session.execution.succeeded":
            case "session.execution.interrupted":
              await finish(data.sessionID)
              break
          }
        }
      } catch (error) {
        if (!signal.aborted) console.error("notify-send plugin stopped", error)
      }
    })()

    return () => controller.abort()
  },
})
