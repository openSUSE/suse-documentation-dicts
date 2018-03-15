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
  result=$(echo -e "$1" | sed -r 's_^[^ \t]+( \+([-'\''!?.:;@#%=<>]|\w)+(/([-'\''!?.:;@#%=<>]|\w)+)?)*$__' | sed -n '/./ p')
  if [[ "$result" ]]; then
    >&2 echo "Problematic lines:"
    >&2 echo "$result"
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

wordlist=$(cat $1)

validate "$wordlist"
[[ $? == 1 ]] && error "File $1 does not validate."

[[ $2 == 'validate' ]] && error "File $1 validates." 0

while [[ "$wordlist" ]]; do
  thisline=$(echo -e "$wordlist" | head -1)
  addaffixes "$thisline"
  wordlist=$(echo -e "$wordlist" | tail -n +2)
done
