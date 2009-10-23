#!/usr/bin/Rscript
library('getopt')
##library(legisdados)
source("/Users/eduardo/reps/legisdados/Rpackages/legisdados/load.R", echo=FALSE)## root = '~/reps/legisdados'
## 'br_chamber/source_data/votes/'

##getQ options, using the spec as defined by the enclosed list.
##we read the options

## 1 means the argument is required, 0 no arg, 2 optional
## give a zip file
opt <- getopt(matrix(c( 'file' , 'f', 1, "character"
                       ), ncol=4, byrow=TRUE))

## tmp directory
tmpdir <- tempdir()

## unzip to temp directory
tmp <- unzip(opt$file,junkpaths=TRUE,exdir=tmpdir)

## unzip zip files inside zip files, if they exist
tmp <- lapply(dir(tmpdir, pattern=".*\\.zip$", full.names=TRUE),function(x) unzip(x,junkpaths=TRUE))


## get the data
res <- get.votos(dir(tmpdir, pattern="LV", full.names=TRUE))


f1 <- gsub(".zip$", "_votos.csv", opt$file)
f2 <- gsub(".zip$", "_votacoes.csv", opt$file)
f3 <- gsub(".zip$", ".RData", opt$file)
## output to csv files and RData files
write.csv(res[["votos"]], file=f1
          , row.names=FALSE)
write.csv(res[["votacoes"]], file=f2
          , row.names=FALSE)
save(res, file=f3)



