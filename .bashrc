#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Autostart tmux
if [[ -z $TMUX ]]; then
    tmux
fi

# Current Weather
function __weather()
{
    LOCATION='' # Place lattitude and longitude coordinates in this variable. Ex. lat=40.730610&lon=-73.935242
    DATA=$(curl -s https://forecast.weather.gov/MapClick.php?${LOCATION})
    TEMP=$(echo "$DATA" | grep 'current-lrg' | awk -F '>' '{ print $2 }' | awk -F '&' '{ print $1 }')
    if [[ $TEMP == 'N/A</p' ]]; then
        TEMP='...'
    fi
  
    COND=$(echo "$DATA" | grep 'myforecast-current' | awk -F '>' '{ print $2 }' | awk -F '<' '{ print $1 }')

    if [[ $COND == 'Sunny' || 'Fair' ]]; then
        WEATHICO=''
    elif [[ $COND == ' Fog/Mist' || $COND == 'Fog' ]]; then
        WEATHICO=''
    elif [[ $COND == 'Overcast' || $COND == 'Cloudy' || $COND == 'Mostly Cloudy' ]]; then
        WEATHICO=''
    elif [[ $COND == 'Partly Cloudy' || $COND == 'Mostly Sunny' ]]; then
        WEATHICO=''
    else
        WEATHICO=$COND
    fi

    echo -n $TEMP°F $WEATHICO
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

# Set Colors
FG_YELLOW=$(tput setaf 226)
FG_PINK=$(tput setaf 172)
FG_LIGHTYELLOW=$(tput setaf 106)
FG_LIGHTPINK=$(tput setaf 167)
FG_CYAN=$(tput setaf 6)
FG_GREY=$(tput setaf 7)
NORM=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)

# Create Prompt
export PS1=\
"\n\[$FG_PINK\]╭─ \[$NORM\]$(__weather) \[$FG_CYAN\]\[$BOLD\]\d \[$FG_WHITE\]\t\[$NORM\]"\
" \[$FG_GREY\]\$(__short_wd_cygwin) \[$FG_LIGHTPINK\]"\
" \$(find . -mindepth 1 -maxdepth 1 -type d | wc -l) "\
" \$(find . -mindepth 1 -maxdepth 1 -type f | wc -l) "\
" \$(find . -mindepth 1 -maxdepth 1 -type l | wc -l)"\
"\$(git branch 2> /dev/null | grep "^*" | colrm 1 2 | xargs -I BRANCH echo -n \" \[$FG_YELLOW\] BRANCH \[$NORM\]\")"\
"\n\[$FG_PINK\]╰─▶ \u\[$NORM\]@\[$FG_LIGHTYELLOW\]\[$BOLD\]\h\[$NORM\]: ¢ "

# Display system information.
if command -v screenfetch; then
    screenfetch
fi


# Timestamp history
export HISTTIMEFORMAT="%F %T "

# History settings 
export HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

# Set Vim as default editor.
export VISUAL=vim
export EDITOR=vim

# Set Aliases
alias ls='ls -la --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p -v'
alias refresh='clear; source $HOME/.bashrc'  # to update weather info
alias edit='vim'
fix-newline() {
  sed -i 's/\\n/\'$'\n/g' "$*"  # With my workflow I run into logs that use a literal '\n' (Think Ansible logs). This function will replace all literal '\n' with a newline.
}

