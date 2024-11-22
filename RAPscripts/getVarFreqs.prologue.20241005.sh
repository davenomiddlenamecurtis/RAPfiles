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

