# bmakelib  [![Build Status](https://app.travis-ci.com/bahmanm/bmakelib.svg?branch=main)](https://app.travis-ci.com/bahmanm/bmakelib) ![Static Badge](https://img.shields.io/badge/license-Apache_License_v2.0-blue) ![Static Badge](https://img.shields.io/badge/dependencies-NONE-green)

The minimalist Make standard library you'd always wished for!

bmakelib is essentially a collection of useful targets, recipes and variables you can use to augment
your Makefiles.

The aim is *not* to simplify writing Makefiles but rather help you write *cleaner* and *easier to read
and maintain* Makefiles.

## Example

Makefile:

```Makefile
include bmakelib/bmakelib.mk

my-target :
	@sleep 2
	@echo my-target is done
```

Shell:

```
$ make my-target!bmakelib.timed
my-target is done
Target 'my-target' took 2009ms to complete.
```

# bmakelib Contents

* [bmakelib.mk](doc/bmakelib.md)
* [error-if-blank.mk](doc/error-if-blank.md)
* [default-if-blank.mk](doc/error-if-blank.md)
* [timed.mk](doc/timed.md)
* [logged.mk](doc/logged.md)
* [enum.mk](doc/enum.md)

# How To Install

## Prerequisites

Although not an installation dependency, bmakelib relies on **Gnu Make 4.4+** which was released
back in 2022.

To check the version which is currently installed, simply `make -v` in a terminal.  The output should
look like below.

```
$ make -v
GNU Make 4.4.1
Built for x86_64-suse-linux-gnu
Copyright (C) 1988-2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

Installing Gnu Make is quite easy.  In fact as easy as:

```
$ wget https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
$ tar xzf make-4.4.1.tar.gz
$ cd make-4.4.1
$ ./configure --prefix=/usr/local
$ make install
```

## Installing bmakelib

### RPM-based Linux Distro

Simply grab the prepackaged RPM from the [release page](https://github.com/bahmanm/bmakelib/releases/latest)
and install it using your faourite method, eg `rpm -i bmakelib-0.1.0-1.1.rpm`.

### DEB-based Linux Distro

Simply grab the prepackaged DEB from the [release page](https://github.com/bahmanm/bmakelib/releases/latest)
and install it using your faourite method, eg `dpkg -i bmakelib_0.1.0-1_all.deb`.

### Homebrew (MacOS and Linux)

Assuming you have Homebrew configured, simply install bmakelib as below:
```
$ brew update
$ brew tap bahmanm/bmakelib
$ brew install bmakelib
```

### Installing From Source

Grab the source archive from the [release page](https://github.com/bahmanm/bmakelib/releases/latest), 
eg `bmakelib-0.1.0.tar.gz`.

```
$ tar zxf bmakelib-0.1.0.tar.gz
$ cd bmakelib-0.1.0
$ sudo PREFIX=/usr/local make install 
```

# How To Use - Examples

bmakelib tries to bring minimal clutter to your Makefiles and be easy to use.  That is, all you need to
start using bmakelib is adding a single line somewhere in your Makefile:

```Makefile
include bmakelib/bmakelib.mk
```

## Make `include` path

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

## Example

Here's a sample Makefile which uses `error-if-blank`target to declare a variable and ensure it's got
a value.

```Makefile
include bmakelib/bmakelib.mk

my-target : bmakelib.error-if-blank( IMPORTANT_OPTION )
my-target :
	some-command --important-option $(IMPORTANT_OPTION)
```

Now, Make refuses to make `my-target` if you don't specificying a value for `IMPORTANT_OPTION`.

```
$ make my-target
*** Provide value for 'IMPORTANT_OPTION.  Stop.
```

