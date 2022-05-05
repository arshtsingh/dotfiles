# -------------------------------------- options --------------------------------------
set-option global autoreload true
set-option global scrolloff 3,0
set-option -add global ui_options ncurses_status_on_top=yes

hook global InsertChar \t %{ exec -draft -itersel h@ }
set-option global tabstop 4
set-option global indentwidth 4

# --------------------------------------- style ----------------------------------------
add-highlighter global/ number-lines
add-highlighter global/ show-whitespaces
add-highlighter global/trailing-whitespace regex '\h+$' 0:default,red+F
add-highlighter global/todo-fixme regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb

# --------------------------------------- funcs ----------------------------------------
def -params 1 extend-line-down %{
  exec "<a-:>%arg{1}X"
}

def -params 1 extend-line-up %{
  exec "<a-:><a-;>%arg{1}K<a-;>"
  try %{
    exec -draft ';<a-K>\n<ret>'
    exec X
  }
  exec '<a-;><a-X>'
}

# --------------------------------------- remaps ---------------------------------------

# convenience
map -docstring 'case insensitive exact search' global normal / /(?i)\Q
map -docstring 'search' global normal ? /
map global normal D <a-x>d

# editing
map -docstring 'save' global normal <c-s> ': write; echo saved<ret>'
map -docstring 'quit' global normal <c-q> ': quit<ret>'
map -docstring 'last buffer' global normal <c-a> ga

# fzf
map global normal <a-o> ': fzf-open<ret>' -docstring "fzf open file"

# copy & paste
hook global RegisterModified '"' %{ nop %sh{
  printf %s "$kak_main_reg_dquote" | pbcopy
}}
map global user P '<a-!>pbpaste --output --clipboard<ret>' -docstring 'paste after'
map global user p '!pbpaste --output --clipboard<ret>' -docstring 'paste before'
map global user r '|pbpaste --output --clipboard<ret>' -docstring 'replace selection'

# selection
map global normal x ':extend-line-down %val{count}<ret>'
map global normal X ':extend-line-up %val{count}<ret>'

# tab/backtab to cycle through completions
hook global InsertCompletionShow .* %{
  map window insert <s-tab> <c-p>
  map window insert <tab> <c-n>
}
hook global InsertCompletionHide .* %{
  unmap window insert <tab> <c-n>
  unmap window insert <s-tab> <c-p>
}

