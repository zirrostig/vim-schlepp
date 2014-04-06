VIM-Schlepp
===========
Vim plugin to allow the movement of lines (or blocks) of text around easily.
Inspired by Damian Conway's DragVisuals from his
[More Instantly Better Vim](http://programming.oreilly.com/2013/10/more-instantly-better-vim.html)

What it Does
============
Schlepp lets you move a highlighted (visual mode) section of text around,
respecting other text around it.

Block and Line Selections work now.

Schlepp also lets you duplicate selections of text

Additionally run for more info
```
:help schlepp 
```

Setup
=====

Movement
--------
Add the following mappings to your vimrc, feel free to change from using the
arrows to something more to your vim usage.

```vimscript
vmap <unique> <up>    <Plug>SchleppUp
vmap <unique> <down>  <Plug>SchleppDown
vmap <unique> <left>  <Plug>SchleppLeft
vmap <unique> <right> <Plug>SchleppRight
```

When moving text left, Schlepp by default does not allow you to move left if any
text is all the way left. eg
```text
All the way left text cannot be moved left
    Even though this text can be
```
To allow the 'Squishing' of text add this line to your vimrc
```vimscript
let g:Schlepp.allowSquishing = 1
```

To disable trailing whitespace removal on block move
```vimscript
let g:Schlepp.trimWS = 0
```

Schlepp can also reindent as it moves. Any of these work
* SchleppUp with reindentation is SchleppIndentUp
* SchleppDown with reindentation is SchleppIndentDown
* let g:Schlepp.reindent = 1
* map to the toggle function (below) - This is how I like to use it
```vimscript
vmap <unique> i <Plug>SchleppToggleReindent
```

Duplication
-----------
Some suggested mappings
```vimscript
vmap <unique> D <Plug>SchleppDup
```
or if you want fine grained control
```vimscript
vmap <unique> Dk <Plug>SchleppDupUp
vmap <unique> Dj <Plug>SchleppDupDown
vmap <unique> Dh <Plug>SchleppDupLeft
vmap <unique> Dl <Plug>SchleppDupRight
```
or set the default direction for SchleppDup
* DupLines can be "up" or "down"
* DupBlock can be "up", "down", "left", or "right"
* shown below are the defaults
```vimscript
let g:Schlepp.dupLinesDir = "down"
let g:Schlepp.dupBlockDir = "right"
```

To enable trailing whitespace removal on block duplication
```vimscript
let g:Schlepp.dupTrimWS = 1
```

Known Issues
============
* See GitHub Issue Tracker
* This README is lacking in cool useful gifs of Schlepp in action. - Someday
