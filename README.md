## Spellcheck Dictionary for SUSE Documentation

This dictionary improves the spellchecking experience for SUSE and openSUSE
documentation by providing an extra word list that can be used in addition
to the regular en_US dictionary.

### Building the Dictionaries

This repository allows for building an aspell RWS file and a Hunspell-compatible
plain-text word list.

Make sure you have the following dependencies installed:

* GNU Make
* sed, iconv, and other standard Unix tools
* aspell

To build the dictionaries for aspell and Hunspell, run:

```
make
```

To create a source TAR ball, run:

```
make
```

To install locally, run:

```
make install
```


### Using the Dictionaries

#### aspell Command line

```
aspell --mode=sgml --encoding=utf-8 --lang=en_US \
--extra-dicts="/usr/share/suse-documentation-dicts/en/en_US-suse-doc-aspell.rws" \
FILE
```

#### aspell & Emacs

Add the following lines to your Emacs configuration file:

```
(add-hook 'sgml-mode-hook
  '(lambda ()
  (setq ispell-program-name "aspell")
  (ispell-change-dictionary "american")
  (setq ispell-extra-args
    '("--extra-dicts=/usr/share/suse-documentation-dicts/en/en_US-suse-doc-aspell.rws"))))
```

#### oXygen

(This is probably horribly outdated)

oXygen comes with its own spell checker and cannot use the aspell
directory. However, a tool to build custom dictionaries from wordlists
is available from (http://www.xmlmind.com/xmleditor/dictbuilder.shtml).

0. Download the ZIP archive from
   (http://www.xmlmind.com/xmleditor/dictbuilder.shtml)
   and unpack it in this directory.

1. Create the dictionary

   Run the following command:

   ```
   <PATH TO DICTBUILDER-DIRECTORY>/dictbuilder -cs utf8 \
   <PATH TO THIS REPO>/suse_wordlist.txt \
   -o <PATH TO THIS REPO>/do-not-package/oxygen/en-US-SUSE/spec.cdi
   ```

2. Add the SUSE dictionary to the oXygen dictionaries.
   Run the following two commands:

   ```
   cd <PATH TO THIS REPO>/do-not-package/oxygen

   zip -9 -r <PATH TO OXYGEN DIRECTORY>/dicts/en.dar \
   en-US-SUSE/
   ```

   Restart oXygen and go to Options -> Preferences -> Spell Check.

There now is a new dictionary available: English (US + SUSE)

### Adding Words

To add words, add them to the file `suse_wordlist.txt`. Apply a bit of
hygiene, though:

* Avoid duplicating regular dictionary words and words that are already in
  the list.

* Make sure the file is sorted, to help others working on it later.
