set fish_greeting
set -x SHELL fish
set -x VISUAL kak
set -x EDITOR kak
set -x GIT_EDITOR kak
set -x PATH $PATH "$HOME/.cargo/bin"
set -x PATH $PATH "$HOME/.go/bin/"
set -x PATH $PATH "$HOME/go/bin"
set -x PATH $PATH "$HOME/.local/bin/"
set -x PATH $PATH "$HOME/.node_modules/bin"
set -x PATH $PATH "$HOME/.poetry/bin"
set -x PATH $PATH "/opt/homebrew/bin"
set -x FZF_OPTS \
  --color=16 \
  --preview 'bat --style=numbers --color=always --line-range :500 {}' \
  --tiebreak=length,end \
  --bind=tab:down,shift-tab:up          # fzf

alias subl "open -a Subl"
alias k "kak"
alias l "la -l"
alias cp "cp -p"
alias tree "tree -C"
alias o "__open"


function wiki_grep --description "grep wiki files for content"
  command rg $argv ~/wiki \
    --ignore-case \
    --type md \
    --glob '!*/node_modules/*' --glob '!*/_target/*' \
    --follow
end


function wiki_find --description "find wiki filename with fzf"
  command fd \
    --base-directory ~/wiki/ \
    --extension md \
    --no-ignore-vcs \
    --exclude 'node_modules/' --exclude '_target/' \
    --follow \
    | fzf
end


function wiki_open --description "find wiki filename with fzf"
  set -l file ~/wiki/(wiki_find)
  if [ -n "$file" ]
    command open -a 'typora' $file
  end
  commandline -f repaint
end


function wiki_insert --description "find wiki filename with fzf"
  commandline --insert --current-token -- (wiki_find)
  commandline --insert --current-token -- " "
end


function project_find --description "find a project dir with fzf"
  echo ~/projects/(
    command fd \
      --type d \
      --base-directory ~/projects \
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


function project_insert --description "insert a project dir into the commandline"
  commandline -it -- (project_find)
  commandline -it -- " "
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


function fzf_insert --description "insert a path using fzf"
  commandline --insert --current-token -- (fd --no-ignore-vcs | fzf $FZF_OPTS)
  commandline --insert --current-token -- " "
end


function man -w man -d "man with kak as the pager"
  if [ -n "$argv" ]; and command man "$argv" > /dev/null 2>&1
    command kak -e "man $argv"
  else
    command man $argv
  end
end


function ezb -d "ssh into main ezb machine"
  set -x TERM xterm-256color
  command ssh 192.168.2.147 -t fish
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


function __open
  switch (file -L -b --mime-type $argv[1])
    case 'application/pdf'
      open -a 'Preview' $argv
    case 'text/*' 'inode/x-empty' 'application/octet-stream' 'application/json' 'application/csv'
      kak $argv
    case 'inode/directory'
      cd $argv
    case 'image/*'
      open -a 'Preview' $argv
    case '*'
      command open $argv
  end
end


bind \ep project_open
bind \eP project_insert
bind \ew wiki_open
bind \eW wiki_insert
bind \eo fzf_open
bind \eO fzf_insert
bind \ec config

bind \cw forward-word
bind \cb backward-kill-word
bind \cs __fish_prepend_sudo
bind \cr __fzf_search_history
bind \> __bound_nextd
bind \< __bound_prevd
