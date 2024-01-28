# `bmakelib.shell.error-if-nonzero`

Executes the given shell command and expands the output.  If the command fails with any non-zero
code, fails the Make process with an "error" message.

###  Example 1

Makefile:

```Makefile
     VAR1 := $(call bmakelib.shell.error-if-nonzero, echo Kaboom! 💣 && false)

     some-target : VAR2 := $(call bmakelib.shell.error-if-nonzero, echo Hello, world)
     some-target :
	@echo Unreachable recipe ⛔
```

Shell:

```text
$ make some-target
Makefile:4: *** bmakelib.shell.error-if-nonzero: Command exited with non-zero value 1.  Stop.
```

###  Example 2

Makefile:

```Makefile
VAR1 := $(call bmakelib.shell.error-if-nonzero,\
	       echo 🧑 $$$$(whoami) 💻 $$$$(perl -nE'say $$$$1 if /^ID="(.+)"$$$$/' < /etc/os-release))

some-target : VAR2 := $(call bmakelib.shell.error-if-nonzero,emacs --version | head -n 1)
some-target :
	@echo VAR1=$(VAR1)
	@echo VAR2=$(VAR2)
```

Shell:

```text
$ make some-target
👉 VAR1=🧑 bahman 💻 opensuse-tumbleweed
👉 VAR2=GNU Emacs 29.1
```

###  Example 3

Makefile:

```Makefile
VAR1 := $(call bmakelib.shell.error-if-nonzero,\
               docker run --rm ubuntu:22.04 echo Hello, world. && echo Goodbye, world.)

some-target : VAR2 := $(call bmakelib.shell.error-if-nonzero,\
                             [[ ! -z $$$$JAVA_HOME ]] \
			     && ls $$$$JAVA_HOME/bin/java \
			     || echo JAVA_HOME not set.)
some-target :
	@echo 👉 VAR1=$(VAR1)
	@echo 👉 VAR2=$(VAR2)
```

Shell:

```text
$ make some-target
👉 VAR1=Hello, world. Goodbye, world.
👉 VAR2=/home/bahman/.sdkman/candidates/java/current/bin/java
```

### Notes:

* Set `bmakelib.conf.shell.error-if-nonzero.SILENT` to "no" to emit an `info` message before
 running the command.

* Quad-quote all the variables and structures that are supposed to be only understood by shell.
  For example:
  - `$(call bmakelib.shell.error-if-nonzero,echo $$$$HOSTNAME)`
  - `$(call bmakelib.shell.error-if-nonzero,PATH="/usr/local/foo/bin:$$$$PATH" foo $$$$(date))

* Currently the a command can contain upto **9** comma (,) charaters.
  - This number is totally arbitrary and it can be increased if there's need for it.
  - Since `$(call)` treats "," (comma) as the parameter separator, it swallows all commas in the
    commands you pass to `bmakelib.shell.error-if-nonzero`.  This means that those commans need
    to be manually inserted in the command string.

---

# `bmakelib.conf.shell.error-if-nonzero.SILENT`

Controls whether `bmakelib.shell.error-if-nonzero` should emit an info message before running
the command.

Default is "yes" which means do NOT emit.  Set to "no" to make it behave otherwise.

---


