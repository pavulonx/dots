# Setup fzf
# ---------
if [[ ! "$PATH" == */home/jrozen/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/jrozen/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/jrozen/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/jrozen/.fzf/shell/key-bindings.zsh"
