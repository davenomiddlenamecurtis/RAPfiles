#!/bin/bash 

# NB needs three arguments if one wants to run exactly the same analysis for each gene,
# all of which need to be listed in a geneListFile contained in the rarg file
# otherwise, there needs to be an explicit geneListFile specified as the 4th argument

# script to run on virtual machine in RAP using Swiss Army Knife app
# need to have run 
# dx cd /
# before submitting this
# then results will end up in subfolders of /results
# idea is to run scoreassoc.R with pre-existing score files

# this version will run multiple scoreassoc analyses using the same set of datafiles
# all analyses will use same testName and will got needed files based on argFile and extraFileList
# the third argument will be a bash script which it is assumed will contain commands to run required scoreassoc analyses

# example usage:
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin="/scripts/runScoreassoc.20240815.sh" -icmd="bash runScoreassoc.20240815.sh $model for.$model.lst runTests.sh geneListFile"

set -x 

unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:

testName=$1
argFile=rsco.$testName.rarg
extraFileList=$2
bashScript=$3

mkdir results # probably in folder ~/out/out
mkdir results/$testName
mkdir results/$testName/geneResults
mkdir results/$testName/failed

mkdir ~/workdir
pushd ~/workdir
dx cd /scripts
dx download $bashScript
dx cd /fileLists
dx download $extraFileList
cat $extraFileList | while read f
do
	dx download $f
done
dx cd /pars
dx download $argFile
dx cd /bin
dx download scoreassoc.R
PATH=$PATH:.
if [ .$4 .eq . ]
then
	gl=(`grep geneListFile $argFile`)
	geneList=${gl[1]}
else
	geneList=$4
fi
dx cd /geneLists
dx download $geneList
ss=(`grep inputscorefilespec $argFile`)
scoreSpec=${ss[1]}
cat $geneList | while read gene
do
	scoreFile=`echo $scoreSpec | sed s/GENE/$gene/`
	dx download $scoreFile # will have full path specified
done

# now strip path from score file spec and replace using command line argumnet, tee hee
strippedSpec=${scoreSpec##*/}
extraArgs="--inputscorefilespec $strippedSpec"

ls -l
# $bashScript must have nothing in it except commands to run scoreassoc.R
cat $bashScript | while read l
do
	cmd="$l $extraArgs"
	echo $cmd
	eval $cmd
done

ls -lrt
pushd
cp ~/workdir/*.rsao results/$testName/geneResults
cp ~/workdir/*summ*.txt results/$testName
pushd

# invoke with:
# model=something

# dx cd / ; dx run swiss-army-knife  --ignore-reuse -y --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/runScoreassoc.20240815.sh -icmd="bash runScoreassoc.20240815.sh $model for.$model.lst  extra-arguments-go-here"
# info re instance types is here: https://documentation.dnanexus.com/developer/api/running-analyses/instance-types




