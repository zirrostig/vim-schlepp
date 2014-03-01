VIM-Schlepp
===========
Vim plugin to allow the movement of lines (or blocks) of text around easily.
Inspired by Damian Conway's DragVisuals from his
[More Instantly Better Vim](http://programming.oreilly.com/2013/10/more-instantly-better-vim.html)

What it Does
============
Schlepp lets you move a highlighted (visual mode) section of text around,
respecting other text around it.

Right now it only supports Visual-Line mode, but Visual-Block mode will be added
soon.

Using
=====
Add the following mappings to your vimrc, feel free to change from using the
arrows to something more to your vim usage.

```viml
    vmap <unique> <up>    <Plug>SchleppUp
    vmap <unique> <down>  <Plug>SchleppDown
    vmap <unique> <left>  <Plug>SchleppLeft
    vmap <unique> <right> <Plug>SchleppRight
```
