source('parse_streets_tei.R')

frame2 <- parse_bsd_file_to_ds(files[1])
str(frame2)