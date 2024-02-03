# `bmakelib.MIN_MAKE_VERSION`

Minimum Make version supported.

Anything older either breaks bmakelib or can cause it to behave in unexpected ways.

---

# `bmakelib.newline`

Expands to a single newline (\n)

---

# `bmakelib.comma`

Expands to a comma (,)

---

# `bmakelib.slash`

Expands to a slash (/)

---

# `bmakelib.backslash`

Expands to a backslash (\)

---

# `bmakelib.space`

Expands to a whitespace

---

# `⬛`

Expands to an empty string.

This silly-looking variable is a formatting convenience for cases when whitespace is significant
and will affect the evaluation. See `bmakelib.shell.error-if-nonzero` for an example.

---


