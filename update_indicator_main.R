# Purpose: To run indicator update scripts
# Requirements: This script runs the code in the folder stated by indicator <- "indicator_folder_name" below.

# install.packages("SDGupdater", repos = NULL, type = "source", force = TRUE)

rm(list = ls())
library(magrittr) # need to use library rather than namespace operator (::) for the pipe ( %>% )

#----------------------------------------------------------------------------------------------

indicator <- "3-2-2" # name of folder for indicator update

setwd(paste0("./", indicator))

source("compile_tables.R")
