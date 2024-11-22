#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app

# need to have run 
# dx cd /
# before submitting this

# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin="/scripts/getVCFheads.sh" -icmd="bash getVCFheads.sh"
argFile=gva.extractExons.arg
phenoFile=UKBB.DEMMax2.20240901.txt
refGeneFile=refseqgenes.hg38.20191018.sorted.onePCDHG.txt 

set -x 

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:
WGSdir='/Bulk/DRAGEN WGS/DRAGEN population level WGS variants, pVCF format [500k release]'
VCFs="ukb24310_c1_b0_v1.vcf.gz ukb24310_c1_b1_v1.vcf.gz"

HOMEDIR=`pwd`
mkdir WGS
mkdir WGS/VCFs
cd WGS/VCFs

mkdir ~/workdir
pushd ~/workdir
dx cd /pars
dx download $argFile
dx cd /bin
dx download geneVarAssoc
chmod 755 geneVarAssoc
dx cd /phenos
dx download $phenoFile
dx cd /reference38
dx download $refGeneFile

dx cd "$WGSdir"
