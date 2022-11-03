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
  
### Examples
Example_Input, Example_output and example_config.R still need to be added.
        
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


1) Save the most recent [UK greenhouse gas emissions final figures](https://www.gov.uk/government/statistics/final-uk-greenhouse-gas-emissions-national-statistics-1990-to-2020) as an **xlsx** file in Jemalex/code for updates/13-2-2/Input. You may need to create the Input folder if one does not already exist.
2) Open RStudio.
3) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
4) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
5) Change the indicator number to '13-1-1' (Dashes NOT dots).
6) Open the example_config file in the 13-1-1 folder. Save it (in the same place) as config.R, and edit as required. `header_row` is the row on which the column names are written. 
This is liable to change between years so please check it! `output_folder` should be 'Output' - this will be created by the script if it doesn't already exist. 
7) Go back to update_indicator_main.R. Click the 'source' button (in the top right of the top left window). This will run the code. 
You may need to install some packages if they are not already installed. Use `install.packages('name_of_package', dependencies = TRUE, type = 'win.binary')` to install packages, 
then try running the code (using the source button) again. If you need to install SDGupdater, the code is slightly different: 
First type `getwd()` in the console to check that it points at the sdg_data_updates folder. If it points at an indicator folder type `setwd('..')`. This is so your computer
is looking for the SDGupdater package (folder) in the right place. Then use `install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)` to install it.
8) csv and html (QA) files will be exported to the Output folder. Read through the QA file, and if there are no issues, copy the csv into the csv tab of the In progress/Indicator xlsx file.
9) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('..')` before repeating step 7.

Please check the data source to check for changes in the caveats, see if the best data are being reported, and check whether there are other series we sohould include

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
	These configurations are used by 'update_indicator.R'.  
	
compile_tables.R: called by update_indicator_main.R.
  
	Reads in the data from the input folder, runs the script that puts the data in the csv format (by_gas_type.R), and the Rmarkdown file that creates the QA html
	which it then saves in the Output folder.  If the Output folder does not already exist, it creates one.  
	
update_indicator.R: called by compile_tables.R
  This is where the bulk of the work is done. It combines data from the 3 data sources and aggregates by sex and cause of death where necessary.
 
