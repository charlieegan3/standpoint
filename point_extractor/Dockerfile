FROM rust:1.19

RUN apt-get update
RUN apt-get install -y git curl freeglut3-dev autoconf libx11-dev \
    libfreetype6-dev libgl1-mesa-dri libglib2.0-dev xorg-dev \
    gperf g++ build-essential cmake virtualenv python-pip \
    libssl1.0-dev libbz2-dev libosmesa6-dev libxmu6 libxmu-dev \
    libglu1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdbus-1-dev

WORKDIR /app
ADD . /app
RUN cargo build --verbose
