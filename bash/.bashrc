# Variables
export ALTERNATE_EDITOR="vim"
export BROWSER="firefox"
export EDITOR="emacsclient -c"
export EMAIL="matthias.paulmier@coopengo.com"
export HISTFILESIZE=20000
export LANG="fr_FR"
export LC_ALL="fr_FR.UTF-8"
export LC_CTYPE="fr_FR.UTF-8"
export NAME="Matthias Paulmier"

# Aliases
alias less="less -R"
alias grep="grep --color=auto"
alias l="ls --color=auto -h -CF"
alias ll="l -l"
alias la="l -A"
alias lla="ll -A"
alias mkdir="mkdir -p"
alias tree="tree -C"
# Ring a bell both audio and visual
alias ding="paplay /usr/share/sounds/freedesktop/stereo/complete.oga; echo -ne \"\007\""
alias rpdb="rlwrap nc 0 4444"

# Prompt (from <http://dotshare.it/dots/1143/>)
# Check for an interactive session
[ -z "$PS1" ] && return

# Parse git branch to show in prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

parse_virtualenv() {
    pyenv version | tr ' ' '\n' | head -1
}

cdc() {
    cd $HOME/coog_dev/workspace_coog_$1
}

_PROMPT() {
    _EXIT_STATUS=$?
    [ $_EXIT_STATUS != 0 ] && _EXIT_STATUS_STR=" \[\033[38;5;7m\][\[$(tput sgr0)\]\[\033[38;5;9m\]$_EXIT_STATUS\[$(tput sgr0)\]\[\033[38;5;7m\]]\[$(tput sgr0)\]"

    PYENSTR=""
    if [ -d .pyenv ]; then
        VIRTUALENV=$(parse_virtualenv)
        if [ "$VIRTUALENV" != "$(pyenv global)" ]; then
            PYENVSTR="($VIRTUALENV)"
        fi
    fi
    export PS1="$PYENVSTR\[$(tput bold)\]\[$(tput setaf 2)\][\[$(tput setaf 3)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 3)\]\h \[$(tput setaf 6)\]\W\[$(tput setaf 2)\]]\[$(tput setaf 4)\]$(parse_git_branch)\\$ \[$(tput sgr0)\]"

    unset VIRTUALENV
    unset PYENVSTR
    unset _EXIT_STATUS_STR
    unset _EXIT_STATUS
}

PROMPT_COMMAND=_PROMPT

export PS2=">>> "

# Functions :
# Extract any archive (may lack some file archive formats I don't use)
function extract {
    if [ -z "$1" ]; then
        echo "Usage: extract <path/file_name>.<zip|bz2|gz|tar|tbz2|tgz|7z|xz|tar.bz2|tar.gz|tar.xz>"
    else
        if [ -f $1 ] ; then
            case $1 in
                *.tar.bz2)   tar xvjf ./$1    ;;
                *.tar.gz)    tar xvzf ./$1    ;;
                *.tar.xz)    tar xvJf ./$1    ;;
                *.bz2)       bunzip2 ./$1     ;;
                *.gz)        gunzip ./$1      ;;
                *.tar)       tar xvf ./$1     ;;
                *.tbz2)      tar xvjf ./$1    ;;
                *.tgz)       tar xvzf ./$1    ;;
                *.zip)       unzip ./$1       ;;
                *.7z)        7z x ./$1        ;;
                *.xz)        unxz ./$1        ;;
                *)           echo "extract: '$1' - unknown archive method" ;;
            esac
        else
            echo "$1 - file does not exist"
        fi
    fi
}

function change_commit_date {
    if [ -z "$1" ]; then
        echo "Usage: change_commit_date <date>"
    else
        GIT_COMMITTER_DATE="$1" git commit --amend --no-edit --date "$1"
    fi
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

if [ -d "$HOME/.pyenv" ]; then
    # colored GCC warnings and errors
    export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    # Pyenv
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
