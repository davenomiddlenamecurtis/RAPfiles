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
dx cd /phenos
dx download UKBB.470Kexome.IDs.txt
dx download UKBB.newIn2023.exome.IDs.txt
dx download ukb23155.IDs.txt
dx cd /results/genotypeCounts
dx download 200K.1.58534246.frqx

dx cd "$WESdir"
dx download ukb23157_c1_b36_v1.vcf.gz
dx cd "$WGSdir"
dx cd chr1
dx download ukb24310_c1_b2926_v1.vcf.gz
ls > downloadedFiles.txt
plink --vcf ukb23157_c1_b36_v1.vcf.gz --vcf-half-call m --chr 1 --from-bp 58534246 --to-bp 58534246 --make-bed --keep-fam ukb23155.IDs.txt --out 200K.OnRAP.WES.1.58534246
plink --vcf ukb23157_c1_b36_v1.vcf.gz --vcf-half-call m --chr 1 --from-bp 58534246 --to-bp 58534246 --make-bed --keep-fam UKBB.newIn2023.exome.IDs.txt --out 270K.OnRAP.WES.1.58534246
plink --vcf ukb24310_c1_b2926_v1.vcf.gz --vcf-half-call m --chr 1 --from-bp 58534246 --to-bp 58534246 --make-bed --keep-fam ukb23155.IDs.txt --out 200K.OnRAP.WGS.1.58534246
plink --vcf ukb24310_c1_b2926_v1.vcf.gz --vcf-half-call m --chr 1 --from-bp 58534246 --to-bp 58534246 --make-bed --keep-fam UKBB.newIn2023.exome.IDs.txt --out 270K.OnRAP.WGS.1.58534246
plink --bfile 200K.OnRAP.WES.1.58534246 --out 200K.OnRAP.WES.1.58534246 --freqx
plink --bfile 270K.OnRAP.WES.1.58534246 --out 270K.OnRAP.WES.1.58534246 --freqx
plink --bfile 200K.OnRAP.WGS.1.58534246 --out 200K.OnRAP.WGS.1.58534246 --freqx
plink --bfile 270K.OnRAP.WGS.1.58534246 --out 270K.OnRAP.WGS.1.58534246 --freqx
plink --bfile 200K.OnRAP.WES.1.58534246 --out 200K.OnRAP.WES.1.58534246 --recode A
plink --bfile 270K.OnRAP.WES.1.58534246 --out 270K.OnRAP.WES.1.58534246 --recode A
plink --bfile 200K.OnRAP.WGS.1.58534246 --out 200K.OnRAP.WGS.1.58534246 --recode A
plink --bfile 270K.OnRAP.WGS.1.58534246 --out 270K.OnRAP.WGS.1.58534246 --recode A
ls -lrt
chr=1
pos=58534246
name=1.58534246
head -n 1 200K.OnRAP.WES.1.58534246.frqx > allFreqs.1.58534246.txt
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
# dx cd /scripts ; dxupload getVarFreqs.1.58534246.sh
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/getVarFreqs.1.58534246.sh -icmd="bash getVarFreqs.1.58534246.sh"
# maybe use ssd for this
