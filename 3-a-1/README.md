Authors(s): Katie Uzzell
Date: 23/02/2023

### 3-a-1 automation

The 3-a-1 automation uses data published by ONS on adult Smoking Habits in the 
United Kingdom. The code pulls data from multiple tabs of one excel spreadsheet 
and formats it to create a csv file for SDG indicator 3-a-1 (Percentage of people 
who are current cigarette smokers aged 18 years and older, disaggregated by sex, 
age, country, England region, country of birth, socio-economic classification, and ethnicity).

Runtime is approx 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still 
look at the source data and check footnotes and information tabs for anything 
that needs to be manually changed in the csv output (e.g., if any figures are 
estimated) or caveats that need to be included in the metadata.

### 3-a-1 update instructions

1) Download the latest data from: https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/healthandlifeexpectancies/datasets/smokinghabitsintheukanditsconstituentcountries.
2) Save the file as an xlsx file in the 'Input' folder in 3-a-1 (if this folder
doesn't exist, make it inside the 3-a-1 folder).  
3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may 
take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
4) If it exists, open the `config.R` file in 3-a-1 (you can do this in the 'Files'
panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 3-a-1.
5) Check the configurations (e.g. filename and tab names) are correct, and if not,
correct them and save. For example, if you have had to save example_config.R as 
config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' 
and 'Output' and the file name is correct.    
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 3-a-1. When running a real update, make sure test_run is set to FALSE (so that it sources the correct config file). 
7) Click 'Source' button to run the script (top right corner of the script panel). This automated update generates a csv file for each of the tables in the source that are used to update this indicator. These are saved in the “CSVs” folder within the “3-a-1” folder. The “update-3-a-1” script then combines these into one output.   
8) The combined csv output (to be copied into the indicator file) will be saved in the Output (or Example_output) folder in 3-a-1 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some 
basic checks to identify any discrepancies between the old data (currently live 
on the platform) and new data (produced by the automation code), which should show up any major issues. **Please check this file before copying to the csv.**

