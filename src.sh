#!/bin/bash

SRC=$(pwd)/src
mkdir -p $SRC
pushd $SRC
curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/md5sums
curl -kO http://www.linuxfromscratch.org/lfs/downloads/stable/wget-list
wget --input-file=wget-list --continue
md5sum -c md5sums
popd

