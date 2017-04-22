library(dplyr)
source('parse_streets_tei.R')

#mark the start time
begin <- Sys.time()

frame2 <- parse_bsd_file_to_df(files[1])

#mark the end time so we can measure total processing
end <- Sys.time()

total_time <- end - begin

cat("Time to parse: ", total_time, '\n')

glimpse(frame2)