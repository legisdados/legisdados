read.fix <-
function(file, encoding="latin1", ...) {
    ff <- file(file)
    tmp <- readLines(ff, encoding=encoding)
    writeLines(tmp, "tmp")
    LV <- read.fwf("tmp" , ...)
    unlink("tmp")
    closeAllConnections()
    LV
}

