#usefull  commands

source ./env-setup OCTEON_CN68XX_PASS2_2
ctags $(find ../../components/ ../../examples/ ../../executive -name \*[.chS])
ctags $(find . -name \*[.chS])
git diff > /tmp/git_diff && ./scripts/checkpatch.pl /tmp/git_diff
git diff > /tmp/git_diff && pushd /export/odp/ && ./scripts/checkpatch.pl /tmp/git_diff && popd
rysnc -aH src dest

aarch64-thunderx-linux-gnu-gcc -O3 -fverbose-asm -S ptr.c

./configure --host=mipsisa64-octeon-elf --with-platform=octeon --with-soc-model=cn68xx_pass2_2 --enable-bare-metal --enable-shared=no --enable-cunit --with-cunit-path=/export/cunit-code/prefix
