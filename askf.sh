#!/bin/zsh

if [ $# -lt 2 ]; then
    echo "Usage: askf PROMPT FILE [FILE...]"
    exit 1
fi

prompt=$1
shift
files=("$@")

{
    for file in "${files[@]}"; do
        cat "$file"
    done
    echo "$prompt"
} | tr -d '\n' | ask