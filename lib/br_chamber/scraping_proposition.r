library('getopt')
opt <- getopt(matrix(c(
                       'basedir', 'b', 1, 'character',
                       'file', 'f', 1, 'character'
                       ), ncol=4, byrow=TRUE))


if (is.null(opt$basedir) ) {
    opt$basedir <- "."
}

basedir <- opt$basedir
billid <- opt$id
source(paste(basedir, "Rpackages/legisdados/load.R", sep="/"), echo=FALSE)

## get the data
res <- get.bill(opt$file)
res.t <- get.tramit(opt$file)

## output to csv file
write.csv(res.t, file=paste(opt$basedir,"/data/br_chamber/output_data/tramit/tramit", res$billid[1], ".csv", sep=''), row.names=FALSE)

## output to csv file
write.csv(res, file=paste(opt$basedir,"/data/br_chamber/output_data/bill/bill", res$billid[1], ".csv", sep=''), row.names=FALSE)
