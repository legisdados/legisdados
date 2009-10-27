## what are the propositions that reached roll call stage?
directory <- "~/reps/legisdados"
source(paste(directory, "Rpackages/legisdados/load.R", sep="/"), echo=FALSE)

connect.db()


bills <- dbGetQuery(connect, "select distinct billid, billyear, billno, billtype, status from br_bills")

bills$done <- grepl("Arquivada|Transformado em nova proposição|Transformado em Norma Jurídica|Vetado totalmente", bills$status)

##FIX: check the reasons for the NA
rollcalls <- dbGetQuery(connect, "select *, billno, billtype, billyear from br_rollcalls where billno is not null")
rollcalls <- merge(rollcalls, bills, all.x=TRUE)
rollcalls$done[is.na(rollcalls$done)] <- FALSE
rollcalls <- subset(rollcalls, !done)
rollcalls <- rollcalls[!duplicated(subset(rollcalls, select=c(billyear,billno,billtype))),]


nr <- nrow(rollcalls)
if (nr>0) {
    for (i in 1:nr) {
        cmd <- with(rollcalls[i,],
                    paste("Rscript ",directory,"/lib/br_chamber/scraping_proposition.r -d ", directory, " --load --type ",billtype, " --number ", billno, " --year ", billyear,  sep=''))
        system(cmd)
    }
}
