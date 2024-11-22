#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app

set -x 

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:
WESdir='/Bulk/Exome sequences/Population level exome OQFE variants, pVCF format - final release'
WGSdir='/Bulk/DRAGEN WGS/DRAGEN population level WGS variants, pVCF format [500k release]'
HOMEDIR=`pwd`
mkdir results
mkdir results/genotypeCounts
cd results/genotypeCounts

mkdir $HOMEDIR/results/tmp
pushd $HOMEDIR/results/tmp


date
dx cd /results/genotypeCounts
dx download 200K.1.58530648.frqx
dx cd /results/tmp
chr=1
pos=58530648
name=1.58530648

for c in 200K 270K
do
	for ew in WES WGS
	do
		dx download $c.OnRAP.$ew.$name.raw
		dx download $c.OnRAP.$ew.$name.frqx
	done
done

ls > downloadedFiles.txt 
head -n 1 200K.OnRAP.WES.1.58530648.frqx > allFreqs.1.58530648.txt
for f in *.frqx; do echo $f >> allFreqs.$name.txt; tail -n 1 $f >> allFreqs.$name.txt; done 
for f in *.raw; do cut -f 1,7 $f | grep -w 1 | sort  > $f.het.txt; done 
wc *.het.txt > hetCounts.$name.txt
for c in 200K 270K; do echo $c overlap: >> hetCounts.$name.txt; join $c.OnRAP.WES.$name.raw.het.txt $c.OnRAP.WGS.$name.raw.het.txt | wc >> hetCounts.$name.txt; done
cat downloadedFiles.txt | while read f; do rm -f $f; done 
pushd
cp $HOMEDIR/results/tmp/allFreqs.$chr.$pos.txt .
cp $HOMEDIR/results/tmp/hetCounts.$chr.$pos.txt .
date
cd $HOMEDIR
# dx cd /scripts ; dxupload fix.1.58530648.sh
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/getVarFreqs.1.58530648.sh -icmd="bash getVarFreqs.1.58530648.sh"
# maybe use ssd for this
