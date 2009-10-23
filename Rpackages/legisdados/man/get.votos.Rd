\name{get.votos}
\Rdversion{1.1}
\alias{get.votos}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
get.votos(LVfile)
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
    ## a wrapper over get.votos.1
    ## accepts a vector of LVfile (length>1)
    require(plyr)
    res <- lapply(LVfile,get.votos.1)
    ##dlply(res,function(x) x[[1]])
    votacoes <- ldply(res,function(x) x[[2]])
    votos <- ldply(res,function(x) x[[1]])
    list(votacoes, votos)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
