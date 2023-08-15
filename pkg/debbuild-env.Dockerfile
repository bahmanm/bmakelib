FROM ubuntu:22.04
VOLUME /project

ADD https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz /tmp/
RUN apt-get update \
    && apt-get install -y gcc perl make

WORKDIR /tmp
RUN tar xzf make-4.4.1.tar.gz \
    && cd make-4.4.1 \
    && ./configure \
    && make install

RUN apt-get update \
    && apt-get install -y debhelper devscripts \
    && hash -r

WORKDIR /project
