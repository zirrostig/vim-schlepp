"Schlepp.vim - Easy movement of lines/blocks of text
"Maintainer:    Zachary Stigall <zirrostig <at> lanfort.org>
"Date:          2 March 2014
"License:       VIM
"
"Inspired by Damian Conway's DragVisuals
"  If you have not watched Damian Conway's More Instantly Better Vim, go do so.
"  http://programming.oreilly.com/2013/10/more-instantly-better-vim.html
"
"This differs in that it is an attempt to improve the code, make it faster and
"remove some of the small specific issuses that can seemingly randomly bite you
"when you least expect it.
"
"IDEAS and TODO
"   Suppress Messages about 'x fewer lines'
"   Make movement with recalc indent
"   Don't affect the users command and search history (Is this happening?)
"   UndoJoin needs to not join between Line and Block modes (may not already - untested)
"   Add padding function, that inserts a space or newline in the direction specified

"====[ Core Implementation ]==================================================

if exists("g:Schlepp#Loaded")
    finish
endif
let g:Schlepp#Loaded = 1

"{{{ Mappings
noremap <unique> <script> <Plug>SchleppUp <SID>SchleppUp
noremap <unique> <script> <Plug>SchleppDown <SID>SchleppDown
noremap <unique> <script> <Plug>SchleppLeft <SID>SchleppLeft
noremap <unique> <script> <Plug>SchleppRight <SID>SchleppRight

noremap <SID>SchleppUp    :call <SID>Schlepp("Up")<CR>
noremap <SID>SchleppDown  :call <SID>Schlepp("Down")<CR>
noremap <SID>SchleppLeft  :call <SID>Schlepp("Left")<CR>
noremap <SID>SchleppRight :call <SID>Schlepp("Right")<CR>
"}}}
"{{{ Schlepp
function! s:Schlepp(dir) range
"  The main function that acts as an entrant function to be called by the user
"  with a desired direction to move the seleceted text.
"  TODO:
"       Work with a count specifier eg. [count]<Up> moves lines count times
"       Maybe: Make word with a motion
"
    "Get what visual mode was being used
    normal gv
    let l:md = mode()
    execute "normal! \<Esc>"

    "Safe return if unsupported
    "TODO: Make this work in visual mode
    if l:md ==# 'v'
        "Give them back their selection
        call s:ResetSelection()
    endif

    "Branch off into specilized functions for each mode, check for undojoin
    if l:md ==# "V"
        if s:CheckUndo(l:md)
            undojoin | call s:SchleppLines(a:dir)
        else
            call s:SchleppLines(a:dir)
        endif
    elseif l:md ==# ""
        if s:CheckUndo(l:md)
            undojoin | call s:SchleppBlock(a:dir)
        else
            call s:SchleppBlock(a:dir)
        endif
    endif
endfunction "}}}
"{{{ SchleppLines
function! s:SchleppLines(dir)
"  Logic for moving text selected with visual line mode

    "build normal command string to reselect the VisualLine area
    let l:fline = getpos("'<")[1]
    let l:lline = getpos("'>")[1]
    let l:numlines = l:lline - l:fline
    "Because s:ResetSelection() will not work in some cases, we need to reselect
    "manually
    let l:reselect  = "V" . (l:numlines ? l:numlines . "j" : "")

    if (a:dir ==? "up" || a:dir ==? "k") "{{{ Up
        if l:fline == 1 "First lines of file, move everything else down
            call append(l:lline, "")
            call s:ResetSelection()
        else
            execute "normal! gvdkP" . l:reselect . "o"
        endif "}}}
    elseif (a:dir ==? "down" || a:dir ==? "j") "{{{ Down
        if l:lline == line("$") "Moving down past EOF
            call append(l:fline - 1, "")
            call s:ResetSelection()
        else
            execute "normal! gvdp" . l:reselect
        endif "}}}
    elseif (a:dir ==? "right" || a:dir ==? "l") "{{{ Right
        for l:linenum in range(l:fline, l:lline)
            let l:line = getline(l:linenum)
            "Only insert space if the line is not empty
            if match(l:line, "^$") == -1
                call setline(linenum, " ".l:line)
            endif
        endfor
        call s:ResetSelection() "}}}
    elseif (a:dir ==? "left" || a:dir ==? "h") "{{{ Left
        "Why doesn't \s work in the match or substitute?
        if !exists("g:Schlepp#AllowSquishing") "Squish the lines left
            let l:lines = getline(l:fline, l:lline)
            if !(match(l:lines, '^[^ \t]') == -1)
                call s:ResetSelection()
                return
            endif
        endif

        for l:linenum in range(l:fline, l:lline)
            call setline(l:linenum, substitute(getline(l:linenum), "^[ \t]", "", ""))
        endfor

        call s:ResetSelection()
    endif "}}}
endfunction "}}}
"{{{ SchleppBlock
function! s:SchleppBlock(dir)
"  Logic for moving a visual block selection, this is much more complicated than
"  lines since I have to be able to part text in order to insert the incoming
"  line
"  TODO:
"       Get whitespace striping inplace

    "Save virtualedit settings, and enable for the function
    let l:ve_save = &l:virtualedit
    "So that if something fails, we can set virtualedit back
    try
        setlocal virtualedit=all

        " While '< is always above or equal to '> in linenum, the column it
        " references could be the first or last col in the block selected
        let [l:fbuf, l:fline, l:fcol, l:foff] = getpos("'<")
        let [l:lbuf, l:lline, l:lcol, l:loff] = getpos("'>")
        let [l:left_col, l:right_col]  = sort([l:fcol + l:foff, l:lcol + l:loff])

        if (a:dir ==? "up" || a:dir ==? "k") "{{{ Up
            if l:fline == 1 "First lines of file
                call append(0, "")
            endif
            normal! gvxkPgvkoko
            "}}}
        elseif (a:dir ==? "down" || a:dir ==? "j") "{{{ Down
            if l:lline == line("$") "Moving down past EOF
                call append(line("$"), "")
            endif
            normal! gvxjPgvjojo
            "}}}
        elseif (a:dir ==? "right" || a:dir ==? "l") "{{{ Right
            normal! gvxpgvlolo
            "}}}
        elseif (a:dir ==? "left" || a:dir ==? "h") "{{{ Left
            if l:left_col == 1
                if exists("g:Schlepp#AllowSquishing")
                    for l:linenum in range(l:fline, l:lline)
                        call setline(l:linenum, substitute(getline(l:linenum), "^[ \t]", "", ""))
                    endfor
                endif
                call s:ResetSelection()
            else
                normal! gvxhPgvhoho
            endif
            "}}}
        endif

    endtry
    let &l:virtualedit = l:ve_save
endfunction "}}}
"{{{ Utility Functions
function! s:ResetSelection()
    execute "normal \<Esc>gv"
endfunction

function! s:CheckUndo(md)
    if !exists("b:SchleppLast")
        let b:SchleppLast = {}
    endif

    if exists("b:SchleppLastNr") && b:SchleppLastNr == changenr() - 1 && b:SchleppLastMd == a:md
        return 1
    endif

    let b:SchleppLastNr = changenr()
    let b:SchleppLastMd = a:md
    return 0
endfunction
"}}}

" vim: ts=4 sw=4 et fdm=marker tw=80 fo+=t
