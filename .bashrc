#
# .bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load sources if they exists
if [[ -f ~/.aliases ]]; then
    source ~/.aliases
fi

if [[ -f ~/.aliases_private ]]; then
    source ~/.aliases_private
fi

# Autostart tmux
if [[ -z $TMUX ]]; then
    tmux
fi

# Set Location for Weather
function __set_location() {
  read -p $'Location needs to be set for the weather function.\x0aEnter your 5-digit zip code: ' zip_code
  if [[ $zip_code =~ ^[0-9]{5}$ ]]; then
    echo $zip_code > ~/.weather_location
  else
    echo "Invalid zip code. Please enter a valid 5-digit zip code."
    __set_location
  fi
}

# Current Weather
function __weather() {
    # Check if location file exists
    if [ ! -f ~/.weather_location ]; then
        __set_location
    else
        LOCATION=$(cat ~/.weather_location)
    fi

    # Get the current time
    NOW=$(date +%s)

    # Check if it's been at least 30 minutes since the last retrieval
    if [[ ! -f ~/.weather ]] || [[ $(expr $NOW - $(date -r ~/.weather +%s)) -ge 1800 ]]; then
        # If so, retrieve the weather and update the file with the current time
        DATA=$(curl -s "https://wttr.in/$LOCATION?format=%c,%t")
        TEMP=$(echo "$DATA" | awk -F ',' '{ print $2 }' | sed 's/+//g')
        COND=$(echo "$DATA" | awk -F ',' '{ print $1 }')
        echo -n $TEMP $COND > ~/.weather
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

PROMPT_COMMAND=__prompt_command

__prompt_command() {
    EXIT="$?"
    PS1=""

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
    PS1+='\n\[$FG_ORANGE\]╭─ \[$NORM\]$(__weather) \[$FG_CYAN\]\[$BOLD\]\d \t\[$NORM\]'
    PS1+='\[$FG_GREY\]$(__short_wd_cygwin) \[$FG_RED\]' 
    PS1+=" \$(find . -mindepth 1 -maxdepth 1 -type d | wc -l) "
    PS1+=" \$(find . -mindepth 1 -maxdepth 1 -type f | wc -l)"
    PS1+=" \$(find . -mindepth 1 -maxdepth 1 -type l | wc -l)"
    PS1+="\$(git branch 2> /dev/null | grep "^*" | colrm 1 2 | xargs -I BRANCH echo -n \" \[$FG_YELLOW\] BRANCH \")"
    PS1+='\n\[$FG_ORANGE\]╰─▶ \u\[$NORM\]@\[$FG_GREEN\]\[$BOLD\]\h\[$NORM\] '

    if [ $EXIT != 0 ]; then
        PS1+="\[$FG_RED\]:(\[$NORM\] "
    else
        PS1+="\[$FG_YELLOW\]:)\[$NORM\] "
    fi

    PS1+="¢ "
}

# Display system information.
screenfetch -A custom

# Timestamp history
export HISTTIMEFORMAT="[%F %T] "

# History settings 
export HISTCONTROL="ignoreboth:erasedups"
export HISTSIZE=10000
export HISTFILESIZE=10000
history -r

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
