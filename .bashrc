#
# .bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ~/.aliases
source ~/.aliases_private

# Autostart tmux
if [[ -z $TMUX ]]; then
    tmux
fi

# Current Weather
function __weather() {
    # Set the location for the weather request
    LOCATION='lat=40.65826500000003&lon=-84.95273499999996'

    # Get the current time
    NOW=$(date +%s)

    # Check if it's been at least 30 minutes since the last retrieval
    if [[ ! -f ~/.weather ]] || [[ $(expr $NOW - $(date -r ~/.weather +%s)) -ge 1800 ]]; then
        # If so, retrieve the weather and update the file with the current time
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

        echo -n $TEMP°F $WEATHICO > ~/.weather
        echo $NOW > ~/.weather_time
        cat ~/.weather
    else
        cat ~/.weather
    fi
}

# The following cygwin function is from https://dev.to/vuong/let-s-add-cygwin-into-windows-terminal-and-customize-it-for-development-looks-1hp8
# Just shorten the cygwin path
function __short_wd_cygwin() 
{
    num_dirs=3
    newPWD="${PWD/#$HOME/~}"
    if [ $(echo -n $newPWD | awk -F '/' '{print NF}') -gt $num_dirs ]; then
        newPWD=$(echo -n $newPWD | awk -F '/' '{print $1 "/.../" $(NF-1) "/" $(NF) }')
    fi

    echo -n $newPWD
}

# Set Colors and Style
FG_YELLOW=$(tput setaf 226)
FG_ORANGE=$(tput setaf 172)
FG_GREEN=$(tput setaf 106)
FG_RED=$(tput setaf 167)
FG_CYAN=$(tput setaf 6)
FG_GREY=$(tput setaf 7)
NORM=$(tput sgr0)
BOLD=$(tput bold)

# Create Prompt
export PS1=\
'\n\[$FG_ORANGE\]╭─ \[$NORM\]$(__weather) \[$FG_CYAN\]\[$BOLD\]\d \t\[$NORM\]'\
' \[$FG_GREY\]$(__short_wd_cygwin) \[$FG_RED\]'\
" \$(find . -mindepth 1 -maxdepth 1 -type d | wc -l) "\
" \$(find . -mindepth 1 -maxdepth 1 -type f | wc -l) "\
" \$(find . -mindepth 1 -maxdepth 1 -type l | wc -l)"\
"\$(git branch 2> /dev/null | grep "^*" | colrm 1 2 | xargs -I BRANCH echo -n \" \[$FG_YELLOW\] BRANCH \")"\
'\n\[$FG_ORANGE\]╰─▶ \u\[$NORM\]@\[$FG_GREEN\]\[$BOLD\]\h\[$NORM\]: ¢ '

# Display system information.
screenfetch -A custom

# Timestamp history
export HISTTIMEFORMAT="[%F %T] "

# History settings 
export HISTCONTROL="ignorespace:erasedups"
export HISTSIZE=10000
export HISTFILESIZE=10000

# Setting various shell options
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s direxpand

# Set Vim as default editor.
export VISUAL=vim
export EDITOR=vim

# Direnv hook
eval "$(direnv hook bash)"
