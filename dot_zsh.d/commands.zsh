# Common aliases
alias zshconf='$EDITOR ~/.zshrc'
alias ssha="eval $(ssh-agent)"

alias i3conf="vim ~/.config/i3/config"
alias ccat='pygmentize -g'
alias diff="diff --color"

alias pacman-clean='sudo pacman -R `pacman -Qdtq`'
alias yaygit='yay -S `pacman -Q | grep "\-git" | cut -d" " -f1`'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias fcl='fc -li 1'
alias :q='exit'

alias chm="chezmoi"

# ls
alias ls='ls --color=auto'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias lt='ls -lat'

# dirs
alias cd..="cd .."
alias ..="cd .."
alias ...='../..'
alias ....='../../..'
alias .....='../../../..'
alias ......='../../../../..'
alias cdgr='$(gitroot)'

alias -- -='cd -'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias md='mkdir -p'

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -10
  fi
}

# docker aliases
alias dr=docker
alias drps="docker ps"
alias dre="docker exec"
alias dreit="docker exec -it"
alias drk="docker kill"
alias drrit="docker run -it -rm"
alias drb="docker build"
alias drc=docker-compose
alias drcip="docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"

# git aliases
alias gitunmodlastcommit='git ls-files --full-name | grep -v "$(git diff --name-only HEAD)"'
alias gdo='git diff origin/"$(git_current_branch)"'
alias gdcao='git diff --cached origin/"$(git_current_branch)"'
alias glogf='~/.bin/git_log_tree_fancy'
alias gitroot='git rev-parse --show-toplevel'

function gcmsgj {
    git commit -m "$(git_current_branch | grep -Eo '[A-Z]+-[0-9]+') $1"
}

# clipboard
function clip {
  case "$1" in
    "p")  xclip -out -selection clipboard;;
    *)  xclip -in -selection clipboard < "${1:-/dev/stdin}";;
  esac
}

# archives
function ex {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           [ -z "$1" ] && printf "Usage:\n\t$0 [path-to-archive]\n" || 
                                  echo "$1 cannot be extracted via ex" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

