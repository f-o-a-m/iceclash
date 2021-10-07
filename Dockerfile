FROM ubuntu:focal

WORKDIR /usr/src/temp

RUN mkdir -p ~/.local/bin
ENV PATH="/root/.local/bin:$PATH"
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get -y install curl build-essential clang bison flex libreadline-dev gawk tcl-dev libffi-dev git graphviz xdot pkg-config python python3 libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev libftdi-dev python3-dev libboost-all-dev cmake libeigen3-dev libgmp10-dev
RUN curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack'
COPY . .
RUN printf "" | /root/.local/bin/stack repl
RUN printf "" /root/.local/bin/stack repl --with-ghc clash
RUN git clone https://github.com/cliffordwolf/icestorm.git icestorm
RUN nproc
WORKDIR icestorm
RUN make -j$(nproc) install
WORKDIR /usr/src/temp
RUN git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
WORKDIR arachne-pnr
RUN make -j$(nproc) install
WORKDIR /usr/src/temp
RUN git clone --recursive https://github.com/YosysHQ/prjtrellis
WORKDIR prjtrellis/libtrellis
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DTRELLIS_INSTALL_PREFIX=/usr/local .
RUN make -j$(nproc) install
WORKDIR /usr/src/temp
RUN git clone https://github.com/YosysHQ/nextpnr nextpnr-ice40
RUN git clone https://github.com/YosysHQ/nextpnr nextpnr-ecp5
WORKDIR nextpnr-ice40
RUN sed -ie 's/project(nextpnr CXX)/project(nextpnr C CXX)/' CMakeLists.txt
RUN cmake -DARCH=ice40 -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=/usr/local .
RUN make -j$(nproc) install
WORKDIR /usr/src/temp/nextpnr-ecp5
RUN sed -ie 's/project(nextpnr CXX)/project(nextpnr C CXX)/' CMakeLists.txt
RUN cmake -DARCH=ecp5 -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=/usr/local .
RUN make -j$(nproc) install
WORKDIR /usr/src/temp
RUN git clone https://github.com/cliffordwolf/yosys.git yosys
WORKDIR yosys
RUN make -j$(nproc) install
RUN apt-get install -y dfu-util
