# library(dplyr)
# source('parse_streets_tei.R')
# 
# #mark the start time
# begin <- Sys.time()
# 
# #df_1855 <- parse_bsd_file_to_df(files[1])
# #df_1845 <- parse_bsd_file_to_df(files[5])
# #df_1865 <- parse_bsd_file_to_df(files[9])
# #df_1870 <- parse_bsd_file_to_df(files[6])
# #sink("df7.log", append=FALSE, split=FALSE)
# #df_7 <- parse_bsd_file_to_df(files[7])
# #saveRDS(df_7, "df_7.rds")
# #sink()
# #sink("df8.log", append=FALSE, split=FALSE)
# #df_8 <- parse_bsd_file_to_df(files[8])
# #saveRDS(df_8, "df_8.rds")
# #sink()
# #sink("df3.log", append=FALSE, split=FALSE)
# #df_3 <- parse_bsd_file_to_df(files[3])
# #saveRDS(df_3, "df_3.rds")
# #sink()
# sink("df4.log", append=FALSE, split=FALSE)
# df_4 <- parse_bsd_file_to_df(files[4])
# #saveRDS(df_4, "df_4.rds")
# #sink()
# #sink("df2.log", append=FALSE, split=FALSE)
# #df_2 <- parse_bsd_file_to_df(files[2])
# #saveRDS(df_2, "df_2.rds")
# #sink()
# #mark the end time so we can measure total processing
# #end <- Sys.time()
# 
# #total_time <- end - begin
# 
# #cat("Time to parse: ", total_time, '\n')
# 
# #glimpse(frame2)
# 
# # 1855 -- total time --  37.20327m
# # 1845 -- Time to parse:  9.981808m
# 
# #saveRDS(df_1855, "df_1855.rds")
# #saveRDS(df_1845, "df_1845.rds")
# #saveRDS(df_1865, "df_1865.rds")
# #saveRDS(df_1870, "df_1870.rds")
# #test_2 <- readRDS("df_1845.rds")
# #save(boston_streets, file="BostonStreets.RData")
# #write.csv(boston_streets, file = "boston_streets.csv")
