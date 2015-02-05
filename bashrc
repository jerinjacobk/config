# .bashrc

COLOR_RESET='\[\e[0m\]'
COLOR_BRIGHT='\[\e[1m\]'
COLOR_DIM='\[\e[2m\]'
COLOR_UNDERSCORE='\[\e[3m\]'
COLOR_BLINK='\[\e[5m\]'
COLOR_REVERSE='\[\e[7m\]'
COLOR_HIDDEN='\[\e[8m\]'

COLOR_FG_BLACK='\[\e[30m\]'
COLOR_FG_RED='\[\e[31m\]'
COLOR_FG_GREEN='\[\e[32m\]'
COLOR_FG_YELLOW='\[\e[33m\]'
COLOR_FG_BLUE='\[\e[34m\]'
COLOR_FG_MAGENTA='\[\e[35m\]'
COLOR_FG_CYAN='\[\e[36m\]'
COLOR_FG_WHITE='\[\e[37m\]'

COLOR_BG_BLACK='\[\e[40m\]'
COLOR_BG_RED='\[\e[41m\]'
COLOR_BG_GREEN='\[\e[42m\]'
COLOR_BG_YELLOW='\[\e[44m\]'
COLOR_BG_BLUE='\[\e[44m\]'
COLOR_BG_MAGENTA='\[\e[45m\]'
COLOR_BG_CYAN='\[\e[46m\]'
COLOR_BG_WHITE='\[\e[47m\]'


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export PATH=/export/OCTEON-SDK/tools/bin/:$PATH
alias m="make -j 4"
alias l="ls -ltr"
set -o vi
# uncomment this after vim-enhanced is installed
alias vi="vim"

if [ ! -f /tmp/xinit.run ]; then
#set to max cpu  clock
touch /tmp/xinit.run
sudo iptables -F
sudo cpupower frequency-set -g performance
#startx
startx /usr/bin/i3
fi

# Prompting: Returns the branch for the current directory's git repo
# or blank if there is no repo
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1]/"
}

export PS1="${COLOR_BRIGHT}${COLOR_FG_RED}➜${COLOR_RESET} ${COLOR_BRIGHT}${COLOR_FG_RED}"'$(parse_git_branch)'"${COLOR_RESET}${COLOR_FG_YELLOW}laptop${COLOR_RESET} [${COLOR_DIM}${COLOR_FG_CYAN}\W${COLOR_RESET}] ${COLOR_BRIGHT}${COLOR_FG_RED}\\\$ ${COLOR_RESET}"

