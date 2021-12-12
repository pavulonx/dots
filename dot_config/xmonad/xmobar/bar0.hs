-- http://projects.haskell.org/xmobar/
-- install xmobar with these flags: --flags="with_alsa" --flags="with_mpd" --flags="with_xft"  OR --flags="all_extensions"
-- you can find weather location codes here: http://weather.noaa.gov/index.html

Config { font    = "xft:Lato:size=9:antialias=true:hinting=true:fontformat=truetype"
  , additionalFonts = [ "xft:Noto Sans:size=9:fontformat=truetype"
    , "xft:NotoSans-Regular:size=8"
    , "xft:MaterialIcons:size=10"
    , "xft:FontAwesome:size=10"
    , "xft:DejaVuSansMono Nerd Font:size=10"
  ]
  , bgColor = "#080808"
  , fgColor = "#ebdbb2"
  , position = Static { xpos = 0 , ypos = 0, width = 2560, height = 24 }
  --, position = Static { height = 24 }
  , lowerOnStart = True
    , hideOnStart = False
    , allDesktops = True
    , persistent = True
    , iconRoot = "/home/jrozen/.config/xmonad/xpm/"  -- default: "."
    , commands = [
    -- Time and date
      Run Date "<fn=4>\xf133</fn>  %b %d %Y - (%H:%M) " "date" 50
      -- Network up and down
      , Run Network "enp6s0" ["-t", "<fn=4>\xf0aa</fn>  <rx>kb  <fn=4>\xf0ab</fn>  <tx>kb"] 20
      -- Cpu usage in percent
      , Run Cpu ["-t", "<fn=4>\xf108</fn>  cpu: (<total>%)","-H","50","--high","red"] 20
      -- Ram used number and percent
      , Run Memory ["-t", "<fn=4>\xf233</fn>  mem: <used>M (<usedratio>%)"] 20
      -- Disk space free
      , Run DiskU [("/", "<fn=4>\xf0c7</fn>  hdd: <free> free")] [] 60
      -- Runs custom script to check for pacman updates.
      -- This script is in my dotfiles repo in .local/bin.
      , Run Com "/home/dt/.local/bin/pacupdate" [] "pacupdate" 36000
      -- Runs a standard shell command 'uname -r' to get kernel version
      , Run Com "uname" ["-r"] "" 3600
      -- Script that dynamically adjusts xmobar padding depending on number of trayer icons.
      , Run Com "/home/jrozen/.config/xmonad/xmobar/trayer-padding-icon.sh" [] "trayerpad" 20
      -- Prints out the left side items such as workspaces, layout, etc.
      -- The workspaces are 'clickable' in my configs.
      , Run UnsafeStdinReader
      ]
      , sepChar = "%"
      , alignSep = "}{"
      , template = " %UnsafeStdinReader% }{ <fc=#666666> |</fc> <fc=#b3afc2><fn=4>linux</fn>  %uname% </fc><fc=#666666> |</fc> <fc=#ecbe7b> %cpu% </fc><fc=#666666> |</fc> <fc=#ff6c6b> %memory% </fc><fc=#666666> |</fc> <fc=#51afef> %disku% </fc><fc=#666666> |</fc> <fc=#98be65> %enp6s0% </fc><fc=#666666> |</fc>  <fc=#46d9ff> %date%  </fc><fc=#666666><fn=4>|</fn></fc>%trayerpad%"
}
