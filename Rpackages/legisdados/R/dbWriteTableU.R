## new defaults for writetable
dbWriteTableU <- function(conn,name,value, ...) {
  if (!is.data.frame(value)) {
      stop("must be a data frame")
  }
  dbWriteTable(conn, name, value,...,row.names = FALSE, eol = "\r\n")
}
