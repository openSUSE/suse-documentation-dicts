# Makefile for suse-documentation-dicts-en
#
# Copyright (C) 2011-2018 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
# Stefan Knorr <sknorr@suse.de>
#

ifndef PREFIX
  PREFIX := /usr/share
endif

LANG					:= en_US.UTF-8
export LANG
SHELL         := /bin/bash
PACKAGE       := suse-documentation-dicts-en
VERSION       := 9
CDIR          := $(shell pwd)
DIST_EXCLUDES := packaging/package-excludes.txt

VIM_DICT      := en-suse-doc
ASPELL_DICT   := en_US-suse-doc-aspell.rws
HUNSPELL_DICT := en_US-suse-doc.dic

BUILD_DIR            := build
INSTALL_DIR          := $(DESTDIR)$(PREFIX)/suse-documentation-dicts/en
INSTALL_DIR_VIM      := $(DESTDIR)$(PREFIX)/vim/current/spell
INSTALL_DIR_HUNSPELL := $(DESTDIR)$(PREFIX)/hunspell

AFFIX_BUILD           := $(BUILD_DIR)/suse_wordlist_affixed.txt
VIM_PATH_BUILD        := $(BUILD_DIR)/$(VIM_DICT)
ASPELL_PATH_BUILD     := $(BUILD_DIR)/$(ASPELL_DICT)
HUNSPELL_PATH_BUILD   := $(BUILD_DIR)/$(HUNSPELL_DICT)
VIM_PATH_INSTALL      := $(INSTALL_DIR_VIM)/$(VIM_DICT)
ASPELL_PATH_INSTALL   := $(INSTALL_DIR)/$(ASPELL_DICT)
HUNSPELL_PATH_INSTALL := $(INSTALL_DIR_HUNSPELL)/$(HUNSPELL_DICT)

SORT := sort -u

all: $(VIM_PATH_BUILD).utf-8.spl $(ASPELL_PATH_BUILD) $(HUNSPELL_PATH_BUILD)

.INTERMEDIATE: $(AFFIX_BUILD)
$(AFFIX_BUILD): suse_wordlist.txt | $(BUILD_DIR)
	bash affix.sh $< | $(SORT) > $@

$(HUNSPELL_PATH_BUILD): $(AFFIX_BUILD) | $(BUILD_DIR)
	wc -l $< > $@
	cat $< >> $@

$(VIM_PATH_BUILD).utf-8.spl: $(AFFIX_BUILD) | $(BUILD_DIR)
	LANG=en_US.UTF-8 vim -N -u NONE -n -c "set nomore" -c "mkspell! $(VIM_PATH_BUILD) $<" -c "q"


# aspell can't handle things like L3 or Wi-fi (i.e. tokens with numbers or
# punctuation in between). We just split those up, if it makes sense, i.e.:
# * "L3" -> "L" -> nothing (because spell-checking "L" does not make sense)
# * "Wi-fi" -> "Wi" + "fi".
# Apparently, it also can't handle UTF-8. Wonderful language software.

$(ASPELL_PATH_BUILD): $(AFFIX_BUILD) | $(BUILD_DIR)
	cat $<                                | \
	sed -r 's/(\W|_|[0-9])+/\n/g'         | \
	sed -n '/../ p'                       | \
	iconv -f 'UTF-8' -t 'ASCII//TRANSLIT' | \
	$(SORT) | aspell --lang=en create master ./$@

# directly install (don't)
.PHONY: install
install: $(INSTALL_DIR) $(INSTALL_DIR_VIM) $(INSTALL_DIR_HUNSPELL)
	install -m644 $(VIM_PATH_BUILD).utf-8.spl $(INSTALL_DIR_VIM)
	install -m644 $(ASPELL_PATH_BUILD) $(ASPELL_PATH_INSTALL)
	install -m644 $(HUNSPELL_PATH_BUILD) $(HUNSPELL_PATH_INSTALL)

$(BUILD_DIR) $(INSTALL_DIR) $(INSTALL_DIR_VIM) $(INSTALL_DIR_HUNSPELL):
	@mkdir -p $@

# Create TAR ball
.PHONY: dist
dist: | $(BUILD_DIR)
	@tar cfjhP $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2 \
	  -C $(CDIR) --exclude-from=$(DIST_EXCLUDES) \
	  --transform 's:^$(CDIR):$(PACKAGE)-$(VERSION):' $(CDIR)
	@echo "Successfully created $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2"

.PHONY: sortvalid
sortvalid: suse_wordlist.txt
	./affix.sh $< validate
	$(SORT) $< > $<.0
	mv $<.0 $<

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
