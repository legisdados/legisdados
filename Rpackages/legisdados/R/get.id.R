get.id <- function(legislatura=51, matricula=1, init.date="20010602", final.date="20010602", directory="~/reps/legisdados/", overwrite=FALSE) {
    if (overwrite) {
        wgetopts <- " -N "
    } else {
        wgetopts <- " -nc "
    }
    fdate <- function(x) gsub("/", "%2F", format(as.Date(x), format="%d/%m/%Y"))
    init.date <- fdate(init.date)
    final.date <- fdate(final.date)
    the.url <- paste("www.camara.gov.br/internet/deputado/RelVotacoes.asp?nuLegislatura=", legislatura, "&nuMatricula=", matricula, "&dtInicio=", init.date, "&dtFim=", final.date, sep="")
    the.directory <- paste(directory, "/data/br_chamber/source_data", sep="")
    cmd <- paste("wget ", wgetopts, " --user-agent=\"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_1; nl-nl) AppleWebKit/532.3+ (KHTML, like Gecko) Version/4.0.3 Safari/531.9\" -x -P ", the.directory, " \"", the.url, "\"", sep='')
    system(cmd)
    fn <- paste(the.directory, the.url, sep="/")
    id <- gsub(".*\\?id=([0-9]*).*", "\\1", grep("\\?id=", readLines(fn, encoding="latin1"), value=TRUE))
    id
}
