#!/usr/bin/env bash

./stop_test.sh

logs_folder=./logs
if [ ! -d "$logs_folder" ]; then
    echo "$FILE is a directory."
    mkdir "$logs_folder"
fi

number_of_clients=$1
if [ "$number_of_clients" == "" ]; then
    number_of_clients=1
fi

echo "Starting server"
godot server > $logs_folder/server.log 2>&1 &
echo $! > .godot_pids

for i in $(seq 1 $number_of_clients);
do
    echo "Starting client $i"
    godot client > $logs_folder/client$i.log 2>&1 &
    echo $! >> .godot_pids
done
