#!/bin/bash

old=$1
new=$2

for f in *.{json,sh}
do
    sed -i .bak -e "s/${old}/${new}/g" $f
done
rm *.bak

