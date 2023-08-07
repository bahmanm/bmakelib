FROM ubuntu:jammy
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential git

VOLUME /bmakelib

WORKDIR  /bmakelib
CMD ls -alh /bmakelib
#CMD make tell-make-version test
