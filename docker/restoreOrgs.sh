#!/bin/bash
for file in /home/krg/sfAuthFiles/*; do
    $filename = basename $file .json
    sf org login sfdx-url --sfdx-url-file "$file" --alias $filename
done

rm -rf /home/krg/sfAuthFiles