# `bmakelib.dict`

Provides key-value dictionaries in GNU Make.

### As Macro (`$(call bmakelib.dict.*)`)

```Makefile
$(call bmakelib.dict.define,LIBCONF)
$(call bmakelib.dict.put,LIBCONF,lib-name,libhello.a)
$(call bmakelib.dict.put,LIBCONF,lib-objs,hello_impl.o)

$(call bmakelib.dict.define,EXECONF)
$(call bmakelib.dict.put,EXECONF,exe-name,hello)
$(call bmakelib.dict.put,EXECONF,exe-objs,hello_main.o)

EXE := $(call bmakelib.dict.get,EXECONF,exe-name)
LIB := $(call bmakelib.dict.get,LIBCONF,lib-name)

.PHONY : all
all : $(EXE)

$(EXE) : $(call bmakelib.dict.get,EXECONF,exe-objs) $(LIB)
	$(CC) $(CFLAGS) -o $@ $^

$(LIB) : $(call bmakelib.dict.get,LIBCONF,lib-objs)
	$(AR) $(ARFLAGS) $@ $^
```

### As Prerequisite (`bmakelib.dict.*(...)`)

```Makefile
define-config : bmakelib.dict.define( DEPLOY )
define-config : bmakelib.dict.put( DEPLOY,env,prod )
define-config : bmakelib.dict.put( DEPLOY,service,accounts )
define-config : bmakelib.dict.put( DEPLOY,host,accounts.example.com )

deploy : define-config
deploy :
	/usr/bin/deploy \
		--env $(call bmakelib.dict.get,DEPLOY,env) \
		--server $(call bmakelib.dict.get,DEPLOY,service) \
		$(call bmakelib.dict.get,DEPLOY,host)
```

> Note: Setting values via target prerequisites will **not** make them available to
> prerequisite lists (`$(TARGET) : $(call bmakelib.dict.get,...)`).

---

## `bmakelib.conf.dict.error-if-blank-key`

Controls whether blank dict keys are accepted.  Default value is `yes`.

If set to
- `yes`, causes an `$(error)` to be raised and make to be aborted.
- anything else, causes the operation to proceed.  However a `$(warning)` message will be
  printed.

---

## `bmakelib.conf.dict.error-if-blank-value`

Controls whether blank dict values are accepted.  Default value is `no`.

If set to
- `yes`, causes an `$(error)` to be raised and make to be aborted.
- anything else, causes the operation to proceed.  However a `$(warning)` message will be
  printed.

---

## `bmakelib.dict.define`

Defines a dictionary.

### Example 1: As Macro

```Makefile
$(call bmakelib.dict.define,MY-DICT)
```

Defines a dictionary named `MY-DICT`.

### Example 2: As Prerequisite

```Makefile
my-config-target : bmakelib.dict.define( MY-DICT )
```

Defines dictionary `MY-DICT` when `my-config-target` runs.

---

## `bmakelib.dict.put`

Stores a given value in the dictionary under a given key.

### Example 1: As Macro

```Makefile
$(call bmakelib.dict.define,MY-DICT)
$(call bmakelib.dict.put,MY-DICT,a-key,a-value)
```

Stores `a-value` under key `a-key` in `MY-DICT`.

### Example 2: As Prerequisite

```Makefile
my-config-target : bmakelib.dict.define( MY-DICT )
my-config-target : bmakelib.dict.put( MY-DICT,a-key,a-value )
```

Stores `a-value` under key `a-key` in `MY-DICT` when `my-config-target` runs.

---

## `bmakelib.dict.get`

Retrieves the value of a given key from the dictionary.

Note: `bmakelib.dict.get` is a function macro evaluated via `$(call ...)`. It cannot be used as a
target prerequisite because target prerequisites cannot return values.

### Example 1: In Variable Assignment

```Makefile
VAR1 = $(call bmakelib.dict.get,MY-DICT,a-key)
```

Retrieves the value of `a-key` from `MY-DICT` and assigns it to `VAR1`.

### Example 2: In Recipe

```Makefile
some-target :
	@echo $(call bmakelib.dict.get,MY-DICT,a-key)
```

Retrieves and prints the value of `a-key` from `MY-DICT` when `some-target` runs.

---


