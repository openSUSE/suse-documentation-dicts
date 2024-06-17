## Spell-check dictionaries for SUSE documentation

The dictionaries expand spell-checking capabilities for SUSE and openSUSE 
documentation by incorporating extra word lists that can be used alongside
the standard en_US dictionary.

## Installation

Install the dictionaries from your distribution packages or build them manually.

### Installing the package version of the dictionaries

* For openSUSE Leap and Tumbleweed users, the easiest option is installing the
  packaged version of the dictionaries from
  https://build.opensuse.org/package/show/Documentation:Tools/suse-documentation-dicts-en.
* For Debian and Ubuntu users, find the package at
  https://build.opensuse.org/package/show/home:tbazant/suse-documentation-dicts.


### Building the dictionaries

This repository allows for building an aspell RWS file, a Hunspell DIC file
and a Vim SPL file.

Make sure you have the following dependencies installed: `make`, `sed`, `iconv`,
`aspell` and `vim`.

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


## Using the dictionaries

The following section assumes the dictionary files are located at the path that
your distribution package installs to.


### DAPS & aspell

```
daps -d DC-DOCUMENT spellcheck \
  --extra-dict="/usr/share/suse-documentation-dicts/en/en_US-suse-doc-aspell.rws"

```


### DAPS & Hunspell

[MISSING]


### aspell command line

```
aspell --mode=sgml --encoding=utf-8 --lang=en_US \
--extra-dicts="/usr/share/suse-documentation-dicts/en/en_US-suse-doc-aspell.rws" \
FILE
```

### aspell & Emacs

Add the following lines to your Emacs configuration file:

```
(add-hook 'sgml-mode-hook
  '(lambda ()
  (setq ispell-program-name "aspell")
  (ispell-change-dictionary "american")
  (setq ispell-extra-args
    '("--extra-dicts=/usr/share/suse-documentation-dicts/en/en_US-suse-doc-aspell.rws"))))
```


### Hunspell

```
hunspell -H -i utf-8 -d en_US,en_US-suse-doc FILE
```

### Vim word list & Vim

After the dictionaries are installed, you can load the Vim version with:

```
:set spelllang=en,en-suse-doc
```

### oXygen

oXygen comes with its own spell checker and cannot use the aspell
directory. However, a tool to build custom dictionaries from word lists
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

### Adding words

The dictionaries include a word list of correct words that are not part of the
standard English dictionaries. The list of acceptable words is updated as 
writers discover words that are correct but not yet included. To improve 
spell checking, please collect words that the spell checker flags as incorrect 
but you believe are correct.

TIP: If you are using VSCode, you probably have such a file already. Check if the
`SUSE-adWords-dict.dic` file exists. If yes, VSCode lets you add the suspect
word to this dictionary by clicking the corresponding small yellow bulb next to
the affected line.

Once you collect a certain amount of new words, follow these steps:

1. Clone the `https://github.com/openSUSE/suse-documentation-dicts` repository
   if you have not already done so.
  ```
  git clone git@github.com:openSUSE/suse-documentation-dicts.git
  ```
2. Create a branch for your changes, for example:
  ```
  git branch tbazant-adding-custom-words
  ```
3. Checkout to this branch, manually or, for example, in VSCode source control pane.
  ```
  git checkout tbazant-adding-custom-words
  ```
4. Edit the `suse_wordlist.txt` file and add all your words to the end of the
  existing list. Avoid duplicating regular dictionary words and words that are
  already in the list.

    TIP: The word list format supports defining suffixes to avoid word
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
    * The suffix definition starts with a `+` character.
    * There are two forms of suffixes:
      * Without replacement, like `+suffix`: the characters `suffix` are appended
        to the entry.
      * With replacement, like `y/iesuffix`: the character `y` is removed from the
    end of the entry and `iesuffix` is appended.

  5. Sort and validate the enhanced word list file:
    ```
    make sortvalid
    ```

  6. Commit the changes to your branch:
    ```
    git commit -m 'Added my custom word list'
    ```
  7. Create a pull request on GitHub and assign it to Daria (@dariavladykina)
     who will verify if the new words are relevant and correct.

