set -x VISUAL kak
set -x EDITOR kak
set -x GIT_EDITOR kak
set -x PATH $PATH "$HOME/Homebrew/bin"

set -x EXA_COLORS "fi=38;5;015:di=38;5;038:ex=38;5;048:ur=38;5;015:uw=38;5;203:ux=38;5;048:ue=38;5;048:gr=38;5;015:gw=38;5;203:gx=38;5;048:tr=38;5;015:tw=38;5;203:tx=38;5;048:sn=38;5;255:sb=38;5;255:uu=38;5;255:un=38;5;214:gu=38;5;255:gn=38;5;214:da=38;5;255:hd=4;38;5;015"

set -x FZF_OPTS \
  --color=16 \
  --reverse \
  --preview 'bat --style=numbers --color=always --line-range :500 {}' \
  --tiebreak=length,end \
  --bind=tab:down,shift-tab:up

alias e='kak'
alias g='lazygit'
alias ls='exa -al --sort=type --ignore-glob=".DS_Store|.CFUserTextEncoding"'
alias tree='exa --classify --tree --level=2'

function chrome -w chrome --description "open browser with specified profile"
  switch $argv
    case ps
      command open -n -a "Google Chrome" --args --profile-directory="Profile 3"
    case fresh
      command open -n -a "Google Chrome" --args --user-data-dir=(mktemp -d)
    case '*'
      command open -n -a "Google Chrome" --args --profile-directory="Default"
  end
end

function open
  switch (file -L -b --mime-type $argv[1])
    case 'text/*' 'inode/x-empty' 'application/octet-stream' 'application/json' 'application/csv'
      kak $argv
    case 'inode/directory'
      cd $argv
    case '*'
      command open $argv
  end
end

function fzf_find --description "find a file using fzf"
  echo (fd --no-ignore-vcs | fzf $FZF_OPTS)
end

function fzf_open --description "open a file using the fzf prompt"
  set -l path (fzf_find)
  if [ -f "$path" ]
    open $path
  else if [ -d "$path" ]
    cd $path
  end
  commandline --function repaint
end

function config --description "access configs"
  switch $argv
    case fish
      open "$HOME/.config/fish/config.fish"
    case kak
      open "$HOME/.config/kak/kakrc"
    case ""
      set -l file ~/.config/(
        command fd \
          --strip-cwd-prefix \
          --base-directory ~/.config/ \
          | fzf $FZF_OPTS
      )
      if [ -n "$file" ]
        open $file
      end
    case "*"
      echo "Unknown arg '$argv'"
  end
end

function project_find --description "find a project dir with fzf"
  echo ~/Fun/(
    command fd \
      --type d \
      --base-directory ~/Fun \
      --exclude 'node_modules/' --exclude '_target/' \
      --follow \
      | fzf
    )
end

function project_open --description "cd into a project with fzf"
  set -l proj (project_find)

  if [ -n "$proj" ]
    cd "$proj"
    commandline --function repaint
    if test -e 'pyproject.toml'
      # if a virtual env is set, deactivate before going into a new one
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

function project_insert --description "insert a project dir into the commandline"
  set -l project (project_find)
  if [ -n "$project" ]
    commandline --insert --current-token -- (string escape "$project")" "
  end
end

function man -w man -d "man with kak as the pager"
  if [ -n "$argv" ]; and command man "$argv" > /dev/null 2>&1
    command kak -e "man $argv"
  else
    command man $argv
  end
end

function fzf_history --description "use fzf to find a command in the history"
  history merge
  history -z | fzf --read0 --print0 --preview '' -q (commandline) | read -lz result
  and commandline -- $result
  commandline --function repaint
end

function __bound_nextd -w nextd -d "nextd with > binding"
  if [ -n (commandline) ]
    commandline --insert ">"
  else
    nextd
    commandline --function repaint
  end
end

function __bound_prevd -w prevd -d "prevd with < binding"
  if [ -n (commandline) ]
    commandline --insert "<"
  else
    prevd
    commandline --function repaint
  end
end

bind \ep project_open
bind \eP project_insert
bind \eo fzf_open
bind \ec config
bind \cr fzf_history
bind \> __bound_nextd
bind \< __bound_prevd

pyenv init --path | source
