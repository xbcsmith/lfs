FROM ubuntu:bionic

RUN apt-get -y update \
    && apt-get -y install \
        sudo \
        bash \
        curl \
        wget \
        gawk \
        build-essential \
        devscripts \
        fakeroot \
        debhelper \
        dpkg-dev \
        automake \
        autotools-dev \
        autoconf \
        libtool \
        perl \
        libperl-dev \
        systemtap-sdt-dev \
        libssl-dev \
        python-dev \
        python3-dev \
        m4 \
        bison \
        flex \
        opensp \
        xsltproc \
        gettext \
        unzip \
        virtualenvwrapper \
        python3-virtualenv \
        openjdk-8-jre-headless \
        openjdk-8-jdk-headless \
        pkg-config \
        texinfo \
        zip

RUN groupadd lfs && useradd -s /bin/bash -g lfs -G sudo -m -k /dev/null lfs
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV MAKEFLAGS="-j 2"
ENV LFS=/lfs

RUN mkdir -p $LFS/tools && chown -v lfs $LFS/tools

COPY bootstrap.sh /lfs/bootstrap.sh

RUN chmod +x /lfs/bootstrap.sh && /lfs/bootstrap.sh && chown -R lfs:lfs /lfs

USER lfs

RUN cd /lfs && ./src/version-check.sh && cp ./src/bashrc /home/lfs/.bashrc && cp ./src/bash_profile /home/lfs/.bash_profile



