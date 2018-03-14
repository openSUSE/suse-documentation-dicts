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

SHELL         := /bin/bash
PACKAGE       := suse-documentation-dicts-en
VERSION       := 0.1
CDIR          := $(shell pwd)
DIST_EXCLUDES := packaging/package-excludes.txt

ASPELL_DICT   := en_US-suse-doc-aspell.rws
HUNSPELL_DICT := en_US-suse-doc-hunspell.txt

BUILD_DIR     := build
INSTALL_DIR   := $(DESTDIR)$(PREFIX)/suse-documentation-dicts/en

AFFIX_BUILD           := $(BUILD_DIR)/suse_wordlist_affixed.txt
ASPELL_PATH_BUILD     := $(BUILD_DIR)/$(ASPELL_DICT)
HUNSPELL_PATH_BUILD   := $(BUILD_DIR)/$(HUNSPELL_DICT)
ASPELL_PATH_INSTALL   := $(INSTALL_DIR)/$(ASPELL_DICT)
HUNSPELL_PATH_INSTALL := $(INSTALL_DIR)/$(HUNSPELL_DICT)


all: $(HUNSPELL_PATH_BUILD) $(ASPELL_PATH_BUILD)

.INTERMEDIATE: $(AFFIX_BUILD)
$(AFFIX_BUILD): suse_wordlist.txt | $(BUILD_DIR)
	bash affix.sh $< > $@

$(HUNSPELL_PATH_BUILD): $(AFFIX_BUILD) | $(BUILD_DIR)
	cat $< | sort -u > $@

$(ASPELL_PATH_BUILD): $(ASPELL_PATH_BUILD).tmp
	aspell --lang=en create master ./$@ < $<

# aspell can't handle things like L3 or Wi-fi (i.e. tokens with numbers or
# punctuation in between). We just split those up, if it makes sense, i.e.:
# * "L3" -> "L" -> nothing (because spell-checking "L" does not make sense)
# * "Wi-fi" -> "Wi" + "fi".
# Apparently, it also can't handle UTF-8. Wonderful language software.

# FIXME: I should not have to apply the same regex twice to resolve e.g.
# "Cortex-A53" -> "Cortex" + nothing else
.INTERMEDIATE: $(ASPELL_PATH_BUILD).tmp
$(ASPELL_PATH_BUILD).tmp: $(HUNSPELL_PATH_BUILD)
	cat $< | \
	  iconv -f 'UTF-8' -t 'ASCII//TRANSLIT' | \
	  sed -r 's/([-_.,:;!?#@$%^&*~+0-9]+)([^\W\d_]*)/\n\2/g' | \
	  sed -r 's/([-_.,:;!?#@$%^&*~+0-9]+)([^\W\d_]*)/\n\2/g' | \
	  sed -r "s/^'.*//g" | \
	  sed -n '/../ p' | \
	  sort -u \
	  > $@


# directly install (don't)
.PHONY: install
install: $(INSTALL_DIR)
	install -m644 $(ASPELL_PATH_BUILD) $(ASPELL_PATH_INSTALL)
	install -m644 $(HUNSPELL_PATH_BUILD) $(HUNSPELL_PATH_INSTALL)

$(BUILD_DIR) $(INSTALL_DIR):
	@mkdir -p $@

# Create TAR ball
.PHONY: dist
dist: | $(BUILD_DIR)
	@tar cfjhP $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2 \
	  -C $(CDIR) --exclude-from=$(DIST_EXCLUDES) \
	  --transform 's:^$(CDIR):$(PACKAGE)-$(VERSION):' $(CDIR)
	@echo "Successfully created $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2"


.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2	

