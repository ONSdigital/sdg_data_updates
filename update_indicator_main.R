# Author: Emma Wood
# Date: 08/01/2021
# Purpose: To create csv data for indicators 3.2.2, ...
# Requirements: This script runs the code in the folder stated by indicator <- "indicator_folder_name" below.
# Runtime: last run approx. 6 seconds

# install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)

rm(list = ls())

start.time <- Sys.time()

library(magrittr) # need to use library rather than namespace operator (::) for the pipe ( %>% )

#----------------------------------------------------------------------------------------------

indicator <- "3-2-2" # name of folder for indicator

setwd(paste0("./", indicator))

source("compile_tables.R")

end.time <- Sys.time()
end.time-start.time

getwd()
