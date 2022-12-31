#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

# Set Colors
COL1=$(tput setaf 226)
COL2=$(tput setaf 172)
COL3=$(tput setaf 106)
COL4=$(tput setaf 167)
NORM=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)

# Command Prompt formating
function git_branch() { # Display the current Git branch in the Bash prompt.
    if [ -d .git ] ; then
        GITBRANCH="($COL1$(git branch 2> /dev/null | awk '/\*/{print $2}')$NORM)"
    else
        GITBRANCH=""
    fi
    export PS1="$COL2\u$NORM@$COL3$BOLD\h$NORM: [$DIM$COL4\w$NORM] $ $GITBRANCH "
}

PROMPT_COMMAND=git_branch

# Display system information.
if command -v screenfetch; then
    screenfetch
fi

# History Formatting and Tweaks
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups:erasedups

# Set Nano as default editor if it exists.
if command -v nano; then
    export VISUAL=nano
    export EDITOR=nano
fi

# Autostart tmux with default layout
if [ -z "$TMUX" ]; then
   tmux
fi
