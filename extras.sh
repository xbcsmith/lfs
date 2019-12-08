#!/bin/bash

umask 022
LFS=/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH

cd /src
tar -xvf which-2.21.tar.gz && cd which-2.21
./configure --prefix=/usr &&
make
make install

cd /src
tar -xvf tcl8.6.10-src.tar.gz && cd tcl8.6.10
tar -xvf ../tcl8.6.10-html.tar.gz --strip-components=1
export SRCDIR=`pwd` &&

cd unix &&

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            $([ $(uname -m) = x86_64 ] && echo --enable-64bit) &&
make &&

sed -e "s#$SRCDIR/unix#/usr/lib#" \
    -e "s#$SRCDIR#/usr/include#"  \
    -i tclConfig.sh               &&

sed -e "s#$SRCDIR/unix/pkgs/tdbc1.1.1#/usr/lib/tdbc1.1.1#" \
    -e "s#$SRCDIR/pkgs/tdbc1.1.1/generic#/usr/include#"    \
    -e "s#$SRCDIR/pkgs/tdbc1.1.1/library#/usr/lib/tcl8.6#" \
    -e "s#$SRCDIR/pkgs/tdbc1.1.1#/usr/include#"            \
    -i pkgs/tdbc1.1.1/tdbcConfig.sh                        &&

sed -e "s#$SRCDIR/unix/pkgs/itcl4.2.0#/usr/lib/itcl4.2.0#" \
    -e "s#$SRCDIR/pkgs/itcl4.2.0/generic#/usr/include#"    \
    -e "s#$SRCDIR/pkgs/itcl4.2.0#/usr/include#"            \
    -i pkgs/itcl4.2.0/itclConfig.sh                        &&

unset SRCDIR

make install &&
make install-private-headers &&
ln -v -sf tclsh8.6 /usr/bin/tclsh &&
chmod -v 755 /usr/lib/libtcl8.6.so

mkdir -v -p /usr/share/doc/tcl-8.6.10 &&
cp -v -r  ../html/* /usr/share/doc/tcl-8.6.10

cd /src
tar -xvf sharutils-4.15.2.tar.xz && cd sharutils-4.15.2
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c        &&
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h &&

./configure --prefix=/usr &&
make
make check
make install

cd /src
tar -xvf db-5.3.28.tar.gz && cd db-5.3.28
sed -i 's/\(__atomic_compare_exchange\)/\1_db/' src/dbinc/atomic.h
cd build_unix                        &&
../dist/configure --prefix=/usr      \
                  --enable-compat185 \
                  --enable-dbm       \
                  --disable-static   \
                  --enable-cxx       &&
make
make docdir=/usr/share/doc/db-5.3.28 install &&
chown -v -R root:root                        \
      /usr/bin/db_*                          \
      /usr/include/db{,_185,_cxx}.h          \
      /usr/lib/libdb*.{so,la}                \
      /usr/share/doc/db-5.3.28

cd /src
tar -xvf libxml2-2.9.10.tar.gz && cd libxml2-2.9.10
sed -i 's/test.test/#&/' python/tests/tstLastError.py
./configure --prefix=/usr    \
            --disable-static \
            --with-history   \
            --with-python=/usr/bin/python3 &&
make
tar xf ../xmlts20130923.tar.gz
## Optional
# wget http://www.w3.org/XML/Test/xmlts20130923.tar.gz
# tar xf ../xmlts20130923.tar.gz
# make check > check.log && grep -E '^Total|expected' check.log
make install


cd /src
tar -xvf libusb-1.0.23.tar.bz2 && cd libusb-1.0.23
sed -i "s/^PROJECT_LOGO/#&/" doc/doxygen.cfg.in &&

./configure --prefix=/usr --disable-static &&
make -j1
make install

cd /src
tar -xvf libtasn1-4.15.0.tar.gz && cd libtasn1-4.15.0
./configure --prefix=/usr --disable-static &&
make
make install
make -C doc/reference install-data-local

cd /src
tar -xvf p11-kit-0.23.18.1.tar.gz && cd p11-kit-0.23.18.1
sed '20,$ d' -i trust/trust-extract-compat.in &&
cat >> trust/trust-extract-compat.in << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Generate a new trust store
/usr/sbin/make-ca -f -g
EOF
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --with-trust-paths=/etc/pki/anchors &&
make
make install &&
ln -sfv /usr/libexec/p11-kit/trust-extract-compat \
        /usr/bin/update-ca-certificates
ln -sfv ./pkcs11/p11-kit-trust.so /usr/lib/libnssckbi.so

cd /src
tar -xvf make-ca-1.5.tar.xz && cd make-ca-1.5
make install &&
install -vdm755 /etc/ssl/local


cd /src
tar -xvf wget-1.20.3.tar.gz && cd wget-1.20.3
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl &&
make
make check
make install

cd /src
tar -xvf nettle-3.5.1.tar.gz && cd nettle-3.5.1
./configure --prefix=/usr --disable-static &&
make
make install &&
chmod   -v   755 /usr/lib/lib{hogweed,nettle}.so &&
install -v -m755 -d /usr/share/doc/nettle-3.5.1 &&
install -v -m644 nettle.html /usr/share/doc/nettle-3.5.1

cd /src
tar -xvf libunistring-0.9.10.tar.xz && cd libunistring-0.9.10
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libunistring-0.9.10 &&
make
make install

cd /src
tar -xvf gnutls-3.6.11.1.tar.xz && cd gnutls-3.6.11.1
./configure --prefix=/usr \
            --docdir=/usr/share/doc/gnutls-3.6.11.1 \
            --disable-guile \
            --with-default-trust-store-pkcs11="pkcs11:" &&
make
make install
make -C doc/reference install-data-local


cd /src
tar -xvf curl-7.67.0.tar.xz && cd curl-7.67.0
./configure --prefix=/usr                           \
            --disable-static                        \
            --enable-threaded-resolver              \
            --with-ca-path=/etc/ssl/certs &&
make
make install &&
rm -rf docs/examples/.deps &&
find docs \( -name Makefile\* -o -name \*.1 -o -name \*.3 \) -exec rm {} \; &&
install -v -d -m755 /usr/share/doc/curl-7.67.0 &&
cp -v -R docs/*     /usr/share/doc/curl-7.67.0


cd /src
tar -xvf libuv-v1.34.0.tar.gz && cd libuv-v1.34.0
sh autogen.sh                              &&
./configure --prefix=/usr --disable-static &&
make
make check
make install

cd /src
tar -xvf lzo-2.10.tar.gz && cd lzo-2.10
./configure --prefix=/usr                    \
            --enable-shared                  \
            --disable-static                 \
            --docdir=/usr/share/doc/lzo-2.10 &&
make
make check
make install


cd /src
tar -xvf libarchive-3.4.0.tar.gz && cd libarchive-3.4.0
./configure --prefix=/usr --disable-static &&
make
LC_ALL=C make check
make install

cd /src
tar -xvf zstd-1.4.4.tar.gz && cd zstd-1.4.4
make
make check
make install


cd /src
tar -xvf cmake-3.16.0.tar.gz && cd cmake-3.16.0
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&
./bootstrap --prefix=/usr        \
            --system-libs        \
            --mandir=/share/man  \
            --no-system-jsoncpp  \
            --no-system-librhash \
            --docdir=/share/doc/cmake-3.16.0 &&
make
bin/ctest -j2 -O cmake-3.16.0-test.log
make install


## Need Internet

wget http://www.cacert.org/certs/root.crt &&
wget http://www.cacert.org/certs/class3.crt &&
openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
        -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
        > /etc/ssl/local/CAcert_Class_1_root.pem &&
openssl x509 -in class3.crt -text -fingerprint -setalias "CAcert Class 3 root" \
        -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
        > /etc/ssl/local/CAcert_Class_3_root.pem &&
/usr/sbin/make-ca -r -f

