#!/bin/bash

cd /lfs/src
tar -xvf binutils-2.32.tar.xz
cd binutils-2.32

mkdir build
cd build
CC=$LFS_TGT-gcc AR=$LFS_TGT-ar RANLIB=$LFS_TGT-ranlib ../configure --prefix=/tools --disable-nls --disable-werror --with-lib-path=/tools/lib --with-sysroot
make
make install
make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin


cd /lfs/src
rm -rf gcc-9.2.0
tar -xvf gcc-9.2.0.tar.xz
cd gcc-9.2.0
cat gcc/limitx.h gcc/glimits.h gcc/limity.h >   `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in gcc/config/{linux,i386/linux{,64}}.h; do
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


cd /tools
echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'
rm -v dummy.c a.out

cd /lfs/src/
tar -xvf tcl8.6.9-src.tar.gz
cd tcl8.6.9/unix/
./configure --prefix=/tools
make
TZ=UTC make test
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh


cd /lfs/src/
tar -xvf expect5.45.4.tar.gz
cd expect5.45.4
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=/tools --with-tcl=/tools/lib --with-tclinclude=/tools/include
make
make test
make SCRIPTS="" install

cd /lfs/src/
tar -xvf dejagnu-1.6.2.tar.gz
cd dejagnu-1.6.2
./configure --prefix=/tools
make install
make check

cd /lfs/src/
tar -xvf m4-1.4.18.tar.xz
cd m4-1.4.18
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure --prefix=/tools
make
make check
make install

cd /lfs/src/
tar -xvf ncurses-6.1.tar.gz
cd ncurses-6.1
sed -i s/mawk// configure
./configure --prefix=/tools --with-shared --without-debug --without-ada --enable-widec --enable-overwrite
make
make install
ln -s libncursesw.so /tools/lib/libncurses.so


cd /lfs/src/
tar -xvf bash-5.0.tar.gz
cd bash-5.0
./configure --prefix=/tools --without-bash-malloc
make
make tests && make install
ln -sv bash /tools/bin/sh

cd /lfs/src/
tar -xvf bison-3.4.1.tar.xz
cd bison-3.4.1
./configure --prefix=/tools
make && make check && make install

cd /lfs/src/
tar -xvf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
make
make PREFIX=/tools install

cd /lfs/src/
tar -xvf coreutils-8.31.tar.xz
cd coreutils-8.31
./configure --prefix=/tools --enable-install-program=hostname
make
make RUN_EXPENSIVE_TESTS=yes check
make install

cd /lfs/src/
tar -xvf diffutils-3.7.tar.xz
cd diffutils-3.7
./configure --prefix=/tools
make && make check && make install

cd /lfs/src/
tar -xvf file-5.37.tar.gz
cd file-5.37
./configure --prefix=/tools
make && make check && make install

cd /lfs/src/
tar -xvf findutils-4.6.0.tar.gz
cd findutils-4.6.0
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h
./configure --prefix=/tools && make && make check && make install

cd /lfs/src/
tar -xvf gawk-5.0.1.tar.xz
cd gawk-5.0.1
./configure --prefix=/tools && make && make check && make install
make install

cd /lfs/src/
tar -xvf gettext-0.20.1.tar.xz
cd gettext-0.20.1
./configure --disable-shared
make

cd /lfs/src/
tar -xvf grep-3.3.tar.xz
cd grep-3.3
./configure --prefix=/tools && make && make check && make install

cd /lfs/src/
tar -xvf gzip-1.10.tar.xz
cd gzip-1.10
./configure --prefix=/tools && make && make check && make install

cd /lfs/src/
tar -xvf make-4.2.1.tar.gz
cd make-4.2.1
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure --prefix=/tools --without-guile
make && make check && make install


cd /lfs/src/
tar -xvf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/tools && make && make check && make install

cd /lfs/src/
tar -xvf perl-5.30.0.tar.xz
cd perl-5.30.0
sh Configure -des -Dprefix=/tools -Dlibs=-lm -Uloclibpth -Ulocincpth
make
cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.30.0
cp -Rv lib/* /tools/lib/perl5/5.30.0

cd /lfs/src/
tar -xvf Python-3.7.4.tar.xz
cd Python-3.7.4
sed -i '/def add_multiarch_paths/a \        return' setup.py
./configure --prefix=/tools --without-ensurepip
make
make install

cd /lfs/src/
tar -xvf sed-4.7.tar.xz
cd sed-4.7
./configure --prefix=/tools && make && make check && make install
make install

cd /lfs/src/
tar -xvf tar-1.32.tar.xz
cd tar-1.32
./configure --prefix=/tools && make && make check && make install

cd /lfs/src/
tar -xvf texinfo-6.6.tar.xz
cd texinfo-6.6
./configure --prefix=/tools && make && make check && make install

cd /lfs/src/
tar -xvf xz-5.2.4.tar.xz
cd xz-5.2.4
./configure --prefix=/tools && make && make check && make install

cd /lfs/src/
strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
find /tools/{lib,libexec} -name \*.la -delete


cd /lfs/
tar -zcvf lfs-tools.tar.gz tools/


