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
zcat $root.vcf.gz | cut -f 1-8 >$root.vars.vcf
ls -lrt
date
bgzip $root.vars.vcf
ls -lrt
date
pushd
date
cp ~/workdir/$root.vars.vcf.gz .
ls -lrt
date
cd $HOMEDIR
# dx cd /scripts ; dxupload getVCFVars.sh
# root=OMA1.exons
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/getVCFVars.sh -icmd="bash getVCFVars.sh $root"
# maybe use ssd for this

