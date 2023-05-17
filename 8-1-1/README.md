Authors(s): Katie Uzzell
Date: 03/05/2023

### 8-1-1 automation

Creates csv data for 8-1-1 (Annual growth rate of real GDP per capita).

Very simple automation that only involves formatting the data. 

Runtime is less than 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 

### 8-1-1 update instructions

1) Download the latest data from: https://www.ons.gov.uk/economy/grossdomesticproductgdp/datasets/unitedkingdomeconomicaccounts.
2) Save the file as an xlsx file in the 'Input' folder in 8-1-1 (if this doesn't exist, make it inside the 8-1-1 folder).  
3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
4) If it exists, open the `config.R` file in 8-1-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 8-1-1.
5) Check the configurations (e.g. filename and tab names) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct. **Make sure the selected years and latest year configs are correct - if you are updating this indicator, it is likely you will have to add the latest year(s) to the list**  
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 8-1-1. Make sure test_run is set to FALSE (so that it sources the correct config file). 
7) Click 'Source' button to run the script (top right corner of the script panel).  
8) Outputs will be saved in the Output folder in 8-1-1 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some basic checks and also shows new data plotted over old data (i.e., what is on the live site), which should show up any major issues. **Please check this file before copying to the csv.**

### Troubleshooting

Sometimes you might get the following error: 

Error: Can't subset columns that don't exist.
x Column `CDID` doesn't exist.

This is due to an issue with the way the data is read in when test_run is set to FALSE in the config file, but it only occurs with certain versions of RStudio. If you get this error, then check if your RStudio needs updating. If no update is available, try running it on an older version (you can change the version in using the settings option in the pop-up that appears when you first open Rstudio).

For information, this automation was written in May 2023, using RStudio version 4.1.3.