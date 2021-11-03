FROM debian:testing

RUN dpkg --add-architecture i386 && apt-get -y update
RUN apt-get -y install git ssh mingw-w64
RUN apt-get --fix-missing -y install wine wine32 libwine fonts-wine
RUN apt-get -y install cmake g++
RUN git clone https://github.com/JWasm/JWasm; cd JWasm; mkdir build && cd build && cmake .. && make && cp jwasm /usr/local/bin
WORKDIR /root/m

CMD "/bin/bash"
