#!/bin/bash 

# script to run on virtual machine in RAP using Swiss Army Knife app
# used to run multiple bash scripts in sequence on same virtual machine
# first argument is scriptList, a file containing a list of bash scripts with their arguments
# all the scripts must have been already uploaded and must be in the /scripts directory of the RAP

# need to have run 
# dx cd /
# before submitting this

set -x 
unset DX_WORKSPACE_ID
dx cd $DX_PROJECT_CONTEXT_ID:
HOMEDIR=`pwd`

scriptList=$1
dx cd /scripts
dx download $scriptList
mkdir ~/workdir
cat $scriptList | while read line
do
	cd ~/workdir
	words=($line)
	dx cd /scripts
	dx download ${words[0]}
	cd $HOMEDIR
	bash ~/workdir/$line # hopefully expands OK and first word is taken to be name of script, with arguments following
done

# Usage:
# scriptList=scriptList.sh # list of bash scripts with their arguments
# dx cd /scripts ; dxupload $scriptList
# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/runRAPScripts.20241027.sh -icmd="bash runRAPScripts.20241027.sh $scriptList"
# maybe use ssd for this
