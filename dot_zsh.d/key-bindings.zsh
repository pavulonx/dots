# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

typeset -A key

key[ShiftTab]=${terminfo[kcbt]}
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   up-line-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" down-line-or-history
[[ -n "${key[ShiftTab]}" ]]  && bindkey  "${key[ShiftTab]}" reverse-menu-complete

if [[ -n "${key[Up]}" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search
#  bindkey  "${key[Up]}"       history-substring-search-up
  bindkey "${key[Up]}" up-line-or-beginning-search
fi

if [[ -n "${key[Down]}"  ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search
#  bindkey  "${key[Down]}"     history-substring-search-down
  bindkey "${key[Down]}" down-line-or-beginning-search
fi

bindkey ' ' magic-space                               # [Space] - do history expansion
bindkey '^[[1;5C' forward-word                        # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word                       # [Ctrl-LeftArrow] - move backward one word
bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
#bindkey '\C-x\C-e' edit-command-line # for emacs key bindings :  # bindkey -e
bindkey '^v' edit-command-line