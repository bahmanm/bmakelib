# `bmakelib.default-if-blank`

If the given variable is blank, sets its value to the provided default.

###  Example 1

Makefile:

```Makefile
VAR1 =
VAR2 = 100
some-target : bmakelib.default-if-blank( VAR1,foo VAR2,bar )
	@echo 👉 VAR1=$(VAR1), VAR2=$(VAR2)
```

Shell:

```text
$ make some-target
👉 VAR1=foo, VAR2=100
```

###  Example 2

Makefile:

```Makefile
some-target : bmakelib.default-if-blank( VAR1,foo )
	@echo ✅ VAR1 is $(VAR1)
```

Shell:

```text
$ make bmakelib.conf.default-if-blank.SILENT=no some-target
Using default value 'foo' for variable 'VAR1'.
✅ VAR1 is foo
```

### Notes:

* Set `bmakelib.conf.default-if-blank.SILENT` to "no" to emit an `info` message when using
the default value.

* Currently there's no way to pass a value which contains spaces for a variable.  That is, the
  following will have undesired effects:

```Makefile
some-target : bmakelib.default-if-blank( VAR1,hello world )
```

---

# `bmakelib.conf.default-if-blank.SILENT`

Controls whether `bmakelib.default-if-blank` should emit an info message when using the default
provided.

Default is "yes" which means do NOT emit.  Set to "no" to make it behave otherwise.

---


