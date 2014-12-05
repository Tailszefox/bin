#!/bin/bash

if [[ $# -eq 0 ]]
then
    exit
fi

if [[ $# -eq 2 ]]
then
    numLetter=$2
else
    numLetter=1
fi

echo $numLetter

dirArg="$1"
dir=`readlink -f "$dirArg"`

echo $dir
cd "$dir"

regex="[a-z0-9]"

find . -type f -print0 | while read -d $'\0' f
do
    name=`echo "$f"|sed 's/ -.*//'`
    name=${name:2}
    letter=`echo "$name" |cut -c$numLetter | tr '[:upper:]' '[:lower:]'`

    if [[ ! $letter =~ $regex ]]
    then
        letter="misc"
    fi

    mkdir -p "$letter"
    mv -v "$f" "$letter"
done