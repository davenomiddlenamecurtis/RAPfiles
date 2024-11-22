#!/bin/bash 
# make a script which will produce a new VCF spanning all transcripts of a gene

gene=$1

refGeneFile=~/reference38/refseqgenes.hg38.20191018.sorted.onePCDHG.txt
extractScript=~/UKBB/RAPfiles/RAPscripts/makeExtractedVCF.20240926.sh

extractGeneCoords=' BEGIN { start=300000000; end=0 } { chr= $3; if ($5<start) start=$5; if ($6>end) end=$6 } END { print chr, start, end }'
geneArgs=`grep -w $gene $refGeneFile | awk "$extractGeneCoords"`
bash $extractScript $gene $geneArgs