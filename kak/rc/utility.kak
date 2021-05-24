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

def trim-whitespaces -docstring "Remove trailing whitespace from every line" %{
  try %{
    exec -draft '%<a-s>ghgl<a-i><space>d'
    echo -markup "{Information}trimmed"
  } catch %{
    echo -markup "{Information}nothing to trim"
  }
}

