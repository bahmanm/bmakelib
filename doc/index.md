# bmakelib

<img alt="bmakelib logo" src="assets/img/logo.png" align="left" width="165" style="max-width: 165px; margin-right: 1.5rem; margin-bottom: 1rem;" />

The minimalist Make standard library you'd always wished for!

`bmakelib` is a standard library of reusable targets, recipes, and functions designed to help you write cleaner, safer, and self-documenting Makefiles with GNU Make 4.4+.

<div style="clear: both;"></div>

---

### Quick Start

Drop this zero-installation bootstrap snippet directly into your `Makefile`:

```makefile
###################### bmakelib: download, install and include.
-include $(or $(BMAKELIB_DIR),$(PWD)/.bmakelib)/bmakelib.mk
$(or $(BMAKELIB_DIR),$(PWD)/.bmakelib)/bmakelib.mk:
	@mkdir -p $(@D)
	@curl -fsSL https://github.com/bahmanm/bmakelib/releases/$(if $(BMAKELIB_VERSION),download/$(BMAKELIB_VERSION),latest/download)/bmakelib-portable.tar.gz \
		| tar -xz -C $(@D) --strip-components=3
###################### bmakelib: done

build: bmakelib.error-if-blank( ENVIRONMENT ) ## Build application artefacts
build:
	@echo "Building for $(ENVIRONMENT)..."
```

- Fetches the _latest_ version by default. Pin the version using `BMAKELIB_VERSION`.
- Installs to `./.bmakelib/` by default. Customise using `BMAKELIB_DIR`.
- Subsequent runs hit the local cache. Delete `BMAKELIB_DIR` to reset.

---

### Module Catalogue

Explore the individual module documentation and practical recipes:

#### Core Modules
- [bmakelib Orchestration](bmakelib.md): Core library initialisation, constants, and runtime version introspection.
- [help](help.md): Automated, scope-aware help system for targets and variables.

#### Validation
- [error-if-blank](error-if-blank.md): Abort the build if mandatory variables or arguments are omitted.
- [default-if-blank](default-if-blank.md): Assign sensible fallback defaults to unset variables.
- [enum](enum.md): Restrict variable values to a defined set of permitted options.

#### Data Structures
- [dict](dict.md): In-memory key-value maps and dictionaries within GNU Make.

#### Observability & Execution
- [timed](timed.md): High-precision benchmarking and execution timing for targets.
- [logged](logged.md): Structured logging with configurable timestamps and severity levels.

#### System Utilities
- [shell](shell.md): Robust subshell execution with error handling.

---

### Installation & Compatibility

- [System-Wide Installation](system-wide-installation.md): Optional global installation via Homebrew, pre-built DEB/RPM packages, or compiled from source.
- Prerequisites: Requires GNU Make 4.4+ (released in 2022).
