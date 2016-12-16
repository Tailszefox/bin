#!/bin/bash

# Recreate hard links if the file exists both in the current directory and in the ~/bin directory

find . -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' f; do
    echo "Analyse de $f"
    ls -l ~/bin/$f

    if [[ -f ~/bin/$f ]]; then
        echo "Recréation du lien"
        rm "$f"
        ln ~/bin/$f .
    fi

    echo
done

