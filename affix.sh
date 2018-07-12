#!/bin/bash
# Expands the word list by affixing affixes.
# Usage: $0 WORD_LIST > NEW_LIST   # to generate plain text word list
# Usage: $0 WORD_LIST validate     # to validate input word list

function error() {
  >&2 echo $1
  [[ $2 == '0' ]] && exit $2
  exit 1
}

function validate() {
  # $1 - word list

  # $'...' creates C-style strings.
  [[ $(echo -e "$1" | grep $'\r') ]] && known+="File contains CR characters for line ends. Use LF only.\n"
  [[ $(echo -e "$1" | grep ' $') ]] && known+="File contains trailing whitespace. Remove it.\n"
  [[ $(echo -e "$1" | grep '^ ') ]] && known+="File contains leading whitespace. Remove it.\n"
  [[ $(echo -e "$1" | grep $'\t') ]] && known+="File contains tabs. Remove/replace them.\n"
  if [[ "$known" ]]; then
    >&2 echo -e "$known"
    return 1
  fi
  result=$(echo -e "$1" | sed -r 's_^[^ \t]+( \+([-'\''!?.:;@#%=<>]|\w)+(/([-'\''!?.:;@#%=<>]|\w)+)?)*$__' | sed -n '/./ p')
  if [[ "$result" ]]; then
    resultanalysis=
    errorlen=$(echo -e "$result" | wc -l)
    for line in $(seq 1 $errorlen); do
      thisline=$(echo -e "$result" | sed -n "$line p")
      if [[ $(echo -e "$thisline" | grep -P "  ") ]]; then
        resultanalysis+="$thisline\n^ Line contains multiple consecutive spaces.\n"
      elif [[ $(echo -e "$thisline" | grep -P " [^+]") ]]; then
        resultanalysis+="$thisline\n^ Affix value without prefixed + character.\n"
      elif [[ $(echo -e "$thisline" | grep -P " \+[^/]*(/[^/]*){2,}") ]]; then
        resultanalysis+="$thisline\n^ Affix value must only contain one / character.\n"
      elif [[ $(echo -e "$thisline" | grep -P " \+[^ ]*[^- '!?.:;@#%=<>a-zA-Z0-9_][^ ]*") ]]; then
        resultanalysis+="$thisline\n^ Affix value contains invalid characters. (Allowed: A-Z, a-z, 0-9, and _-'!?.:;@#%=<>)\n"
      else
        resultanalysis+="$thisline\n^ Undiagnosed validation issue found.\n"
      fi
    done
    >&2 echo "Problematic lines:"
    >&2 echo -e "$resultanalysis"
    return 1
  fi
}

function addaffixes() {
  # $1 - current line

  output=""
  if [[ $(echo "$1" | grep -o ' ') ]]; then
    word=$(echo "$1" | cut -d ' ' -f 1)
    line=$(echo "$1" | cut -d ' ' -f 2-)
    output="$word"
    while [[ "$line" ]]; do
      # we only support suffixes right now. prefixes would complicate this
      # thing a bit.
      affix=$(echo "$line" | cut -d ' ' -f 1)
      [[ $(echo "$line" | grep -o ' ') ]] || line=''
      line=$(echo "$line" | cut -d ' ' -f 2-)

      affix=$(echo "$affix" | sed -r 's/(^\+|\+$)//')

      wordprepared="$word"
      if [[ $(echo "$affix" | grep '/') ]]; then
        replace=$(echo "$affix" | cut -d '/' -f 1)
        wordprepared=$(echo "$word" | sed -r "s/$replace\$//")
        affix=$(echo "$affix" | cut -d '/' -f 2)
      fi

      output+="\n${wordprepared}${affix}"
    done
  else
    output="$1"
  fi

  echo -e "$output"
}

[[ ! -f "$1" ]] && error "File $1 does not exist."

wordlist=$(cat "$1")

validate "$wordlist"
[[ $? == 1 ]] && error "File $1 does not validate."

[[ $2 == 'validate' ]] && error "File $1 validates." 0

len=$(echo -e "$wordlist" | wc -l)

for line in $(seq 1 $len); do
  thisline=$(echo -e "$wordlist" | sed -n "$line p")
  addaffixes "$thisline"
done
