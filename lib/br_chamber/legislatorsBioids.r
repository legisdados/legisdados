
directory <- "~/reps/legisdados"
source(paste(directory, "/Rpackages/legisdados/load.R", sep="/"), echo=FALSE)

connect.db()

##MATRICULA VS BIOID


##MANUAL FIXES
## Dornelles was elected by RJ
dbGetQuery(connect,"update br_bio set state='RJ' where (bioid='98823')")
## make a table with both bio names
bioall <- dbGetQuery(connect, "select name, namelegis, bioid, legisserved, state, mandates from br_bio")
bionames <- ddply(unique(bioall[ , c("name", "state", "namelegis", "bioid", "legisserved", "mandates") ]),
                  "bioid",
                  function(x) with(x,
                                   data.frame(name, namelegis, state, bioid, mandates,
                                              legis=get.session.n(legisserved))))


library(reshape)

bio <- melt(bionames, id.var=c("bioid", "legis", "state", "mandates"))
bio$variable <- NULL
names(bio)[length(bio)] <- "name"
bio$name <- clean(bio$name)

## PHILEMON RODRIGUES was a deputy both in MG and in PB
rnow <- bio$bioid=="98291"
bio[rnow&bio$legis<52, "state"] <- "MG"
bio[rnow&bio$legis>=52, "state"] <- "PB"
##tatico deputy in both DF and GO
rnow <- bio$bioid=="108697"
bio[rnow&bio$legis>52, "state"] <- "GO"
bio[rnow&bio$legis<=52, "state"] <- "DF"
## ze indio: 100486
rnow <- bio$bioid=="100486"
tmp <- bio[rnow,]
tmp$name <- 'JOSÉ ÍNDIO'
bio <- rbind(bio, tmp)
## Mainha is José de Andrade Maia Filho 182632
rnow <- bio$bioid=="182632"
tmp <- bio[rnow,]
tmp$name <- 'MAINHA'
bio <- rbind(bio, tmp)
##Pastor Jorge is Jorge dos Reis Pinheiro 100606
rnow <- bio$bioid=="100606"
tmp <- bio[rnow,]
tmp$name <- 'PASTOR JORGE'
bio <- rbind(bio, tmp)
bio <- unique(bio)




votes <- dbGetQuery(connect, "select distinct namelegis, matricula, legis, state from  br_votes where matricula<800 ")

votes$name <- clean(votes$namelegis)
## get the longest name by matricula, legis
votes$namelegis <- NULL
votes$name <- with(votes,ave(name, matricula, legis, FUN=function(x) x[which.max(nchar(as.character(x)))]))
votes <- unique(votes)

all <- NULL
for ( i in sort(unique(votes$legis))) {
##for ( i in 50) {
    res <- NULL
    tm1 <- subset(bio, legis==i)
    tm2 <- subset(votes, legis==i)
    ## merge first those without mandate info
    ## first use state
    tm1$id <- 1:nrow(tm1)
    tm1s <- subset(tm1, is.na(mandates))
    tm2s <- tm2
    res <- rbind(res, merge(tm1s, tm2s, by=c("name", "legis", "state")))
    ## then ignore states
    tm1s <- tm1s[!tm1s$bioid%in%res$bioid,]
    tm2s <- tm2s[!tm2s$matricula%in%res$matricula,]
    tmp <- merge(tm1s, tm2s, by=c("name", "legis"))
    tmp$state <- tmp$state.y
    tmp$state.x <- NULL
    tmp$state.y <- NULL    
    res <- rbind(res, tmp)
    ## then merge remaining
    tm1s <- tm1[!tm1$bioid%in%res$bioid,]
    tm2s <- tm2[!tm2$matricula%in%res$matricula,]
    tmp0 <- subset(merge.approx(brstates, tm1s, tm2s
                                , "state", "name", maxd=.3), select=c(name, name.1, matricula, bioid, threshold, legis))
    res <- unique(rbind(subset(res, select=c(bioid, matricula, legis)), subset(tmp0,select=c(bioid, matricula, legis) )))   
    all <- rbind(all, res)
}

all <- unique(rbind(all, data.frame(bioid=98939, matricula=24, legis=51)))
err <- votes[which(!votes$matricula%in%all$matricula),]
if (nrow(err)>0) {
    stop("legislator not found")
}

dbWriteTableU(connect, "br_matriculabioid", all, append=TRUE)
