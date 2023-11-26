# `bmakelib.error-if-blank`

Fails make with an error message if the provided variable is blank.

### Example

Makefile:

```Makefile
VAR1 =
VAR2 = 100
some-target : bmakelib.error-if-blank( VAR1 VAR2 )
```

Shell:

```text
$ make some-target
*** Provide value for 'VAR1'.  Stop.
```

---


