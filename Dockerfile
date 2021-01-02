FROM nvidia/cuda:11.1-base-ubuntu20.04


RUN apt-get update && apt-get install -y \
    # DAIN App dependancys
    python3.8.5 

# create DAIN-App user
RUN groupadd -r DAIN-App && useradd --no-log-init -r -g DAIN-App DAIN-App

WORKDIR /DAIN-App

COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt

# Nvidia hardware accelerated ffmpeg
FROM jrottenberg/ffmpeg:4.1-nvidia 