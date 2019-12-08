#!/bin/bash

mkdir -p /lfs/src
pushd /lfs/src
cat > bash_profile << EOF
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash

EOF

cat > bashrc << EOF
set +h
umask 022
LFS=/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH

EOF

cat > version-check.sh << "EOF"
#!/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH

echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1

if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "yacc not found"
fi

bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1

if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else
  echo "awk not found"
fi

gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
python3 --version
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1  # texinfo version
xz --version | head -n1

echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
rm -f dummy.c dummy

EOF

chmod +x version-check.sh

curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/lfs-bootscripts-20190524.tar.xz
curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/LFS-BOOK-9.0-NOCHUNKS.html
curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/LFS-BOOK-9.0.pdf
curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/LFS-BOOK-9.0.tar.xz
curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/md5sums
curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/wget-list
wget --input-file=wget-list --continue --direcory-prefix=/lfs/sources
md5sum -c md5sums
wget https://github.com/cracklib/cracklib/releases/download/v2.9.7/cracklib-2.9.7.tar.bz2
wget https://github.com/cracklib/cracklib/releases/download/v2.9.7/cracklib-words-2.9.7.bz2
echo "0d68de25332cee5660850528a385427f cracklib-2.9.7.tar.bz2" > extra.md5sums
echo "94e9963e4786294f7fb0f2efd7618551 cracklib-words-2.9.7.bz2" >> extra.md5sums
wget https://ftp.gnu.org/gnu/which/which-2.21.tar.gz
echo "097ff1a324ae02e0a3b0369f07a7544a which-2.21.tar.gz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/cpio/cpio-2.13.tar.bz2
echo "f3438e672e3fa273a7dc26339dd1eed6 cpio-2.13.tar.bz2" >> extra.md5sums
wget https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1.tar.xz
echo "558ff53b0fc0563ca97f79e911822165 Linux-PAM-1.3.1.tar.xz" >> extra.md5sums
wget https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1-docs.tar.xz
echo "1885fae049acd1b699a5459d7c4a0130 Linux-PAM-1.3.1-docs.tar.xz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/sharutils/sharutils-4.15.2.tar.xz
echo "5975ce21da36491d7aa6dc2b0d9788e0 sharutils" >> extra.md5sums
wget https://ftp.gnu.org/gnu/nettle/nettle-3.5.1.tar.gz
echo "0e5707b418c3826768d41130fbe4ee86" >> extra.md5sums



md5sum -c extra.md5sums
popd

ln -sf /lfs/tools /tools
