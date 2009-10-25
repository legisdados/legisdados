get.bill <- function(file) {  
    billid <- gsub(".*=([0-9]*)","\\1", file)
    if (length(grep("Prop_Erro|Prop_Lista",file))>0)  return(NULL)
    tmp <- readLines(file)
    if (!any(grepl("Módulo", tmp))) tmp <- readLines(file, encoding="latin1")  
    if(length(grep("Nenhuma proposição encontrada",tmp))>0) return(NULL)
    tmp <-  gsub("\r|&nbsp","",tmp)
    tmp <-  gsub(";+"," ",tmp)
    t0 <- tmp[grep("Proposição",tmp)[1]]
    propno <- as.numeric(trimm(gsub(".*CodTeor=([0-9]+).*","\\1",t0)))
    ##FIX: parse result when a deputado is the author
    t0 <- tmp[grep("Autor",tmp)[1]]
    author <- trimm(gsub(".*Autor: </b></td><td>(.*)</td>.*","\\1",t0))
    ##FIX: what to do with "Poder Executivo" and other non-legislators?
    if (length(grep("Detalhe.asp", t0))>0) {
        authorid <- gsub(".*Detalhe.asp\\?id=([0-9]*).*", "\\1", t0)
    } else {
        authorid <- NA
    }
    t0 <- tmp[grep("Data de Apresentação",tmp)]
    date <- trimm(gsub(".*</b>(.*)","\\1",t0))
    date <- as.character(as.Date(date,"%d/%m/%Y"))
    ##FIX: find what this is
    t0 <- tmp[grep("Apreciação:",tmp)][1]
    aprec <- trimm(gsub(".*</b>(.*)","\\1",t0))
    ##FIX: need english name
    t0 <- tmp[grep("Regime de tramitação:",tmp)+1][1]
    ## note use of the not operator!
    tramit <- trimm(gsub("([^<]*)<br>?.*","\\1",t0, perl=TRUE))
    tramit[tramit=="."] <- NA
    ##FIX: Categorize response
    t0 <- tmp[grep("Situação:",tmp)][1]
    status <- trimm(gsub(".*</b>(.*)<br>","\\1",t0))
    ##FIX: name
    t0 <- tmp[grep("Ementa:",tmp)][1]
    ementa <- trimm(gsub(".*</b>(.*)","\\1",t0))
    ##FIX: name
    t0 <- tmp[grep("Explicação da Ementa:",tmp)][1]
    ementashort <- trimm(gsub(".*</b>(.*)","\\1",t0))
    ##FIX: name
    t0 <- tmp[grep("Indexação:",tmp)][1]
    indexa <- trimm(gsub(".*Indexação: </b>(.*)","\\1",t0))
    ##FIX: name
    iua <- grep("Última Ação:",tmp)[1]+7
    if (!is.na(iua)) {
        t0 <- tmp[iua]
        uadate <- as.Date(trimm(gsub("<b>([^<]*).*","\\1",  tmp[iua])), format="%d/%m/%Y")
        iua.e <- grep("</table>",tmp[-c(1:iua)])[1]+iua
        t0 <- paste(tmp[(iua+1):iua.e],  collapse=" ")
        t0 <- trimm(gsub("<[^<]*>|\t",  "",  t0))
        uadesc <- trimm(gsub("<b>([^<]*).*","\\1",  tmp[iua+7]))
    } else {
        uadate <- NA
        uadesc <- NA
    }
    ## FIX: what else? despacho? 
    f <- function(x) ifelse (length(x)==0,NA,remove.tags(x))
    res <- try(data.frame(## billtype=f(sigla), ##FIX GET FROM FILE
                          ## billno=f(numero),
                          ## billyear=f(ano),
                          billid=billid,
                          propno=f(propno),
                          billauthor=f(author),
                          billauthorid=f(authorid),
                          billdate=f(date),
                          aprec=f(aprec),
                          tramit=f(tramit),
                          status=f(status),
                          ementa=f(ementa),
                          ementashort=f(ementashort),
                          indexa=f(indexa),
                          lastactiondate=f(uadate),
                          lastaction=f(uadesc),
                          stringsAsFactors=FALSE))
    if (("try-error"%in%class(res))) {   
        res <- NULL
    } 
  res
}
