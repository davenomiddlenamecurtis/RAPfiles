#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app

# extract a list of variants from a vcf file in /GWS/VCF

set -x 

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:
root=$1

HOMEDIR=`pwd`
mkdir WES
mkdir WES/VCFs
cd WES/VCFs

mkdir ~/workdir
pushd ~/workdir
dx cd /WES/VCFs
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
# dx cd /scripts ; dxupload get.WES.fromPlink.VCFVars.sh
# root=TREM2.WES.fromPlink
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/get.WES.fromPlink.VCFVars.sh -icmd="bash get.WES.fromPlink.VCFVars.sh $root"
# maybe use ssd for this

