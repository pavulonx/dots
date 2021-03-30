# fixme - the load process here seems a bit bizarre
zmodload -i zsh/complist

#WORDCHARS='' # where not to stop hen moving word (ctrl+left/right) default stop only on space

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end
setopt auto_list         # automatically list choices on ambiguous completion.

# should this be in keybindings?
bindkey -M menuselect '^@' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# Auto complete with case insenstivity
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$HOME/.cache/zsh"

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit
