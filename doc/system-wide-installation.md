# System-Wide Installation

While bmakelib is primarily designed for zero-install project bootstrapping, it can also be installed system-wide for environments where global availability is preferred.

---

# 1. Homebrew (macOS and Linux)

```bash
brew update
brew tap bahmanm/bmakelib
brew install bmakelib
```

---

# 2. Linux Distributions (DEB / RPM)

Pre-built binary packages are published on each [GitHub Release](https://github.com/bahmanm/bmakelib/releases/latest):

### 2.1 Debian / Ubuntu

```bash
wget https://github.com/bahmanm/bmakelib/releases/download/v0.8.0/bmakelib_0.8.0-1_all.deb
sudo dpkg -i bmakelib_0.8.0-1_all.deb
```

### 2.2 RHEL / Fedora / CentOS

```bash
wget https://github.com/bahmanm/bmakelib/releases/download/v0.8.0/bmakelib-0.8.0-1.1.noarch.rpm
sudo rpm -i bmakelib-0.8.0-1.1.noarch.rpm
```

---

# 3. Building and Installing from Source

```bash
git clone https://github.com/bahmanm/bmakelib.git
cd bmakelib
sudo make install PREFIX=/usr/local
```

---

# 4. Usage with Global Installations

When installed globally to standard locations (such as `/usr/local` or `/usr`), include bmakelib directly in your `Makefile`:

```makefile
include bmakelib/bmakelib.mk
```
