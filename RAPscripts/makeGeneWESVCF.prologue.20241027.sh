#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app

# need to have run 
# dx cd /
# before submitting this

set -x 
unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:
HOMEDIR=`pwd`

dxdownload() {
	if [ ! -e "$1" ]
	then
		dx download "$1"
	fi
}
export -f dxdownload
# only download a file if it does not already exist

argFile=gva.extractWES.20241027.arg
phenoFile=UKBB.DEMMax2.20240901.txt
refGeneFile=refseqgenes.hg38.20191018.sorted.onePCDHG.txt 
WESdir="/Bulk/Exome sequences/Population level exome OQFE variants, pVCF format - final release"
# there is something else called interim 450K so I do not know if this may differ slightly from the 470K

mkdir WES
mkdir WES/VCFs
cd WES/VCFs

mkdir ~/workdir
cd ~/workdir
dx cd /pars
dxdownload $argFile
dx cd /bin
dxdownload geneVarAssoc
chmod 755 geneVarAssoc
dx cd /phenos
dxdownload $phenoFile
dx cd /reference38
dxdownload $refGeneFile
dx cd "$WESdir"

