# vim-config

Single file VIM configuration. It covers most of the functions required by competitive programming.

- C++ syntax check
- C++ compile and run
- Submit code to AtCoder
- Automatic completion
- Template

And some things I like.

- Customized startup interface
- Excerpts from Haruki Murakami's book

## The Basic

VIM configuration without plug-ins (Windows GVIM only, for XCPC). Just copy [basic.vim](./basic.vim).

## Install

Copy [vimrc.vim](./vimrc.vim) to `.vimrc` (macOS/Linux) or `_vimrc` (Windows).

[vim-plug](https://github.com/junegunn/vim-plug) needs to be installed manually on Windows.

###### Windows (PowerShell)

```
iwr -useb https://ghproxy.com/https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
```
