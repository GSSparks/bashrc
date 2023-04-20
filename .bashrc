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
      echo -n "${branch_status##*/}"
      echo -n "  $ahead_behind "
    elif [[ $ahead_behind -lt 0 ]]; then
      echo -n "${branch_status##*/}"
      echo -n "  $((-ahead_behind)) "
    else
      echo -n "${branch_status##*/}"
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
    FG_YELLOW=$(tput setaf 226)
    FG_ORANGE=$(tput setaf 172)
    FG_GREEN=$(tput setaf 106)
    FG_RED=$(tput setaf 167)
    FG_CYAN=$(tput setaf 6)
    FG_GREY=$(tput setaf 7)
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

# Set TERM
export TERM=xterm-256color

# Direnv hook
eval "$(direnv hook bash)"
