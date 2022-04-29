Author(s): Emma Wood

Create csv data for 3-2-2 (Neonatal mortality rate) with the following disaggregations:
- birthweight by mother age (though cross disaggregation not currently kept for the csv)
- country of occurrence by sex of baby
- area of residence (region)
- mother's country of birth
Neonatal period (early or late) is also included

Runtime is less than 30 seconds

Input data are stored in a folder named 'Input' (See 'Example Data'). Outputs are saved to a folder named 'Output'. 

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs as caveats may change in the future.  
  
### Examples
Example data are given in the Example data folder. These tables are based on 2017 tables but have been cropped.  
Example data can be run through the script using `example_config.R` to produce the output in the 'Example output' folder.  
To do this you will need to follow the instructions below from step 3. You will additionally need to edit `compile_tables.R` so that it reads `source('example_config.R')` rather
than `source('config.R')`.  
        
### USER INSTRUCTIONS (SDG Data team): 

1) Save 'Child mortality (death cohort) tables in England and Wales' as an **xlsx** file in Jemalex/code for updates/3.2.2/Input. You may need to create the Input folder if one does not already exist.
2) Open config.yml in the 3-2-2 folder and check that all configurations are correct. For example, `input_folder` must be `'Input'`, not `'example_input'`.  
> The `first_header_row` settings refer to the row number of the top level of column names. All rows above this just contain information like the country and year the data refer to.
3) Open RStudio.
4) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
5) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
6) Change the indicator number to '3-2-2' (Dashes NOT dots).
7) Click the 'source' button (in the top right of the top left window). This will run the code. You may need to install some packages if they are not already installed. ~Use `install.packages('name_of_package', dependencies = TRUE)` to install packages, then try running the code (using the source button) again.
8) csv and html (QA) files will be exported to Output folder.
9) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('./..')` before repeating step 7.

Please check the data source to check for changes in the caveats, see if the best data are being reported, and check whether there are other series we sohould include

### QA PROCESS (SDG Data team):
Read the automatically generated QA report. Pay particular attention to the charts as this is where you are likely to spot any unexpected problems with the code. For
emaple if a line or point is missing, or looks strange, this may indicate a change in the formatting of the data.

The QA report does not negate checking the source data for notes, but if everythig looks fine in the report, numbers should not need to be checked.

### TROUBLESHOOTING:
Some possible errors (may not be an exact match) and solutions:    
    
```diff
- Error in setwd(paste0("H:/Coding_repos/sdg_data_updates/", indicator)): 
- cannot change working directory

The folder name you have given for indicator does not exist. Check you are using '-' not '.' between the numbers.  
  
```  
  
```diff
- Error: Sheets not found: "Table  2"  
  
There is a typo in one of the tables in the `config.R` file. e.g. here there is an extra space.
  
```
  
```diff
- Error: Problem with `mutate()` column `number_late_neonatal_deaths`.
- i `number_late_neonatal_deaths = neonatal_number - early_neonatal_number`.
- x object 'neonatal_number' not found  
  
You may have entered an existing, but incorrect table number. OR    
  
The headings of the table may have changed, or, for example, been split over multiple cells. 
Check the source table headings look like those in previous releases. 
If not, either adapt the code and test it on old and new data tables, or edit the excel file (the former is recommended).  

```
  
```diff
- Error in setwd(indicator) : cannot change working directory
  
The folder name (`indicator`) in `update_indicator_main.R` is incorrectly typed. OR    
  
The script is looking in the wrong working directory. 
To check which directory it is looking in, type `getwd()` in the console and hit enter.
It should not have the indicator folder at the end of the filepath, but should end with 'sdg_data_updates'. 
If it does not end with 'sdg_data_updates' type `setwd('./..')`, this will make R look in the directory above.

```

```diff
- Warning messages:
1: In rename_column(., primary = c("rate", "neo"), not_pattern = "peri|post|early|late|stillbirth",  :
  0 columns identified for neonatal_rate . Please refine 'primary', 'alternate', and 'not_pattern' arguments. Column name not replaced
  
The name of the column (in this case for neonal=tal mortality rate) has changed and is not longer captured by the arguments in  
rename_column. Adapt the arguments as described in the warning message.
  
If there are multiple warnings that are very similar, the first_header_row is probably incorrect for one of the tables. Correct this in the config file.


```


### NOTES:
	
config.R: contains configuration data that will/are likely to change between years e.g filename and tab names.
	These configurations are used by country_of_occurence_by_sex.R, birthweight_by_mum_age.R, and region.R.  
	
compile_tables.R: called by update_indicator_main.R.
	Reads in the data from the input folder, and runs the scripts for each table, and compiles them into a single csv, 
	which it saves in the Output folder.  If the Output folder does not already exist, it creates one.  
	
country_of_occurence_by_sex.R, birthweight_by_mum_age.R, region.R etc: where the bulk of the work is done.
	These scripts take the data from the input file, mung it into the format we want, and do calculations.
	Each script uses a different tab in the xlsx file. Output from each is saved in the global environment
	in case the user wants to see what data came from where, but they are not individually saved to the Output folder.
  
Table 1 in the source data is used from 2018 onwards for England and Wales figures, as this is no longer included in table 2.
  
See the available disaggregations, calculations, and other info fields on the live platform for more information on why certain disaggregations are not shown, and why calculations differ for some disaggregations.  
#### still to do
Index of Multiple Deprivation is in the 2021 download for all years - may want to add
this as an automated table next year (no point this year as we don't know what it will look like)
