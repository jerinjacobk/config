#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

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

if [ ! -f /usr/lib/python3.10/site-packages/codespell_lib/data/dictionary.txt ]; then
	echo "############################### CODESPELL path changed fix up /home/jerin/.config/dpdk/devel.config"	
fi

# User specific aliases and functions
export LANG=en_US.UTF-8

#export CC="ccache aarch64-marvell-linux-gnu-gcc"
export PATH=/usr/lib/ccache/bin/:$PATH
#export PATH=/opt/marvell-tools-248.0/bin/:$PATH
export PATH=/opt/marvell-tools-1010.0/bin/:$PATH
export PATH=/opt/armv7-eabihf--glibc--stable-2018.11-1/bin/:$PATH
export PATH=/home/jerin/kwbuildtools/bin/:$PATH
export PATH=/home/jerin/kwcmd/bin/:$PATH

source /usr/share/bash-completion/bash_completion

export TERM=xterm-256color
export EXTRA_CFLAGS='-g'
export EXTRA_LDFLAGS='-g'

alias b="git rebase --autosquash -i"
alias q="git clean -dxf"
alias c="clear"
alias d="cd /export/dpdk.org"
alias e="exit"
alias ev="cd /export/dpdk-next-eventdev"
alias f='git ci -m "f"'
alias g="git diff"
alias l="ls -ltr"
alias m="meson build"
alias md=" CFLAGS='-g -ggdb3' meson build"
alias n="ninja -C build"
alias o="cd /export/dpdk-marvell"
alias p='git diff HEAD > /tmp/git_diff && if [  -f ./scripts/checkpatch.pl ]; then ./scripts/checkpatch.pl -q /tmp/git_diff; else ./devtools/checkpatches.sh /tmp/git_diff ; fi'
alias pa="sudo pacman"
alias r="git pull --rebase"
alias v="vim"
alias mk="make -j"
alias x="make -j -C build"
alias X="make -j 1 -C build V=1"
function odp_build_skelton {
	if [ ! -f ./configure  ]; then
		./bootstrap
	fi
	rm -rf build && mkdir -p build && pushd build && PKG_CONFIG_PATH=/export/cross_prefix/prefix/lib/pkgconfig ../configure  --host=aarch64-marvell-linux-gnu --build=x86_64-linux-gnu --disable-abi-compat $@ --with-openssl-path=/export/cross_prefix/prefix/ && popd
	
}
alias z="odp_build_skelton --with-platform=cn10k --disable-shared --enable-test-vald --enable-lto"
alias s="odp_build_skelton --with-platform=cn10k --disable-shared --enable-test-vald"
alias sd="odp_build_skelton --with-platform=cn10k --disable-shared --enable-test-vald --enable-doxygen-doc"
alias e="odp_build_skelton --with-platform=cn9k --disable-shared --enable-test-vald"

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# https://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
#Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

set -o vi

export BR2_DL_DIR=/home/jerin/dl/

if [ ! -f /tmp/xinit.run ]; then
	touch /tmp/xinit.run
	sudo iptables -F
	sudo cpupower frequency-set -g performance
fi

# Prompting: Returns the branch for the current directory's git repo
# or blank if there is no repo
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1]/"
}

export PS1="${COLOR_FG_RED}"'$(parse_git_branch)'"${COLOR_RESET}${COLOR_FG_YELLOW}dell${COLOR_RESET}[${COLOR_DIM}${COLOR_FG_CYAN}\W${COLOR_RESET}] ${COLOR_BRIGHT}${COLOR_FG_RED}\\\$ ${COLOR_RESET}"

export EDITOR=vim
export PATH=~/.local/bin:"$PATH"
