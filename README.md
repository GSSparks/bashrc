# bashrc
My Bash login script.

## Features include:
* Displays current Git branch name.
* Shortens URL after 3 directories
* Autostarts tmux and sets vim as my default editor.
* Adds time format to history and ignores and erases duplicate entries.
* Displays system information using screenfetch.
* Display date, time, and weather information in prompt
* Asks for API key and zip code if one is not set for weather.
* Weather is curled from wttr.in or openweathermap.org and updated every 30 minutes.
* Useful Aliases such as `..` for `cd ..` and `...` for `cd ../..`

![Screenshot](media/bash.png?raw=true "Screenshot")

* Exit code indicators

![Screenshot](media/exit_code_indicator.png?raw=true "Screenshot")

## Requirements
* Needs DejaVu Mono fonts from [Nerd Fonts](https://www.nerdfonts.com)
* Needs bat, curl, tmux, vim, and screenfetch
* Needs an [openweathermap.org](https://openweathermap.org) API key to use the secondary weather function
