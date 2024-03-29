# bmakelib 
[![CircleCI](https://dl.circleci.com/status-badge/img/circleci/UMKeFZ8ns9T9vi5aquTfVT/7xEbdNjRYsdqW8yXCjZD9v/tree/main.svg?style=svg&circle-token=CCIPRJ_H6RDDH8tmi86oJU42UaqJf_e7f27baf05915c0ae68d428ee8a6ddb4f3062e31)](https://dl.circleci.com/status-badge/redirect/circleci/UMKeFZ8ns9T9vi5aquTfVT/7xEbdNjRYsdqW8yXCjZD9v/tree/main)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/bahmanm/bmakelib/total?style=flat&logo=github&logoColor=white&color=0e80c0)
[![Docker Pulls](https://img.shields.io/docker/pulls/bdockerimg/bmakelib?style=flat&logo=docker&logoColor=white&label=pulls&color=%230e80c0)](https://hub.docker.com/r/bdockerimg/bmakelib)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/bahmanm/bmakelib?style=flat&logo=github&label=commits)
[![Matrix](https://img.shields.io/matrix/.mk%3Amatrix.org?server_fqdn=matrix.org&style=flat&logo=matrix&color=%230e80c0)](https://matrix.to/#/#github-bahmanm-bmakelib:matrix.org)

The minimalist Make standard library you'd always wished for!

<img alt="bmakelib logo" src="https://imgur.com/lt9nwW3.png" style="height: 200px; width: 200px; vertical-align: top" />

bmakelib is essentially a collection of useful targets, recipes and variables you can use to augment
your Makefiles.

The aim is *not* to simplify writing Makefiles but rather help you write *cleaner* and *easier to read
and maintain* Makefiles.

## An Example

Makefile:

```Makefile
include bmakelib/bmakelib.mk

my-target : bmakelib.error-if-blank( VAR1 )
my-target :
	@echo ✅ VAR1 value is $(VAR1)
```

Shell:

```text
$ make my-target
*** Provide value for 'VAR1'.  Stop.

$ make VAR1=foo my-target
✅ VAR1 value is foo
```

# 1. Features and Options

### ⭐ [`error-if-blank`](doc/error-if-blank.md)
### ⭐ [`default-if-blank`](doc/default-if-blank.md)
### ⭐ [`enum`](doc/enum.md)
### ⭐ [`shell`](doc/shell.md)
### ⭐ [`dict`](doc/dict.md)
### ⭐ [`timed`](doc/timed.md)
### ⭐ [`logged`](doc/logged.md)
### ⭐ [bmakelib.mk](doc/bmakelib.md)

# 2. How To Install

## 2.1 Prerequisites

Although not an installation dependency, bmakelib relies on **Gnu Make 4.4+** which was released
back in 2022.

To check the version which is currently installed, simply `make -v` in a terminal.  The output should
look like below.

```
$ make -v
GNU Make 4.4.1
...
```

💡 Installing Gnu Make is quite easy.  In fact as easy as:

```
$ wget https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
$ tar xzf make-4.4.1.tar.gz
$ cd make-4.4.1
$ ./configure --prefix=/usr/local
$ make install
```

## 2.2 Installing bmakelib

### RPM-based Linux Distro

Simply grab the prepackaged RPM from the [release page](https://github.com/bahmanm/bmakelib/releases/latest)
and install it using your faourite method.  For example:

```text
$ wget https://github.com/bahmanm/bmakelib/releases/download/v0.6.0/bmakelib-0.6.0-1.1.noarch.rpm
$ rpm -i bmakelib-0.6.0-1.1.noarch.rpm
```

### DEB-based Linux Distro

Simply grab the prepackaged DEB from the [release page](https://github.com/bahmanm/bmakelib/releases/latest)
and install it using your faourite method.  For example:

```text
$ wget https://github.com/bahmanm/bmakelib/releases/download/v0.6.0/bmakelib_0.6.0-1_all.deb
$ dpkg -i bmakelib_0.6.0-1_all.deb
```

### Homebrew (MacOS and Linux)

Assuming you have Homebrew configured, simply install bmakelib as below:
```
$ brew update
$ brew tap bahmanm/bmakelib
$ brew install bmakelib
```

### Installing From Source

Grab the source archive from the [release page](https://github.com/bahmanm/bmakelib/releases/latest):

```
$ wget https://github.com/bahmanm/bmakelib/releases/download/v0.6.0/bmakelib-0.6.0.tar.gz
$ tar zxf bmakelib-0.6.0.tar.gz
$ cd bmakelib-0.6.0
$ sudo PREFIX=/usr/local make install 
```

# 3. How To Use

bmakelib tries to introduce as little clutter as possible to Makefiles and be easy to use.   
That is, all you need to start using bmakelib is adding a single line somewhere in your Makefile:

```Makefile
include bmakelib/bmakelib.mk
```

## 3.1 Make `include` path

💡 *You can safely skip this section if you have installed bmakelib using the prepackaged artefacts or
you have installed it in a standard location (such as `/usr/local` or `/usr`.)*

In case you installed bmakelib in a non-standard location, you either need to `include` bmakelib using
full path or pass the installation directory to make via `--include-dir` option.

For example, assuming you installed bmakelib to `/my-collection/bmakelib`:

### Option #1

Makefile:

```Makefile
include bmakelib/bmakelib.mk

my-target :
    ...
```

Shell:

```
$ make --include-dir /my-collection/bmakelib my-target
```

### Option #2

Makefile:

```Makefile
include /my-collection/bmakelib/include/bmakelib.mk

my-target :
    ...
```

Shell:

```
$ make my-target
```
