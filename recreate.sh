#!/bin/bash

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