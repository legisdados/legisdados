\name{get.votos.1}
\Rdversion{1.1}
\alias{get.votos.1}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
get.votos.1(LVfile)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{LVfile}{
%%     ~~Describe \code{LVfile} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function(LVfile) {
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
    names(LV) <- c("session","rcvoteid","namelegis",paste("vote",voteid,sep="."),"party","state","id") #rename fields
    LV$state <- toupper(state.l2a(LV$state))
    LV$state <- factor(LV$state,levels=toupper(states))
    LV <- LV[,c("id","namelegis","party","state",paste("vote",voteid,sep="."))] #rearrange fields
    ## read fields in HE file
    vt <- unlist(read.table(HEfile, header=FALSE, strip.white = TRUE, as.is = TRUE, encoding="latin1", sep="\n"))
    vt.date <- as.Date(vt[3], "\%d/\%m/\%Y")
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
    return(list(data.votos=data.votos,data.votacoes=data.votacoes))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
