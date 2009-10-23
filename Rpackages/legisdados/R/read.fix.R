read.fix <-
function(file, encoding="latin1", ...) {
    ff <- file(file)
    tmp <- readLines(ff, encoding=encoding)
    tmpfile <- tempfile()
    writeLines(tmp, tmpfile)
    LV <- read.fwf(tmpfile, ...)
    unlink(tmpfile)
    closeAllConnections()
    LV
}

