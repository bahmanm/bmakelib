FROM opensuse/tumbleweed
VOLUME /project

RUN zypper refresh && zypper install -y make perl rpmbuild rpmdevtools

WORKDIR /project
