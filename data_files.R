files = c("UA069.005.DO.00002.archival.xml","UA069.005.DO.00005.archival.xml",
          "UA069.005.DO.00012.archival.xml","UA069.005.DO.00015.archival.xml",
          "UA069.005.DO.00017.archival.xml","UA069.005.DO.00018.archival.xml",
          "UA069.005.DO.00019.archival.xml","UA069.005.DO.00020.archival.xml",
          "UA069.005.DO.00021.archival.xml")

initialize_dataset <- function() {
  bsd_data <- tibble(Seq=integer(),
                     Id=character(),
                     DisplayName=character(),   
                     LastName=character(),
                     FirstName=character(),
                     RoleName=character(),
                     OrgName=character(),
                     RecordType=character(),
                     City=character(),
                     State=character(),
                     Year=character(),
                     Occupation=character(),
                     ResidenceType=character(),
                     ResidenceName=character(),
                     ResidentialAddress=character(),
                     BusinessAddress=character())
  #First Name, Last Name, Role, Occupation, Residential Address, Business Address, Residence Type, Residence Name
  return(bsd_data)
}
