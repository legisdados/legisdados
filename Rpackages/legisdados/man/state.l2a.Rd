\name{state.l2a}
\Rdversion{1.1}
\alias{state.l2a}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
state.l2a(object)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{
%%     ~~Describe \code{object} here~~
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
function(object) {
  ##require(car)
  object <- tolower(as.character(object))
  car:::recode(object,"
                       'acre'                  = 'ac';
                       'alagoas'               = 'al';
                       'amazonas'              = 'am';
                       c('amapa','amapá')      = 'ap';
                       'bahia'                 = 'ba';
                       c('ceara','ceará')       = 'ce';
                       'distrito federal'      = 'df';
                       'espírito santo'        = 'es';
                       'espirito santo'        = 'es';
                       'espitito santo'        = 'es';
                       c('goias','goiás')       = 'go';
                       c('maranhao','maranhão')= 'ma';
                       'minas gerais'          = 'mg';
                       'mato grosso do sul'    = 'ms';
                       'mato g sul'            = 'ms';
                       'm. g. do sul'          = 'ms';
                       'mato grosso'           = 'mt';
                       'para'                  = 'pa';
                       'pará'                  = 'pa';
                       'paraiba'               = 'pb';
                       'paraíba'               = 'pb';
                       'pernambuco'            = 'pe';
                       'piaui'                 = 'pi';
                       'piauí'                 = 'pi';
                       'parana'                = 'pr';
                       'paraná'                = 'pr';
                       'rio de janeiro'        = 'rj';
                       'r. g. do norte'        = 'rn';
                       'rio grande do norte'   = 'rn';
                       'rondonia'              = 'ro';
                       'rondônia'              = 'ro';
                       'roraima'               = 'rr';
                       'rio grande do sul'     = 'rs';
                       'r. g. do sul'          = 'rs';
                       'santa catarina'        = 'sc';
                       'sergipe'               = 'se';
                       'sao paulo'             = 'sp';
                       'são paulo'             = 'sp';
                       'tocantins'              = 'to'")
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
