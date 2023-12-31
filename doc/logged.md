# `!!bmakelib.logged`

Logs the output of a given target to file.

### Example 1

Makefile:

```Makefile
some-target :
	@echo ✅ some-target is done!
```

Shell:

```text
$ make my-target!!bmakelib.logged
Logging target some-target to some-target-20230808-16221691536940-884103049.logged
exec 3>&1 4>&2 \
&& trap 'exec 2>&4 1>&3' 0 1 2 3 \
&& exec 1>/tmp/tmp.37mr7DpGnn/test_logged/some-target-20230808-16221691536940-884103049.logged 2>&1 \
&& make -f Makefile some-target

$ cat some-target-20230808-16221691536940-884103049.logged
✅ some-target is done!
```

### Example 2

Makefile:

```Makefile
some-target :
	@echo 🤖 Done this and that.
```

Shell:

```text
$ make bmakelib.conf.logged.SILENT=yes \
       bmakelib.conf.logged.ECHO_COMMAND=no \
       some-target!!bmakelib.logged

$ cat some-target-20230808-16221691536940-834199518.logged
🤖 Done this and that.
```

### Notes

  * See `!!logged` below for a shorter name.
  * The name contains two consecutive exclamation marks (`!!`).  That is to denote that it runs a
    a new make process.
  * The log file name format is `TARGET_NAME-%Y%m%d-%H%M%s.%µs.logged` (a la `date` command.)

---

# `bmakelib.conf.logged.convenience-target`

Whether to define the convenience target `%!!logged`.
Set to 'no' *before* including bmakelib to disable.

---

# `!!logged`

Convenience target with a shorter and more intuitive name.  It's a drop-in replacement for
`!!bmakelib.logged`.

Lets you write

```Makefile
some-target : other-target!!logged
```

or

```
$ make my-target!!logged
```

See also `bmakelib.conf.logged.convenience-target`.

---

# `bmakelib.conf.logged.SILENT`

If set to yes, causes `!!bmakelib.logged` to emit an info containing the log filename.

---

# `bmakelib.conf.logged.ECHO_COMMAND`

If set to no, causes `!!bmakelib.logged` to not echo the actual command it runs.

---


