#
# spec file for package suse-xsl-stylesheets
#
# Copyright (c) 2017 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           suse-documentation-dicts-en
Version:        0.1
Release:        0

###############################################################
#
#  IMPORTANT:
#  Only edit this file directly in the Git repo:
#  https://github.com/openSUSE/daps, branch develop,
#  packaging/suse-xsl-stylesheets.spec
#
#  Your changes will be lost on the next update.
#  If you do not have access to the Git repository, notify
#  <fsundermeyer@opensuse.org> and <toms@opensuse.org>
#  or send a patch.
#
################################################################

Summary:        Spellcheck Dictionaries for SUSE Documentation Purposes
License:        GPL-2.0 or GPL-3.0
Group:          Productivity/Publishing/XML
Url:            https://github.com/openSUSE/suse-xsl
Source0:        %{name}-%{version}.tar.bz2
Source1:        susexsl-fetch-source-git
Source2:        %{name}.rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

BuildRequires:  make
Requires:       aspell
Requires:       aspell-en

%description
English Dictionaries for aspell and hunspell to spellcheck SUSE (and
openSUSE) documentation with.

#--------------------------------------------------------------------------

%prep
%setup -q -n %{name}

#--------------------------------------------------------------------------

%build
%__make  %{?_smp_mflags}

#--------------------------------------------------------------------------

%install
make install DESTDIR=%{buildroot} LIBDIR=%{_libdir}

# create symlinks:
%fdupes -s %{buildroot}/%{_datadir}

%files
%defattr(-,root,root)

# Directories
%dir %{_datadir}/suse-xsl-stylesheets
%dir %{_datadir}/suse-xsl-stylesheets/aspell
%{_datadir}/suse-xsl-stylesheets/aspell/en_US-suse-addendum.rws

#----------------------

%changelog
