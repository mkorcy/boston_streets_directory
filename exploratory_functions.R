library(XML)

# Trying to get an idea of how much data I'm dealing with.
approximate_number_of_entries <- function(files) {
  s <- c()
  index <- 0
  for(file in files) {
    doc<-xmlParse(file)
    nodeSet <- getNodeSet(doc, '//div3')
    s[index] <- length(nodeSet)
    index <- index + 1
  }
  print(sum(s))
}

# approximate_number_of_entries(files)
# 1243698
