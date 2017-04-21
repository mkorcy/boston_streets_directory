library(XML)
library(tibble)

source('data_files.R')
source('utils.R')

parse_bsd_file_to_ds <- function(file) {
  people <- tibble(Seq=integer(),
                   Id=character(),
                   DisplayName=character(),   
                   LastName=character(),
                   FirstName=character(),
                   OrgName=character(),
                   RecordType=character(),
                   City=character(),
                   State=character(),
                   Year=character())
  doc<-xmlParse(file)
  
  # get imprint information
  imprint_list <- xmlToList(getNodeSet(doc, '//imprint')[[1]])
  publication_place <- strsplit(imprint_list$pubPlace,",")
  city <- trim(publication_place[[1]][1])
  state <- trim(publication_place[[1]][2])
  publisher <- imprint_list$publisher
  year <- imprint_list$date
  
  # get get just the people/business entries
  nodeSets <- getNodeSet(doc, '//div3')
  i <- 0
  for (nodeSet in nodeSets)
  {
    # debug code for dumping out smaller sets
    if (i >100) {
       break
    }
    entry_attrs <- xmlAttrs(nodeSet)
    tryCatch({
    id <- entry_attrs['id']
    entry <- xmlToList(nodeSet)
    display_name <- entry$p$persName$.attrs['n']
    last_name <- entry$p$persName$surname$text
    first_name <- entry$p$persName$foreName$text
    org_name <- NA
    }, error=function(cond) {
      print("error")
      print(cond)
      print(id)
      print(display_name)
      print(last_name)
      print(first_name)
    })
    if (is.null(last_name) & is.null(first_name)) {
      # its not a person its an organization
      org_name <- entry$p$orgName$text
      first_name <- NA
      last_name <- NA
      display_name <- org_name
      record_type <- "organization"
    } else {
      record_type <- "resident"
    }
    
      
      
    tryCatch(
      {
        people <- add_row(people, Seq=i, Id=id, DisplayName=display_name, 
                          LastName=last_name, FirstName=first_name, 
                          OrgName=org_name,RecordType=record_type, City=city,
                          State=state, Year=year)
      }, error=function(cond) {
        print("error")
        print(cond)
        print(id)
        print(display_name)
        print(last_name)
        print(first_name)
      })
    #last_name <- nodeSet[['p']][['persName']][['surname']][1]$text
    #first_name <- nodeSet[['p']][['persName']][['foreName']][1]$text
    #referencing_string_attrs <- xmlAttrs(nodeSet[['p']][['rs']])
    #type <- referencing_string_attrs['type']
    #val <- referencing_string_attrs['n']
    #class(id)
    #class(last_name)
    #class(first_name)
    #class(val)
    i <- i + 1
    
  }
  return(people)
}
