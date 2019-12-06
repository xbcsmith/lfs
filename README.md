# LFS

## Bootstrap

```bash
./bootstrap.sh
```

## Toolchain

### Pre

```bash
umask 022
LFS=/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
```

### binutils

```bash
cd /lfs/src
tar -xvf binutils-2.32.tar.xz && cd binutils-2.32
mkdir build
cd build
../configure --prefix=/tools --with-sysroot=/lfs --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror
make
case $(uname -m) in   x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;; esac
make install
cd /lfs/src
```

### GCC

```bash 
cd /lfs/src
tar -xvf gcc-9.2.0.tar.xz && cd gcc-9.2.0
tar -xvf ../mpfr-4.0.2.tar.xz
mv -v mpfr-4.0.2 mpfr
tar -xvf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xvf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
 ;;
esac

make
make install
```

### linux-5.2.8 API Headers

```bash
cd /lfs/src
tar -xvf linux-5.2.8.tar.xz && cd linux-5.2.8
make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include
```

### glibc-2.3.0

```bash
cd /lfs/src/
tar -xvf glibc-2.30.tar.xz && cd glibc-2.30
mkdir build
cd build
../configure --prefix=/tools --host=$LFS_TGT --build=$(../scripts/config.guess) --enable-kernel=3.2 --with-headers=/tools/include
make
make install
```

#### Test

```bash
cd /tools
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c 
readelf -l a.out | grep ': /tools'
rm dummy.c a.out 
cd -
```

### Libstdc++ from GCC-9.2.0

```bash
cd /lfs/src/gcc-9.2.0
rm -rf build
mkdir -v build
cd build/
../libstdc++-v3/configure --host=$LFS_TGT --prefix=/tools --disable-multilib --disable-nls --disable-libstdcxx-threads --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/9.2.0
make
make install
```

## Pass 2

### Binutils

```bash
cd /lfs/src/
rm -rf binutils-2.32
tar -xvf binutils-2.32.tar.xz && cd binutils-2.32
mkdir build
cd build
CC=$LFS_TGT-gcc AR=$LFS_TGT-ar RANLIB=$LFS_TGT-ranlib ../configure --prefix=/tools --disable-nls --disable-werror --with-lib-path=/tools/lib --with-sysroot
make
make install
make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin
```

### GCC

```bash
cd /lfs/src
rm -rf gcc-9.2.0
tar -xvf gcc-9.2.0.tar.xz && cd gcc-9.2.0
cat gcc/limitx.h gcc/glimits.h gcc/limity.h >   `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in gcc/config/{linux,i386/linux{,64}}.h; dp
    cp -uv $file{,.orig};
    sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' -e 's@/usr@/tools@g' $file.orig > $file;
    echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file;
    touch $file.orig;
done

case $(uname -m) in
 x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64;
 ;;
esac

tar -xvf ../mpfr-4.0.2.tar.xz
mv -v mpfr-4.0.2 mpfr
tar -xvf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xvf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc
rm -rvf build/
mkdir -v build
cd       build
CC=$LFS_TGT-gcc CXX=$LFS_TGT-g++ AR=$LFS_TGT-ar RANLIB=$LFS_TGT-ranlib ../configure --prefix=/tools --with-local-prefix=/tools --with-native-system-header-dir=/tools/include --enable-languages=c,c++ --disable-libstdcxx-pch --disable-multilib --disable-bootstrap --disable-libgomp
make
make install
ln -sv gcc /tools/bin/cc
```

#### Test

```bash
cd /tools
echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'
rm -v dummy.c a.out
```

### Tcl

```bash
cd /lfs/src/
tar -xvf tcl8.6.9-src.tar.gz && cd tcl8.6.9/unix/
./configure --prefix=/tools
make
TZ=UTC make test
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh
```

### Expect

```bash
cd /lfs/src/
tar -xvf expect5.45.4.tar.gz && cd expect5.45.4
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools --with-tcl=/tools/lib --with-tclinclude=/tools/include
make
make test
make SCRIPTS="" install
```

### dejagnu

```bash
cd /lfs/src/
tar -xvf dejagnu-1.6.2.tar.gz && cd dejagnu-1.6.2
./configure --prefix=/tools
make install
make check
```

### m4

```bash
cd /lfs/src/
tar -xvf m4-1.4.18.tar.xz && cd m4-1.4.18
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure --prefix=/tools
make
make check
make install
```

### ncurses

```bash
cd /lfs/src/
tar -xvf ncurses-6.1.tar.gz && cd ncurses-6.1
sed -i s/mawk// configure
./configure --prefix=/tools --with-shared --without-debug --without-ada --enable-widec --enable-overwrite
make
make install
ln -s libncursesw.so /tools/lib/libncurses.so
```


### Bash

```bash
cd /lfs/src/
tar -xvf bash-5.0.tar.gz && cd bash-5.0
./configure --prefix=/tools --without-bash-malloc
make 
make tests && make install
ln -sv bash /tools/bin/sh
```

### bison

```bash
cd /lfs/src/
tar -xvf bison-3.4.1.tar.xz && cd bison-3.4.1
./configure --prefix=/tools
make && make check && make install
```

### bzip2

```bash
cd /lfs/src/
tar -xvf bzip2-1.0.8.tar.gz && cd bzip2-1.0.8
make
make PREFIX=/tools install
```

### coreutils

```bash
cd /lfs/src/
tar -xvf coreutils-8.31.tar.xz && cd coreutils-8.31
./configure --prefix=/tools --enable-install-program=hostname
make
make RUN_EXPENSIVE_TESTS=yes check
make install
```

### diffutils

```bash
cd /lfs/src/
tar -xvf diffutils-3.7.tar.xz && cd diffutils-3.7
./configure --prefix=/tools
make && make check && make install
```

### file

```bash
cd /lfs/src/
tar -xvf file-5.37.tar.gz && cd file-5.37
./configure --prefix=/tools
make && make check && make install
```

### findutils

```bash
cd /lfs/src/
tar -xvf findutils-4.6.0.tar.gz && cd findutils-4.6.0
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h
./configure --prefix=/tools && make && make check && make install
```

### gawk

```bash
cd /lfs/src/
tar -xvf gawk-5.0.1.tar.xz && cd gawk-5.0.1
./configure --prefix=/tools && make && make check && make install
#### Tests fail install anyway ####
make install
```

### gettext

```bash
cd /lfs/src/
tar -xvf gettext-0.20.1.tar.xz && cd gettext-0.20.1
./configure --disable-shared
make && make check
make install
```

### grep 

```bash
cd /lfs/src/
tar -xvf grep-3.3.tar.xz && cd grep-3.3
./configure --prefix=/tools && make && make check && make install
``` 
 
### gzip

```bash
cd /lfs/src/
tar -xvf gzip-1.10.tar.xz && cd gzip-1.10
./configure --prefix=/tools && make && make check && make install
```

### make

```bash
cd /lfs/src/
tar -xvf make-4.2.1.tar.gz && cd make-4.2.1
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure --prefix=/tools --without-guile
make && make check && make install
```

### patch

```bash
cd /lfs/src/
tar -xvf patch-2.7.6.tar.xz && cd patch-2.7.6
./configure --prefix=/tools && make && make check && make install
```

### perl

```bash
cd /lfs/src/
tar -xvf perl-5.30.0.tar.xz && cd perl-5.30.0
sh Configure -des -Dprefix=/tools -Dlibs=-lm -Uloclibpth -Ulocincpth
make
cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.30.0
cp -Rv lib/* /tools/lib/perl5/5.30.0
```

### python

```bash
cd /lfs/src/
tar -xvf Python-3.7.4.tar.xz && cd Python-3.7.4
sed -i '/def add_multiarch_paths/a \        return' setup.py
./configure --prefix=/tools --without-ensurepip
make
make install
```

### sed

```bash
cd /lfs/src/
tar -xvf sed-4.7.tar.xz && cd sed-4.7
./configure --prefix=/tools && make && make check && make install
make install
```

### tar

```bash
cd /lfs/src/
tar -xvf tar-1.32.tar.xz && cd tar-1.32
./configure --prefix=/tools && make && make check && make install
```

### texinfo

```bash
cd /lfs/src/
tar -xvf texinfo-6.6.tar.xz && cd texinfo-6.6
./configure --prefix=/tools && make && make check && make install
```

### xz

```bash
cd /lfs/src/
tar -xvf xz-5.2.4.tar.xz && cd xz-5.2.4
./configure --prefix=/tools && make && make check && make install
```

### Strip

```bash
cd /lfs/src/
strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
find /tools/{lib,libexec} -name \*.la -delete
```

### Archive Tools

```bash
cd /lfs/
tar -zcvf lfs-tools.tar.gz tools/
```

## LFS

### Prep SD card


#### sfdisk

```bash
sudo sfdisk --dump /dev/sdd > sdd.dump
cat sdd.dump
cat sdd.dump | sudo sfdisk /dev/sdd
```

#### parted

```bash
sudo parted --script /dev/sdd \
mklabel gpt \
mkpart primary ext4 1MiB 100MiB \
mkpart primary ext4 100MiB 3200MB 
```

### Setup

```bash
export LFS=$HOME/lfs/build
```

#### Mount main filesytems

```bash
mkdir $LFS
sudo mount /dev/sdd2 $LFS
sudo mkdir $LFS/boot
sudo mount /dev/sdd1 $LFS/boot/
```

#### Mount devs

```bash
sudo mkdir -pv $LFS/{dev,proc,sys,run}
sudo mknod -m 600 $LFS/dev/console c 5 1
sudo mknod -m 666 $LFS/dev/null c 1 3
sudo mount -v --bind /dev $LFS/dev
sudo mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
sudo mount -vt proc proc $LFS/proc
sudo mount -vt sysfs sysfs $LFS/sys
sudo mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
  sudo mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi
```

#### Tools and Source

```bash
cd $LFS
sudo tar -xvf ../lfs-tools.tar.gz 
sudo tar -xvf ../lfs-sources.tar.gz
```

#### Login

```bash
sudo chroot "$LFS" /tools/bin/env -i HOME=/root TERM="$TERM" PS1='(lfs chroot) \u:\w\$ ' PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin /tools/bin/bash --login +h
```

#### Make Directories

```bash
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
```

```bash
case $(uname -m) in
 x86_64) mkdir -v /lib64 ;;
esac
```

```bash
mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}
```

```bash
ln -sv /tools/bin/{bash,cat,chmod,dd,echo,ln,mkdir,pwd,rm,stty,touch} /bin
ln -sv /tools/bin/{env,install,perl,printf}         /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1}                  /usr/lib
ln -sv /tools/lib/libstdc++.{a,so{,.6}}             /usr/lib

ln -sv bash /bin/sh

ln -sv /proc/self/mounts /etc/mtab
```

#### Passwd and Group

```bash
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false

EOF
```

```bash
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
```

#### Re Login

```bash
exec /tools/bin/bash --login +h
```

#### Adjustments

```bash
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp
```

### Start Building LFS

```bash
./lfs.sh
```

#### Carefully install grub on SD card

```bash
mount | grep sd
grub-install /dev/sdd
```

#### Logout and umount

```bash
logout
```

```bash
sudo umount -v $LFS/dev/pts
sudo umount -v $LFS/dev
sudo umount -v $LFS/run
sudo umount -v $LFS/proc
sudo umount -v $LFS/sys
sudo umount $LFS/boot
sudo umount $LFS
```


### Archive

```
sudo dd if=/dev/sdd of=lfs-9.0-x86_64.img bs=2M status=progress
```




