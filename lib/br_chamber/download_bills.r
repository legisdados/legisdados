library('getopt')
opt <- getopt(matrix(c(
                       'basedir', 'b', 1, 'character',
                       'id', 'i', 1, 'character'
                       ), ncol=4, byrow=TRUE))


if (is.null(opt$basedir) ) {
    opt$basedir <- "."
}

basedir <- opt$basedir
billid <- opt$id
source(paste(basedir, "Rpackages/legisdados/load.R", sep="/"), echo=FALSE)

the.url <- paste("www.camara.gov.br/sileg/Prop_Detalhe.asp?id=",billid,sep="")
ofile <- system(paste("wget -N -P ",basedir,"/data/br_chamber/source_data/ -x ",the.url, " ", sep=""), intern=TRUE)
