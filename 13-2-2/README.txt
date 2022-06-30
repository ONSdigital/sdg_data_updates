Author(s): Emma Wood
Indicator: 13-2-2

Create csv data for 13-2-2 (Total greenhouse gas emissions per year) with the following disaggregation(s):
- gas

Runtime is less than 30 seconds

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs as caveats may change in the future.
In particular, please check in the source data whether the most recent figures are provisional. If they 
are, in the csv tab of the In progress/Indicator xlsx file change the observation status to 'Provisional'.  
  
### Examples
Example data are given in the Example_Input folder. These tables are based on real tables but have been shortened and the numbers edited.  
Example data can be run through the script using `example_config.R` to produce the output in the Example_output folder.  
To do this you will need to follow the instructions below from step 3. You will additionally need to edit `compile_tables.R` so that it reads `source('example_config.R')` rather
than `source('config.R')`.  
        
### USER INSTRUCTIONS (SDG Data team): 

1) Save '' as an **xlsx** file in Jemalex/code for updates/13-2-2/Input. You may need to create the Input folder if one does not already exist.
2) Open RStudio.
3) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
4) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
5) Change the indicator number to '13-2-2' (Dashes NOT dots).
6) Open the example_config file in the 13-2-2 folder. Save it (in the same place) as config.R, and edit as required. `header_row` is the row on which the column names are written. 
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
- Error: Sheets not found: "1. 1"  
  
There is a typo in one of the tables in the `config.R` file. e.g. here there is an extra space (in this case it should have been 1.1 to match the source.
  
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
	
config.R: contains configuration data that will/are likely to change between years e.g filename and tab names.
	These configurations are used by 'by_gas_type.R'.  
	
compile_tables.R: called by update_indicator_main.R.
	Reads in the data from the input folder, runs the script that puts the data in the csv format (by_gas_type.R), and the Rmarkdown file that creates the QA html
	which it then saves in the Output folder.  If the Output folder does not already exist, it creates one.  
	
by_gas_type.R: where the bulk of the work is done.
	Thise script takes the data from the input file, and mungs it into the format we want. In this indicator no calculations are required.
  
  
#### For development
In the for_development folder there is an old script that pulled out the data for emissions by sector. I'm not sure if we want this on the platform, but if we do
this script can be integrated into the code.
