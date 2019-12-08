#!/bin/bash

mkdir -p /lfs/src/extras
pushd /lfs/src/extras
wget https://github.com/cracklib/cracklib/releases/download/v2.9.7/cracklib-2.9.7.tar.bz2
echo "0d68de25332cee5660850528a385427f cracklib-2.9.7.tar.bz2" > extra.md5sums
wget https://github.com/cracklib/cracklib/releases/download/v2.9.7/cracklib-words-2.9.7.bz2
echo "94e9963e4786294f7fb0f2efd7618551 cracklib-words-2.9.7.bz2" >> extra.md5sums
wget https://ftp.gnu.org/gnu/which/which-2.21.tar.gz
echo "097ff1a324ae02e0a3b0369f07a7544a which-2.21.tar.gz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/cpio/cpio-2.13.tar.bz2
echo "f3438e672e3fa273a7dc26339dd1eed6 cpio-2.13.tar.bz2" >> extra.md5sums
wget https://github.com//libusb/libusb/releases/download/v1.0.23/libusb-1.0.23.tar.bz2
echo "1e29700f6a134766d32b36b8d1d61a95 libusb-1.0.23.tar.bz2" >> extra.md5sums
wget https://github.com/p11-glue/p11-kit/releases/download/0.23.18.1/p11-kit-0.23.18.1.tar.gz
echo "79480c3a2c905a74f86e885966148537 p11-kit-0.23.18.1.tar.gz" >> extra.md5sums
wget https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1.tar.xz
echo "558ff53b0fc0563ca97f79e911822165 Linux-PAM-1.3.1.tar.xz" >> extra.md5sums
wget https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1-docs.tar.xz
echo "1885fae049acd1b699a5459d7c4a0130 Linux-PAM-1.3.1-docs.tar.xz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/sharutils/sharutils-4.15.2.tar.xz
echo "5975ce21da36491d7aa6dc2b0d9788e0 sharutils-4.15.2.tar.xz" >> extra.md5sums
wget http://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz
echo "b99454564d5b4479750567031d66fe24 db-5.3.28.tar.gz" >> extra.md5sums
wget https://github.com/djlucas/make-ca/releases/download/v1.5/make-ca-1.5.tar.xz
echo "0d50d9e0c9ebd6059fe4116353f2d5be make-ca-1.5.tar.xz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/wget/wget-1.20.3.tar.gz
echo "db4e6dc7977cbddcd543b240079a4899 wget-1.20.3.tar.gz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.15.0.tar.gz
echo "33e3fb5501bb2142184238c815b0beb8 libtasn1-4.15.0.tar.gz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/nettle/nettle-3.5.1.tar.gz
echo "0e5707b418c3826768d41130fbe4ee86 nettle-3.5.1.tar.gz" >> extra.md5sums
wget https://www.gnupg.org/ftp/gcrypt/gnutls/v3.6/gnutls-3.6.11.1.tar.xz
echo "3670ee0b0d95b3dee185eff2dc910ee7 gnutls-3.6.11.1.tar.xz" >> extra.md5sums
wget https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.15.0.tar.gz
echo "33e3fb5501bb2142184238c815b0beb8 libtasn1-4.15.0.tar.gz" >> extra.md5sums
wget https://c-ares.haxx.se/download/c-ares-1.15.0.tar.gz
echo "d2391da274653f7643270623e822dff7 c-ares-1.15.0.tar.gz" >> extra.md5sums
wget https://curl.haxx.se/download/curl-7.67.0.tar.xz
echo "d55351b88dec558dd3a24dabb2c2d899 curl-7.67.0.tar.xz" >> extra.md5sums
wget https://dist.libuv.org/dist/v1.34.0/libuv-v1.34.0.tar.gz
echo "811ebe06c326e788ac7adf062328f3f1 libuv-v1.34.0.tar.gz" >> extra.md5sums
wget https://github.com/google/brotli/archive/v1.0.7/brotli-v1.0.7.tar.gz
echo "7b6edd4f2128f22794d0ca28c53898a5 brotli-v1.0.7.tar.gz" >> extra.md5sums
wget https://downloads.sourceforge.net/tcl/tcl8.6.10-src.tar.gz
echo "97c55573f8520bcab74e21bfd8d0aadc tcl8.6.10-src.tar.gz" >> extra.md5sums
wget https://downloads.sourceforge.net/tcl/tcl8.6.10-html.tar.gz
echo "a012711241ba3a5bd4a04e833001d489 tcl8.6.10-html.tar.gz" >> extra.md5sums
wget http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz
echo "10942a1dc23137a8aa07f0639cbfece5 libxml2-2.9.10.tar.gz" >> extra.md5sums
https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.10.tar.xz
echo "db08bb384e81968957f997ec9808926e libunistring-0.9.10.tar.xz" >> extra.md5sums
wget https://cmake.org/files/v3.16/cmake-3.16.0.tar.gz
echo "a38cb4d547ca79f8a1b8211be41790b1 cmake-3.16.0.tar.gz" >> extra.md5sums
wget https://github.com/libarchive/libarchive/releases/download/v3.4.0/libarchive-3.4.0.tar.gz
echo "6046396255bd7cf6d0f6603a9bda39ac libarchive-3.4.0.tar.gz" >> extra.md5sums
wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
echo "39d3f3f9c55c87b1e5d6888e1420f4b5 lzo-2.10.tar.gz" >> extra.md5sums
wget https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.gz
echo "487f7ee1562dee7c1c8adf85e2a63df9 zstd-1.4.4.tar.gz" >> extra.md5sums

md5sum -c extra.md5sums
popd
