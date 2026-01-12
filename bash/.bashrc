# interactive shell only
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

if command -v tput &>/dev/null; then
  bold=$(tput bold)
  cyan=$(tput setaf 6) # \e[36m
  pink=$(tput setaf 13)
  reset=$(tput sgr0) # \e[0m
  PS1='\n\[$bold$cyan\]\w\n\[$bold$pink\]↳  \[$reset\]'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.config/bash/.bash_aliases ]; then
  . ~/.config/bash/.bash_aliases
fi

export PATH="$HOME/.local/bin:$PATH"
export WHOME="/mnt/c/Users/andres"
export EDITOR=vim

# asdf
export PATH="$HOME/.asdf/shims:$PATH"
. <(asdf completion bash)

# npm
. ~/.npm-completion
