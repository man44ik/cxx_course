FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update && apt-get install -y \
        g++-16 g++-16-multilib \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-16 116 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
        cmake git \
        binutils grep libc-bin ltrace strace \
        gdb valgrind kcachegrind \
        coreutils linux-tools-common \
        util-linux procps locales htop \
        pciutils iputils-ping traceroute iproute2 gawk nmap curl lsof tcpdump telnet \
        python3 python3-dev python3-matplotlib libicu-dev libtbb-dev \
        autotools-dev build-essential libboost-all-dev libbz2-dev \
        postgresql postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp \
    && apt-get update && apt-get install -y \
        wget \
    && wget -O boost_1_90_0.tar.gz \
        "https://sourceforge.net/projects/boost/files/boost/1.90.0/boost_1_90_0.tar.gz/download" \
    && tar xvf boost_1_90_0.tar.gz \
    && cd boost_1_90_0/ \
    && apt-get update && apt-get install -y \
        autotools-dev build-essential libboost-all-dev libbz2-dev \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-16 116 \
    && ./bootstrap.sh --with-python=/usr/bin/python3.12 \
    && ./b2 install \
        python=3.12 \
        toolset=gcc variant=release link=static runtime-link=static threading=multi \
    && cd / && rm -rf /tmp/boost*

RUN cd /tmp \
    && git clone https://github.com/google/glog \
    && cd glog \
    && mkdir -p build && cd build \
    && cmake .. && cmake --build . --config Release \
    && cmake --install . \
    && cd / && rm -rf /tmp/glog

RUN cd /tmp \
    && git clone https://github.com/google/googletest \
    && cd googletest \
    && mkdir -p build && cd build \
    && cmake .. && cmake --build . --config Release \
    && cmake --install . \
    && cd / && rm -rf /tmp/googletest

RUN cd /tmp \
    && git clone https://github.com/google/benchmark \
    && cd benchmark \
    && mkdir -p build && cd build \
    && cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . --config Release \
    && cmake --install . \
    && cd / && rm -rf /tmp/benchmark

RUN cd /tmp \
    && git clone https://github.com/nlohmann/json \
    && cd json \
    && mkdir -p build && cd build \
    && cmake .. && cmake --build . --config Release \
    && cmake --install . \
    && cd / && rm -rf /tmp/json

RUN cd /tmp \
    && git clone https://github.com/galkahana/PDF-Writer \
    && cd PDF-Writer \
    && mkdir -p build && cd build \
    && cmake .. && cmake --build . --config Release \
    && cmake --install . \
    && cd / && rm -rf /tmp/PDF-Writer

RUN cd /tmp \
    && git clone https://github.com/lecrapouille/zipper --recursive \
    && cd zipper \
    && mkdir -p build && cd build \
    && apt-get update && apt-get install -y \
        zlib1g-dev \
    && cmake .. -DZIPPER_SHARED_LIB=ON -DZIPPER_BUILD_DEMOS=ON -DZIPPER_BUILD_TESTS=ON \
    && cmake --build . --config Release \
    && cmake --install . \
    && cd / && rm -rf /tmp/zipper

RUN cd /tmp \
    && apt-get update && apt-get install -y \
        postgresql postgresql-contrib \
        libpq-dev \
    && git clone https://github.com/jtv/libpqxx \
    && cd libpqxx \
    && mkdir -p build && cd build \
    && cmake .. && cmake --build . --config Release \
    && cmake --install . \
    && cd / && rm -rf /tmp/libpqxx

RUN cd /tmp \
    && git clone https://github.com/randombit/botan \
    && cd botan \
    && ./configure.py \
    && make install \
    && cd / && rm -rf /tmp/botan

WORKDIR /work

CMD ["bash"]