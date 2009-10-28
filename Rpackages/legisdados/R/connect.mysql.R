connect.mysql <- function(connection, group, defaultfile.windows="C:/my.cnf", defaultfile.unix="~/.my.cnf" ) {
    if (.Platform$OS.type!="unix") {
        defaultfile <- defaultfile.windows
    } else {
        defaultfile <- path.expand(defaultfile.unix)
    }
    new <- TRUE
    library(RMySQL)  
    if (exists(connection)) {
        testconnect <- class(try(dbListTables(get(connection)),silent=TRUE))
        if ("try-error"%in%testconnect) {
        try(dbDisconnect(get(connection)))
    } else {
        new <- FALSE
    }
    }
    if (new) {
        driver <-dbDriver("MySQL")
        assign(connection,dbConnect(driver,
                                    group=group,
                                    default.file=defaultfile)
               ,envir = .GlobalEnv)
  }
}
