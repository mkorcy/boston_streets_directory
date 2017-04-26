#https://www.dataplusscience.com/Gender2.html
# install the packages if you need to
if (require("gender")) {
#install.packages('gender') ;
}
# NOTE - if asked to install GenderData click 1 for yes.
if (require("parallel")) {
#install.packages('parallel') ;
}
if (require("doParallel")) {
#install.packages('doParallel') ;
}
# load packages
library(gender) ;
library(parallel) ;
library(doParallel) ;

# Detect Cores and Register
cl<-makeCluster(detectCores())
setDefaultCluster(cl)
registerDoParallel(cl, cores=detectCores())
clusterEvalQ(cl, "gender")
clusterExport(cl,"gender")

# Create gender search function
workerFunc <- function(n){
  return
  cbind(n, gender(n, method = "ssa", years = c(1880, 1880))$gender)
}

df_1865 <- readRDS("df_1865.rds")

# Start process and track processing time
Sys.time()
res <- parLapply(cl, df_1865$FirstName, workerFunc)
Sys.time()

# Stop the cluster and create the result data frame
stopCluster(cl)

# Put final results together in data frame
indx <- sapply(res, length)
results <- as.data.frame(do.call(rbind,lapply(res, `length<-`, max(indx))))
colnames(results) <- c("name", "gender")



