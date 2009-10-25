get.tramit <- function(file) {
    billid <- gsub(".*=([0-9]*)","\\1", file)
    require(XML)
    zz <- pipe(paste("tidy -q -raw ",file, "2>&1"), encoding="latin1")
    tidy <- readLines(zz)
    closeAllConnections() 
    html <- htmlTreeParse(tidy, asText=TRUE, error=function(...){},
                          useInternalNodes=TRUE,
                          encoding="utf8")
    ##html <- htmlTreeParse(readLines(fnow), asText=TRUE, useInternalNodes=TRUE)
    tmp <- xpathSApply(html,"//table[1]/tr[1]",xmlValue)
    tmp <- tmp[grep("Andamento:",tmp):length(tmp)]
    tmp <- strsplit(tmp[-1],"\n")
    df <- data.frame(do.call(rbind,lapply(tmp,function(x) c(x[2],trimm(paste(x[3:length(x)],collapse=" "))))))
    names(df) <- c("date","event")
    df$date <- as.Date(as.character(df$date), "%d/%m/%Y")
    df$billid <- billid
    df$id <- 1:nrow(df)
    df
}
