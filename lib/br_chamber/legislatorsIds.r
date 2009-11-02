## gets the legislatos ids from their roll call votes

directory <- "~/reps/legisdados"
source(paste(directory, "/Rpackages/legisdados/load.R", sep="/"), echo=FALSE)

connect.db()


## MATRICULA vs ID

## get the matriculas for each legislatura, first and last vote dates
## matricula > 800 are senate members
ml <- dbGetQuery(connect, "select a.namelegis, a.matricula, a.legis, a.state, min(b.rcdate) as mindate, max(b.rcdate) as maxdate from (select  namelegis, matricula, legis, rcvoteid, state from br_votes where legis>50 and matricula<800) as a, br_rollcalls as b where a.rcvoteid=b.rcvoteid group by matricula, legis")
## already matched
lin <- dbGetQuery(connect, "select * from br_matriculaid");dim(lin)
ml <- merge(ml, lin, all.x=TRUE)
ml <- subset(ml, is.na(id))


nr <- nrow(ml)
if (nr>0) {
    for (i in 1:nr) {
        print(i)
        ## Try with the mandate only first
        try(ml$id[i] <- with(ml[i,], get.id(legislatura=legis, matricula=matricula, init.date=mindate, final.date=mindate)))
        ## if na, try again with whole range of dates
    if (is.na(ml$id[i])) {
        try(ml$id[i] <- with(ml[i,], get.id(legislatura=legis, matricula=matricula, init.date=as.Date(mindate)-365, final.date=as.Date(maxdate)+365, overwrite=FALSE)))
    }
        ## if successful, save
        if (!is.na(ml$id[i])) {
            dbWriteTableU(connect, "br_matriculaid", data.frame(ml[i,c("matricula", "legis", "id")]), append=TRUE)
        }
    }
    ## Manual fixes
    dbWriteTableU(connect, "br_matriculaid", data.frame(matricula=423, legis=51, id=510602), append=TRUE)
}





