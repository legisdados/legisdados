## based on hadley's load.R
library(plyr)
## Load installed package
##suppressMessages(library(legisdados, warn.conflicts = FALSE))

## Find path of this file and source in R files
frame_files <- compact(llply(sys.frames(), function(x) x$ofile))
PATH <- dirname(frame_files[[length(frame_files)]])

paths <- dir(file.path(PATH, "R"), full.name=T)
paths <- paths[grepl("R$",paths)]
l_ply(paths, source)
