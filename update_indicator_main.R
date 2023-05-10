# Author: Emma Wood
# Date: 08/01/2021
# Purpose: This script runs the code in the folder stated by 
#          indicator <- "indicator_folder_name" below. 


# Because SDGupdater is a local package we install it slightly differently:

install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)

# note that to install this package the working directory needs to be
# sdg_data_updates. Use getwd() to check this is the folder you are in.

<<<<<<< HEAD
rm(list = ls())
=======

# rm(list = ls())
>>>>>>> 69ff629bcf26f1711c5185a79e3475921fc2104b

test_run <- FALSE # for real updates use FALSE

indicator <- "3-5-1" # name of folder for indicator(s)

source("compile_tables.R")