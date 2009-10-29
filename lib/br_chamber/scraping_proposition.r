library('getopt')
opt <- getopt(matrix(c(
                       'directory', 'd', 1, 'character',
                       'id', 'i', 2, 'character',
                       'type', 't', 1, 'character',
                       'number', 'q', 1, 'character',
                       'year', 'y', 1, 'character',                       
                       'no-parse', 'n', 0, 'logical',
                       'no-get', 'p', 0, 'logical',                   
                       'no-overwrite', 'r', 0, 'logical',
                       'load', 'l', 0, 'logical'         ##load to database      
                       ), ncol=4, byrow=TRUE))


if (is.null(opt$directory) ) {
    opt$directory <- "."
}

if (is.null(opt$id)&(is.null(opt$number)|is.null(opt$year)|is.null(opt$type)) ) {
    stop("Must specify the id or the type/number/year")
}

if (is.null(opt$`no-get`) ) {
    opt$`no-get` <- FALSE
}

if (is.null(opt$`no-parse`) ) {
    opt$`no-parse` <- FALSE
}

if (is.null(opt$`no-overwrite`) ) {
    opt$`no-overwrite` <- FALSE
    wgetoptions <- "-N"
} else {
    wgetoptions <- "-nc"
}

if (opt$`no-get` & opt$`no-parse`) {
    stop("invalid options")
}

if (is.null(opt$`load`) ) {
    opt$`load` <- FALSE
}


if (!exists("DEBUG") ) {
    DEBUG <- FALSE
}


if (DEBUG) {
    opt$directory <- "~/reps/legisdados/"
    opt$id <- 443165
    opt$number <- 447
    opt$year <- 2008
    opt$type <- "MPV"
}


source(paste(opt$directory, "Rpackages/legisdados/load.R", sep="/"), echo=FALSE)
billid <- opt$id


## download
if (!opt$`no-get`) {
    if (!is.null(opt$id)) {
        ## id was given
        the.url <- paste("www.camara.gov.br/sileg/Prop_Detalhe.asp?id=",billid,sep="")    
        ofile <- system(paste("wget ", wgetoptions, " -P ",opt$directory,"/data/br_chamber/source_data/ -x ",the.url, " ", sep=""), intern=TRUE)
    } else {
        ## get id from type, number and year
        billid <- get.bill(sigla=opt$type, numero=opt$number, ano=opt$year, overwrite=!opt$`no-overwrite`, directory=opt$directory)
    }
}


## get the data
if (!is.null(opt$`no-parse`)) {
    fn <- paste(opt$directory,"/data/br_chamber/source_data/www.camara.gov.br/sileg/Prop_Detalhe.asp?id=", billid, sep='')
    res <- parse.bill(fn)
    res.t <- get.tramit(fn)    
    ## output to csv files
    write.csv(res.t, file=paste(opt$directory,"/data/br_chamber/output_data/tramit/tramit", opt$id, ".csv", sep=''), row.names=FALSE)
    write.csv(res, file=paste(opt$directory,"/data/br_chamber/output_data/bill/bill", opt$id, ".csv", sep=''), row.names=FALSE)
}


## load into db
if (opt$`load`) {
    connect.db()
    if (is.null(opt$id)) {
        ## write the billid
        dbWriteTableU(connect, "br_billid", data.frame(billid=billid,
                                                       billno=opt$number,
                                                       billyear=opt$year,
                                                       billtype=opt$type),
                      append=TRUE)
    }
    ## write tramit
    dbWriteTableU(connect, "br_tramit", res.t, append=TRUE)
    ## delete proposition info
    dbGetQuery(connect, paste("delete from br_bills where billid=", billid, sep=''))
    ## write proposition info
    dbWriteTableU(connect, "br_bills", res, append=TRUE)
}
