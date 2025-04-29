#!/bin/bash
hostname=$1
barman_dir=$2
pattern="*.conf"
cd $barman_dir

for filename in *; do
        echo "Filename: $filename"
        if [ $filename == "$hostname.conf.disabled" ]
        then
                echo "Enabled config file $hostname.conf"
                mv $filename $hostname.conf
                continue
        elif [ $filename == "$hostname.conf" ]
        then
                echo "Config file $filename is already enable before"
                continue
        elif [[ $filename == $pattern ]]
        then
                mv $filename $filename.disabled
                echo "Disabled config file: $filename.disabled"
        fi
done
