## Spellcheck Dictionary for SUSE Documentation

This dictionary improves the spellchecking experience for SUSE and openSUSE
documentation by providing an extra word list that can be used in addition
to the regular en_US dictionary.

### Installing the package version of the dictionaries

For openSUSE Leap and Tumbleweed users, the easiest option is installing the
packaged version of the dictionaries from
https://build.opensuse.org/package/show/Documentation:Tools/suse-documentation-dicts-en.


### Building a wordlist

To update our custom dictionaries, it may be useful to output a list of words
that hunspell would find.

Before you can get a list, you need to apply the `cleanup.xsl` stylesheet on
your XML file. This will eliminate all elements that are not relevant for spell-checking (like etc.).

1. Install some packages:

     ```
     sudo zypper install hunspell aspell
     ```

1. Rebuild the dictionaries:

     ```
     make
     ```

   After the command was successful, a new directory `build/` appears with the
   file `en_US-suse-doc.dic`.


1. Cleanup your DocBook file (replace `FILE` with the real file name):

     ```
     export DICPATH="$PWD/build/"
     xsltproc --xinclude cleanup.xsl FILE | hunspell -H -i utf-8 -d en_US,en_US-suse-doc -l | sort | uniq
     ```

    The options mean:
    
    `-H`: The input file is in SGML/HTML format.
    `-i`: Set input encoding
    `-d`: Set dictionaries by their base names with or without paths.
    `-l`: The "list" option is used to produce a list of misspelled words from the standard input.

1. Investigate the output and add new words to the file list, if needed.


### Building the Dictionaries

This repository allows for building an aspell RWS file, a Hunspell DIC file,
and a Vim SPL file.

Make sure you have the following dependencies installed:

* GNU Make
* sed, iconv, and other standard Unix tools
* aspell
* vim

To build the dictionaries for aspell and Hunspell, run:

```
make
```

To create a source TAR ball, run:

```
make dist
```

To install locally, run:

```
make install
```


### Using the Dictionaries

The following section assumes the dictionary files are located at the
path that the openSUSE RPM package installs to.


#### DAPS & aspell

```
daps -d DC-DOCUMENT spellcheck \
  --extra-dict="/usr/share/suse-documentation-dicts/en/en_US-suse-doc-aspell.rws"

```


#### DAPS & Hunspell

[MISSING]


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


#### Hunspell

```
hunspell -H -i utf-8 -d en_US,en_US-suse-doc FILE
```

#### Vim Word List & Vim

After the dictionaries are installed, you can load the Vim version with:

```
:set spelllang=en,en-suse-doc
```

#### oXygen

oXygen comes with its own spell checker and cannot use the aspell
directory. However, a tool to build custom dictionaries from wordlists
is available from (http://www.xmlmind.com/xmleditor/dictbuilder.shtml).

0. Download the ZIP archive from
   (http://www.xmlmind.com/xmleditor/dictbuilder.shtml)
   and unpack it.

1. Build the dictionary as a plain-text file:

   ```
   ./<PATH TO THIS REPO>/affix.sh <PATH TO THIS REPO>/suse_wordlist.txt > \
   <PATH TO THIS REPO>/wordlist_affixed.txt
   ```

2. Create the dictionary

   Run the following command:

   ```
   <PATH TO DICTBUILDER-DIRECTORY>/dictbuilder -cs utf8 \
   <PATH TO THIS REPO>/wordlist_affixed.txt \
   -o <PATH TO THIS REPO>/do-not-package/oxygen/en-US-SUSE/spec.cdi
   ```

3. Add the SUSE dictionary to the oXygen dictionaries.
   Run the following two commands:

   ```
   cd <PATH TO THIS REPO>/do-not-package/oxygen

   zip -9 -r <PATH TO OXYGEN DIRECTORY>/dicts/en.dar \
   en-US-SUSE/
   ```

4. Restart oXygen and go to Options -> Preferences -> Spell Check.

5. In 'Default Language' for spell checking, select the newly created dictionary: English (US + SUSE)

### Adding Words

To add words, add them to the file `suse_wordlist.txt`. Apply a bit of
hygiene, though:

* Avoid duplicating regular dictionary words and words that are already in
  the list.

* Sort and validate the file: Edit the list, then run `make sortvalid` before
  committing.

The word list format supports suffixes dictionary words to avoid word
repetitions. Suffixes are appended to the regular entry this way:

```
entry +suffix +y/iesuffix
```

This produces the following three words in the output word list:

```
entry
entrysuffix
entriesuffix
```

* There must be exactly one space before each suffix definition.
* Suffix definition start with a `+` character.
* There are two forms of suffixes:
  * Without replacement, like `+suffix`: the characters `suffix` are appended
    to the entry.
  * With replacement, like `y/iesuffix`: the character `y` is removed from the
    end of the entry and `iesuffix` is appended.
