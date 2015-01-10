# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export PATH=/home/jerin/projects/OCTEON-SDK/tools/bin/:$PATH
alias m="make -j 10"

if [ ! -f /tmp/xinit.run ]; then
touch /tmp/xinit.run
xinit -e i3
fi
