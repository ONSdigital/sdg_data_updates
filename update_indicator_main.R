# Author: Emma Wood
# Date: 08/01/2021
# Purpose: This script runs the code in the folder stated by 
#          indicator <- "indicator_folder_name" below. 


# Because SDGupdater is a local package we install it slightly differently:

install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)

# note that to install this package the working directory needs to be
# sdg_data_updates. Use getwd() to check this is the folder you are in.


rm(list = ls())

test_run <- FALSE # for real updates use FALSE

indicator <- "ODA" # name of folder for indicator


setwd(indicator)

source("compile_tables.R")

