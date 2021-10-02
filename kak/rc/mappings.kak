# --------------------------------------- remaps ---------------------------------------
map global insert <tab> '<a-;><a-gt>'
map global insert <s-tab> '<a-;><lt>'

map global normal <c-s> ': write<ret>'
map global normal x ':extend-line-down %val{count}<ret>'
map global normal X ':extend-line-up %val{count}<ret>'
map global normal '#' ': comment-line<ret>' -docstring 'comment line'
map global normal ^ ': upper<ret>'
map global normal _ ': lower<ret>'

map global user g ':grep ''''<left>' -docstring 'RipGrep'

map -docstring 'write' global user w ':write<ret>'
map -docstring 'write-quit' global user q ':write-quit<ret>'
map -docstring "paste" global user p '!pbpaste --output --clipboard<ret>'
map -docstring "trim whitespaces" global user w ':trim-whitespaces<ret>'

define-command where 'echo %val{buffile}'
define-command lower 'exec `'
define-command upper 'exec ~'
define-command W 'write'
