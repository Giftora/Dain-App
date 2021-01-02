FROM nvidia/cuda:11.1-cudnn8-devel-ubuntu20.04

RUN apt-get update && apt-get install -y \
        gcc-9 \
        g++-9 &&\
        rm /usr/bin/gcc && rm /usr/bin/g++ && \
        ln -s /usr/bin/gcc-9 /usr/bin/gcc && ln -s /usr/bin/g++-9 /usr/bin/g++ && \
        rm -rf /var/lib/apt/lists/* 

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Berlin" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && apt-get install -y \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install -y  \
        # DAIN App dependancys
        python3.8 \
        # ffmpeg dependencys 
        autoconf \
        automake \
        build-essential \
        cmake \
        git-core \
        libass-dev \
        libfreetype6-dev \
        libgnutls28-dev \
        libsdl2-dev \
        libtool \
        libva-dev \
        libvdpau-dev \
        libvorbis-dev \
        libxcb1-dev \
        libxcb-shm0-dev \
        libxcb-xfixes0-dev \
        pkg-config \
        texinfo \
        wget \
        yasm \
        zlib1g-dev \
        unzip \
        libnuma1 \
        libnuma-dev &&\
        rm -rf /var/lib/apt/lists/* 

RUN apt-get update && apt-get install -y \
        gcc-8 \
        g++-8 &&\
        rm /usr/bin/gcc && rm /usr/bin/g++ && \
        ln -s /usr/bin/gcc-8 /usr/bin/gcc && ln -s /usr/bin/g++-8 /usr/bin/g++ 

WORKDIR /tmp
# ffmpeg compile
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && make install && cd - && \
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/


RUN cd ffmpeg && \
    sed -i 's/compute_30/compute_35/' configure && sed -i 's/sm_30/sm_35/' configure &&\
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure \
        --enable-cuda-nvcc \
        --enable-cuda-llvm \
        --enable-cuda \
        --enable-filter=thumbnail_cuda \
        --enable-cuvid \
        --enable-nvenc \
        --enable-nonfree \
        --enable-libnpp  \
        --extra-cflags=-I/usr/local/cuda/include  \
        --extra-ldflags=-L/usr/local/cuda/lib64 && \
    make -j 2 && \
    make install 

# # create DAIN-App user
# RUN groupadd -r DAIN-App && useradd --no-log-init -r -g DAIN-App DAIN-App
# USER DAIN-App
# WORKDIR /DAIN-App

# COPY requirements.txt /tmp/
# RUN pip install --requirement /tmp/requirements.txt

