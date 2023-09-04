Author(s): Emma Wood
## 11-1-1 update  
### Introduction
Create csv data for 11-1-1 (Percentage of dwellings or households failing the decent homes standard) with the following disaggregations:  
#### By dwelling:  
- urban/rural  
- sub-national area (historic data) or region (recent data)  
- index of multiple deprivation    
#### By household:  
- age of oldest and youngest in the household  
- disability status (household)  
- ethnicity (houshold)  
- income  
- household composition  
- poverty status   
- workless or not  
- length of residence  
  
Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs as caveats may change in the future.  
  
### Examples
Example data are given in the Example_input folder. These tables are based on 2019 and 2020 tables but not all levels of each disaggregation are included (reduces filesize).    
Example data can be run by setting `test_run` in update_inidcator_main.R to `TRUE`.    
        
### USER INSTRUCTIONS (SDG Data team):  

1) Download the source data from the [Statistical data set on English Housing Survey data on dwelling condition and safety](https://www.gov.uk/government/statistical-data-sets/dwelling-condition-and-safety).
'DA3202 Decent homes - areas' is for dwellings, and 'DA3203 Decent homes - households is for households'. 
Save household and dwelling spreadsheets as **xlsx** files in Jemalex/code for updates/11-1-1/Input. You may need to create the Input folder if one does not already exist.  
2) Open RStudio.  
3) Go to File > Open Project, and open sdg_data_updates.Rproj.  
4) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.  
5) Change `indicator` to '11-1-1' (Dashes NOT dots).  
6) Set `test_run` to 'FALSE'.  
7) If there is no file called config.R, save the example_config.R file as config.R. Check that all configurations are correct. Ensure `areas_filename` and `households_filename` in config.R match the filenames of your downloads in step 1. `input_folder` must be 'Input', not 'example_input'.    
> The `header_row` settings refer to the row number of the main column names (the row number on which the headings 'non-decent', 'repair' etc are found).
> Ensure that the tabname variable in the configurations is edited to reflect all the tabs on the Input file(s). You will likely have to add the newest year. 
8) Go back to update_indicator_main.R and click the 'source' button (in the top right of the top left window). This will run the code.  
9) csv and html (QA) files will be exported to the output folder in 11-1-1.  
10) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('./..')` before repeating step 7.  
  
Please check the data source to check for caveats (e.g in the notes on each tab), and check whether there are any new disaggregations we should include.
  
### QA PROCESS (SDG Data team):
Read the automatically generated QA report. Pay particular attention to the charts as this is where you are likely to spot any unexpected problems with the code. For
examaple if a line or point is missing, or looks strange, this may indicate a change in the formatting of the data.  
  
The QA report does not negate checking the source data for notes, but if everythig looks fine in the report, the numbers should not need to be checked.  
  
If you get an error on the QA file, run it block by block. Any errors at this stage are usually because there is something unexpected in the data that needs to be addressed.  

### TROUBLESHOOTING:
Some possible errors (may not be an exact match) and solutions:    
  
```diff
- Error: Sheets not found: "2017"  
  
There is a typo in one of the tables in the `config.R` file.
  
```
    
```diff
- Error in setwd(indicator) : cannot change working directory
  
The folder name (`indicator`) in `update_indicator_main.R` is incorrectly typed. OR    
  
The script is looking in the wrong working directory. 
To check which directory it is looking in, type `getwd()` in the console and hit enter.
It should not have the indicator folder at the end of the filepath, but should end with 'sdg_data_updates'. 
If it does not end with 'sdg_data_updates' type `setwd('./..')`, this will make R look in the directory above.

```
