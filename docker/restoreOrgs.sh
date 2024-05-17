#!/bin/bash
for file in /home/krg/sfAuthFiles/*; do
    sf org login sfdx-url --sfdx-url-file "$file"
done

rm -rf /home/krg/sfAuthFiles