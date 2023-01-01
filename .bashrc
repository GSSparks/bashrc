#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Current Weather
function __weather()
{
    TEMP=$(inxi -w | grep temperature | awk -F: '{ print $3 }' | awk -F' ' '{ print $3 }' | sed -e 's/(//')
    COND=$(inxi -w | grep conditions | awk -F: '{ print $4 }')

    if [[ COND=='Overcast clouds' ]]; then
        WEATHICO=""
    elif [[ COND=='Sunny' ]]; then
        WEATHICO=""
    else
        WEATHICO=""
    fi
    
    echo -n $TEMP°F $WEATHERICO
}

# The following cygwin and cygpath functions are from https://dev.to/vuong/let-s-add-cygwin-into-windows-terminal-and-customize-it-for-development-looks-1hp8
# Just shorten the cygwin path
function __short_wd_cygwin() 
{
    num_dirs=3
    newPWD="${PWD/#$HOME/~}"
    if [ $(echo -n $newPWD | awk -F '/' '{print NF}') -gt $num_dirs ]; then
        newPWD=$(echo -n $newPWD | awk -F '/' '{print $1 "/.../" $(NF-1) "/" $(NF)}')
    fi

    echo -n $newPWD
}

# Convert shorten path and shorten the Windows path
function __short_wd_cygpath() 
{
    num_dirs=3
    newPWD=$(cygpath -C ANSI -w ${PWD/#$HOME/~})
    if [ $(echo -n $newPWD | awk -F '\\' '{print NF}') -gt $num_dirs ]; then
        newPWD=$(echo -n $newPWD | awk -F '\\' '{print $1 "\\...\\" $(NF-1) "\\" $(NF)}')
    fi

    echo -n $newPWD
}

# Set Colors
COL1=$(tput setaf 226)
COL2=$(tput setaf 172)
COL3=$(tput setaf 106)
COL4=$(tput setaf 167)
NORM=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)
FFMT_BOLD="\[\e[1m\]"
FMT_DIM="\[\e[2m\]"
FMT_RESET="\[\e[0m\]"
FMT_UNBOLD="\[\e[22m\]"
FMT_UNDIM="\[\e[22m\]"
FG_BLACK="\[\e[30m\]"
FG_BLUE="\[\e[34m\]"
FG_CYAN="\[\e[36m\]"
FG_GREEN="\[\e[32m\]"
FG_GREY="\[\e[37m\]"
FG_MAGENTA="\[\e[35m\]"
FG_RED="\[\e[31m\]"
FG_WHITE="\[\e[97m\]"
BG_BLACK="\[\e[40m\]"
BG_BLUE="\[\e[44m\]"
BG_CYAN="\[\e[46m\]"
BG_GREEN="\[\e[42m\]"
BG_MAGENTA="\[\e[45m\]"

export PS1=\
"\n${FG_BLUE}╭─${FG_CYAN}  ${NORM}$(__weather) ${FG_CYAN}${FMT_BOLD}\d ${FG_WHITE}\t${FMT_UNBOLD} ${FG_MAGENTA}"\
"${FG_GREY}\$(__short_wd_cygwin) "\
"${FG_BLUE} \$(find . -mindepth 1 -maxdepth 1 -type d | wc -l) "\
" \$(find . -mindepth 1 -maxdepth 1 -type f | wc -l) "\
" \$(find . -mindepth 1 -maxdepth 1 -type l | wc -l) "\
"${FMT_RESET}${FG_CYAN}"\
"\$(git branch 2> /dev/null | grep '^*' | colrm 1 2 | xargs -I BRANCH echo -n \"${COL1}BRANCH${FMT_RESET}${FG_GREEN}\")"\
"\n${FG_BLUE}╰▶${FG_CYAN} $COL2\u$NORM@$COL3$BOLD\h$NORM: ¢ ${FMT_RESET}"

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

# Set Aliases
alias ls="ls -la --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias mkdir="mkdir -p -v"
