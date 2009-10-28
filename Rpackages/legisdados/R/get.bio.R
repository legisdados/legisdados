## load indexes
download.legis <- function(session=53, overwrite=FALSE, directory="~/reps/legisdados/data/br_chamber/source_data/") {
    index.url <- paste("DepNovos_Lista.asp?fMode=1&forma=lista&SX=QQ&Legislatura=",session,"&nome=&Partido=QQ&ordem=nome&condic=QQ&UF=QQ&Todos=sim",sep="")
    the.dir <- paste("www.camara.gov.br/internet/deputado/", sep="")
    the.file <- paste(the.dir, index.url, sep="")
    ## remove index
    unlink(path.expand(paste(directory, the.dir, index.url, sep='')))
    if (overwrite) {
        wgetopt <- " -N "
    } else {
        wgetopt <- " -nc "
    }    
    cmd <- paste("wget ", wgetopt, " -x -r -l 1 -A \"DepNovos_*\" -P ", path.expand(directory), " ", shQuote(paste(the.file, sep='')), " 2>&1",sep='')
    print(cmd)
    system(cmd)
}

## put this in a separate script
## download.legis(session=53)
## download.legis(session=52)
## download.legis(session=51)
## download.legis(session=50)

get.bio <- function(file.now) {
    id <- gsub(".*id=([0-9]+)&.*","\\1",file.now)
    cat(id,"\n")
    text.now <- readLines(file.now,encoding="latin1")
    namelong <- gb(text.now[83])
    bdate <- text.now[grep("Nascimento",text.now)]
    birth <-trim(
                 sub(".*:","",
                     text.now[84]
                     )
                 )
    ##imagefile <- gsub(".*\"(.*)\".* width.*","\\1",text.now[grep("img",text.now)[1]])
    ##imagefile <- gsub("/internet/deputado/","",imagefile)
    ##imagefile <- gsub(".*/(depnovos.*)&nome.*","\\1",imagefile)
    oldimagefile <- dir(rf("data/bio/all"),pattern=paste("foto.asp\\?id=",id,".*",sep=''))[1]
    imagefile <- paste("foto",id,".jpg",sep="")
    file.copy(rf(paste("data/bio/all/",oldimagefile,sep="")),rf(paste("data/images/bio/",imagefile,sep='')),overwrite=TRUE) 
    birthplace <- gb((gsub(".* - ","",birth)))
    birthdate <-  as.Date(gb(gsub(" - .*","",birth)),format="%d/%m/%Y")
    sessions <- gb(text.now[grep("Legislaturas:",text.now)[1]])
    sessions <- gsub(".*: |\\.| +","",sessions)
    mandates <- gsub("<.*>(.*)<.*>","\\1",trim(text.now[grep("Mandatos Eletivos",text.now)[1]+5]))  
    nameshort <- gb(text.now[65])
    if (substr(nameshort,nchar(nameshort),nchar(nameshort))=="-") {
        ##no party/state info (deputies from older sessions)
        ##cat(file.now,"\n")
        nameshort <- substr(nameshort,1,nchar(nameshort)-2)
        if (is.na(mandates)) {
            ## there is no mandate info
            ##FIX?: assume the person is a deputy of the birth state
            party <- NA
            state <- substr(birthplace,nchar(birthplace)-1,nchar(birthplace))
        } else {
            ##cat(file.now,"\n")
            mandlist <- sapply(strsplit(mandates,";")[[1]],trim)
            mandlist <- mandlist[grep("Deputad[oa] Federal",mandlist)]
            mandlist <- strsplit(mandlist[length(mandlist)],",")[[1]]
            lm <- length(mandlist)    
            party <- trim(mandlist[lm])
            state <- trim(mandlist[lm-1])
        }
    } else {
        partystate <- strsplit(toupper(trim(gsub(".* - ","",nameshort))),"/")
        party <- partystate[[1]][1]
        state <- partystate[[1]][2]
        nameshort <- toupper(trim(gsub(" - .*","",nameshort)))
    }
    parties <- toupper(paste(party,";",trim(gsub("<.*>(.*)<.*>","\\1",text.now[grep("Filiações Partidárias",text.now)[1]+5]))))
    ##print(sessions)
    file.now <- gsub(".*/(DepNovos.*)","\\1",file.now)
    parties <- gsub("\t+| +|^ +|^\t+","",parties)
    mandates <- gsub("\t+|^ +|^\t+","",mandates)
    gc()
    data.frame(namelegis=nameshort, name=namelong, party=party, state=state, birthdate, birthplace, legisserved=sessions, prevparties=parties , mandates,bioid=id,biofile=file.now,imagefile)
}
## bio.all.list <- lapply(files.list[1:2],get.bio)  
