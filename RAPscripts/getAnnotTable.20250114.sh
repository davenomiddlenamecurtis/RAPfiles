#!/bin/bash
# get results comparing annotation SLPs
# arguments are pheno gene
set -x
dx select DaveCurtisExomes
unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:


if [ .%2 == . ]
then
	echo Usage: $0  phenotype gene
	exit
fi

pheno=$1
gene=$2

ver=forAnnot.20250114

testName=UKBB.$pheno.$ver
scoresFn=UKBB.$pheno.$ver.$gene.sco
resultsFile=results.$ver.$pheno.$gene.txt

varCatsFn="varCats.20210401.txt"
catsFn="categories.txt"
extraWeightsFn="extraWeights.20231106.txt"
PCsFile="ukb23158.common.all.20230806.eigenvec.txt"
sexFile="UKBB.sex.20230807.txt"

neededFiles="
/results/$testName/geneResults/$scoresFn
/annot/$varCatsFn
/annot/$catsFn
/annot/$extraWeightsFn
/covars/$PCsFile
/covars/$sexFile
/scripts/doMultiWeightAnalyses.20250114.R
"

mkdir results
mkdir results/$ver/
cd results/$ver/
resultsDir=`pwd`

mkdir ~/workDir
cd ~/workDir
for f in $neededFiles
do
  dx download $f
done

Rscript doMultiWeightAnalyses.20250114.R $pheno $gene
cp $resultsFile $resultsDir

# invoke with e.g. 
# p=HL
# g=LDLR
# dx cd /; dx run swiss-army-knife --ignore-reuse --name "getAnnotTable.$p.$g" -y --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin="/scripts/getAnnotTable.20250110.sh" -icmd="bash getAnnotTable.20250110.sh $p $g"
