#!/bin/bash 
# make a script which will produce a VCF for a gene from the plink WES files

gene=$1

refGeneFile=~/reference38/refseqgenes.hg38.20191018.sorted.onePCDHG.txt
prologue=~/UKBB/RAPfiles/RAPscripts/makeGeneWESVCF.prologue.20241025.sh
# dataFileSpec=ukb23155_c - this has changed! (hope the data has not)
dataFileSpec=ukb23158_c

extractGeneCoords=' BEGIN { start=300000000; end=0 } { chr= $3; if ($5<start) start=$5; if ($6>end) end=$6 } END { print chr, start, end }'
geneArgs=`grep -w $gene $refGeneFile | awk "$extractGeneCoords"`

coords=($geneArgs)
chr=${coords[0]/chr/} # removes chr, see https://stackoverflow.com/questions/19551613/modify-the-content-of-variable-using-sed-or-something-similar
start=${coords[1]}
end=${coords[2]}

scriptName=extractWES.$gene.sh

cp $prologue $scriptName

for e in bim bed
do
	echo dxdownload $dataFileSpec${chr}_b0_v1.$e >> $scriptName
done
echo dxdownload ${dataFileSpec}22_b0_v1.fam >> $scriptName # used by arg file

echo date >>$scriptName

echo ls -lrt >>$scriptName
echo ./geneVarAssoc --arg-file '$argFile' --gene $gene >>$scriptName
echo mv gva.$gene.cont.1.vcf $gene.WES.vcf >>$scriptName
echo date >>$scriptName
echo ls -lrt >>$scriptName


echo bgzip $gene.WES.vcf >>$scriptName
echo date >>$scriptName
echo tabix -p vcf $gene.WES.vcf.gz >>$scriptName
echo date >>$scriptName
echo ls -lrt >>$scriptName

echo 'cd $HOMEDIR' >>$scriptName
echo cd WES/VCFs >>$scriptName
echo cp '~/workdir/'$gene.WES.vcf.gz $gene.WES.fromPlink.vcf.gz >>$scriptName
echo cp '~/workdir/'$gene.WES.vcf.gz.tbi $gene.WES.fromPlink.vcf.gz.tbi >>$scriptName
# do not allow ~/workdir to be expanded on the local computer
echo date >>$scriptName

echo 'cd $HOMEDIR' >>$scriptName # so I can run multiple scripts in same session

echo "# dx cd /scripts ; dxupload $scriptName" >>$scriptName
echo "# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/$scriptName -icmd=\"bash $scriptName\"" >>$scriptName
echo "# maybe use ssd for this"  >>$scriptName
