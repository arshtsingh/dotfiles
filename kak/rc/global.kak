set global tabstop 2
set global indentwidth 2

set-option global autoreload true
set-option global scrolloff 3,0
set-option -add global ui_options ncurses_status_on_top=yes

addhl global/ wrap -word -marker "↳ "
addhl global/ruler column 88 default,rgb:303030
addhl global/trailing-whitespace regex '\h+$' 0:default,red
addhl global/todo regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb
addhl global/ number-lines -hlcursor
addhl global/show-matching show-matching

# tab/backtab to cycle through completions
hook global InsertCompletionShow .* %{
  map window insert <s-tab> <c-p>
  map window insert <tab> <c-n>
}
hook global InsertCompletionHide .* %{
  unmap window insert <tab> <c-n>
  unmap window insert <s-tab> <c-p>
}
hook global NormalKey y|d|c %{ nop %sh{
  printf %s "$kak_main_reg_dquote" | pbcopy
}}
hook global InsertChar \t %{
  exec -draft h@
}

