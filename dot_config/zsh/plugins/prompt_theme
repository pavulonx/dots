# vim:ft=zsh ts=2 sw=2 sts=2

setopt prompt_subst

# prompt settings
_prompt_start=$(${SALT_BOLD_PROMPT:-false} && echo "%S %s" || echo "")
_show_date=${SALT_SHOW_DATE:-false}
_show_time=${SALT_SHOW_TIME:-true}
_show_vi=${SALT_SHOW_VI:-true}
_show_venv=${SALT_SHOW_VENV:-true}
_show_git=${SALT_SHOW_GIT:-true}
_show_user=${SALT_SHOW_USER:-true}

#disable default venv prompt
"$_show_venv" && export VIRTUAL_ENV_DISABLE_PROMPT=true

VICMD_INDICATOR="NORMAL"
VIINS_INDICATOR="INSERT"
#VICMD_INDICATOR="N"
#VIINS_INDICATOR="I"
prompt_vi_mode() {
  "$_show_vi" || return;
  local mode
  is_normal() {
    test -n "${${KEYMAP/vicmd/$VICMD_INDICATOR}/(main|viins)/}"  # param expans
  }
  if is_normal; then
    print -n "%S $VICMD_INDICATOR %s"
  else
    print -n " $VIINS_INDICATOR "
  fi
}

prompt_context() {
  local ctx
  if [ -n "$SSH_CLIENT" ]; then
    ctx="%{%F{magenta}%} %n@%m %{%f%}"
  else
    $_show_user && ctx=" %n "
  fi
  # if root red{user@host} else on remote magenta{user@host}, on local - {user}
  print -n "%(!.%{%F{white}%K{red}%} %n@%m %{%k%}%{%f%}.${ctx:-})"
}

prompt_virtualenv() {
  "$_show_venv" || return;
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path ]]; then
    print -n "%{%F{blue}%}  $(basename "$virtualenv_path") %{%f%}"
  fi
}

PLUSMINUS="\u00b1"
BRANCH="\uf126"
prompt_git() {
  "$_show_git" || return;
  # if not inside git repo do nothing
  [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ] && return;

  local ref dirty mode repo_path clean has_upstream
  local modified untracked added deleted tagged stashed
  local ready_commit git_status
  local commits_diff commits_ahead commits_behind has_diverged to_push to_pull
  local g_prompt_color

  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  dirty=$(git status --porcelain --ignore-submodules="${GIT_STATUS_IGNORE_SUBMODULES:-dirty}" 2> /dev/null | tail -n1)
  git_status=$(git status --porcelain 2> /dev/null)
  ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
  if [[ -n $dirty ]]; then
    clean=''
    g_prompt_color='yellow'
  else
    clean=' ✔'
    g_prompt_color='green'
  fi

  local upstream; upstream=$(git rev-parse --symbolic-full-name --abbrev-ref "@{upstream}" 2> /dev/null)
  if [[ -n "${upstream}" && "${upstream}" != "@{upstream}" ]]; then has_upstream=true; fi

  local current_commit_hash; current_commit_hash=$(git rev-parse HEAD 2> /dev/null)

  local number_of_untracked_files; number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
  # if [[ $number_of_untracked_files -gt 0 ]]; then untracked=" $number_of_untracked_files◆"; fi
  if [[ $number_of_untracked_files -gt 0 ]]; then untracked=" $number_of_untracked_files☀"; fi

  local number_added; number_added=$(\grep -c "^A" <<< "${git_status}")
  if [[ $number_added -gt 0 ]]; then added=" $number_added✚"; fi

  local number_modified; number_modified=$(\grep -c "^.M" <<< "${git_status}")
  if [[ $number_modified -gt 0 ]]; then
    modified=" $number_modified●"
    g_prompt_color='red'
  fi

  local number_added_modified; number_added_modified=$(\grep -c "^M" <<< "${git_status}")
  local number_added_renamed; number_added_renamed=$(\grep -c "^R" <<< "${git_status}")
  if [[ $number_modified -gt 0 && $number_added_modified -gt 0 ]]; then
    modified="$modified$((number_added_modified+number_added_renamed))$PLUSMINUS"
  elif [[ $number_added_modified -gt 0 ]]; then
    modified=" ●$((number_added_modified+number_added_renamed))$PLUSMINUS"
  fi

  local number_deleted; number_deleted=$(\grep -c "^.D" <<< "${git_status}")
  if [[ $number_deleted -gt 0 ]]; then
    deleted=" $number_deleted‒"
    g_prompt_color='red'
  fi

  local number_added_deleted; number_added_deleted=$(\grep -c "^D" <<< "${git_status}")
  if [[ $number_deleted -gt 0 && $number_added_deleted -gt 0 ]]; then
    deleted="$deleted$number_added_deleted$PLUSMINUS"
  elif [[ $number_added_deleted -gt 0 ]]; then
    deleted=" ‒$number_added_deleted$PLUSMINUS"
  fi

  local tag_at_current_commit; tag_at_current_commit=$(git describe --exact-match --tags "$current_commit_hash" 2> /dev/null)
  if [[ -n $tag_at_current_commit ]]; then tagged=" ☗$tag_at_current_commit "; fi

  local number_of_stashes; number_of_stashes="$(git stash list 2> /dev/null | wc -l)"
  if [[ $number_of_stashes -gt 0 ]]; then
    stashed=" ${number_of_stashes##*(  )}⚙"
  fi

  if [[ $number_added -gt 0 || $number_added_modified -gt 0 || $number_added_deleted -gt 0 ]]; then ready_commit=' ⚑'; fi

  local upstream_prompt=''
  if [[ $has_upstream == true ]]; then
    commits_diff="$(git log --pretty=oneline --topo-order --left-right "${current_commit_hash}...${upstream}" 2> /dev/null)"
    commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
    commits_behind=$(\grep -c "^>" <<< "$commits_diff")
    upstream_prompt="$(git rev-parse --symbolic-full-name --abbrev-ref "@{upstream}" 2> /dev/null)"
    upstream_prompt=$(sed -e 's/\/.*$/ ☊ /g' <<< "$upstream_prompt")
  fi

  has_diverged=false
  if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then has_diverged=true; fi
  if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then to_push=" ↑$commits_ahead"; fi
  if [[ $has_diverged == false && $commits_behind -gt 0 ]]; then to_pull=" %f%F{yellow} ↓$commits_behind %f%F{$g_prompt_color}"; fi

  if [[ -e "${repo_path}/BISECT_LOG" ]]; then
    mode=" <B>"
  elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
    mode=" >M<"
  elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
    mode=" >R>"
  fi

  g_prompt_txt="${ref/refs\/heads\//$BRANCH $upstream_prompt}${mode}$to_push$to_pull$clean$tagged$stashed$untracked$modified$deleted$added$ready_commit"
  print -n "%F{$g_prompt_color} $g_prompt_txt %f"
}

prompt_dir() {
  print -n " %~ "
}

prompt_date() {
  "$_show_date" || return;
  print -n " %D{%Y-%m-%d} "
}

prompt_time() {
  "$_show_time" || return;
  print -n " %D{%H:%M} "
}

SYMBOL_ERR="\u2718"
SYMBOL_JOB="\u2699"
prompt_status() {
  err_prompt="%0(?..%{%F{red}%} $SYMBOL_ERR %? %f)"
  jobs_prompt="%1(j.%{%F{cyan}%} $SYMBOL_JOB %j %f.)"
  print -n "$err_prompt$jobs_prompt"
}

SYMBOL_CMD=" $ "
SYMBOL_CMD_SU="%{%F{red}%} # %{%f%}"
prompt_cmd() {
  print -n "%(!.$SYMBOL_CMD_SU.$SYMBOL_CMD)"
}

## Main prompt
build_prompt() {
  print -n "\n$_prompt_start"
  prompt_status
  prompt_context
  prompt_dir
  prompt_virtualenv
  prompt_git
  print -n "\n$_prompt_start"
  prompt_cmd
}

build_rprompt() {
  prompt_vi_mode
  prompt_date
  prompt_time
}

# shellcheck disable=SC2016,SC2034
PROMPT='%B$(build_prompt)%b'
RPROMPT='%B$(build_rprompt)%b'
# shellcheck disable=SC2016,SC2034
