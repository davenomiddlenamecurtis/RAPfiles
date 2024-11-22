#!/bin/bash 
# make a script which will produce a new VCF spanning all transcripts of a gene

gene=$1

refGeneFile=~/reference38/refseqgenes.hg38.20191018.sorted.onePCDHG.txt
prologue=~/UKBB/RAPfiles/RAPscripts/makeGeneExonsVCF.prologue.20240927.sh

extractGeneCoords=' BEGIN { start=300000000; end=0 } { chr= $3; if ($5<start) start=$5; if ($6>end) end=$6 } END { print chr, start, end }'
geneArgs=`grep -w $gene $refGeneFile | awk "$extractGeneCoords"`

name=$gene
coords=($geneArgs)
chr=${coords[0]}
start=${coords[1]}
end=${coords[2]}

scriptName=extractExons.$name.sh
fileList=neededVCFs.$name.txt

cp $prologue $scriptName

echo dx cd $chr >> $scriptName

index=~/UKBB/WGS/dragen_pvcf_coordinates.$chr.txt
getFiles='{ if ($3>start) { print last } ; last=$1; if ($3 > end) { exit } }'

awk -v start=$start -v end=$end "$getFiles" $index > $fileList

echo date >>$scriptName
cat $fileList | while read f
do
	echo date >>$scriptName
	echo dx download $f >>$scriptName
done


echo date >>$scriptName
cat $fileList | while read f
do
	echo date >>$scriptName
	echo dx download $f.tbi >>$scriptName
done

echo date >>$scriptName
# echo zcat `head -n 1 $fileList` "| grep '^\#'" "> $name.exons.vcf" >>$scriptName
# maybe tabix will be quicker, or else use head so do not have to grep the whole file
echo tabix -h `head -n 1 $fileList` chrY:0-0 "> $name.exons.vcf" >>$scriptName
echo wc $name.exons.vcf  >>$scriptName

cat $fileList | while read f
do
	echo date >>$scriptName
	echo ls -lrt >>$scriptName
	echo ./geneVarAssoc --arg-file '$argFile' --case-file $f --gene $gene >>$scriptName
	echo mv gva.$name.case.1.vcf $f.exons.vcf >>$scriptName
done
echo date >>$scriptName
echo ls -lrt >>$scriptName

cat $fileList | while read f
do
	echo date >>$scriptName
	echo cat $f.exons.vcf  "| grep -v '^\#' >>$name.exons.vcf"  >>$scriptName
done
echo date >>$scriptName

echo date >>$scriptName
echo ls -lrt >>$scriptName

echo bgzip $name.exons.vcf >>$scriptName
echo date >>$scriptName
echo tabix -p vcf $name.exons.vcf.gz >>$scriptName
echo date >>$scriptName
echo ls -lrt >>$scriptName

echo pushd >>$scriptName
echo date >>$scriptName
echo 'cp ~/workdir/'$name.exons.vcf.gz . >>$scriptName
echo 'cp ~/workdir/'$name.exons.vcf.gz.tbi . >>$scriptName
echo date >>$scriptName

echo 'cd $HOMEDIR' >>$scriptName # so I can run multiple scripts in same session

echo "# dx cd /scripts ; dxupload $scriptName" >>$scriptName
echo "# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/$scriptName -icmd=\"bash $scriptName\"" >>$scriptName
echo "# maybe use ssd for this"  >>$scriptName