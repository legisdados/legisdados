library('getopt')
## download all files up to the current year

## 'br_chamber/source_data/votes/'
##getQ options, using the spec as defined by the enclosed list.
##we read the options

## 1 means the argument is required, 0 no arg, 2 optional
## give a date in YYYYMM numeric format
opt <- getopt(matrix(c(
                       'directory', 'd', 1, 'character',
                       'all', 'a', 0, 'logical',
                       'no-parse', 'n', 0, 'logical',
                       'no-get', 'p', 0, 'logical',                
                       'load', 'l', 0, 'logical'         ##load to database          
                       ), ncol=4, byrow=TRUE))


if (is.null(opt$`no-get`) ) {
    opt$`no-get` <- FALSE
}

if (is.null(opt$`no-parse`) ) {
    opt$`no-parse` <- FALSE
}

if (is.null(opt$`load`) ) {
    opt$`load` <- FALSE
}


if (opt$`no-get` & opt$`no-parse` & (!opt$`load`)) {
    stop("invalid options")
}

if (is.null(opt$directory) ) {
    opt$directory <- "."
}

directory <- opt$directory
source(paste(directory, "Rpackages/legisdados/load.R", sep="/"), echo=FALSE)


##Get current year
current.year <- format(Sys.time(), "%Y")
if ( !is.null(opt$a) ) {
    init.year <- 1995
} else {
    init.year <- current.year
}

years <- init.year:current.year
meses <- as.list(c("Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"))
meses[[3]] <- c("Marco","Mar%C3%A7o")
years.f <- ifelse(years>1998,substr(years,3,4),years)


if ( !is.null(opt$all) ) {
    print("all available data")
    zip.files <- c("Janeiro1999","1slo51l","2sle51l","2slo51l","4sle51l","3slo51l")
    zip.files <- unique(c(zip.files,apply(expand.grid(unlist(meses),years.f),1,paste,collapse="")))    
} else {
    print("only current and last months")
    current.date <- as.Date(Sys.time())
    last.date <- as.Date(Sys.time())-30
    current.file <- paste(meses[as.numeric(format(current.date, "%m"))],
                          format(current.date, "%y"),sep='')
    last.file <- paste(meses[as.numeric(format(last.date, "%m"))],
                       format(last.date, "%y"),sep='')
    zip.files <- c(current.file,last.file)
}

for (i in zip.files) {
    print(paste("now on file", i))
    the.url <- paste("www.camara.gov.br/internet/plenario/result/votacao/",i,".zip",sep="")
    the.file <- paste(opt$directory,"data/br_chamber/source_data/",the.url, sep="/")
    if (!opt$`no-get`) {
        print(paste("downloading file", i))        
        tmp <- system(paste("wget -x -N -P ",directory,"/data/br_chamber/source_data/ ", the.url, sep=''))
    }
    if (!opt$`no-parse`) {
        print(paste("parsing file", i))                
        cmd <- paste("Rscript ",directory,"/lib/br_chamber/scraping_votes1.r -d ", directory, " -f ", the.file, sep='')
        system(cmd)
    }
    if (opt$`load`) {
        connect.db()
        print(paste("loading file", i, " to mysql database"))                
        j <- paste(directory, "/data/br_chamber/output_data/votes/", gsub(".zip",".RData",basename(the.file)), sep='')
        res <- NULL
        load(j)
        dbWriteTableU(connect, "br_votes", res[["votos"]], append=TRUE)
        dbWriteTableU(connect, "br_rollcalls", res[["votacoes"]], append=TRUE)
    }
}

