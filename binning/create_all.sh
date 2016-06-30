#!/bin/bash

all="${1}/all.txt"
touch $all
echo -e "binner\trank\tbin\tprecision\trecall\tpredicted_size\treal_size" > $all

for f in ${1}*.tsv
do
name="${f##*/}"
name="${name%.tsv}" #get rid of path and ending
{
read
while read p
do
echo -e "${name}\t$p" >> "$all"
done
} < $f
done

#now remove apostrophes because that f*cks up R

