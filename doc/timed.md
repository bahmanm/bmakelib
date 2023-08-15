# `%!bmakelib.timed`

Times the execution of a given target and report the duration with milliseconds precision.
The following variables will be populated:
  * `stdlib.vars.timed.begin-ts.TARGET_NAME` (nanos)`
  * `stdlib.vars.timed.end-ts.TARGET_NAME` (nanos)`
  * `stdlib.vars.timed.duration.TARGET_NAME` (millis)`

# Example 1

Makefile:

```Makefile
my-target :
	@sleep 2
	@echo my-target is done
```

Shell:

```
$ make my-target!bmakelib.timed
Using default value 'yes' for variable 'stdlib.conf.timed.SILENT'
my-target is done
Target 'my-target' took 2009ms to complete.
```

# Example 2

Makefile:

```Makefile
some-target :
	@sleep 2

my-target : stdlib.conf.timed.SILENT = yes
my-target : some-target!bmakelib.timed
	@echo ✅ Made some-target in $(stdlib.vars.timed.duration.some-target)ms 🙌
```

Shell:

```
$ make my-target
✅ Made some-target in 2008ms 🙌
```

---

# `%!timed`

Convenice target with a shorter and more intuitive name.  It's a drop-in replacement for
`%!bmakelib.timed`.

Lets you write

```Makefile
some-target : other-target!timed
```

or

```
$ make my-target!timed
```

See also `bmakelib.conf.timed.convenience-target`.

---

 # `bmakelib.conf.timed.SILENT`

 If set to yes, causes `%!bmakelib.timed` to emit an info containing the duration of the target.

---


