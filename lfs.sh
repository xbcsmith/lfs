#!/bin/bash

umask 022
LFS=/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH


mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v  /usr/libexec
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -v  /usr/lib/pkgconfig

case $(uname -m) in
 x86_64) mkdir -v /lib64 ;;
esac

mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}

ln -sv /tools/bin/{bash,cat,chmod,dd,echo,ln,mkdir,pwd,rm,stty,touch} /bin
ln -sv /tools/bin/{env,install,perl,printf}         /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1}                  /usr/lib
ln -sv /tools/lib/libstdc++.{a,so{,.6}}             /usr/lib

ln -sv bash /bin/sh

ln -sv /proc/self/mounts /etc/mtab

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false

EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
wheel:x:97:
nogroup:x:99:
users:x:999:

EOF

exec /tools/bin/bash --login +h

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

# linux api headers

cd /src
tar -xvf linux-5.2.8.tar.xz
cd linux-5.2.8
make mrproper
make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include

cd /src
tar -xvf man-pages-5.02.tar.xz
cd man-pages-5.02
make install

cd /src
tar -xvf glibc-2.30.tar.xz
cd glibc-2.30
patch -Np1 -i ../glibc-2.30-fhs-1.patch

sed -i '/asm.socket.h/a# include <linux/sockios.h>' sysdeps/unix/sysv/linux/bits/socket.h

case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
    ;;
esac

mkdir -v build
cd build

CC="gcc -ffile-prefix-map=/tools=/usr" \
../configure --prefix=/usr                          \
             --disable-werror                       \
             --enable-kernel=3.2                    \
             --enable-stack-protector=strong        \
             --with-headers=/usr/include            \
             libc_cv_slibdir=/lib

make

case $(uname -m) in
  i?86)   ln -sfnv $PWD/elf/ld-linux.so.2        /lib ;;
  x86_64) ln -sfnv $PWD/elf/ld-linux-x86-64.so.2 /lib ;;
esac

make check
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
make localedata/install-locales




cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf

EOF

tar -xf ../../tzdata2019b.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

ln -sfv /usr/share/zoneinfo/US/Eastern /etc/localtime

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B1 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep found dummy.log

rm -v dummy.c a.out dummy.log

cd /src
tar -xvf zlib-1.2.11.tar.xz
cd zlib-1.2.11
/configure --prefix=/usr && make && make check && make install
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

cd /src
tar -xvf file-5.37.tar.gz
cd file-5.37
./configure --prefix=/usr && make && make check && make install

cd /src
tar -xvf readline-8.0.tar.gz
cd readline-8.0
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/readline-8.0

make SHLIB_LIBS="-L/tools/lib -lncursesw"
make SHLIB_LIBS="-L/tools/lib -lncursesw" install

mv -v /usr/lib/lib{readline,history}.so.* /lib
chmod -v u+w /lib/lib{readline,history}.so.*
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.0

cd /src
tar -xvf m4-1.4.18.tar.xz
cd m4-1.4.18
./configure --prefix=/usr && make && make check && make install

cd /src
tar -xvf bc-2.1.3.tar.gz && cd bc-2.1.3
PREFIX=/usr CC=gcc CFLAGS="-std=c99" ./configure.sh -G -O3
make && make test && make install

cd /src
tar -xvf binutils-2.32.tar.xz && cd binutils-2.32
expect -c "spawn ls"
sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
mkdir -v build
cd build
 ../configure --prefix=/usr --enable-gold --enable-ld=default --enable-plugins --enable-shared --disable-werror --enable-64-bit-bfd --with-system-zlib
make tooldir=/usr
make -k check
make tooldir=/usr install

cd /src
tar -xvf gmp-6.1.2.tar.xz && cd gmp-6.1.2
./configure --prefix=/usr --enable-cxx --disable-static --docdir=/usr/share/doc/gmp-6.1.2
make && make html
make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install
make install-html

cd /src
tar -xvf mpfr-4.0.2.tar.xz && cd mpfr-4.0
./configure --prefix=/usr --disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr-4.0.2
make && make html && make check
make install && make install-html

cd /src
tar -xvf mpc-1.1.0.tar.gz && cd mpc-1.1.0
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpc-1.1.0
make && make html && make check
make install && make install-html

## should add cracklib
## http://www.linuxfromscratch.org/blfs/view/9.0/postlfs/cracklib.html

cd /src
tar -xvf cracklib-2.9.7.tar.bz2 && cd cracklib-2.9.7
sed -i '/skipping/d' util/packer.c &&
./configure --prefix=/usr    \
            --disable-static \
            --with-default-dict=/lib/cracklib/pw_dict &&
make
make install                      &&
mv -v /usr/lib/libcrack.so.* /lib &&
ln -sfv ../../lib/$(readlink /usr/lib/libcrack.so) /usr/lib/libcrack.so
install -v -m644 -D    ../cracklib-words-2.9.7.bz2 \
                         /usr/share/dict/cracklib-words.bz2    &&

bunzip2 -v               /usr/share/dict/cracklib-words.bz2    &&
ln -v -sf cracklib-words /usr/share/dict/words                 &&
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  &&
install -v -m755 -d      /lib/cracklib                         &&

create-cracklib-dict     /usr/share/dict/cracklib-words \
                         /usr/share/dict/cracklib-extra-words


cd /src
tar -xvf shadow-4.7.tar.xz && cd shadow-4.7
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
## with cracklib
sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs

sed -i 's/1000/999/' etc/useradd
./configure --sysconfdir=/etc --with-group-name-max-length=32 --with-libcrack
make
make install
mv -v /usr/bin/passwd /bin
pwconv
grpconv
sed -i 's/yes/no/' /etc/default/useradd
## passwd root
echo "root:lfspasswd" | chpasswd

cd /src
tar -xvf gcc-9.2.0.tar.xz && cd gcc-9.2.0
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac
SED=sed ../configure --prefix=/usr --enable-languages=c,c++ --disable-multilib --disable-bootstrap --with-system-zlib
make

ulimit -s 32768
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make -k check"

make install
rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/9.2.0/include-fixed/bits/
chown -v -R root:root /usr/lib/gcc/*linux-gnu/9.2.0/include{,-fixed}
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/9.2.0/liblto_plugin.so /usr/lib/bfd-plugins/

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd /src
tar -xvf bzip2-1.0.8.tar.gz && cd bzip2-1.0.8
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so && make clean
make && make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

cd /src
tar -xvf pkg-config-0.29.2.tar.gz && cd pkg-config-0.29.2
./configure --prefix=/usr --with-internal-glib --disable-host-tool --docdir=/usr/share/doc/pkg-config-0.29.2
make && make check && make install

cd /src
tar -xvf ncurses-6.1.tar.gz && cd ncurses-6.1
sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
./configure --prefix=/usr --mandir=/usr/share/man --with-shared --without-debug --without-normal --enable-pc-files --enable-widec
make && make install
mv -v /usr/lib/libncursesw.so.6* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
mkdir -v       /usr/share/doc/ncurses-6.1
cp -v -R doc/* /usr/share/doc/ncurses-6.1

cd /src
tar -xvf attr-2.4.48.tar.gz && cd attr-2.4.48
./configure --prefix=/usr --bindir=/bin --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/attr-2.4.48
make && make check && make install
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

cd /src
tar -xvf acl-2.2.53.tar.gz && cd acl-2.2.53
./configure --prefix=/usr --bindir=/bin --disable-static --libexecdir=/usr/lib --docdir=/usr/share/doc/acl-2.2.53
make && make install
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

cd /src
tar -xvf libcap-2.27.tar.xz && cd libcap-2.27
sed -i '/install.*STALIBNAME/d' libcap/Makefile
make
make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 /usr/lib/libcap.so.2.27
mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so


cd /src
tar -xvf sed-4.7.tar.xz && cd sed-4.7
sed -i 's/usr/tools/'                 build-aux/help2man
sed -i 's/testsuite.panic-tests.sh//' Makefile.in
make && make html
make check && make install
install -d -m755           /usr/share/doc/sed-4.7
install -m644 doc/sed.html /usr/share/doc/sed-4.7

cd /src
tar -xvf psmisc-23.2.tar.xz && cd psmisc-23.2
./configure --prefix=/usr
make && make install
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin

cd /src
tar -xvf iana-etc-2.30.tar.bz2 && cd iana-etc-2.30
make && make install

cd /src
tar -xvf bison-3.4.1.tar.xz && cd bison-3.4.1
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.4.1
make -j1
make install

cd /src
tar -xvf flex-2.6.4.tar.gz && cd flex-2.6.4
sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
HELP2MAN=/tools/bin/true ./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
make && make check && make install
ln -sv flex /usr/bin/lex

cd /src
tar -xvf grep-3.3.tar.xz && cd grep-3.3
./configure --prefix=/usr --bindir=/bin
make && make -k check && make install


cd /src
tar -xvf bash-5.0.tar.gz && cd bash-5.0
./configure --prefix=/usr --docdir=/usr/share/doc/bash-5.0 --without-bash-malloc --with-installed-readline
make
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH HOME=/home make tests"
make install
mv -vf /usr/bin/bash /bin
exec /bin/bash --login +h

cd /src
tar -xvf libtool-2.4.6.tar.xz && cd libtool-2.4.6
./configure --prefix=/usr
make && make check
make install

cd /src
tar -xvf gdbm-1.18.1.tar.gz && cd gdbm-1.18.1
./configure --prefix=/usr --disable-static --enable-libgdbm-compat
make && make check && make install

cd /src
tar -xvf gperf-3.1.tar.gz && cd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make && make -j1 check && make install

cd /src
tar -xvf expat-2.2.7.tar.xz && cd expat-2.2.7
sed -i 's|usr/bin/env |bin/|' run.sh.in
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/expat-2.2.7
make && make check && make install
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.7

cd /src
tar -xvf inetutils-1.9.4.tar.xz && cd inetutils-1.9.4
./configure --prefix=/usr --localstatedir=/var --disable-logger --disable-whois --disable-rcp --disable-rexec --disable-rlogin --disable-rsh --disable-servers
make && make check && make install
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin


cd /src
tar -xvf perl-5.30.0.tar.xz && cd perl-5.30.0
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib                  \
                  -Dusethreads

make && make -k test && make install
unset BUILD_ZLIB BUILD_BZIP2


cd /src
tar -xvf XML-Parser-2.44.tar.gz && cd XML-Parser-2.44
perl Makefile.PL
make && make test && make install

cd /src
tar -xvf intltool-0.51.0.tar.gz && cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make && make check && make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd /src
tar -xvf autoconf-2.69.tar.xz && cd autoconf-2.69
sed '361 s/{/\\{/' -i bin/autoscan.in
./configure --prefix=/usr
make ## && make check && make install ## The test suite is currently broken by bash-5 and libtool-2.4.3
make install

cd /src
tar -xvf automake-1.16.1.tar.xz && cd automake-1.16.1
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.1
make && make -j4 check && make install

cd /src
tar -xvf xz-5.2.4.tar.xz && cd xz-5.2.4
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/xz-5.2.4
make && make check && make install
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

cd /src
tar -xvf kmod-26.tar.xz && cd kmod-26
./configure --prefix=/usr --bindir=/bin --sysconfdir=/etc --with-rootlibdir=/lib --with-xz --with-zlib
make && make install
for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done
ln -sfv kmod /bin/lsmod


cd /src
tar -xvf gettext-0.20.1.tar.xz && cd gettext-0.20.1
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/gettext-0.20.1
make && make check && make install
chmod -v 0755 /usr/lib/preloadable_libintl.so


cd /src
tar -xvf elfutils-0.177.tar.bz2 && cd elfutils-0.177
./configure --prefix=/usr
make && make check && make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig


cd /src
tar -xvf libffi-3.2.1.tar.gz && cd libffi-3.2.1
sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' -i include/Makefile.in
sed -e '/^includedir/ s/=.*$/=@includedir@/' -e 's/^Cflags: -I${includedir}/Cflags:/' -i libffi.pc.in
./configure --prefix=/usr --disable-static --with-gcc-arch=native
make && make check && make install

cd /src
tar -xvf openssl-1.1.1c.tar.gz && cd openssl-1.1.1c
sed -i '/\} data/s/ =.*$/;\n    memset(\&data, 0, sizeof(data));/' crypto/rand/rand_lib.c
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib shared zlib-dynamic
make && make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1c
cp -vfr doc/* /usr/share/doc/openssl-1.1.1c

cd /src
tar -xvf Python-3.7.4.tar.xz  && cd Python-3.7.4
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi --with-ensurepip=yes
make && make install
chmod -v 755 /usr/lib/libpython3.7m.so
chmod -v 755 /usr/lib/libpython3.so
ln -sfv pip3.7 /usr/bin/pip3
install -v -dm755 /usr/share/doc/python-3.7.4/html
tar --strip-components=1 --no-same-owner --no-same-permissions -C /usr/share/doc/python-3.7.4/html -xvf ../python-3.7.4-docs-html.tar.bz2

cd /src
tar -xvf ninja-1.9.0.tar.gz && cd ninja-1.9.0
export NINJAJOBS=4
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap
./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd /src
tar -xvf meson-0.51.1.tar.gz && cd meson-0.51.1

python3 setup.py build
python3 setup.py install --root=dest
cp -rv dest/* /


cd /src
tar -xvf coreutils-8.31.tar.xz && cd coreutils-8.31
patch -Np1 -i ../coreutils-8.31-i18n-1.patch
sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
sed -i 's/1.15/1.16/g' configure
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --enable-no-install-program=kill,uptime
make
make NON_ROOT_USERNAME=nobody check-root
echo "dummy:x:1000:nobody" >> /etc/group
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
sed -i '/dummy/d' /etc/group
make install
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
mv -v /usr/bin/{head,nice,sleep,touch} /bin

cd /src
tar -xvf check-0.12.0.tar.gz && cd check-0.12.0
./configure --prefix=/usr
make && make check && make docdir=/usr/share/doc/check-0.12.0 install
sed -i '1 s/tools/usr/' /usr/bin/checkmk

cd /src
tar -xvf diffutils-3.7.tar.xz && cd diffutils-3.7
./configure --prefix=/usr
make && make check && make install

cd /src
tar -xvf gawk-5.0.1.tar.xz && cd gawk-5.0.1
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make && make check && make install
mkdir -v /usr/share/doc/gawk-5.0.1
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.0.1

cd /src
tar -xvf findutils-4.6.0.tar.gz && cd findutils-4.6.0
sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h
./configure --prefix=/usr --localstatedir=/var/lib/locate
make && make check && make install
mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

cd /src
tar -xvf groff-1.22.4.tar.gz && cd groff-1.22.4
PAGE=A4 ./configure --prefix=/usr
make -j1 && make install

cd /src
tar -xvf grub-2.04.tar.xz && cd grub-2.04
./configure --prefix=/usr --sbindir=/sbin --sysconfdir=/etc --disable-efiemu --disable-werror
make && make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd /src
tar -xvf gzip-1.10.tar.xz && cd gzip-1.10
./configure --prefix=/usr
make && make check ## two tests fail
make install
mv -v /usr/bin/gzip /bin


cd /src
tar -xvf iproute2-5.2.0.tar.xz && cd iproute2-5.2.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
sed -i 's/.m_ipt.o//' tc/Makefile
make && make DOCDIR=/usr/share/doc/iproute2-5.2.0 install


cd /src
tar -xvf kbd-2.2.0.tar.xz && cd kbd-2.2.0
patch -Np1 -i ../kbd-2.2.0-backspace-1.patch
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
make && make check && make install
mkdir -v       /usr/share/doc/kbd-2.2.0
cp -R -v docs/doc/* /usr/share/doc/kbd-2.2.0

cd /src
tar -xvf libpipeline-1.5.1.tar.gz && cd libpipeline-1.5.1
./configure --prefix=/usr
make && make check && make install


cd /src
tar -xvf make-4.2.1.tar.gz && cd make-4.2.1
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure --prefix=/usr
make
make PERL5LIB=$PWD/tests/ check
make install

cd /src
tar -xvf patch-2.7.6.tar.xz && cd patch-2.7.6
./configure --prefix=/usr
make && make check && make install

cd /src
tar -xvf man-db-2.8.6.1.tar.xz && cd man-db-2.8.6.1
./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.8.6.1 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=           \
            --with-systemdsystemunitdir=
make && make check && make install


cd /src
tar -xvf tar-1.32.tar.xz && cd tar-1.32
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --bindir=/bin
make && make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.32

cd /src
tar -xvf texinfo-6.6.tar.xz && cd texinfo-6.6
./configure --prefix=/usr --disable-static
make && make check
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd

cd /src
tar -xvf vim-8.1.1846.tar.gz && cd vim-8.1.1846
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
chown -Rv nobody .
su nobody -s /bin/bash -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
make install
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim81/doc /usr/share/doc/vim-8.1.1846
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

cd /src
tar -xvf procps-ng-3.3.15.tar.xz && cd procps-ng-3.3.15
./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.15 \
            --disable-static                         \
            --disable-kill
make
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
sed -i '/set tty/d' testsuite/pkill.test/pkill.exp
rm testsuite/pgrep.test/pgrep.exp
make check
make install
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

cd /src
tar -xvf util-linux-2.34.tar.xz && cd util-linux-2.34
mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.34 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir
make
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make -k check"
make install

cd /src
tar -xvf e2fsprogs-1.45.3.tar.gz && cd e2fsprogs-1.45.3
mkdir -v build && cd build/
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make && make check
make install && make install-libs
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd /src
tar -xvf sysklogd-1.5.1.tar.gz && cd sysklogd-1.5.1
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
make
make BINDIR=/sbin install
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

cd /src
tar -xvf sysvinit-2.95.tar.xz && cd sysvinit-2.95
patch -Np1 -i ../sysvinit-2.95-consolidated-1.patch
make && make install

cd /src
tar -xvf eudev-3.2.8.tar.gz && cd eudev-3.2.8
./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static
make
mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d
make check
make install
tar -xvf ../udev-lfs-20171102.tar.xz
make -f udev-lfs-20171102/Makefile.lfs install
udevadm hwdb --update

## Stripping

save_lib="ld-2.30.so libc-2.30.so libpthread-2.30.so libthread_db-1.0.so"

cd /lib

for LIB in $save_lib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.27
             libitm.so.1.0.0 libatomic.so.1.2.0"

cd /usr/lib

for LIB in $save_usrlib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

unset LIB save_lib save_usrlib

exec /tools/bin/bash

/tools/bin/find /usr/lib -type f -name \*.a \
   -exec /tools/bin/strip --strip-debug {} ';'

/tools/bin/find /lib /usr/lib -type f \( -name \*.so* -a ! -name \*dbg \) \
   -exec /tools/bin/strip --strip-unneeded {} ';'

/tools/bin/find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
    -exec /tools/bin/strip --strip-all {} ';'

rm -rf /tmp/*

logout

sudo chroot "$LFS" /usr/bin/env -i          \
    HOME=/root TERM="$TERM"            \
    PS1='(lfs chroot) \u:\w\$ '        \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login

rm -f /usr/lib/lib{bfd,opcodes}.a
rm -f /usr/lib/libbz2.a
rm -f /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -f /usr/lib/libltdl.a
rm -f /usr/lib/libfl.a
rm -f /usr/lib/libz.a
find /usr/lib /usr/libexec -name \*.la -delete

cd /src
tar -xvf lfs-bootscripts-20190524.tar.xz && cd lfs-bootscripts-20190524
make install

cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.2
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

domain <Your Domain Name>
nameserver <IP address of your primary nameserver>
nameserver <IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF

echo "lfs.foo" > /etc/hostname

cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost
127.0.1.1 lfs.foo lfs
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF



cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc S

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF
cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

KEYMAP="pl2"
FONT="lat2a-16 -m 8859-2"

# End /etc/sysconfig/console
EOF

cat /etc/sysconfig/rc.site << "EOF"
# rc.site
# Optional parameters for boot scripts.

# Distro Information
# These values, if specified here, override the defaults
#DISTRO="Linux From Scratch" # The distro name
#DISTRO_CONTACT="lfs-dev@linuxfromscratch.org" # Bug report address
#DISTRO_MINI="LFS" # Short name used in filenames for distro config

# Define custom colors used in messages printed to the screen

# Please consult `man console_codes` for more information
# under the "ECMA-48 Set Graphics Rendition" section
#
# Warning: when switching from a 8bit to a 9bit font,
# the linux console will reinterpret the bold (1;) to
# the top 256 glyphs of the 9bit font.  This does
# not affect framebuffer consoles

# These values, if specified here, override the defaults
#BRACKET="\\033[1;34m" # Blue
#FAILURE="\\033[1;31m" # Red
#INFO="\\033[1;36m"    # Cyan
#NORMAL="\\033[0;39m"  # Grey
#SUCCESS="\\033[1;32m" # Green
#WARNING="\\033[1;33m" # Yellow

# Use a colored prefix
# These values, if specified here, override the defaults
#BMPREFIX="      "
#SUCCESS_PREFIX="${SUCCESS}  *  ${NORMAL} "
#FAILURE_PREFIX="${FAILURE}*****${NORMAL} "
#WARNING_PREFIX="${WARNING} *** ${NORMAL} "

# Manually seet the right edge of message output (characters)
# Useful when resetting console font during boot to override
# automatic screen width detection
#COLUMNS=120

# Interactive startup
#IPROMPT="yes" # Whether to display the interactive boot prompt
#itime="3"    # The amount of time (in seconds) to display the prompt

# The total length of the distro welcome string, without escape codes
#wlen=$(echo "Welcome to ${DISTRO}" | wc -c )
#welcome_message="Welcome to ${INFO}${DISTRO}${NORMAL}"

# The total length of the interactive string, without escape codes
#ilen=$(echo "Press 'I' to enter interactive startup" | wc -c )
#i_message="Press '${FAILURE}I${NORMAL}' to enter interactive startup"

# Set scripts to skip the file system check on reboot
#FASTBOOT=yes

# Skip reading from the console
#HEADLESS=yes

# Write out fsck progress if yes
#VERBOSE_FSCK=no

# Speed up boot without waiting for settle in udev
#OMIT_UDEV_SETTLE=y

# Speed up boot without waiting for settle in udev_retry
#OMIT_UDEV_RETRY_SETTLE=yes

# Skip cleaning /tmp if yes
#SKIPTMPCLEAN=no

# For setclock
#UTC=1
#CLOCKPARAMS=

# For consolelog (Note that the default, 7=debug, is noisy)
#LOGLEVEL=7

# For network
#HOSTNAME=mylfs

# Delay between TERM and KILL signals at shutdown
#KILLDELAY=3

# Optional sysklogd parameters
#SYSKLOGD_PARMS="-m 0"

# Console parameters
#UNICODE=1
#KEYMAP="de-latin1"
#KEYMAP_CORRECTIONS="euro2"
#FONT="lat0-16 -m 8859-15"
#LEGACY_CHARSET=

EOF

mkdir -pv /etc/profile.d

cat > /etc/profile << "EOF"
# Begin /etc/profile

export LANG=en_US.UTF-8

for i in /etc/profile.d/*.sh /etc/profile.d/sh.local ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then
            . "$i"
        else
            . "$i" >/dev/null
        fi
    fi
done


# End /etc/profile
EOF

echo -e "#Add any required envvar overrides to this file, it is sourced from /etc/profile" > /etc/profile.d/sh.local

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/sda1      /boot        ext4     defaults            0     0
/dev/sda2      /            ext4     defaults            1     1
# /dev/<yyy>     swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF

## http://www.linuxfromscratch.org/hints/downloads/files/lfs-uefi.txt

curl -kO https://curl.haxx.se/download/curl-7.67.0.tar.xz
cd /src
tar -xvf curl-7.67.0.tar.xz && cd curl-7.67.0
./configure --prefix=/usr                           \
            --disable-static                        \
            --enable-threaded-resolver              \
            --with-ca-path=/etc/ssl/certs &&
make
make test
make install &&
rm -rf docs/examples/.deps &&
find docs \( -name Makefile\* -o -name \*.1 -o -name \*.3 \) -exec rm {} \; &&
install -v -d -m755 /usr/share/doc/curl-7.67.0 &&
cp -v -R docs/*     /usr/share/doc/curl-7.67.0


cd /src
tar -xvf cpio-2.13.tar.bz2 && cd cpio-2.13
./configure --prefix=/usr \
            --bindir=/bin \
            --enable-mt   \
            --with-rmt=/usr/libexec/rmt &&
make &&
makeinfo --html            -o doc/html      doc/cpio.texi &&
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi &&
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi
make install &&
install -v -m755 -d /usr/share/doc/cpio-2.13/html &&
install -v -m644    doc/html/* \
                    /usr/share/doc/cpio-2.13/html &&
install -v -m644    doc/cpio.{html,txt} \
                    /usr/share/doc/cpio-2.13


cd /src
tar -xvf linux-5.2.8.tar.xz && cd linux-5.2.8
make mrproper  ## left off
make defconfig
cp -iv cp ../kernel-5.2.8-x86_64.config .config
make menuconfig
make
make modules_install
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.2.8-lfs-9.0
cp -iv System.map /boot/System.map-5.2.8
cp -iv .config /boot/config-5.2.8
install -d /usr/share/doc/linux-5.2.8
cp -vr Documentation/* /usr/share/doc/linux-5.2.8

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF


cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,1)

menuentry "GNU/Linux, Linux 5.2.8-lfs-9.0" {
        linux   (hd0,1)/vmlinuz-5.2.8-lfs-9.0 root=/dev/sda2 ro
}

EOF

echo "Linux From Scratch willful-squirrel 9.0" > /etc/issue

echo 9.0 > /etc/lfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="9.0"
DISTRIB_CODENAME="willful-squirrel"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /usr/libexec/grepconf.sh << "EOF"
#!/bin/sh

case "$1" in
    -c | --interactive-color)
        ! grep -qsi "^COLOR.*none" /etc/GREP_COLORS
        ;;
    *)
        echo >&2 "Invalid / no option passed, so far only -c | --interactive-color is supported."
        exit 1
        ;;
esac

EOF

chmod +x /usr/libexec/grepconf.sh


