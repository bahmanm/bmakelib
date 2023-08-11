# Copyright © 2023 Bahman Movaqar
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
Version:        0.1.0
Release:        1%{?dist}.0
Summary:        The minimalist Make standard library you'd always wished for!
License:        Apache License 2.0
URL:            https://github.com/bahmanm/bmakelib
Source0:        bmakelib-0.1.0.tar.gz
BuildRequires:  bash perl make
BuildArch:      noarch
Requires:       bash perl make

%description

%prep
%setup -q

%build
make %{?_smp_mflags} test

%install
rm -rf ${RPM_BUILD_ROOT}/*
make PREFIX=${RPM_BUILD_ROOT}%{_prefix} install

%files
%{_includedir}/bmakelib/bmakelib.Makefile
%{_includedir}/bmakelib/error-if-blank.Makefile
%{_includedir}/bmakelib/default-if-blank.Makefile
%{_includedir}/bmakelib/timed.Makefile
%{_includedir}/bmakelib/logged.Makefile
%{_includedir}/bmakelib/VERSION
%{_prefix}/doc/bmakelib/LICENSE
%{_prefix}/doc/bmakelib/VERSION

%changelog
