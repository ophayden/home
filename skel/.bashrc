# ~/.bashrc: executed by bash(1) for non-login shells.  see
# /usr/share/doc/bash/examples/startup-files (in the package
# bash-doc) for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# COLOR Configuration
# On OS X (maybe others), need to escape colors or they are
# included in the width of the terminal
sesc='\['
eesc='\]'
black=$sesc'\033[m'$eesc
bold_black=$sesc'\033[1m'$eesc
bold_cyan=$sesc'\033[1;36m'$eesc
usr='${USER//[aeiou]}'
host='$(
    hn=$(hostname -s)
    echo -n ${hn//[aeiou]}
)'
usr_host=$bold_black"$usr"'@'"$host"$black

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    elif [ -f /usr/local/etc/bash_completion ]; then
        . /usr/local/etc/bash_completion # homebrew
    fi

    if [ -f /usr/share/bash-completion/completions/git ]; then
        . /usr/share/bash-completion/completions/git
    elif [ -f ~/.bash_completion.d/git ]; then
        . ~/.bash_completion.d/git
    fi
fi

if which git &>/dev/null; then
    # Set git branch PS1
    alias is_git='git rev-parse &>/dev/null'
    alias gk='gitk &>/dev/null&'
    alias gka='gitk --all &>/dev/null&'


    git_prefix='$(
        is_git && echo "(PS1_COLOR_ON$(git branch-name 2>/dev/null)PS1_COLOR_OFF) "
    )'
    git_prefix="${git_prefix/PS1_COLOR_ON/${black}}"
    git_prefix="${git_prefix/PS1_COLOR_OFF/${black}}"

    if __git_aliases &>/dev/null; then
        function_exists() {
            declare -f -F $1 > /dev/null
            return $?
        }

        for al in $(__git_aliases); do
            alias g$al="git $al"

            complete_func=_git_$(__git_aliased_command $al)
            function_exists $complete_fnc && __git_complete g$al $complete_func
        done
    else
        for al in $(git list-aliases | cut -f1 -d"="); do
            alias g$al="git $al"
        done
    fi

    c() {
        root="$(git root || echo err)"
        if [ "$root" = err ]; then
            echo "No git dir"
            return
        fi
        cd "$root"
    }
fi

if which code &>/dev/null; then
    alias ch='code .'
fi

# Set current working directory PS1
cwd='$(
    wd="$(pwd)"
    wd=${PWD/#${HOME}/\~}
    if [ ${#wd} -gt 30 ];then
        twd="${wd:0:14}..${wd: -14}"
        wd="$twd"
    fi
    echo -n ${wd}
    #echo ${wd//[aeiou]}
)'
cwd=$bold_cyan"$cwd"$black
color_ps1="$git_prefix$usr_host:$cwd\\$ "

# Set colored PS1 for bash but not sh. However, if sh is called from bash, it
# will inherit the colored PS1 and not work. You will have to resource .bashrc.
case "$0" in
    *bash*) PS1="$color_ps1" ;;
    *) PS1="\u@\h:\w\\$ " ;;
esac
export PS1
unset usr host sesc eesc \
    black bold_black bold_cyan \
    usr_host cwd git_prefix color_ps1

# Set ls color
if  uname -a | grep -q Microsoft; then
    LS_COLORS='ow=01;36;40'
    export LS_COLORS
    alias ls="ls --color=auto -F"
elif [ "$(uname)" = Darwin ]; then
    # ls color
    alias ls="ls -GF"
elif [ "$(uname)" = Linux ]; then
    # ls color
    alias ls="ls --color=auto -F"
fi
# Set grep colors
alias grep="grep --color=auto"
# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# HISTORY Configuration
# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE
HISTSIZE=
HISTFILESIZE=

alias ..='cd ..'
alias ...='..; ..'
alias ....='...; ..'
alias .....='....; ..'

# OTHER Configurations
# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# Some ls aliases
alias ll='ls -al'

# Use vi on the cmd line
set -o vi
# Use vim instead of vi
if which vim &>/dev/null; then
    export EDITOR=vim
    alias vi=vim
elif which vi &>/dev/null; then
    export EDITOR=vi
    alias vim=vi
else
    export EDITOR=nano
fi
export VIEWER=less

# Change directory aliases
alias cdp='cd "$(pwd -P)"'

# Kill aliases
alias ki='kill -s INT'
alias kil='ki %1'

# Remap capslock to ctrl
alias remap_caps='setxkbmap -o ctrl:nocaps'

# Set homebrew ruby stuff
ruby_dir="/usr/local/opt/ruby/bin"
if [ -d "$ruby_dir" ]; then
    PATH="$PATH:"$ruby_dir""
fi

# set homebrew sbin stuff
brew_sbin="/usr/local/sbin"
if [ -d "$brew_sbin" ]; then
    PATH="$PATH:$brew_sbin"
fi

alias python='python3'
alias go='gnome-open'

# Set mac python bin
pyth_bin="$HOME/Library/Python/3.7/bin"
if [ -d "$pyth_bin" ]; then
    PATH="$PATH:$pyth_bin"
fi

which ipython &>/dev/null && alias ipy='ipython --TerminalInteractiveShell.editing_mode=vi'

# Set usr bin
usr_bin="$HOME/bin"
if [ -d "$usr_bin" ]; then
    PATH="$usr_bin:$PATH"
fi

export PATH

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# work spaces
unset -f j1 j2 j3 p1 p2 p3
function j1() { cd "$ENV1"; }
function j2() { cd "$ENV2"; }
function j3() { cd "$ENV3"; }
function p1() { pushd "$ENV1"; }
function p2() { pushd "$ENV2"; }
function p3() { pushd "$ENV3"; }
alias pd=popd

# Source the custom bashrc extension
if [ -d ~/.ws ]; then
    for ws in ~/.ws/*; do
        if [ -f "$ws/bashrc" ]; then
            . "$ws/bashrc"
        fi
    done
fi

# Source the custom bashrc extension
if [ -d ~/.bashrc.d ]; then
    for bashrc in ~/.bashrc.d/*; do
        if [ -r "$bashrc" ]; then
            . "$bashrc"
        fi
    done
fi

