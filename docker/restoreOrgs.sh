#!/bin/bash
for file in ./sfAuthFiles/*; do
    sf org login sfdx-url --sfdx-url-file "$file" --alias $(basename $file .json)
done

rm -rf ./sfAuthFiles