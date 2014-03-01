"Schlepp.vim - Easy movement of lines/blocks of text
"Maintainer:    Zachary Stigall <zirrostig <at> lanfort.org>
"Date:          28 Feb 2014
"License:       VIM
"
"Inspired by Damian Conway's DragVisuals
"  If you have not watched Damian Conway's Instantly Better Vim, go do so.
"  http://programming.oreilly.com/2013/10/more-instantly-better-vim.html
"
"This differs in that it is an attempt to improve the code, make it faster and
"remove some of the small specific issuses that can seemingly randomly bite you
"when you least expect it.
"
"IDEAS and TODO
"   Make movement with recalc indent
"   Don't use Temp Mappings
"   Don't affect the users command and search history
"   UndoJoin needs to not join between Line and Block modes (may not already,
"       untested)

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
function! s:Schlepp(d) range
"  The main function that acts as an entrant function to be called by the user
"  with a desired direction to move the seleceted text.
"  TODO:
"       Make range function
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
            undojoin | call s:SchleppLines(a:d, a:firstline, a:lastline)
        else
            call s:SchleppLines(a:d, a:firstline, a:lastline)
        endif
    elseif l:md ==# "CTRL-V"
        if s:CheckUndo(l:md)
            undojoin | call s:SchleppBlock(a:d)
        else
            call s:SchleppBlock(a:d)
        endif
    endif
endfunction "}}}
"{{{ SchleppLines
function! s:SchleppLines(dir, fline, lline)
"  Logic for moving text selected with visual line mode
"  TODO:
"       Up/Down should work on the entire set of lines together
"       Left/Right should be done per line (left boundry checks)
"       Get working as a range function
"
    "build normal command string to reselect the VisualLine area
    let l:numlines = (a:lline - a:fline)
    let l:reselect  = "V" . (l:numlines ? l:numlines . "j" : "")

    if (a:dir ==? "up" || a:dir ==? "k") "{{{ Up
        if a:fline == 1 "First lines of file, move everything else down
            execute "normal! '>o\<Esc>gv"
        else
            execute "normal! gvdkP" . l:reselect
        endif "}}}
    elseif (a:dir ==? "down" || a:dir ==? "j") "{{{ Down
        if a:lline == line("$") "Moving down past EOF
            execute "normal! '<O\<Esc>gv"
        else
            execute "normal! gvdp" . l:reselect
        endif "}}}
    elseif (a:dir ==? "right" || a:dir ==? "l") "{{{ Right
        for l:linenum in range(a:fline, a:lline)
            let l:line = getline(l:linenum)
            "Only insert space if the line is empty
            if match(l:line, "^$") == -1
                call setline(linenum, " ".l:line)
            endif
        endfor
        call s:ResetSelection() "}}}
    elseif (a:dir ==? "left" || a:dir ==? "h") "{{{ Left
        "Why doesn't \s work in the match or substitute?
        if !exists("g:Schlepp#AllowSquishing") "Squish the lines left
            let l:lines = getline(a:fline, a:lline)
            if !(match(l:lines, '^[^ \t]') == -1)
                call s:ResetSelection()
                return
            endif
        endif

        for l:linenum in range(a:fline, a:lline)
            call setline(l:linenum, substitute(getline(l:linenum), "^[ \t]", "", ""))
        endfor

        call s:ResetSelection()
    endif "}}}
endfunction "}}}
"{{{ SchleppBlock
function! s:SchleppBlock(d)
"  Logic for moving a visual block selection, this is much more complicated than
"  lines since I have to be able to part text in order to insert the incoming
"  line
"  TODO:
"       Implement

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
