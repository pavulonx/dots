Zsh execution:

|  |Interactive login |Interactive non-login|Script|
|-----------------|-----------|-----------|------|
|/etc/zshenv     |    A      |    A      |  A   |
|~/.zshenv       |    B      |    B      |  B   |
|/etc/zprofile   |    C      |           |      |
|~/.zprofile     |    D      |           |      |
|/etc/zshrc      |    E      |    C      |      |
|~/.zshrc        |    F      |    D      |      |
|/etc/zlogin     |    G      |           |      |
|~/.zlogin       |    H      |           |      |
|~/.zlogout      |    I      |           |      |
|/etc/zlogout    |    J      |           |      |

Bash execution:

|  |Interactive login |Interactive non-login|Script|
|-----------------|-----------|-----------|------|
| /etc/profile    |   A       |           |      |
| ~/.bash_profile |   B1      |           |      |
| ~/.bash_login   |   B2      |           |      |
| ~/.profile      |   B3      |           |      |
| /etc/bash.bashrc|           |    A      |      |
| ~/.bashrc       |           |    B      |      |
| BASH_ENV        |           |           |  A   |
| ~/.bash_logout  |    C      |           |      |

Bash is not supported

# Cron

To send notifications `DBUS_SESSION_BUS_ADDRESS` must be set globally and `DISPLAY` must be defined

```sh
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USER)/bus"; export DISPLAY=:0; "$HOME"/.local/bin/<CMD>
```
