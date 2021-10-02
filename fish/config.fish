set fish_greeting
set -x SHELL fish
set -x VISUAL kak
set -x EDITOR kak
set -x GIT_EDITOR kak
set -x PATH $PATH "$HOME/.cargo/bin"
set -x PATH $PATH "$HOME/.poetry/bin"
set -x PATH $PATH "$HOME/.local/bin/"

set -x FZF_OPTS \
  --color=16 \
  --preview 'bat --style=numbers --color=always --line-range :500 {}' \
  --tiebreak=length,end \
  --bind=tab:down,shift-tab:up

set -x EXA_COLORS "fi=38;5;015:di=38;5;038:ex=38;5;048:ur=38;5;015:uw=38;5;203:ux=38;5;048:ue=38;5;048:gr=38;5;015:gw=38;5;203:gx=38;5;048:tr=38;5;015:tw=38;5;203:tx=38;5;048:sn=38;5;255:sb=38;5;255:uu=38;5;255:un=38;5;214:gu=38;5;255:gn=38;5;214:da=38;5;255:hd=4;38;5;015"

set -Ux PYENV_ROOT $HOME/.local/.pyenv
set -Ux NODE_PATH $HOME/.local/node/

set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths

alias c "clear"
alias k "kak"
alias l='exa --classify --across'
alias ls="exa -al --classify --long --group"
alias llg='exa --classify --long --grid --group'
alias tree="exa --classify --tree"
alias cp "cp -p"
alias o "__open"
alias weathr "curl v2.wttr.in"

function project_find --description "find a project dir with fzf"
  echo ~/.fun/(
    command fd \
      --type d \
      --base-directory ~/.fun \
      --exclude 'node_modules/' --exclude '_target/' \
      --follow \
      | fzf $FZF_OPTS
    )
end


function project_open --description "cd into a project with fzf"
  set -l proj (project_find)

  if [ -n "$proj" ]
    cd $proj
    commandline -f repaint
    if test -e 'pyproject.toml'
      if set -q VIRTUAL_ENV
        deactivate
      end
      echo -e '\n'(set_color yellow)'Found pyproject.toml'(set_color normal)
      set -l venv_file (poetry env list --full-path | awk '{ print $1 }')/bin/activate.fish
      if [ -f "$venv_file" ]
        source "$venv_file"
      else
        echo -e (set_color red)'No virtualenv'(set_color normal)
      end
    end
  end
end


function fzf_open --description "open a file using the fzf prompt"
  set -l path (fd --no-ignore-vcs | fzf $FZF_OPTS)
  if [ -f "$path" ]
    kak "$path"
  else if [ -d "$path" ]
    cd "$path"
  end
  commandline -f repaint
end


function man -w man -d "man with kak as the pager"
  if [ -n "$argv" ]; and command man "$argv" > /dev/null 2>&1
    command kak -e "man $argv"
  else
    command man $argv
  end
end


function __bound_nextd -w nextd -d "nextd with > binding"
  if [ -n (commandline) ]
    commandline -i ">"
  else
    nextd
    commandline -f repaint
  end
end

function __bound_prevd -w prevd -d "prevd with < binding"
  if [ -n (commandline) ]
    commandline -i "<"
  else
    prevd
    commandline -f repaint
  end
end


function config --description "access configs"
  set -l file ~/.config/(
    command fd \
      --base-directory ~/.config/ \
      --exclude '*/BraveSoftware/*' \
      --follow \
      | fzf
  )
  if [ -n "$file" ]
    kak $file
  end
end


function __fzf_search_history --description "Search command history. Replace the command line with the selected command."
  builtin history merge
  set --local --export SHELL (command --search fish)
  set command_with_ts (
    builtin history --null --show-time="%m-%d %H:%M:%S | " |
    fzf --read0 \
    --tiebreak=index \
    --query=(commandline) \
    --preview="echo -- {4..} | fish_indent --ansi" \
    --preview-window="bottom:3:wrap" \
    $fzf_history_opts |
    string collect
  )
  if test $status -eq 0
    set command_selected (string split --max 1 " | " $command_with_ts)[2]
    commandline --replace -- $command_selected
  end
  commandline --function repaint
end


function edit-commandline
  set -q EDITOR; or return 1
  set -l tmpfile (mktemp); or return 1
  commandline > $tmpfile
  eval $EDITOR $tmpfile
  commandline -r (cat $tmpfile)
  rm $tmpfile
end

bind \cp project_open
bind \co fzf_open
bind \cc config

bind \cw forward-word
bind \cb backward-kill-word
bind \cs __fish_prepend_sudo
bind \cr __fzf_search_history
bind \> __bound_nextd
bind \< __bound_prevd
bind \ce edit-commandline

pyenv init --path | source
