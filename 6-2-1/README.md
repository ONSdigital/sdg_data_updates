Authors(s): Michael Nairn and Tom McNulty
Date: 04/07/2023

### 6-2-1 automation

Creates csv data for 6-2-1 (Proportion of population using (a) safely managed sanitation services and (b) a hand-washing facility with soap and water).

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 


### 6-2-1 sourcing data instructions

You will need to download three similar csv files. These analyse the sanitation
data by service level, facility type, and safely managed criteria.
1) To download the latest wash data School workforce in England data go to https://washdata.org/data/household#!/gbr .
2) Click "View data table"
3) Under measure, select "Sanitation".
4) Under Inequality select "Total", "Rural", and "Urban".
5) Under Time period select the full range. Currently this is 2000 to 2022. 
6) Under Ladder type select "Analyse by service level".
7) Download as csv.
8) Go to your downloads folder and copy the csv file into the Input folder within 
6-2-1. Rename it as "washdash_service_level.csv". 
9) Under Ladder type select "Analyse by facility type".
10) Download as csv.
11) Go to your downloads folder and copy the csv file into the Input folder within 
6-2-1. Rename it as "washdash_facility_type.csv". 
12) Under Ladder type select "Analyse by safely managed criteria".
13) Download as csv.
14) Go to your downloads folder and copy the csv file into the Input folder within 
6-2-1. Rename it as "washdash_criteria.csv".

15) you should have three files in the 6-2-1/Input folder. "washdash_facility_type.csv",
"washdash_criteria.csv", and "washdash_service_level.csv". 




### 6-2-1 update instructions

1) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
2) If it exists, open the `config.R` file in 6-2-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 6-2-1.
3) Check the configurations (e.g. filename) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file names are correct. 
4) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 6-2-1. Make sure test_run is set to FALSE (so that it sources the correct config file). 
5) Click 'Source' button to run the script (top right corner of the script panel).  
6) Outputs will be saved in the Output folder in 6-2-1 (which the script will create if it doesn't already exist).  
7) An html file will also be created in the Outputs folder. This contains some basic checks and relevant information for the person who will be QAing the update. **Please check this file before copying to the csv.** 



### 6-2-1 Troubleshooting



