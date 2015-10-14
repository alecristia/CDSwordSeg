#Converting xls files to phono-like format
#Alex Cristia alecristia@gmail.com 2015-07-13

#########VARIABLES
#*****VARIABLES TO CHANGE*********#
XLSFOLDER="/Users/caofrance/Documents/algoComp_201506/databases/LS-SGM/xls/" #must exist and contain trs files
RESFOLDER="/Users/caofrance/Documents/algoComp_201506/tests/LS-SGM/" #will be created and output cha files will be stored there
INCCODES=c(1,2,3)
KEYNAME="lssgm" #pick a nice name for your phonological corpus, because this keyname will be used for every output file!
#*********************************#
#NOTE: there are lots of annotation below, but you can ignore it all


library(xlsx)

dir.create(RESFOLDER)

xlsfiles=dir(path= XLSFOLDER,pattern=".xls")

all=NULL
for(thisfile in xlsfiles){
	read.xlsx(paste(XLSFOLDER, xlsfiles,sep="/"),1,encoding="MacRoman")->infile #ez	s in 
	infile=infile[infile[,1] %in% INCCODES,] #leave only the desired speakers/addressees
	all=rbind(all,infile[,2])
}

	write.table(all,paste(RESFOLDER, paste(KEYNAME,"-ortholines.txt",sep=""),sep="/"),quote=F,sep="\t",row.names=F,col.names=F)

print("all done")

