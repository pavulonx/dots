# Set terminal window and tab/icon title
#
# usage: title short_tab_title [long_window_title]
#
# See: http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss3.1
# (In screen, only short_tab_title is used)
function title {
  [ "$DISABLE_AUTO_TITLE" != "true" ] || return
  : "${2=$1}"
  case "$TERM" in
    xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|st*)
      print -Pn "\e]2;$2:q\a" # set window name
      print -Pn "\e]1;$1:q\a" # set tab name
      ;;
    screen*|tmux*)
      print -Pn "\ek$1:q\e\\" # set screen hardstatus
      ;;
  esac
}

ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
ZSH_THEME_TERM_TITLE_IDLE="%n@%m: %~"

# Runs before showing the prompt
function termsupport_precmd {
  title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}

# Runs before executing the command
function termsupport_preexec {
  emulate -L zsh
  setopt extended_glob
  local CMD=${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}   # cmd name only, or if this is sudo or ssh, the next cmd
  local LINE="${2:gs/%/%%}"

  title "$CMD" "%100>...>$LINE%<<"
}

autoload -U add-zsh-hook
add-zsh-hook precmd termsupport_precmd
add-zsh-hook preexec termsupport_preexec
