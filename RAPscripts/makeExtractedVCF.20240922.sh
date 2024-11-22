#!/bin/bash 
# make a script which will produce a new VCF spanning provided coordinates

# arguments: name chr start end

name=$1
chr=$2 # e.g. chr22
start=$3
end=$4

scriptName=extract.$name.sh
fileList=neededVCFs.$name.txt

prologue=~/UKBB/RAPfiles/RAPscripts/makeExtractedVCF.prologue.20240922.sh

cp $prologue $scriptName

echo dx cd $chr >> $scriptName

index=~/UKBB/WGS/dragen_pvcf_coordinates.$chr.txt
getFiles='{ if ($3>start) { print last } ; last=$1; if ($3 > end) { exit } }'

awk -v start=$start -v end=$end "$getFiles" $index > $fileList

cat $fileList | while read f
do
	echo dx download $f >>$scriptName
done

# cat $fileList | while read f
# do
# 	echo dx download $f.tbi	>>$scriptName
# done

# echo tabix -h `head -n 1 $fileList` $chr:0-0 "> $name.vcf" >>$scriptName
# cat $fileList | while read f
# do
# 	echo tabix $f $chr:0-300000000 ">>$name.vcf" >>$scriptName
# done

echo bcftools view --header-only `head -n 1 $fileList` "> $name.vcf" >>$scriptName
cat $fileList | while read f
do
	echo bcftools view --no-header $f ">>$name.vcf" >>$scriptName
done

echo bgzip $name.vcf >>$scriptName
echo tabix -p vcf $name.vcf.gz >>$scriptName
echo ls -lrt >>$scriptName

echo pushd >>$scriptName
echo 'cp ~/workdir/'$name.vcf.gz . >>$scriptName
echo 'cp ~/workdir/'$name.vcf.gz.tbi . >>$scriptName

echo 'dx cd "$WGSdir"' >>$scriptName
echo 'cd $HOMEDIR' >>$scriptName # so I can run multiple scripts in same session


echo "# dx cd /scripts ; dxupload $scriptName" >>$scriptName
echo "# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_hdd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/$scriptName -icmd=\"bash $scriptName\"" >>$scriptName

