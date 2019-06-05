#!/bin/bash

# Recreate hard links if the file exists both in the current directory and in the ~/bin directory

find . -maxdepth 1 -type f | while read f; do
    filename=$(basename $f)
    echo "Analyzing $filename"

    if [[ -f ~/bin/$filename ]]; then
        echo "Recreating hard link: ~/bin/$filename -> ./$filename"
        rm "$f"
        ln ~/bin/$filename .
    else
        echo "$filename not found in ~/bin"
    fi

    echo
done

