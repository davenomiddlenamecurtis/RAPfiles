#!/bin/bash 
# make a script to get genotype counts of a variant in exome and WGS datasets

chr=$1 # a number to be prefixed by chr
pos=$2
name=$chr.$pos

prologue=~/UKBB/RAPfiles/RAPscripts/getVarFreqs.prologue.20241002.sh

scriptName=getVarFreqs.$name.sh

cp $prologue $scriptName

getFile='{ if ($3>start) { print last ; exit } ; last=$1; }'

index=~/UKBB/WGS/dragen_pvcf_coordinates.chr$chr.txt
WGSVCF=`awk -v start=$pos "$getFile" $index` 

index=~/UKBB/field_23157_pVCF_500k_Exome_starter_pos.chr$chr.txt
WESVCF=`awk -v start=$pos "$getFile" $index` 

localExomeDir=/SAN/ugi/UGIbiobank/data/downloaded/

plink --fam $localExomeDir/ukb23155_c22_b0_v1_s200632.fam \
	--bed $localExomeDir/ukb23155_c${chr}_b0_v1.bed \
	--bim $localExomeDir/UKBexomeOQFE_chr${chr}.bim \
	--chr $chr \
	--from-bp $pos \
	--to-bp $pos \
	--freqx \
	--out 200K.$name
dx cd /results/genotypeCounts
dxupload 200K.$name.frqx

echo "
date
dx cd /phenos
dx download UKBB.470Kexome.IDs.txt
dx download UKBB.newIn2023.exome.IDs.txt
dx download ukb23155.IDs.txt
dx cd /results/genotypeCounts
dx download 200K.$name.frqx
" >>$scriptName
echo dx cd '"$WESdir"' >>$scriptName
echo dx download $WESVCF >>$scriptName

echo plink --vcf $WESVCF --vcf-half-call m --chr $chr --from-bp $pos --to-bp $pos --freqx --keep-fam ukb23155.IDs.txt --out 200K.OnRAP.WES.$name >>$scriptName
echo plink --vcf $WESVCF --vcf-half-call m --chr $chr --from-bp $pos --to-bp $pos --freqx --keep-fam UKBB.newIn2023.exome.IDs.txt --out 270K.OnRAP.WES.$name >>$scriptName

echo dx cd '"$WGSdir"' >>$scriptName
echo dx cd chr$chr >>$scriptName
echo dx download $WGSVCF >>$scriptName

echo plink --vcf $WGSVCF --vcf-half-call m --chr $chr --from-bp $pos --to-bp $pos --freqx --keep-fam ukb23155.IDs.txt --out 200K.OnRAP.WGS.$name >>$scriptName
echo plink --vcf $WGSVCF --vcf-half-call m --chr $chr --from-bp $pos --to-bp $pos --freqx --keep-fam UKBB.newIn2023.exome.IDs.txt --out 270K.OnRAP.WGS.$name >>$scriptName

echo ls -lrt >>$scriptName
echo chr=$chr >>$scriptName
echo pos=$pos >>$scriptName
echo "head -n 1 200K.$name.frqx > allFreqs.$chr.$pos.txt" >>$scriptName
echo 'for f in *.frqx; do echo $f >> allFreqs.$chr.$pos.txt; tail -n 1 $f >> allFreqs.$chr.$pos.txt; done ' >>$scriptName
echo pushd >>$scriptName

echo 'cp ~/workdir/allFreqs.$chr.$pos.txt .' >>$scriptName
echo date >>$scriptName

echo 'cd $HOMEDIR' >>$scriptName # so I can run multiple scripts in same session

echo "# dx cd /scripts ; dxupload $scriptName" >>$scriptName
echo "# dx cd / ; dx run swiss-army-knife -y --ignore-reuse --instance-type mem3_ssd2_v2_x4  -imount_inputs=FALSE -iin=/scripts/$scriptName -icmd=\"bash $scriptName\"" >>$scriptName
echo "# maybe use ssd for this"  >>$scriptName