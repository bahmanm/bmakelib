# Copyright © Bahman Movaqar
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
####################################################################################################

Name:           bmakelib
Version:        N/A
Release:        1%{?dist}
Summary:        The minimalist Make standard library you'd always wished for!
License:        Apache License v2.0
URL:            https://github.com/bahmanm/bmakelib
Source0:        N/A
BuildRequires:  bash perl make
BuildArch:      noarch
Requires:       bash perl make

####################################################################################################

%description
bmakelib is essentially a collection of useful targets, recipes and variables you can use to augment
your Makefiles.

The aim is *not* to simplify writing Makefiles but rather help you write *cleaner* and *easier to read
and maintain* Makefiles.

####################################################################################################

%prep
%setup -q

####################################################################################################

%build
make %{?_smp_mflags} test

####################################################################################################

%install
rm -rf ${RPM_BUILD_ROOT}/*
make PREFIX=${RPM_BUILD_ROOT}%{_prefix} install

####################################################################################################

%files

%{_includedir}/bmakelib/bmakelib.mk
%{_includedir}/bmakelib/error-if-blank.mk
%{_includedir}/bmakelib/default-if-blank.mk
%{_includedir}/bmakelib/timed.mk
%{_includedir}/bmakelib/logged.mk
%{_includedir}/bmakelib/enum.mk
%{_includedir}/bmakelib/shell.mk
%{_includedir}/bmakelib/VERSION

%{_prefix}/share/doc/bmakelib/LICENSE
%{_prefix}/share/doc/bmakelib/VERSION
%{_prefix}/share/doc/bmakelib/README.md
%{_prefix}/share/doc/bmakelib/bmakelib.md
%{_prefix}/share/doc/bmakelib/error-if-blank.md
%{_prefix}/share/doc/bmakelib/default-if-blank.md
%{_prefix}/share/doc/bmakelib/timed.md
%{_prefix}/share/doc/bmakelib/logged.md
%{_prefix}/share/doc/bmakelib/enum.md
%{_prefix}/share/doc/bmakelib/shell.md

####################################################################################################

%changelog
