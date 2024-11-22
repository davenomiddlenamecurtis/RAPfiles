#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app
# need to have run 
# dx cd /
# before submitting this
# then results will end up in subfolders of /results
# this script takes on gene as an argument and assumes that the file /WGS/VCFs/GENE.vcf.gz exists
# in this case, there is not much lost by treating each gene separately because this vcf will be the biggest download

set -x 

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

testName=$1
gene=$2
extraFileList=$3 # probably for.$testName.lst
extraArgs="$4 $5 $6 $7 $8 $9" # for geneVarAssoc, so test can be specified
argFile=gva.$testName.arg
vcf=$gene.exons.vcf.gz

HOMEDIR=`pwd`

mkdir results # probably in folder ~/out/out
mkdir results/$testName
mkdir results/$testName/geneResults
mkdir results/$testName/failed

mkdir ~/workdir
pushd ~/workdir
dx cd /fileLists
dx download $extraFileList
cat $extraFileList | while read f
do
	dx download $f
done
dx cd /WGS/VCFs/
dx download $vcf
dx cd /annot
dx download ukb23158.annot.vcf.gz
dx cd /pars
dx download $argFile
dx cd /bin
dx download scoreassoc
dx download geneVarAssoc
chmod 755 scoreassoc geneVarAssoc
PATH=$PATH:.
dx cd /reference38
dx download refseqgenes.hg38.20191018.sorted.onePCDHG.txt
dx cd /annot
dx download ukb23158.annot.vcf.gz.tbi # here to make sure it is newer
dx cd /WGS/VCFs/
dx download $vcf.tbi

geneVarAssoc --arg-file $argFile --gene $gene --case-file $vcf --keep-temp-files 1 $extraArgs
cat $testName.$gene.sh
ls -lrt
if [ -e *.$gene.sco ] # was *.$gene.sao
then
	pushd
	cp ~/workdir/*.$gene.s?o results/$testName/geneResults
	pushd
else
	echo $gene > $gene.failed.txt
	ls -l >> $gene.failed.txt
	wc *.vcf >> $gene.failed.txt
	pushd
	cp ~/workdir/$gene.failed.txt results/$testName/failed
	pushd
fi

popd
cd $HOMEDIR # so potentially a number of these scripts could run in sequence

# invoke with:
# gene=OMA1; model=UKBB.DEMScore.WGS.annot.20240922
# dx rm /results/$testName/geneResults/'*'.$gene.s'?'o ; dx rm /results/$testName/failed/$gene.failed.txt
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin="/scripts/runOneGeneWithFileList.20240922.sh" -icmd="bash runOneGeneWithFileList.20240922.sh $model $gene for.$model.lst extra arguments specifying test"
# info re instance types is here: https://documentation.dnanexus.com/developer/api/running-analyses/instance-types




