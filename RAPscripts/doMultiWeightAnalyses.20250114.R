#!/share/apps/R-3.6.1/bin/Rscript
# script to do analyses with different annotations contributing to weights

ver="forAnnot.20250114"

varCatsFn="varCats.20210401.txt"
catsFn="categories.txt"
extraWeightsFn="extraWeights.20231106.txt"
PCsFile="ukb23158.common.all.20230806.eigenvec.txt"
sexFile="UKBB.sex.20230807.txt"

pheno="T2D"
gene="GCK"

args = commandArgs(trailingOnly=TRUE)
if (length(args)==2) {
  pheno=args[1]
  gene=args[2]
}

scoresFn=sprintf("UKBB.%s.%s.%s.sco",pheno,ver,gene)
resultsFile=sprintf("results.%s.%s.%s.txt",ver,pheno,gene)

cats=data.frame(read.table(catsFn,header=FALSE,sep="",stringsAsFactors=FALSE))
vwNames=cats[cats[,1]!="Unused",1]
extraWeights=data.frame(read.table(extraWeightsFn,header=TRUE,sep="",stringsAsFactors=FALSE))
ewNames=c("GPN_MSA","AM_prediction","AM_score",extraWeights[,1])
wNames=c(vwNames,ewNames)

if (!file.exists(scoresFn)) {
	print(sprintf("Error: file %s not found",scoresFn))
	quit()
}
	
scores=data.frame(read.table(scoresFn,header=FALSE,sep=""))
colnames(scores)[1:3]=c("IID","Pheno","VEPweight")
colnames(scores)[4:ncol(scores)]=wNames
PCsTable=data.frame(read.table(PCsFile,header=TRUE,sep="\t"))
# colnames(PCsTable)[1:2]=c("FID","IID")
# fixed in 470K version
covars=""
for (p in 1:20) {
  covars=sprintf("%sPC%d + ",covars,p)
#  colnames(PCsTable)[2+p]=sprintf("PC%d",p) # because first row of PCs file starts with hash sign FID
# fixed already
}

sexTable=data.frame(read.table(sexFile,header=TRUE,sep="\t"))
colnames(sexTable)=c("IID","Sex")
covars=sprintf("%s Sex ",covars)

allData=merge(scores,PCsTable,,by="IID",all=FALSE)
allData=merge(allData,sexTable,by="IID",all=FALSE)

resultColumns=c("Weight","beta","SLP")
results=data.frame(matrix(ncol=length(resultColumns),nrow=length(wNames)))
colnames(results)=resultColumns
results$Weight=wNames
for (r in 1:nrow(results)) {
	formulaString=sprintf("Pheno ~ %s + %s",covars,results[r,1])
	if (r>length(vwNames)) {
		formulaString=sprintf("%s + ProteinAltering + LOF",formulaString)
		# this is because GPN could recognise LOF
	}
	if (pheno=="BMI") {
		m=glm(as.formula(formulaString), data = allData)
	} else {
		m=glm(as.formula(formulaString), data = allData, family="binomial")
	}
	if (results[r,1]=="GPN_MSA") {
		print(summary(m))
	}
	if ((nrow(summary(m)$coefficients)>22&&r<=length(vwNames)) || (nrow(summary(m)$coefficients)>24&&r>length(vwNames))) {
		results$beta[r]=summary(m)$coefficients[23,1]
		results$SLP[r]=sprintf("%.2f",-log10(summary(m)$coefficients[23,4])*sign(results$b[r]))
	} else { # no valid data for this weight
		results$beta[r]=0
		results$SLP[r]="0.00"
	}
}

write.table(results,resultsFile,row.names=FALSE,quote=FALSE,sep="\t")



