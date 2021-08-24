## Template R code
  
The code in this folder has been pulled together to make the process of writing automations in R faster and more consistent across indicators. 
It also contains bits of code that aid in future-proofing against changes in the initial files.
  
There are four main files that should be relatively consistent in what they do across all indicators (where it is just a standard update):
1. `update_indicator_main.R` This file is the control script for ALL standard R updates. 
You should not need to change anything on it, other than the indicator number when you are testing your automation
2. `compile_tables.R` Every standard R update needs a script with this exact name. It is the script called by `update_indicator_main.R`, 
and which calls the scripts that do the donkey-work. The csv may be saved from here. The Rmarkdown html file is run and saved from here.
3. `config.R` This could be written as a yaml, but usually the configs are straightforward enough that an R config file is fine. This is where
user configurations are set - these are aspects of the code that may need to be changed depending on when it is run, but that we can't or don't want to automate.
It should have this name to save any confusion, and because this is a standard name for this kind of file. It is called by `compile_tables.R`
4. A .R script or scripts that do the bulk of the work called by `compile_tables.R`. In this template folder, the template script is called `update_x-x-x.R`.
It/they can be called anything, but try to keep it informative.
5. A .Rmd script that creates an html for QA purposes (not yet in templates) called by `compile_tables.R`.
  
## 

