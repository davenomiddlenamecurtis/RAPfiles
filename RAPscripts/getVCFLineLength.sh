#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app

# extract a list of variants from a vcf file in /GWS/VCF

set -x 

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:
root=$1

HOMEDIR=`pwd`
mkdir WGS
mkdir WGS/VCFs
cd WGS/VCFs

mkdir ~/workdir
pushd ~/workdir
dx cd /WGS/VCFs
date
dx download $root.vcf.gz
ls -lrt
date
zcat $root.vcf.gz | grep -v '^\#' | head -n 1 | wc 
zcat $root.vcf.gz | grep -v '^\#' | head -n 1 | wc > $root.LineLength.txt
zcat $root.vcf.gz | grep -v '^\#' | head -n 1 > $root.FirstLine.txt
ls -lrt
date
pushd
cp ~/workdir/$root.LineLength.txt .
cp ~/workdir/$root.FirstLine.txt .
ls -lrt
date
cd $HOMEDIR
# dx cd /scripts ; dxupload getVCFLineLength.sh
# root=OMA1.exons
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/getVCFLineLength.sh -icmd="bash getVCFLineLength.sh $root"
# maybe use ssd for this

