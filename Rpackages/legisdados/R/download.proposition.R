get.bill <- function(sigla="MPV",numero=447,ano=2008,overwrite=TRUE, directory="~/reps/legisdados/") {
    ##FIX use RCurl?
    if (overwrite) {
        opts <- "-N"
    } else {
        opts <- "-nc"
    }  
    ## FIX: code as NA if value is missing
    ## -N for overwriting, -nc for not overwriting
    ##tmp <- system(paste("wget -r -l1 -t 15  ",opts," 'http://www.camara.gov.br/sileg/Prop_Lista.asp?Sigla=",sigla,"&Numero=",numero,"&Ano=",ano,"' -P ~/reps/CongressoAberto/data/www.camara.gov.br/sileg  2>&1",sep=''),intern=TRUE)
    cmd <- paste("wget -t 15 -x --accept Prop_Deta* --force-html --base=url  ",opts," 'http://www.camara.gov.br/sileg/Prop_Lista.asp?Sigla=",sigla,"&Numero=",numero,"&Ano=",ano,"' -P ", directory, "/data/br_chamber/source_data/  2>&1",sep='')
    print(cmd)  
    tmp <- system(cmd,intern=TRUE)
    tmp <- iconv(tmp,from="latin1")
    urlloc <- grep(".*www.camara.gov.br/sileg/.*id=.*",tmp)[1]
    ##url <- Prop_Detalhe.asp?id=
    ##id <- gsub(".*id=(.*)", "\\1", url)
    url <- tmp[urlloc]
    id <- gsub(".*id=([0-9]*).*", "\\1", url)
    if (length(grep("id=", url))==0) {
        id <- NA
    }
    ##c(url, id)
    id
}
