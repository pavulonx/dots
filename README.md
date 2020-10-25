# Screenshots:
# ![Current setup](https://raw.githubusercontent.com/rozenj/dots/master/other/scrot/2020-10-25-012729_2560x1440_scrot.png)

# Required configuration:
In `~/.config/chezmoi/chezmoi.toml` set:
 - **machine_type** - to one of `desktop`, `server`, `laptop`
 - **browser** - path to browser
 - **browser_desktop** - browser desktop file name
```
[data]
    machine_type = "desktop"
    browser = "/usr/bin/firefox"
    browser_desktop = "firefox.desktop"
```

___
#### TODO:
- use current_player script
- auto configure crontab - backup
- https://stackoverflow.com/a/38980986/8156320

