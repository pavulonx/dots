function _term_set_title {
  print -Pn "\e]2;$1:q\a" # set window name
  print -Pn "\e]1;$1:q\a" # set window name
}

function termsupport_precmd {
  _term_set_title "%n@%m: %50<..<%~%<<"
}

function termsupport_preexec {
  _term_set_title "%100>...>$1%<<"
}

case "$TERM" in
  xterm*|rxvt*|alacritty|st*)
    autoload -U add-zsh-hook
    add-zsh-hook precmd termsupport_precmd
    add-zsh-hook preexec termsupport_preexec
    ;;
esac
