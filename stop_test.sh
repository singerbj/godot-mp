#!/usr/bin/env bash

pid_file=".godot_pids"

if test -f "$pid_file"; then
    while IFS= read -r line
    do
        kill -9 "$line" > /dev/null 2>&1
    done < "$pid_file"

    rm -f "$pid_file"

fi
