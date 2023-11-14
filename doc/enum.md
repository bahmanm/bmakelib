# `bmakelib.enum.define(%)`

Define an enum (aka variant or option.)
It can later be used to verify the value of variables by using
`bmakelib.enum.error-unless-member`.

## Example 1

Makefile:

    ```Makefile
    define-enums : bmakelib.enum.define( DaysOfWeek/SUN,MON,TUE,WED,THU,FRI,SAT )
    define-enums : bmakelib.enum.define( DISTRO/openSUSE,Debian,Fedora)
    include define-enums
    ```

The above makefile defines two enums:

- `DaysOfWeek` with 7 possible values: `SUN`, `MON`, ...
- `DISTRO` with 3 possible values: `openSUSE`, `Debian` and `Fedora`

💡 _Note the last line in the snippet:  `include`ing a non-PHONY target causes it to be
evaluated before any other targets.  We're using this technic to ensure the enums are defined
before we access them._

## Example 2

Makefile:

    ```Makefile
    publish-package : bmakelib.enum.define( PKG-TYPE/deb,rpm,aur)
publish-package :
	...
```

The above snippet defines an enum `PKG-TYPE` with 3 possible values `deb`, `rpm` and `aur`.  The
difference with the method used in example 1 is that `PKG-TYPE` is not going to be accessible
before `publish-package` is invoked.

---

# `bmakelib.enum.error-unless-member(%)`

Verifies if a value is a member of a given enum and aborts make in case if it's not.

## Example

Makefile:

    ```Makefile
define-enum : bmakelib.enum.define( DEPLOY-ENV/testing,development,staging,production )
include define-enum

    deploy : bmakelib.enum.error-unless-member( DEPLOY-ENV,ENV )
deploy :
	@echo Deploying to $(ENV)...
```

Shell:

```
$ make ENV=local-laptop deploy
*** 'local-laptop' is not a member of enum 'DEPLOY-ENV'.  Stop.

    $ make ENV=production deploy
 	Deploying to production...


---


