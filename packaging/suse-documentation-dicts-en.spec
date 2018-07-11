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

%define compatdir  suse-xsl-stylesheets/aspell
%define compatfile en_US-suse-addendum.rws

Name:           suse-documentation-dicts-en
Version:        4
Release:        0

###############################################################
#  IMPORTANT:
#  Only edit this file directly in the Git repo:
#  https://github.com/sknorr/suse-documentation-dicts, branch master,
#  packaging/suse-documentation-dicts-en.spec
################################################################

Summary:        Spellcheck Dictionaries for SUSE Documentation
License:        CC0-1.0
Group:          Productivity/Publishing/XML
Url:            https://github.com/sknorr/suse-documentation-dicts
Source0:        %{name}-%{version}.tar.bz2
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

BuildRequires:  vim
BuildRequires:  make
BuildRequires:  aspell
BuildRequires:  aspell-en
BuildRequires:  myspell-dictionaries
Requires:       vim
Requires:       myspell-dictionaries
Recommends:     aspell
Recommends:     aspell-en
Recommends:     hunspell
Recommends:     myspell-en_US
Conflicts:      suse-xsl-stylesheets < 2.0.9


%description
English Dictionaries for aspell, Hunspell, and Vim to spellcheck SUSE and
openSUSE documentation.

#--------------------------------------------------------------------------

%prep
%setup -q -n %{name}-%{version}

#--------------------------------------------------------------------------

%build
%__make %{?_smp_mflags}

#--------------------------------------------------------------------------

%install
make install DESTDIR=%{buildroot} LIBDIR=%{_libdir}

# License
mkdir -p %{buildroot}%{_defaultdocdir}/%{name}
cp LICENSE %{buildroot}%{_defaultdocdir}/%{name}
chmod 644 %{buildroot}%{_defaultdocdir}/%{name}/*

# Extra symlinks for backward compatibility
mkdir -p %{buildroot}%{_datadir}/suse-xsl-stylesheets/aspell
cd %{buildroot}%{_datadir}/suse-xsl-stylesheets/aspell && \
  ln -s ../../suse-documentation-dicts/en/en_US-suse-doc-aspell.rws \
    %{compatfile}
chmod 644 %{buildroot}%{_datadir}/%{compatdir}/%{compatfile}


%files
%defattr(-,root,root)

%dir %{_datadir}/suse-documentation-dicts
%dir %{_datadir}/suse-documentation-dicts/en
%dir %{_datadir}/suse-xsl-stylesheets
%dir %{_datadir}/suse-xsl-stylesheets/aspell
%dir %{_defaultdocdir}/%{name}

%{_datadir}/hunspell/en_US-suse-doc.dic
%{_datadir}/suse-documentation-dicts/en/en_US-suse-doc-aspell.rws
%{_datadir}/vim/current/spell/en-suse-doc.utf-8.spl
%{_datadir}/suse-xsl-stylesheets/aspell/en_US-suse-addendum.rws

%doc %{_defaultdocdir}/%{name}/*

%changelog
