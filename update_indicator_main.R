# Author: Emma Wood
# Date: 08/01/2021
# Purpose: To create csv data for indicators 3.2.2, ...
# Requirements: This script runs the code in the folder stated by indicator <- "indicator_folder_name" below. 
# Runtime: last run approx. 22 seconds

# You should not need to install any packages, but if you do, use the following 
# code and just replace the name of the package from tidyr to the package you need.
# install.packages("tidyr", dependencies = TRUE, type = "win.binary")

# Because SDGupdater is a local package we install it slightly differently:

setwd("D:/Coding_repos/sdg_data_updates")
install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)

# rm(list = ls())

test_run <- FALSE

setwd(indicator)

source("compile_tables.R")
