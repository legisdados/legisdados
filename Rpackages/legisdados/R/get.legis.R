get.legis <-
function(x) {
    ## note the +1 here to make calc right
    vec <- as.numeric(cut(x+1,seq(1947,max(x)+4,4),include.est=FALSE))+37
    vec
}

