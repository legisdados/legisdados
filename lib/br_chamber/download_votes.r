library('getopt')
##library(legisdados)

## download all files up to the current year

## 'br_chamber/source_data/votes/'
##getQ options, using the spec as defined by the enclosed list.
##we read the options

## 1 means the argument is required, 0 no arg, 2 optional
## give a date in YYYYMM numeric format
opt <- getopt(matrix(c(
                       'directory', 'd', 1, 'character',
                       'all', 'a', 0, 'character'
                       ), ncol=4, byrow=TRUE))


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
if ( !is.null(opt$a) ) {
    zip.files <- c("Janeiro1999","1slo51l","2sle51l","2slo51l","4sle51l","3slo51l")
} else {
    zip.files <- NULL
}
zip.files <- unique(c(zip.files,apply(expand.grid(unlist(meses),years.f),1,paste,collapse="")))
print(zip.files)

for (i in zip.files) {
    the.url <- paste("http://www.camara.gov.br/internet/plenario/result/votacao/",i,".zip",sep="")
    tmp <- system(paste("wget -x -N -P ",directory,"data/br_chamber/source_data/ ", the.url, sep=''))
}

