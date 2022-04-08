Author: Atanaska Nikolova, March 2022

Creating csv data for 9-a-1 (Net Official Development Assistance (ODA) to infrastructure) with disaggregation of country income group. 

### Instructions for running

#### Prepare input files

- Create a folder in 9-a-1 called "Input" where you will save the input files.
- Input data are two .ods spreadsheets from Source 1 of the indicator, which should be saved as two .csv files in the "Input" folder. These two spreadsheets cover all available years (2009 to 2020 at present). They are the "Data underlying SID.ods" files from the source link. The latest one should be in the primary source link, and the second one (2009-2016) should be linked in the "Other information" section of the Source tab of the indicator.
After you first open the two .ods spreadsheets, make sure the last column (the net ODA) is formatted as numbers and extended to at least 4 decimal places. Then you can save as .csv and place in the Input folder in 9-a-1.

#### Running the code

- Edit the example_config.R so the `filename_1` and `filename_2` variables match the names of the two .csv spreadsheets (the order is not important) in the Input folder. R scripts can be edited throug RStudio or they can be opened with Notepad or Notepad++
- Save the edited example_config.R script as config.R
- Open RStudio (if you haven't already), navigate to File -> Open Project... and open the sdg_data_updates.Rproj located in the sdg_data_updates folder
- From the files box (bottom right panel) open the update_indicator_main.R script
- Make sure `indicator <- "9-a-1"`
- Run the automation by clicking the Source button towards the top right of the script window 
- The results should be saved in an sub-folder called Output in the 9-a-1 folder, and there should be a message confirming the name and location of the output csv. You may get some warning messages about packages, but as longas tyou get the message that the csv has been saved in the Output folder, it should be fine.


### Possible future improvements:

- Currently the code is using base R, but perhaps it can be made clearer with tidyverse packages
- Possibly integrate an automated QA
- Include checks for the data that raise errors
- Externalise the code from the big ODA_9.a.1 function in update_9-a-1.R. The function works, but is not useful.
