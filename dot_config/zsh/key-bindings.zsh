function zle-line-init() {
  zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
  echo -ne "\e[5 q"
}
zle -N zle-line-init

function zle-keymap-select() {
  if [[ ${KEYMAP} == vicmd ]] ||
    [[ $1 = 'block' ]]; then
      echo -ne '\e[2 q'
    elif [[ ${KEYMAP} == main ]] ||
      [[ ${KEYMAP} == viins ]] ||
      [[ ${KEYMAP} = '' ]] ||
      [[ $1 = 'beam' ]]; then
          echo -ne '\e[5 q'
  fi
  zle reset-prompt
  #  zle -R
}
zle -N zle-keymap-select


bindkey -v
export KEYTIMEOUT=1

# setup key accordingly
bindkey  "^[[H"  beginning-of-line      # Home
bindkey  "^[[F"  end-of-line            # End
bindkey  "^[[2~" overwrite-mode         # Insert
bindkey  "^[[3~" delete-char            # Delete
bindkey  "^[[D"  backward-char          # Left
bindkey  "^[[C"  forward-char           # Right
bindkey  "^[[5~" up-line-or-history     # PageUp
bindkey  "^[[6~" down-line-or-history   # PageDown
bindkey  "^[[Z"  reverse-menu-complete  # ShiftTab

# ci", ci', ci`, di", etc
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
done

# ci{, ci(, ci<, di{, etc
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

## keyup and  keydown search
autoload -U up-line-or-beginning-search && zle -N up-line-or-beginning-search
#bindkey  "^[[A"       history-substring-search-up
bindkey "^[[A" up-line-or-beginning-search

autoload -U down-line-or-beginning-search && zle -N down-line-or-beginning-search
#bindkey  "^[[B"     history-substring-search-down
bindkey "^[[B" down-line-or-beginning-search

bindkey '^[[1;5C' forward-word                        # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word                       # [Ctrl-LeftArrow] - move backward one word
bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.

# Edit line in vim buffer ctrl-v
autoload edit-command-line; zle -N edit-command-line; bindkey '^v' edit-command-line
# Enter vim buffer from normal mode
autoload -U edit-command-line && zle -N edit-command-line && bindkey -M vicmd "^v" edit-command-line
