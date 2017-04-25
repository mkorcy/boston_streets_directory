# combine data frames
con = file("rds_files.txt", "r")

# start with an empty frame
boston_streets <- readRDS('df_1885_0.rds')

while(TRUE) {
  line = readLines(con, n = 1)
  if ( length(line) == 0 ) {
    break
  }
  temp_df <- readRDS(line)
  boston_streets <- rbind(boston_streets,temp_df)
}

close(con)
saveRDS(boston_streets, "boston_streets_combined.rds")
boston_streets$Occupation <- as.factor(boston_streets$Occupation)
