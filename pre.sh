#!/bin/bash

cd /lfs/src
tar -Jxvf binutils-2.32.tar.xz
cd binutils-2.32
mkdir build
cd build
../configure --prefix=/tools --with-sysroot=/lfs --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror
make
case $(uname -m) in   x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;; esac
make install

cd /lfs/src
tar -xvf gcc-9.2.0.tar.xz
cd gcc-9.2.0
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
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

make
make install

cd /lfs/src
tar -xvf linux-5.2.8.tar.xz
cd linux-5.2.8
make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

cd /lfs/src/
tar -xvf glibc-2.30.tar.xz
cd glibc-2.30
mkdir build
cd build
../configure --prefix=/tools --host=$LFS_TGT --build=$(../scripts/config.guess) --enable-kernel=3.2 --with-headers=/tools/include
make
make install

cd /tools
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'
rm dummy.c a.out


cd /lfs/src
cd gcc-9.2.0
rm -rf build
mkdir -v build
cd build/
../libstdc++-v3/configure --host=$LFS_TGT --prefix=/tools --disable-multilib --disable-nls --disable-libstdcxx-threads --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/9.2.0
make
make install



