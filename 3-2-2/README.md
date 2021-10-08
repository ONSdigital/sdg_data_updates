Author(s): Emma Wood

Create csv data for 3-2-2 (Neonatal mortality rate) with the following disaggregations:
- birthweight by mother age
- country of occurrence by sex of baby
- area of residence (region)

Runtime is approximately 6 seconds

Input data are stored in a folder named 'Input' (See 'Example Data'). Outputs are saved to a folder named 'Output'. 
        
### USER INSTRUCTIONS (SDG Data team): 

1) Save 'Child mortality (death cohort) tables in England and Wales' as an xlsx file in Jemalex/code for updates/3.2.2/Input. You may need to create the Input folder if one does not already exist.
2) Open config.yml in the 3-2-2 folder and check that all configurations are correct.
> The `first_header_row` settings refer to the row number of the top level of column names. All rows above this just contain information like the country and year the data refer to.
3) Open RStudio.
4) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
5) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
6) Change the indicator number to '3-2-2' (Dashes NOT dots).
7) Click the 'source' button (in the top right of the top left window). This will run the code. You may need to install some packages if they are not already installed. ~Use `install.packages('name_of_package', dependencies = TRUE)` to install packages, then try running the code (using the source button) again.
8) csv files will be exported to Output folder.

Please check the data source to see if the best data are being reported, or if there are other series we sohould include

### QA PROCESS (SDG Data team):
...

### TROUBLESHOOTING:
If you get the error:
Error in setwd(paste0("H:/Coding_repos/sdg_data_updates/", indicator)) : 
  cannot change working directory
-The folder name you have given for indicator does not exist. Check you are using '-' not '.' between the numbers.


### NOTES:
	
config.yml: contains configuration data that will/are likely to change between years e.g filename and tab names.
	These configurations are used by country_of_occurence_by_sex.R, birthweight_by_mum_age.R, and region.R.  
	
compile_tables.R: called by update_indicator_main.R.
	Reads in the data from the input folder, and runs the scripts for each table, and compiles them into a single csv, 
	which it saves in the Output folder.  If the Output folder does not already exist, it creates one.  
	
country_of_occurence_by_sex.R, birthweight_by_mum_age.R, and region.R: where the bulk of the work is done.
	These scripts take the data from the input file, mung it into the format we want, and do calculations.
	Each script uses a different tab in the xlsx file. Output from each is saved in the global environment
	in case the user wants to see what data came from where, but they are not individually saved to the Output folder.

#### still to do
Index of Multiple Deprivation is in the 2021 download for all years - may want to add
this as an automated table next year (no point this year as we don't know what it will look like)
