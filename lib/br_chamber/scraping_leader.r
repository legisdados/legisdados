#!/usr/bin/Rscript
library('getopt')
##library(legisdados)
source("/Users/eduardo/reps/legisdados/Rpackages/legisdados/load.R", echo=TRUE)## root = '~/reps/legisdados'
## 'br_chamber/source_data/votes/'

##getQ options, using the spec as defined by the enclosed list.
##we read the options

## 1 means the argument is required, 0 no arg, 2 optional
## give a zip file
opt <- getopt(matrix(c( 'rcvoteid' , 'r', 1, "character"
                       ), ncol=4, byrow=TRUE))

## get the data
res <- get.lider(opt$rcvoteid)

## output to csv file
write.csv(res, file=paste("~/reps/legisdados/data/br_chamber/output_data/leaders/leader", opt$rcvoteid, ".csv", sep=''), row.names=FALSE)
