#Converting xls files to CHILDES-like format
#Alex Cristia alecristia@gmail.com 2015-07-13

#########VARIABLES
#*****VARIABLES TO CHANGE*********#
XLSFOLDER="/Users/caofrance/Documents/algoComp_201506/databases/LS-SGM/xls/" #must exist and contain trs files
CHAFOLDER="/Users/caofrance/Documents/algoComp_201506/databases/LS-SGM/CHAmot/" #will be created and output cha files will be stored there
INCCODES=c(1,2,3)
#*********************************#
#NOTE: there are lots of annotation below, but you can ignore it all


library(xlsx)

dir.create(CHAFOLDER)

xlsfiles=dir(path= XLSFOLDER,pattern=".xls")
for(thisfile in xlsfiles){
	read.xlsx(paste(XLSFOLDER, xlsfiles,sep="/"),1,encoding="MacRoman")->infile #ez	s in 
	infile=infile[infile[,1] %in% INCCODES,] #leave only the desired speakers/addressees
	infile[,1]=sub(1,"*MOT:",infile[,1],fixed=T)	#rename the codes in terms of cha-like participants
	infile[,1]=sub(2,"*FAT:",infile[,1],fixed=T)	
	infile[,1]=sub(3,"*SIB:",infile[,1],fixed=T)	
	chafile=sub("xls","cha",thisfile)
	write.table(infile,paste(CHAFOLDER, chafile,sep="/"),quote=F,sep="\t",row.names=F,col.names=F)
}

print("all done")

