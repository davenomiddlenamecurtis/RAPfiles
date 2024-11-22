#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app
# need to have run 
# dx cd /
# before submitting this
# then results will end up in subfolders of /results
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin="/scripts/getVCFheads.sh" -icmd="bash getVCFheads.sh"

set -x 

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

WGSdir='/Bulk/DRAGEN WGS/DRAGEN population level WGS variants, pVCF format [500k release]'
VCFs="ukb24310_c1_b0_v1.vcf.gz ukb24310_c1_b1_v1.vcf.gz"

mkdir results
mkdir results/WGS
mkdir results/WGS/VCFheads
cd results/WGS/VCFheads

mkdir ~/workdir
pushd ~/workdir

dx cd "$WGSdir"
dx cd chr1

for f in $VCFs
do
	dx download $f
	zcat $f | head -n 200 > $f.head.txt
	ls -l
done

pushd

for f in $VCFs
do
	cp ~/workdir/$f.head.txt .
done
ls -l

# invoke with:

# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin="/scripts/getVCFheads.sh" -icmd="bash getVCFheads.sh"
