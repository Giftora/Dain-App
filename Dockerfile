FROM nvidia/cuda:11.1-base-ubuntu20.04 

RUN apt-get update && apt-get install -y \
    # DAIN App dependancys
    python3.8.5 \
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
    && rm -rf /var/lib/apt/lists/* 


WORKDIR /tmp
# ffmpeg compile
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && sudo make install && cd – && \
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/ && \
    sudo apt-get install build-essential yasm cmake libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev \
    ./configure --enable-nonfree -–enable-cuda-sdk –enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 \
    make -j 2 \
    make install

# create DAIN-App user
RUN groupadd -r DAIN-App && useradd --no-log-init -r -g DAIN-App DAIN-App
USER DAIN-App
WORKDIR /DAIN-App

COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt

