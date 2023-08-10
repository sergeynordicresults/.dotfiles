# user mode entered with ,
map global user y '<a-|>copyq add -<ret>'     -docstring 'clipboard yank'
map global user p '<a-!>copyq clipboard<ret>' -docstring 'clipboard paste after'
map global user P '!copyq clipboard<ret>'     -docstring 'clipboard paste before'
map global user R '|copyq clipboard<ret>'     -docstring 'clipboard replace current selection'

# hook global RegisterModified '"' %{ nop %sh{
#   printf %s "$kak_main_reg_dquote" | copyq add -
# }}

# def -hidden copy_merged_selections %{ nop %sh{
#   printf %s "$kak_selections" | sed -e 's/^://g' -e 's/\([^\\]\):/\1\n/g' -e 's/\\\\/\\/g' -e 's/\\:/:/g' | xsel --input --clipboard
# } }


# map global normal d \"_d
# map global normal c \"_c
# map global user   d ':copy_merged_selections<ret>d' -docstring 'yank and delete'
# map global user   c ':copy_merged_selections<ret>c' -docstring 'yank and delete and enter insert mode'
#
# map global user p '<a-!>copyq clipboard<ret>' -docstring 'clipboard paste after'
# map global user P '!copyq clipboard<ret>'     -docstring 'clipboard paste before'
# map global user R '|copyq clipboard<ret>'     -docstring 'clipboard replace current selection'
#
# map global insert <a-p> '<a-;>!copyq clipboard<ret>'
