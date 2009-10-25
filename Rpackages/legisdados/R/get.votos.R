get.votos <-
function(LVfile) {
    ## a wrapper over get.votos.1
    ## accepts a vector of LVfile (length>1)
    require(plyr)
    res <- lapply(LVfile,get.votos.1)
    ##dlply(res,function(x) x[[1]])
    votacoes <- ldply(res,function(x) x[["votacoes"]])
    votos <- ldply(res,function(x) x[["votos"]])
    list(votacoes=votacoes, votos=votos)
}

