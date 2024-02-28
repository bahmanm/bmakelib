# `bmakelib.enum.define`

Defines an enum (aka variant or option.)

It can later be used to verify the value of variables by using
`bmakelib.enum.error-unless-member`.

There are two variations to this feature.
- as a target dependency
- as a variable (macro)

Both produce the same results.  Except some minor cases, choice of the variation is mostly a
matter of style.

### Example 1

Makefile using target dependency:

```Makefile
define-enums : bmakelib.enum.define( DaysOfWeek/SUN,MON,TUE,WED,THU,FRI,SAT )
define-enums : bmakelib.enum.define( DISTRO/openSUSE,Debian,Fedora )
include define-enums
```

Or Makefile using variable (macro):

```Makefile
$(call bmakelib.enum.define,DaysOfWeek/SUN,MON,TUE,WED,THU,FRI,SAT)
$(call bmakelib.enum.define,DISTRO/openSUSE,Debian,Fedora)
```

Either of the above makefiles defines two enums:

- `DaysOfWeek` with 7 possible values: `SUN`, `MON`, ...
- `DISTRO` with 3 possible values: `openSUSE`, `Debian` and `Fedora`

💡 _Note the last line in the first snippet:  `include`ing a non-PHONY target causes it to be
evaluated before any other targets.  We're using this technic to ensure the enums are defined
before we access them._

### Example 2

Makefile using target dependency:

```Makefile
publish-package : bmakelib.enum.define( PKG-TYPE/deb,rpm,aur)
publish-package :
	...
```

Or Makefile using variable (macro):

```Makefile
$(call bmakelib.enum.define,PKG-TYPE/deb,rpm,aur)
```

Either of the above snippets defines an enum `PKG-TYPE` with 3 possible values `deb`, `rpm`
and `aur`.

_In case of the the first snippet (using target dependency), the difference with the method used
in example 1 is that `PKG-TYPE` would not be accessible before `publish-package` is invoked._

---

# `bmakelib.enum.error-unless-member`

Verifies if a variable's value is a member of a given enum and aborts make in case it's not.

_Note that just like `bmakelib.enum.define`, there are two variations of `error-unless-member`._

### Example 1

Makefile:

```Makefile
$(call bmakelib.enum.define,DEPLOY-ENV/development,staging,production)

deploy : bmakelib.enum.error-unless-member( DEPLOY-ENV,ENV )
deploy :
	@echo 🚀 Deploying to $(ENV)...
```

Shell:

```text
$ make ENV=local-laptop deploy
*** 'local-laptop' is not a member of enum 'DEPLOY-ENV'.  Stop.

$ make ENV=production deploy
🚀 Deploying to production...
```

### Example 2

Makefile:

```Makefile
define-enum : bmakelib.enum.define( BUILD-TARGET/android,ios,linux )
include define-enum

deploy :
	$(call bmakelib.enum.error-unless-member,BUILD-TARGET,TARGET)
	@echo 🏭 Building for $(TARGET)...
```

Shell:

```text
$ make TARGET=windows deploy
*** 'windows' is not a member of enum 'BUILD-TARGET'.  Stop.

$ make TARGET=ios deploy
🏭 building for ios...
```

---


