# bmakelib 
[![CI](https://github.com/bahmanm/bmakelib/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/bahmanm/bmakelib/actions/workflows/ci.yml/badge.svg?branch=main)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/bahmanm/bmakelib/total?style=flat&logo=github&logoColor=white&color=0e80c0)
[![Docker Pulls](https://img.shields.io/docker/pulls/bdockerimg/bmakelib?style=flat&logo=docker&logoColor=white&label=pulls&color=%230e80c0)](https://hub.docker.com/r/bdockerimg/bmakelib)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/bahmanm/bmakelib?style=flat&logo=github&label=commits)
[![Matrix](https://img.shields.io/matrix/.mk%3Amatrix.org?server_fqdn=matrix.org&style=flat&logo=matrix&color=%230e80c0)](https://matrix.to/#/#github-bahmanm-bmakelib:matrix.org)

The minimalist Make standard library you'd always wished for!

<img alt="bmakelib logo" src="https://imgur.com/lt9nwW3.png" style="height: 200px; width: 200px; vertical-align: top" />

bmakelib is a standard library of reusable targets, recipes, and functions designed to help you write cleaner, safer, and self-documenting Makefiles.

---

# 1. Quick Start

Just drop this bootstrap snippet directly into your `Makefile`. Zero installation and privileges required:

```makefile
### bmakelib: download, install and include.
-include $(or $(BMAKELIB_DIR),$(PWD)/.bmakelib)/bmakelib.mk
$(or $(BMAKELIB_DIR),$(PWD)/.bmakelib)/bmakelib.mk:
	@mkdir -p $(@D)
	@curl -fsSL https://github.com/bahmanm/bmakelib/releases/$(if $(BMAKELIB_VERSION),download/$(BMAKELIB_VERSION),latest/download)/bmakelib-portable.tar.gz \
		| tar -xz -C $(@D) --strip-components=3
### bmakelib: done

build: bmakelib.error-if-blank( ENVIRONMENT ) ## Build application artefacts
build:
	@echo "Building for $(ENVIRONMENT)..."
```

### Notes
- Fetches the _latest_ version by default. Pin the version using `BMAKELIB_VERSION`.
- Installs to `./.bmakelib/` by default. Customise using `BMAKELIB_DIR`.
- Subsequent runs simply hit the cache. Delete `BMAKELIB_DIR` to reset.

---

# 2. Key Features and Showcase

### 2.1 Defensive Parameter Validation

Ensure mandatory build parameters and environment variables are supplied before recipes execute:

Makefile:

```makefile
build: bmakelib.error-if-blank( RELEASE_STAGE )
build:
	@echo ✅ Deploying to $(RELEASE_STAGE)
```

Shell output:

```text
$ make build
*** Provide a value for 'RELEASE_STAGE'.  Stop.

$ make RELEASE_STAGE=staging build
✅ Deploying to staging
```

### 2.2 Self-Documenting Makefiles

Document variables and targets inline with `##` comments and generate a clean, categorised help screen automatically:

Makefile:

```makefile
ENVIRONMENT ?= development ## Target deployment environment (development|staging|production)

build: bmakelib.error-if-blank( ENVIRONMENT ) ## Compile binaries and package distribution artefacts
build:
	@echo ✅ Building for $(ENVIRONMENT)...
```

Shell output:

```text
$ make help
================================================================================
  LOCAL: defined inside the source tree
================================================================================

  TARGETS
    build  Compile binaries and package distribution artefacts

  VARIABLES
    ENVIRONMENT  Target deployment environment (development|staging|production)

--------------------------------------------------------------------------------
Notes:
- Run 'env' to view the environment variables passed to Make.
- Use 'bmakelib.conf.help.scope=local|included|builtin|all' to control the scope.
- Use 'bmakelib.conf.help.targets=no' to skip targets.
- Use 'bmakelib.conf.help.variables=no' to skip variables.
- Use 'bmakelib.conf.help.show-bmakelib=yes' to display bmakelib definitions.
- Use 'bmakelib.conf.help.tips=no' to silence this tip.
```

---

# 3. Module Catalogue

Detailed documentation and practical examples for each bmakelib module:

- Self-Documentation:
  - [`help`](doc/help.md): Automated, scope-aware help system for targets and variables.
- Validation:
  - [`error-if-blank`](doc/error-if-blank.md): Abort build if required variables or arguments are omitted.
  - [`default-if-blank`](doc/default-if-blank.md): Assign sensible fallback defaults to unset variables.
  - [`enum`](doc/enum.md): Restrict variable values to a defined set of valid options.
- Data Structures:
  - [`dict`](doc/dict.md): In-memory key-value maps and dictionaries within GNU Make.
- Observability and Execution:
  - [`timed`](doc/timed.md): High-precision benchmarking and execution timing for targets.
  - [`logged`](doc/logged.md): Structured logging with configurable timestamps and severity levels.
- Shell and Runtime Utilities:
  - [`shell`](doc/shell.md): Robust subshell execution with error handling.
  - [`bmakelib.mk`](doc/bmakelib.md): Core library orchestration, constants, and runtime version introspection.

---

# 4. System-Wide Installation (Optional)

If you prefer to install bmakelib globally (via Homebrew, pre-built DEB/RPM packages, or compiled from source) rather than bootstrapping per project, see [System-Wide Installation](doc/system-wide-installation.md).

---

# 5. Prerequisites and Compatibility

bmakelib requires **GNU Make 4.4+** (released in 2022).

Verify your installed version:

```bash
make -v
```

If your operating system provides an older Make version, upgrading is straightforward:

```bash
wget https://ftpmirror.gnu.org/make/make-4.4.1.tar.gz
tar xzf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr/local
make
sudo make install
```
