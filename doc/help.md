# `bmakelib.help`

Extracts and displays available targets and variables along with their documentation.

### Example

Makefile:

```Makefile
build: ## Compile and package all build artefacts
PREFIX ?= /usr ## Base installation prefix directory
```

Shell:

```text
$ make bmakelib.help
================================================================================
  LOCAL
================================================================================

  TARGETS
    build   Compile and package all build artefacts

  VARIABLES
    PREFIX  Base installation prefix directory
```

---

# `bmakelib.conf.help.convenience-target`

Whether to define the convenience target `help`.
Set to 'no' *before* including bmakelib to disable.

Precedence:
  1. `bmakelib.conf.help.convenience-target` (Make variable)
  2. `BMAKELIB_CONF_HELP_CONVENIENCE_TARGET` (environment variable)
  3. `yes` (default)

---

# `help`

Convenience target with a shorter and more intuitive name.  It's a drop-in replacement for
`bmakelib.help`.

See also `bmakelib.conf.help.convenience-target`.

---

# `bmakelib.conf.help.targets`

Controls whether `bmakelib.help` should render target definitions.

Precedence:
  1. `bmakelib.conf.help.targets` (Make variable)
  2. `BMAKELIB_CONF_HELP_TARGETS` (environment variable)
  3. `yes` (default)

---

# `bmakelib.conf.help.variables`

Controls whether `bmakelib.help` should render variable definitions.

Precedence:
  1. `bmakelib.conf.help.variables` (Make variable)
  2. `BMAKELIB_CONF_HELP_VARIABLES` (environment variable)
  3. `yes` (default)

---

# `bmakelib.conf.help.scope`

Controls which category scopes to display in `bmakelib.help`.
Possible values: `all`, `local`, `included`, `builtin` (or a comma-separated combination).

Precedence:
  1. `bmakelib.conf.help.scope` (Make variable)
  2. `BMAKELIB_CONF_HELP_SCOPE` (environment variable)
  3. `all` (default)

---

# `bmakelib.conf.help.tips`

Controls whether `bmakelib.help` should display the usage notes/tips footer block.

Precedence:
  1. `bmakelib.conf.help.tips` (Make variable)
  2. `BMAKELIB_CONF_HELP_TIPS` (environment variable)
  3. `yes` (default)

---


