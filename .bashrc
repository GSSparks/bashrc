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
  if [ ! -f ~/.weather_api ]; then
    __set_weather_api
  else
    source ~/.weather_api
  fi

  read -p $'Location needs to be set for the weather function.\x0aEnter your 5-digit zip code: ' zip_code
  read -p $'Please enter your two-digit alphabetic country code: ' country_code
  country_code=$(echo "$country_code" | tr '[:lower:]' '[:upper:]')

  valid_country_code=$(curl -s https://gist.githubusercontent.com/ssskip/5a94bfcd2835bf1dea52/raw/3b2e5355eb49336f0c6bc0060c05d927c2d1e004/ISO3166-1.alpha2.json | jq -r)
  if [[ $valid_country_code != *"$country_code"* ]]; then
    __set_location
  fi

  if [[ $zip_code =~ ^[0-9]{5}$ ]]; then
    DATA=$(curl -s "http://api.openweathermap.org/geo/1.0/zip?zip=$zip_code,$country_code&appid=$API_KEY")
    lattitude=$(echo "$DATA" | jq -r '.lat')
    longitude=$(echo "$DATA" | jq -r '.lon')
    printf "ZIP=%s\nCOUNTRY=%s\nLAT=%s\nLON=%s\n" "$zip_code" "$country_code" "$lattitude" "$longitude" > ~/.weather_location
  else
    echo "Invalid zip code. Please enter a valid 5-digit zip code."
    __set_location
  fi
}

function __set_weather_api() {
  read -p $'Please enter your Openweather.org API key: ' api_key
  # Perform a test request to validate the API key
  response=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=London,uk&appid=$api_key")
  if [[ $response =~ "Invalid API key" ]]; then
    echo "Invalid API key. Please enter a valid OpenWeatherMap API key."
    __set_weather_api
  else
    printf "API_KEY=%s\n" "$api_key" > ~/.weather_api
  fi
}

# Current Weather
function __weather() {
    # Check whether API key exists
    if [ ! -f ~/.weather_api ]; then
      __set_weather_api
    else
      source ~/.weather_api
    fi

    # Check if location file exists
    if [ ! -f ~/.weather_location ]; then
        __set_location
    else
        source ~/.weather_location
    fi

    # Get the current time
    NOW=$(date +%s)

    # Check if it's been at least 30 minutes since the last retrieval
    if [[ ! -f ~/.weather ]] || [[ $(expr $NOW - $(date -r ~/.weather +%s)) -ge 1800 ]]; then
        # If so, retrieve the weather and update the file with the current time
       DATA=$(curl -m 5 -s "https://wttr.in/$ZIP?format=1")
       if [[ $? -eq 0 ]] && [[ $DATA != "Unknown location; please try"* ]]; then
         # If successful, extract the temperature and condition
         TEMP=$(echo "$DATA" | awk -F ' ' '{ print $2 }' | sed 's/+//g')
         COND=$(echo "$DATA" | awk -F ' ' '{ print $1 }')
       else
         # If wttr.in fails, try openweathermap.org
         DATA=$(curl -m 5 -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$API_KEY&units=imperial")
         if [[ $? -eq 0 ]]; then
           # If successful, extract the temperature and condition
           TEMP=$(echo "$DATA" | jq -r '.main.temp | round')'°F'
           COND=$(echo "$DATA" | jq -r '.weather[0].description')
           if [[ $COND == *"cloud"* ]]; then
             ICON="☁️"
           elif [[ $COND == *"rain"* ]]; then
             ICON="🌧️"
           elif [[ "$COND" == *"snow"* ]]; then
             ICON="❄️"
           else
             ICON="☀️"
           fi
           COND=$ICON
         else
           # If both services fail, use an error message
           TEMP="N/A"
           COND="Weather service unavailable"
         fi
       fi
       echo -n $TEMP $COND > ~/.weather
    fi
    cat ~/.weather
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

# Show if the git tree is dirty and how many uncommits are present
function __git_dirty() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo -n " "
    uncommits=$(git status --porcelain 2>/dev/null| wc -l | tr -d ' ')
    if [[ $uncommits != "0" ]]; then
        echo " $uncommits"
    fi
  fi
}

# Display an arrow followed by the number commits that are ahead or behind the remote branch.
function __git_branch_status {
  local branch_status=$(git rev-parse --abbrev-ref HEAD 2> /dev/null | xargs git rev-parse --symbolic-full-name @{u} 2>&1 || echo "")
  if [[ "$branch_status" == *"no upstream configured for branch"* ]]; then
    branch_status="* $(git rev-parse --abbrev-ref HEAD) *"
  fi
  if [[ "$branch_status" ]]; then
    local ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null \
        | awk '{print $1}')
    if [[ $ahead_behind -gt 0 ]]; then
      echo -n "${branch_status##*/}" | awk '{print substr($0,1,20)}' | awk '{if (length($0)==20) {print $0"..." } else {print $0}}' | tr -d '\n'
      echo -n "  $ahead_behind "
    elif [[ $ahead_behind -lt 0 ]]; then
      echo -n "${branch_status##*/}" | awk '{print substr($0,1,20)}' | awk '{if (length($0)==20) {print $0"..." } else {print $0}}' | tr -d '\n'
      echo -n "  $((-ahead_behind)) "
    else
      echo -n "${branch_status##*/}" | awk '{print substr($0,1,20)}' | awk '{if (length($0)==20) {print $0"..." } else {print $0}}' | tr -d '\n'
      echo -n "  "
    fi
  fi
}

# Update current directory stats -- called by `cd`
function __dfl_count() {
  dir_count=" $(find . -mindepth 1 -maxdepth 1 -type d | wc -l)"
  file_count=" $(find . -mindepth 1 -maxdepth 1 -type f | wc -l)"
  link_count=" $(find . -mindepth 1 -maxdepth 1 -type l | wc -l)"
}

# Update the current directory stats when changing directories
cd() {
  builtin cd "$@"
  __dfl_count
}

# Call the function to initialize the current directory stats
__dfl_count

PROMPT_COMMAND=__prompt_command

__prompt_command() {
    EXIT="$?"
    PS1=""

    # Set Colors and Style
    FG_YELLOW=$(tput setaf 214)
    FG_ORANGE=$(tput setaf 208)
    FG_GREEN=$(tput setaf 106)
    FG_RED=$(tput setaf 167)
    FG_CYAN=$(tput setaf 109)
    FG_GREY=$(tput setaf 245)
    NORM=$(tput sgr0)
    BOLD=$(tput bold)

    # Create Prompt
    PS1+="\n\[$FG_ORANGE\]╭─ \[$NORM\]\$(__weather) \[$FG_CYAN\]\[$BOLD\] \d \t \[$NORM\]"
    PS1+="\[$FG_GREY\]\$(__short_wd_cygwin) \[$FG_RED\]"

    PS1+="\$dir_count \$file_count \$link_count "

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      PS1+="\[$FG_YELLOW\]\[$FG_RED\]\$(__git_dirty)\[$FG_YELLOW\] \$(__git_branch_status)"
    fi

    PS1+="\n\[$FG_ORANGE\]╰─▶ \u\[$NORM\]@\[$FG_GREEN\]\[$BOLD\]\h\[$NORM\] "

    if [[ -n "$IN_NIX_SHELL" ]]; then
      PS1+="\[$FG_RED\]{nix-shell}\[$NORM\] "
    fi

    if [ $EXIT != 0 ]; then
      if [ $EXIT == 1 ]; then
        PS1+="\[$FG_RED\]:(\[$NORM\] "
      elif [ $EXIT == 2 ]; then
        PS1+="\[$FG_ORANGE\]¯\\_(ツ)_/¯\[$NORM\] "
      elif [[ $EXIT == 127 ]]; then
        PS1+="\[$FG_RED\]:|\[$NORM\] "
      elif [ $EXIT == 255 ]; then
        PS1+="\[$FG_ORANGE\]:/\[$NORM\] "
      else
        PS1+="\[$FG_RED\]:(\[$NORM\] "
      fi
    fi
    if [ $EXIT == 0 ]; then
      PS1+="\[$FG_YELLOW\]=)\[$NORM\] "
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

# Set TERM
export TERM=xterm-256color

# Direnv hook
eval "$(direnv hook bash)"
