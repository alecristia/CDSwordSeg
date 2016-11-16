setwd("~/Documents/CDSwordSeg")
results_cds_childes <- read.csv("~/Documents/CDSwordSeg/results_cds_childes.txt", sep="")
results_bern<-subset(results_cds_childes ,results_cds_childes$corpus=="Bernstein")
bern_dibs<-subset(results_bern,results_bern$algo=="dibs")
bern_dibs
dim(bern_dibs)
hist(bern_dibs$token_f.score)
mean(bern_dibs$token_f.score)
mean(bern_dibs$boundary_f.score)
