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
  * The log file name format is `TARGET_NAME-<time-format>.<microseconds>.logged`.
  * See `bmakelib.conf.logged.output-dir` to customise the output directory for logs.
  * See `bmakelib.conf.logged.time-format` to customise the timestamp format.

---

# `bmakelib.conf.logged.output-dir`

The directory where log files are written.

Precedence for resolving the output directory:
  1. `bmakelib.conf.logged.output-dir` (Make variable)
  2. `BMAKELIB_CONF_LOGGED_OUTPUT_DIR` (environment variable)
  3. `ROOT` (legacy Make or environment variable)
  4. `./` (default)

---

# `bmakelib.conf.logged.convenience-target`

Whether to define the convenience target `%!!logged`.
Set to 'no' *before* including bmakelib to disable.

Precedence:
  1. `bmakelib.conf.logged.convenience-target` (Make variable)
  2. `BMAKELIB_CONF_LOGGED_CONVENIENCE_TARGET` (environment variable)
  3. `yes` (default)

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

Precedence:
  1. `bmakelib.conf.logged.SILENT` (Make variable)
  2. `BMAKELIB_CONF_LOGGED_SILENT` (environment variable)
  3. `no` (default)

---

# `bmakelib.conf.logged.ECHO_COMMAND`

If set to no, causes `!!bmakelib.logged` to not echo the actual command it runs.

Precedence:
  1. `bmakelib.conf.logged.ECHO_COMMAND` (Make variable)
  2. `BMAKELIB_CONF_LOGGED_ECHO_COMMAND` (environment variable)
  3. `yes` (default)

---

# `bmakelib.conf.logged.time-format`

The `strftime`-compatible format string used for the timestamp in log filenames.
Microseconds are always appended to avoid filename collisions.

Precedence:
  1. `bmakelib.conf.logged.time-format` (Make variable)
  2. `BMAKELIB_CONF_LOGGED_TIME_FORMAT` (environment variable)
  3. `%Y%m%d-%H%M%S` (default)

---


