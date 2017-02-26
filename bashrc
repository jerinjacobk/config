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
export PATH=/export/SDK/OCTEON-SDK-3_1_1_P2/tools/bin/:/export/sdk_thunderx/tools/bin/:/opt/arm-2014.05/bin/:$PATH

#export PATH=/home/jerin/toolchain-install-gcc_5_3-421/bin:$PATH
#export LD_LIBRARY_PATH=/home/jerin/toolchain-install-gcc_5_3-421/lib64/:${LD_LIBRARY_PATH}

#export TERM=screen
#export EXTRA_CFLAGS='-g -ggdb'
#export EXTRA_LDFLAGS='-g -ggdb'

alias m="make -j 8"
alias l="ls -ltr"
alias p="git diff > /tmp/git_diff && ./scripts/checkpatch.pl /tmp/git_diff"
set -o vi
# uncomment this after vim-enhanced is installed
alias v="vim"
alias g="git"
alias c="clear"

export BR2_DL_DIR=/export/dl/

#export LD_LIBRARY_PATH=/opt/gcc-6.1.0/lib64/
#export PATH=/opt/gcc-6.1.0/bin:$PATH

if [ ! -f /tmp/xinit.run ]; then
#set to max cpu  clock
touch /tmp/xinit.run
sudo iptables -F
sudo cpupower frequency-set -g performance

#sudo chmod 777 /dev/ttyUSB0
#sudo chmod 777 /dev/ttyUSB1
#sudo chmod 777 /dev/ttyUSB2
#sudo chmod 777 /dev/ttyUSB3
#sudo mount /dev/sda6 /export/

#startx
startx /usr/bin/i3 1> /tmp/1.txt  2> /tmp/2.txt
fi

# Prompting: Returns the branch for the current directory's git repo
# or blank if there is no repo
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1]/"
}

export PS1="${COLOR_BRIGHT}${COLOR_FG_RED}➜${COLOR_RESET} ${COLOR_BRIGHT}${COLOR_FG_RED}"'$(parse_git_branch)'"${COLOR_RESET}${COLOR_FG_YELLOW}laptop${COLOR_RESET} [${COLOR_DIM}${COLOR_FG_CYAN}\W${COLOR_RESET}] ${COLOR_BRIGHT}${COLOR_FG_RED}\\\$ ${COLOR_RESET}"

export EDITOR=vim
