Authors(s): Michael Nairn
Date: 29/06/2023

### 4-c-1 automation

Creates csv data for 4-c-1 (Proportion of teachers with the minimum required qualifications, by education level).

PLEASE NOTE - this automation produces 
It is a fairly simple automation that only involves formatting the data (no calculations). However, there are a lot of disaggregations and data points (nearly 100,000 by 2021 to 2022).


Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 


### 4-c-1 sourcing data instructions

1) To download the latest School workforce in England data go to https://explore-education-statistics.service.gov.uk/data-tables/school-workforce-in-england .
2) Under Step 2 select the "Teacher characteristics" dataset. 
3) Under "What would you like to do?" click "Download full data set (ZIP)"
4) In your downloads folder, open the zip folder. It will be named something like "school-workforce-in-england_2022.zip".
5) In the data subfolder copy the csv file into the Input folder within 4-c-1. It will be called something like "workforce_teacher_characteristics_2010_2022_nat_reg_la.csv" . 




### 4-c-1 update instructions

1) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
4) If it exists, open the `config.R` file in 4-c-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 4-c-1.
5) Check the configurations (e.g. filename) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file names are correct. 
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 4-c-1. Make sure test_run is set to FALSE (so that it sources the correct config file). 
7) Click 'Source' button to run the script (top right corner of the script panel).  
8) Outputs will be saved in the Output folder in 4-c-1 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some basic checks and relevant information for the person who will be QAing the update. **Please check this file before copying to the csv.** 




### 4-c-1 Troubleshooting




