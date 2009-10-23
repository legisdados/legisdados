trim <-  function (s)
{
  s <- sub("^\t+","", s)
  s <- sub("^ +", "", s)
  s <- sub(" +$", "", s)
  s
}

trimm <- function(x) gsub(" +"," ",trim(x))
