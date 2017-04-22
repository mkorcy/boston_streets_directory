library(XML)
library(tibble)

source('data_files.R')
source('utils.R')

add_row_to_ds <- function(ds, i, id, display_name, last_name, first_name,
                          org_name, record_type, city, state, year, occupation,
                          residence_type, residence_name, residential_address,
                          business_address, role_name) {
  tryCatch(
    {
      #tibble's add_row function
      people <- add_row(ds, Seq=i, Id=id, DisplayName=display_name, 
                        LastName=last_name, FirstName=first_name, 
                        OrgName=org_name,RecordType=record_type, City=city,
                        State=state, Year=year, Occupation=occupation,
                        ResidenceType=residence_type, ResidenceName=residence_name,
                        ResidentialAddress=residential_address, 
                        BusinessAddress=business_address, RoleName = role_name)
      return(people)
    }, error=function(cond) {
      log_error_to_console(cond, id, display_name, last_name, first_name)
    })
}

parse_bsd_file_to_df <- function(file) {
  people <- initialize_dataset()
  
  doc<-xmlParse(file)
  
  # get imprint information
  imprint_list <- xmlToList(getNodeSet(doc, '//imprint')[[1]])
  publication_place <- strsplit(imprint_list$pubPlace,",")
  city <- trim(publication_place[[1]][1])
  state <- trim(publication_place[[1]][2])
  publisher <- imprint_list$publisher
  year <- imprint_list$date
  
  # get just the people/business entries
  nodeSets <- getNodeSet(doc, '//div3')
  i <- 0
  for (nodeSet in nodeSets)
  {
    # debug code for dumping out smaller sets
    if (i > 250) {
       break
    }
    entry_attrs <- xmlAttrs(nodeSet)
    
    tryCatch({
      id <- entry_attrs['id']
      entry <- xmlToList(nodeSet)
      
      # not a person entry, there are these 'see also' entries which don't contain people
      if (is.null(entry$p$persName)) {
        print('skip')
        next
      }
      if (!is.null(entry$p$persName$roleName)) {
        role_name <- entry$p$persName$roleName$text
      } else {
        role_name <- NA
      }
      
      display_name <- entry$p$persName$.attrs['n']
      last_name <- entry$p$persName$surname$text
      first_name <- entry$p$persName$foreName$text
      if (!is.null(entry$p$rs)) {
        occupation <- entry$p$rs$.attrs['n']
      } else {
        occupation <- NA
      }
      
      addresses <- getNodeSet(nodeSet,'.//address')
      
      residence_type <- NA
      residence_name <- NA
      residential_address <- NA
      business_address <- NA
      
      for (address in addresses)
      { 
        address <- xmlToList(address)
        if (address$.attrs['n'] == "residential") {
          # add residential
          if (!is.null(address$type)) {
            residence_type <- address$type$.attrs['n']
          }
        } else if (address$.attrs['n'] == "commercial") {
           business_address <- address$street$.attrs['n']
        } else {
          print("unknown address type:")
          print(address$.attrs['n'])
        }
      }
      
    }, error=function(cond) {
      log_error_to_console(cond, id, display_name, last_name, first_name)
    })
    
    org_name <- NA
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
    
    people <- add_row_to_ds(people, i, id, display_name, last_name, first_name,
                            org_name, record_type, city, state, year, occupation,
                            residence_type, residence_name, residential_address,
                            business_address, role_name)
 
    i <- i + 1
    
  }
  return(people)
}
