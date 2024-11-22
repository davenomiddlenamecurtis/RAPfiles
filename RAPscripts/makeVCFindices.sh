#!/bin/bash 

cd ~/UKBB/WGS

allChrs="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X"

for c in $allChrs
do
	zcat dragen_pvcf_coordinates.zip | grep ",chr$c," | sort -t"," --key=3g | sed 's/,/\t/g' > dragen_pvcf_coordinates.$c.txt
done
