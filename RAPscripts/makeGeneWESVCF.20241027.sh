#!/bin/bash 
# make a script which will extract a VCF for a gene from the WES VCF data

gene=$1

refGeneFile=~/reference38/refseqgenes.hg38.20191018.sorted.onePCDHG.txt
prologue=~/UKBB/RAPfiles/RAPscripts/makeGeneWESVCF.prologue.20241027.sh
# dataFileSpec=ukb23155_c - this has changed! (hope the data has not)

extractGeneCoords=' BEGIN { start=300000000; end=0 } { chr= $3; if ($5<start) start=$5; if ($6>end) end=$6 } END { print chr, start, end }'
geneArgs=`grep -w $gene $refGeneFile | awk "$extractGeneCoords"`

coords=($geneArgs)
chr=${coords[0]/chr/} # removes chr, see https://stackoverflow.com/questions/19551613/modify-the-content-of-variable-using-sed-or-something-similar
start=${coords[1]}
end=${coords[2]}

scriptName=extractWES.$gene.sh

cp $prologue $scriptName
fileList=neededVCFs.$gene.txt
index=~/UKBB/WES/field_23157_pVCF_500k_Exome_starter_pos.chr$chr.txt
getFiles='{ if ($3>start) { print last } ; last=$1; if ($3 > end) { exit } }'
awk -v start=$start -v end=$end "$getFiles" $index > $fileList

cat $fileList | while read f
do
	echo date >>$scriptName
	echo dxdownload $f >>$scriptName
done

cat $fileList | while read f
do
	echo date >>$scriptName
	echo dxdownload $f.tbi >>$scriptName
done

echo date >>$scriptName
echo tabix -h `head -n 1 $fileList` chrY:0-0 "> $gene.WES.vcf" >>$scriptName
echo wc $gene.WES.vcf  >>$scriptName

cat $fileList | while read f
do
	echo date >>$scriptName
	echo ls -lrt >>$scriptName
	echo 'echo --add-chr 1 > useTheseGenotypes.arg' >>$scriptName
	echo ./geneVarAssoc --arg-file '$argFile' --case-file $f --gene $gene >>$scriptName
	echo mv gva.$gene.case.1.vcf $f.WES.vcf >>$scriptName
	echo 'echo --add-chr 0 > useTheseGenotypes.arg' >>$scriptName
	echo ./geneVarAssoc --arg-file '$argFile' --case-file $f --gene $gene >>$scriptName
	echo mv gva.$gene.case.1.vcf $f.WES.noChr.vcf >>$scriptName
done
echo date >>$scriptName
echo ls -lrt >>$scriptName

cat $fileList | while read f
do
	echo date >>$scriptName
	echo cat $f.WES.vcf  "| grep -v '^\#' >>$gene.WES.vcf"  >>$scriptName
done
echo date >>$scriptName

echo bgzip $gene.WES.vcf >>$scriptName
echo date >>$scriptName
echo tabix -p vcf $gene.WES.vcf.gz >>$scriptName
echo date >>$scriptName
echo ls -lrt >>$scriptName

echo 'cd $HOMEDIR' >>$scriptName
echo cd WES/VCFs >>$scriptName
echo cp '~/workdir/'$gene.WES.vcf.gz . >>$scriptName
echo cp '~/workdir/'$gene.WES.vcf.gz.tbi . >>$scriptName
# do not allow ~/workdir to be expanded on the local computer
echo date >>$scriptName

echo 'cd $HOMEDIR' >>$scriptName # so I can run multiple scripts in same session

echo "# dx cd /scripts ; dxupload $scriptName" >>$scriptName
echo "# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/$scriptName -icmd=\"bash $scriptName\"" >>$scriptName
echo "# maybe use ssd for this"  >>$scriptName
