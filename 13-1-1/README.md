Author(s): Steven Jones
Indicator: 13-1-1

Create csv data for 13-1-1 (Number of deaths and Age-Standardised mortality rates for deaths attributed to disasters in England and Wales) with the following disaggregation(s):
- cause of death
- sex
- country

Runtime is less than 30 seconds

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs as caveats may change in the future.
In particular, please check in the source data whether the most recent figures are provisional. If they 
are, in the csv tab of the In progress/Indicator xlsx file change the observation status to 'Provisional'.  
  
        
### USER INSTRUCTIONS (SDG Data team): 

1) Open RStudio.
2) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
3) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
4) Change the indicator number to '13-1-1' (Dashes NOT dots).
5) Open the example_config file in the 13-1-1 folder. Save it (in the same place) as config.R, and edit as required.
6) Go back to update_indicator_main.R. Click the 'source' button (in the top right of the top left window). This will run the code. 
You may need to install some packages if they are not already installed. Use `install.packages('name_of_package', dependencies = TRUE, type = 'win.binary')` to install packages, 
then try running the code (using the source button) again. If you need to install SDGupdater, the code is slightly different: 
First type `getwd()` in the console to check that it points at the sdg_data_updates folder. If it points at an indicator folder type `setwd('..')`. This is so your computer
is looking for the SDGupdater package (folder) in the right place. Then use `install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)` to install it.
7) csv and html (QA) files will be exported to the Output folder. Read through the QA file, and if there are no issues, copy the csv into the csv tab of the In progress/Indicator xlsx file.
8) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('..')` before repeating step 7.

### QA PROCESS (SDG Data team):
Read the automatically generated QA report. The QA report will display a table of non-matching rows between the original and updated datasets. If this table contains rows for years which are covered by the original dataset, an error has occurred.

The QA report does not negate checking the source data for notes, but if everythig looks fine in the report, numbers should not need to be checked.

### TROUBLESHOOTING:
Some possible errors (may not be an exact match) and solutions:    
    
```diff
- Error in setwd(paste0("H:/Coding_repos/sdg_data_updates/", indicator)): 
- cannot change working directory

The folder name you have given for indicator does not exist. Check you are using '-' not '.' between the numbers.  
  
```  
  
  
```diff
- Error in setwd(indicator) : cannot change working directory
  
The folder name (`indicator`) in `update_indicator_main.R` is incorrectly typed. OR    
  
The script is looking in the wrong working directory. 
To check which directory it is looking in, type `getwd()` in the console and hit enter.
It should not have the indicator folder at the end of the filepath, but should end with 'sdg_data_updates'. 
If it does not end with 'sdg_data_updates' type `setwd('./..')`, this will make R look in the directory above.

```


### NOTES:
	
config.R: called by compile_tables.R

  The Nomis links shouldn't need to be updated. The ONS dataset is unlikely to be updated (beyond 2018) and the script only uses data up to 2012.
	These configurations are used by recent_data.R and historical_data.R to load the source data and by compile_tables.R decide whether to run historical_data.R.
	
compile_tables.R: called by update_indicator_main.R.
  
	Combines the output from recent_data.R and historical_data.R if appropriate. Writes the output dataframe to csv and renders the QA document.  
	
recent_data.R: called by compile_tables.R
	
	Produces the dataframe for the number of deaths caused by natural disasters and age-standardised mortality rate for 2013 onward.

historical_data.R: called by compile_tables.R if in config.R: run_historic_data <- TRUE

	Produces the dataframe for the number of deaths caused by natural disasters for 2001 to 2012.
