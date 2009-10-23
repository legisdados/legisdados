get.votacoes <-
    function(data.votacoes) {
        data.votacoes <- within(data.votacoes,{
            ##modify bill so that it is parseable
            billproc <- billtext
            billproc <- gsub(" +"," ",billproc)
            billproc <- gsub(" / ","/",billproc)
            billproc <- gsub("^PL P ","PLP ",billproc)
            billproc <- gsub("N º","Nº",billproc)
            billproc <- gsub("N \\.","N.",billproc)
            billproc <- gsub("/;","/",billproc)
            billproc <- gsub("(^[A-Z]+) ([0-9])","\\1 Nº \\2",billproc)
            ##     wpdate <- as.character(paste(data,"T12:00:00"))
        })
        ## parse billproc (bill)
        ss <- strsplit(gsub(" +"," ",as.character(data.votacoes$billproc)),c(" |/"))
        data.votacoes <- within(data.votacoes,{  
            billtype <- as.character(sapply(ss,function(x) x[1]))
            billtype <- recode.billtype(gsub("\\.","",billtype))
            billno <- get.billno(sapply(ss,function(x) x[3]))
            billyear <- as.numeric(sapply(ss,function(x) x[4]))
            billyear[billyear==203] <- 2003
            billyear <- ifelse(billyear<1000 & billyear>50, billyear+1900,billyear)
            billyear <- ifelse(billyear<1000 & billyear<50, billyear+2000,billyear)
            rcyear <- format.Date(rcdate,"%Y")
            m <- as.numeric(as.numeric(format.Date(rcdate,"%m"))<2)
            legisyear <- as.numeric(rcyear)-m
            rm(m)
            ##if ano is missing use ano_votacao
            billyear <- ifelse(is.na(billyear), rcyear,billyear)
            bill <- with(data.votacoes,paste(billtype," ",billno,"/",billyear,sep=""))
            billdescription <- sapply(ss,function(x) paste(x[6:length(x)], collapse=" "))
            billdescription <- gsub("^ *- *", "", billdescription)
        })
        data.votacoes
    }

