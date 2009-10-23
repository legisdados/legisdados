get.votos.1 <-
function(LVfile) {
    brstates <- c("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO")
    ## This function needs both the LV and the HE file in the same directory
    ## It does not work for LP files without modification
    ## options(encoding="ISO8859-1")
    HEfile <- gsub("/LV","/HE",LVfile)
    ##Read data from VOTE LIST file for the vote
    if(nchar(LVfile)==24)  { #formato antigo: titulo tinha 24 characters, no novo so 21
        LV <- read.fix(LVfile, widths=c(9,-1,9,40,10,10,25,4),strip.white=TRUE)
    }  else {
        LV <- read.fix(LVfile, widths=c(9,-1,6,40,10,10,25,4),strip.white=TRUE,encoding="latin1")
    }
    voteid <- LV$V2[1]  #store number of vote for future use
    names(LV) <- c("session","rcvoteid","namelegis",paste("vote",voteid,sep="."),"party","state","matricula") #rename fields
    LV$state <- toupper(state.l2a(LV$state))
    LV$state <- factor(LV$state,levels=toupper(brstates))
    LV <- LV[,c("matricula","namelegis","party","state",paste("vote",voteid,sep="."))] #rearrange fields
    ## read fields in HE file
    vt <- unlist(read.table(HEfile, header=FALSE, strip.white = TRUE, as.is = TRUE, encoding="latin1", sep="\n"))
    vt.date <- as.Date(vt[3], "%d/%m/%Y")
    vt.time <- as.POSIXlt(paste(vt.date, vt[4]))
    vt.descrip<-gsub("\"","",vt[13])    #get rid of quotes in the description of the bill
    vt.session<- vt[1]
    HE <- data.frame(rcvoteid=voteid,rcdate=vt.date,rctime=vt.time,session=vt.session,billtext=vt.descrip)  
    data.votacoes <- get.votacoes(HE)
    data.votacoes$legis <- get.legis(data.votacoes$legisyear)
    rcfile <- gsub(".*/(LV.*)\\.txt","\\1",LVfile)
    data.votacoes$rcfile <- rcfile
    data.votos <- LV
    data.votos$rcvoteid <- voteid
    names(data.votos)[5] <- "rc"
    data.votos$rc <- gsub("^<.*","Ausente",as.character(data.votos$rc))
    data.votos$rc <- gsub("^Art.*","Abstenção",as.character(data.votos$rc))
    data.votos$legis <- data.votacoes$legis[1]
    return(list(votos=data.votos,votacoes=data.votacoes))
}

