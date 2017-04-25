library(XML)
library(tibble)

source('data_files.R')
source('utils.R')

add_row_to_ds <- function(ds, i, id, display_name, last_name, first_name, 
                          org_name, record_type, residence_city, business_city, state, year, occupation,
                          residence_type, residence_name, residential_address,
                          business_address, role_name) {
  tryCatch(
    {
      # clean up
      if (is.na(business_address)) {
         business_city <- NA
      }
      
      if (is.null(residential_address)) {
        residential_address <- NA
      }
      if (is.na(residential_address) && is.na(residence_type)) {
          residence_city <- NA
      }
      
      #tibble's add_row function
      people <- add_row(ds, Seq=i, Id=id, DisplayName=display_name, 
                        LastName=last_name, FirstName=first_name, 
                        OrgName=org_name,RecordType=record_type, BusinessCity=business_city,
                        ResidenceCity=residence_city, State=state, Year=year, Occupation=occupation,
                        ResidenceType=residence_type, ResidenceName=residence_name,
                        ResidentialAddress=residential_address, 
                        BusinessAddress=business_address, RoleName = role_name)
      return(people)
    }, error=function(cond) {
      log_error_to_console(cond, id, display_name, last_name, first_name)
    })
}

skip_entry <- function(entry) {
  skip <- FALSE
  
  if (!is.recursive(entry$p) || is.null(entry$p$persName)) {
    skip <- TRUE
  }
  
  return(skip)
}

parse_bsd_file_to_df <- function(file) {
  people <- initialize_dataset()
  
  doc<-xmlParse(file)
  
  # get imprint information
  imprint_list <- xmlToList(getNodeSet(doc, '//imprint')[[1]])
  publication_place <- strsplit(imprint_list$pubPlace,",")
  # good starting point for city, there are a few exceptions
  business_city <- trim(publication_place[[1]][1])
  residence_city <- trim(publication_place[[1]][1])
  state <- trim(publication_place[[1]][2])
  publisher <- imprint_list$publisher
  year <- imprint_list$date
  
  # get just the people/business entries
  nodeSets <- getNodeSet(doc, '//div3')
  i <- 0
  
  for (nodeSet in nodeSets)
  {
    #print(i)
    if (i %% 1000 == 0) {
      print(i)
    }
    
    if (i %% 10000 == 0) {
      output_file <- "df_" %&% year %&% "_" %&% i %&% ".rds"
      saveRDS(people, output_file)
      print("writing file...")
      people <- initialize_dataset()
    }
    
    business_city <- trim(publication_place[[1]][1])
    residence_city <- trim(publication_place[[1]][1])
    # debug code for dumping out smaller sets
  
    #if (i > 1000) {
    #   break
    #}
    entry_attrs <- xmlAttrs(nodeSet)
    
    tryCatch({
      id <- entry_attrs['id']
      entry <- xmlToList(nodeSet)
      
      if (id == "d.1905.e.2570") {
        print("stop")
      }
      # not a person entry, there are these 'see also' entries which don't contain people
      
      if (skip_entry(entry)) {
        next
      }
      
      if (!is.null(entry$p$persName$roleName)) {
        role_name <- entry$p$persName$roleName$text
      } else {
        role_name <- NA
      }
      
      display_name <- entry$p$persName$.attrs['n']
      if (is.null(entry$p$persName$surname)) {
        last_name <- NA
      } else {
        if (is.atomic(entry$p$persName$surname)) {
          last_name <- entry$p$persName$surname
        } else {
          last_name <- entry$p$persName$surname$text  
        }
        
      }
      
      first_name <- NA
      if (!is.null(entry$p$persName$foreName)) {
        if (is.atomic(entry$p$persName$foreName)) {
          first_name <- entry$p$persName$foreName
          } else {
          first_name <- entry$p$persName$foreName$text
        }
      }
      
      if (!is.null(entry$p$rs)) {
        if (is.atomic(entry$p$rs)) {
          occupation <- entry$p$rs['n']
        } else {
          occupation <- entry$p$rs$.attrs['n']
        }
      } else {
        occupation <- NA
      }
      
      addresses <- getNodeSet(nodeSet,'.//address')
      
      residence_type <- NA
      residence_name <- NA
      residential_address <- NA
      business_address <- NA
      
      for (address_xml in addresses)
      { 
        address <- xmlToList(address_xml)
        if (address$.attrs['n'] == "residential") {
          
          # add residential
          if (!is.null(address$name)) {
            if (grepl("key",attributes(address$name$.attrs)) == TRUE) {
              residence_type <- address$name$.attrs['key']
            } else {
              residence_type <- address$name$.attrs['n']
            }
          } else {
            residence_type <- "residential"
          }
          
          if (!is.null(address$street)) {
            residential_address <- address$street$.attrs['n']
          }
          
          if (grepl("boards",residence_type)) {
            placeName <- getNodeSet(address_xml,'.//placeName')
            if (length(placeName) > 0) {
              placeName <- xmlToList(placeName[[1]])
              if (!is.null(placeName)) {
                residence_name <- placeName$.attrs['n']
              }
            }
          }
          
          if (!grepl("boards",residence_type) & grepl(" at",residence_type)) {
            placeName <- getNodeSet(address_xml,'.//placeName')
            if (length(placeName) > 0) {
              tryCatch({
                placeName <- xmlToList(placeName[[1]])
                if (!is.null(placeName)) {
                  residence_city <- placeName$.attrs['n']
                }
              }, error=function(cond) {
                residence_city <- placeName[[1]]
              })
              
            }
          }
          if (residence_type == "h.") {
            placeName <- getNodeSet(address_xml,'.//placeName')
            if (length(placeName) > 0) {
              placeName <- xmlToList(placeName[[1]])
              tryCatch({
                residence_name <- placeName$.attrs['n']
              }, error=function(cond) {
                residence_name <- placeName[[1]]
              })
                
            }
          }
          
          
        } else if (address$.attrs['n'] == "commercial") {
          if (!is.null(address$street)) {
            business_address <- address$street$.attrs['n']
          }
            
           
        } else if (address$.attrs['n'] == "residential.nonBoston" | address$.attrs['n'] == "residenital.nonBoston") {
          
          # get place name
          if (!is.null(address$street)) {
            residential_address <- address$street$.attrs['n']
          }
          placeName <- getNodeSet(address_xml,'.//placeName')
          if (length(placeName) > 0) {
            placeName <- xmlToList(placeName[[1]])
            residence_city <- placeName$.attrs['n']
          }
          
        } else if (address$.attrs['n'] == "commercial.nonBoston" | address$.attrs['n'] == "commercial. nonBoston") {
          
          # get place name
          if (!is.null(address$street)) {
            business_address <- address$street$.attrs['n']
          }
          placeName <- getNodeSet(address_xml,'.//placeName')
          if (length(placeName) > 0) {
            placeName <- xmlToList(placeName[[1]])
            business_city <- placeName$.attrs['n']
          }
          
        } else {
          
          print("unknown address type:", address$.attrs['n'], '\n')
          
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
  
 
    if (is.null(residential_address) || is.na(residential_address)) {
      list2 <- xmlToList(nodeSet, addAttributes = TRUE, simplify = TRUE)
      if (class(list2[[length(list2) -1]]) == "character") {
        temp <- gsub("\\t|,","", list2[[length(list2) -1]])
        if (!is.null(temp))
        {
          business_address <- temp
        }
      }
    }
    people <- add_row_to_ds(people, i, id, display_name, last_name, first_name,
                            org_name, record_type, residence_city, business_city, state, year, occupation,
                            residence_type, residence_name, residential_address,
                            business_address, role_name)
 
    i <- i + 1
    
  }
  return(people)
}
