FROM opensuse/tumbleweed
VOLUME /project

RUN useradd -mU rpmbuild
RUN zypper refresh && zypper install -y make perl rpmbuild rpmdevtools

WORKDIR /project
USER rpmbuild
