get.billno <-
function(x) {
    x <- gsub("\\.","",x)
    x <- gsub("[A-Z]*|-","",x)
    x <- as.numeric(x)
    x
}

