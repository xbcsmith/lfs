# .bashrc
# User specific aliases and functions
set -b

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
BLACK='1;30m'
RED='1;31m'
GREEN='1;32m'
YELLOW='1;33m'
BLUE='1;34m'
MAGENTA='1;35m'
CYAN='1;36m'
WHITE='1;37m'


NCOLOR=$GREEN
HCOLOR=$CYAN
ACOLOR=$WHITE


if [ $UID -eq 0 ];
    then
        NCOLOR=$RED
        HCOLOR=$RED
        ACOLOR=$RED
fi

PS1="\[\033[1;37m\][\[\033[1;37m\]\[\033[${NCOLOR}\]\u\[\033[1;37m\]@\[\033[1;37m\]\[\033[${HCOLOR}\]\h\[\033[1;35m\]\[\033[1;37m\]:\[\033[1;37m\]\[\033[${ACOLOR}\]\w\[\033[1;31m\]\[\033[1;37m\]]---\[\033[1;37m\]\n\[\033[1;37m\]-(\[\033[00m\]\W\[\033[1;37m\])-\[\033[1;37m\]\[\033[${ACOLOR}\]>>>\[\033[00m\]"

export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'

#setup terminal tab title
function title {
    if [ "$1" ]
    then
        unset PROMPT_COMMAND
        echo -ne "\033]0;${*}\007"
    else
        export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'
    fi
}

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
alias whence='which '
alias more='/usr/bin/less '

export PATH=$PATH:$HOME/bin

