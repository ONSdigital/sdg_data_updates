Authors(s): Katie Gummer
Date: 15/08/2023

### 9-c-1 automation

Creates csv data for 9-c-1 (Proportion of population covered by a mobile network, by technology).

Very simple automation that only involves formatting the data. 

Runtime is less than 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 

### 9-c-1 update instructions

1) Download the latest data from: https://unstats.un.org/sdgs/dataportal/database. Select Data Series = 9.c.1, Geographic Areas = Countries - United Kingdom of Great Britain and Northern Ireland, Period = Years (all years). Click download, the dark cloud button. 
2) Save the file as 9-c-1_data_from_SDG_database.xlsx in the 'Input' folder in 9-c-1 (if this doesn't exist, make it inside the 9-c-1 folder).  
3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
4) If it exists, open the `config.R` file in 9-c-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 9-c-1.
5) Check the configurations (e.g. filename and tab names) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct.    
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 9-c-1. Make sure test_run is set to FALSE (so that it sources the correct config file). 
7) Click 'Source' button to run the script (top right corner of the script panel).  
8) Outputs will be saved in the Output folder in 9-c-1 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some basic checks and also shows all plots, which should show up any major issues. Please note – this automation inputs “Normal value” for all rows in observation status, so you will need to check if this is correct and manually amend csv output where necessary (e.g., if value is estimated). **Please check this file before copying to the csv.**