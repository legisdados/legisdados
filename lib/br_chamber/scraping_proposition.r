library('getopt')
opt <- getopt(matrix(c(
                       'directory', 'd', 1, 'character',
                       'id', 'i', 1, 'character',
                       'no-parse', 'g', 0, 'logical',
                       'no-get', 'p', 0, 'logical',                   
                       'no-overwrite', 'r', 0, 'logical'                      
                       ), ncol=4, byrow=TRUE))


if (is.null(opt$directory) ) {
    opt$directory <- "."
}

if (is.null(opt$`no-get`) ) {
    opt$`no-get` <- FALSE
}

if (is.null(opt$`no-parse`) ) {
    opt$`no-parse` <- FALSE
}

if (is.null(opt$`no-overwrite`) ) {
    wgetoptions <- "-N"
} else {
    wgetoptions <- "-nc"
}

if (opt$`no-get` & opt$`no-parse`) {
    stop("invalid options")
}



if (!exists("DEBUG") ) {
    DEBUG <- FALSE
}


if (DEBUG) {
    opt$directory <- "~/reps/legisdados/"
    opt$id <- opt$id <- 443164
}

billid <- opt$id

source(paste(opt$directory, "Rpackages/legisdados/load.R", sep="/"), echo=FALSE)


## download
if (!opt$`no-get`) {
    the.url <- paste("www.camara.gov.br/sileg/Prop_Detalhe.asp?id=",billid,sep="")    
    ofile <- system(paste("wget ", wgetoptions, " -P ",opt$directory,"/data/br_chamber/source_data/ -x ",the.url, " ", sep=""), intern=TRUE)
}


## get the data
if (!is.null(opt$`no-parse`)) {
    fn <- paste(opt$directory,"/data/br_chamber/source_data/www.camara.gov.br/sileg/Prop_Detalhe.asp?id=", opt$id, sep='')
    res <- get.bill(fn)
    res.t <- get.tramit(fn)

    ## output to csv files
    write.csv(res.t, file=paste(opt$directory,"/data/br_chamber/output_data/tramit/tramit", opt$id, ".csv", sep=''), row.names=FALSE)
    write.csv(res, file=paste(opt$directory,"/data/br_chamber/output_data/bill/bill", opt$id, ".csv", sep=''), row.names=FALSE)
}
