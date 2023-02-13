Author(s): Ali Campbell

Create csv data for 5-6-1 (Women using Sexual and Reproductive Health Services) with disaggregations:
- Age
- Main method of contraception -> Type of contraception
- Region -> local authority

Runtime of about 30 seconds

Once finished, output folder should contain a .csv output and a .html QA checks file. Still advisable to look at the source data and check foot notes and information tabs.
In particular: 
	- Prior to 2020/21 the local authority tab is called 'Table 17', but from 2020/21 onwards it is 'Table 17a', so check the tab names haven't changed
	- Check that values being read in are thousands not percentages
	- Check the foot notes for 'Other methods', the totals are different depending on whether age or local authority data

### Examples


### USER INSTRUCTIONS (SDG DATA TEAM)
1) Save the most recent data from [Sexual and Reproductive Health Services (Contraception): https://digital.nhs.uk/data-and-information/publications/statistical/sexual-and-reproductive-health-services] as a .xlsx file in Z:\Data Collection and Reporting\Jemalex\sdg_data_updates\5-6-1\Input. Ensure in the format “srh-serv-eng-21-22-tab.xlsx”.
2) Open RStudio
3) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
4) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
5) Change the indicator number to '5-6-1' (Dashes NOT dots).
6) Open the example_config file in the 5-6-1 folder. Save it (in the same place) as config.R, and edit as required. `header_row` is the row on which the column names are written. Make sure the year(s) are correct and the filename(s) match the format in the code. The tabnames are liable to change so check them in the table.
This is liable to change between years so please check it! `output_folder` should be 'Output' - this will be created by the script if it doesn't already exist. 
7) Go back to update_indicator_main.R. Click the 'source' button (in the top right of the top left window). This will run the code. 
You may need to install some packages if they are not already installed. Use `install.packages('name_of_package', dependencies = TRUE, type = 'win.binary')` to install packages, 
then try running the code (using the source button) again. If you need to install SDGupdater, the code is slightly different: 
First type `getwd()` in the console to check that it points at the sdg_data_updates folder. If it points at an indicator folder type `setwd('..')`. This is so your computer
is looking for the SDGupdater package (folder) in the right place. Then use `install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)` to install it.
8) There will be a message in the console at the end of the run that should say "No duplicates found, good to go"
9) csv and html (QA) files will be exported to the Output folder. Read through the QA file, and if there are no issues, copy the csv into the csv tab of the In progress/Indicator xlsx file.
10) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('..')` before repeating step 7.
Please check the data source to check for changes in the caveats, see if the best data are being reported, and check whether there are other series we sohould include

### QA PROCESS (SDG Data team):
Read the automatically generated QA report. Pay particular attention to the charts and table as this is where you are likely to spot any unexpected problems with the code. For
emaple if a line or point is missing, or looks strange, this may indicate a change in the formatting of the data. (Note: local authority data for 2018/19 and earlier SHOULD be missing)

The QA report does not negate checking the source data for notes, but if everythig looks fine in the report, numbers should not need to be checked.

### TROUBLESHOOTING:
Some possible errors (may not be an exact match) and solutions:    

```
Error in file(filename, "r", encoding = encoding) : 
  cannot open the connection

Set the working directory to the sdgupdates folder.  
  
```  

```
Error in file(file, ifelse(append, "a", "w")) : 
  cannot open the connection
In addition: Warning message:
In file(file, ifelse(append, "a", "w")) :
  cannot open file 'Output/2023-01-27_update_5-6-1.csv': Permission denied
  
  You probably have one of the files from the Output folder open
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
	These configurations are used by 'update_5-6-1.R'.  
	
compile_tables.R: called by update_indicator_main.R.
	Reads in the data from the input folder, runs the script that puts the data in the csv format (update_5-6-1.R), and the Rmarkdown file that creates the QA html
	which it then saves in the Output folder.  If the Output folder does not already exist, it creates one.  
	
update_5-6-1.R: where the bulk of the work is done.
	Thise script takes the data from the input file, and mungs it into the format we want. In this indicator no calculations are required.
