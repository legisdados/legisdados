## Gets the leadership votes for a specific voteid or vote.file
get.lider <- function(x, directory="~/reps/legisdados/") {    #voteid field
    ##convert the coalition dataframe into a parties dataframe
    splitBlocks <- function(data) {
        data$block <- gsub("Repr ","",data$block)
        ## single parties are all caps and no slashes
        singlep <- data$block==toupper(data$block)
        singlep[grep("/",data$block)] <- FALSE  
        ## put all parties initials (and initials only) as caps
        data$block <- gsub("PTdoB","Ptdob",data$block)
        data$block <- gsub("PCdoB","Pcdob",data$block)
        data$block <- gsub("DEM","Dem",data$block)
        datas <- data[singlep,]
        data <- data[!singlep,]
        if (nrow(data)>0) {
            ## now the capital letter splits coalitions
            res <- lapply(1:nrow(data),function(x) {
                dx <- data[x,]
                party <- splitBlock(dx$block)
                np <- length(party)
                data.frame(data[rep(x,np),],party)
    })
            res <- do.call(rbind,res)
        } else {
            res <- NULL
        }
        datas$party <- datas$block
        res <- rbind(datas,res)  
        res$party <- car::recode(toupper(res$party),"'PTDOB'='PTdoB';'PCDOB'='PCdoB'")
        res$block <- toupper(res$block)
        res
    }
    ##split the coalition string into individual components
    splitBlock <- function(block="PmdbPtPsdb") {
        if (length(grep("/",block))>0) {
            strsplit(block,"/")[[1]]
        } else {
            split1 <- strsplit(block,"")[[1]]
            split1 <- which(split1==toupper(split1))
            init <- split1
            end <- c(split1[-1]-1,nchar(block))
            substring(block,init,end)
        }
    }
    print(x)
    if((nchar(x)>8))   {
        ## there is no data for these rcvoteid's
        return(NULL)
    }
    vote.name<-as.numeric(x)
    the.url <- paste("http://www.camara.gov.br/internet/votacao/mostraVotacao.asp?ideVotacao=",vote.name,sep="")
    ## download file with wget
    ## FIX: fix path here
    ofile <- system(paste("wget -nc -P ",directory,"/data/br_chamber/source_data/ -x ",the.url, " 2>&1", sep=""), intern=TRUE)
    tfile <- paste(directory, "/data/br_chamber/source_data/www.camara.gov.br/internet/votacao/mostraVotacao.asp?ideVotacao=",x, sep="")
    ## we try downloading the file first because
    ## readLines directly chokes when the page is missing an end of file code
    ## using wget since camara is gving 403 errors with default
    raw.data <-try(readLines(tfile,500),silent=TRUE)
    if(!any(grepl("ORDINÁRIA",raw.data))) {
        ## fix encoding
        raw.data <-try(readLines(tfile,500,encoding="latin1"),silent=TRUE)
    }
    if(!any(grepl("ORDINÁRIA",raw.data))) {
        stop("encoding problems")
    }
    if(class(raw.data)=="try-error") {
        print(the.url)
        cat("Connection problems",vote.name,"Will try again soon\n")
        Sys.sleep(10)
        cat("\t Attempting to connect...\n")
        flush.console()
        down <- try(download.file(the.url,tfile))
        raw.data <-try(readLines(tfile,500),silent=TRUE)
        if(class(raw.data)=="try-error") {
            warning("\t No data for",vote.name,"\n")
            return(NULL)
      }
    }
    orientation.line <- grep("Orientação",raw.data)
    ##Check for encoding problems here  
    if(length(orientation.line)==0){
        cat("############################\n")
        cat("No data for",vote.name,"\n")
        cat("############################\n")
        flush.console()
        return(NULL)
    } #No leadership votes
    raw.orientation <- raw.data[grep("Orientação",raw.data):(grep("Parlamentar",raw.data)-10)]
    raw.leadership <- raw.orientation[grep(":",raw.orientation)]#make sure all parties are caps, for later matches
    raw.position <- raw.orientation[grep(":",raw.orientation)+1]
    leadership <- gsub(".*\"right\" >(.*):.*$","\\1",raw.leadership)
    ##leadership <- gsub("^.*>(\\w*)\\W{1,2}<.*$","\\1",raw.leadership)
    position <- gsub("^.*>(\\w*)\\s*<.*$","\\1",raw.position)
    leadership <- trimm(gsub("\\."," ",leadership))
    output <- data.frame(rcvoteid=vote.name,block=leadership,rc=position)
    output <- splitBlocks(output)
    ##print("waiting a few seconds to give time to server")
    ##Sys.sleep(2)
    return(output)
}
