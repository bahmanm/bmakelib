# `bmakelib.default-if-blank(%)`

If the given variable(s) is blank, sets its value to the provided default.
It will also emit an "info" message if the value of `bmakelib.conf.default-if-blank.SILENT` is
"no".


## Notes:

Currently there's no way to pass a value which contains spaces for a variable.  That is, the
following will have undesired effects:

```
some-target : bmakelib.default-if-blank( VAR1,hello world )
```

##  Example 1

Makefile:

```
VAR1 =
VAR2 = 100
some-target : bmakelib.default-if-blank( VAR1,foo VAR2,bar )
	@echo $(VAR1), $(VAR2)
```

Shell:

```
$ make some-target
foo, 100
```

##  Example 2

Makefile:

```
some-target : bmakelib.default-if-blank( VAR1,foo )
	@echo $(VAR1)
	...
```

Shell:

```
$ make bmakelib.conf.default-if-blank.SILENT=no some-target
Using default value 'foo' for variable 'VAR1'.
foo
```

---

# `bmakelib.conf.default-if-blank.SILENT`

Controls whether `bmakelib.default-if-blank` should emit an info message when using the default
provided.

Default is "yes" which means do NOT emit.
Set to "no" to make it behave otherwise.

---


