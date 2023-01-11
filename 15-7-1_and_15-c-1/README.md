Authors(s): Katie Uzzell
Date: 22/12/2022

### 15-7-1_and_15-c-1 automation

Creates csv data for 15-7-1_and_15-c-1 (Number of endangered species seizures), disaggregated by import type.

Fairly simple automation that is mostly cleaning and formatting the data. However, data is published for each quarter so these figures need aggregating to give a total for the year (which is how we publish it on the platform).

Runtime is less than 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 

### 15.7.1 and 15.c.1 update instructions

1) Download the latest data from: https://www.gov.uk/search/all?keywords=border+force+transparency+data&order=relevance. This should be Q4 for the year, so that it covers the entire year. If only Q1, Q2, or Q3 is available, wait to do update until Q4 figures are published.
2) Save the  tables as an xlsx file in the 'Input' folder in 15-7-1_and_15-c-1 (if this doesn't exist, make it inside the 15-7-1_and_15-c-1 folder).  
3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
4) If it exists, open the `config.R` file in 15-7-1_and_15-c-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 15-7-1_and_15-c-1.
5) Check the configurations (e.g. filename and tab names) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct.    
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 15-7-1_and_15-c-1. Make sure test_run is set to FALSE (so that it sources the correct config file). Click 'Source' button to run the script (top right corner of the script panel).  
8) Outputs will be saved in the Outputs folder in 15-7-1_and_15-c-1 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some basic checks and also shows all plots, which should show up any major issues. **Please check this file before copying to the csv.**