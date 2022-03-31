Author: Atanaska Nikolova, March 2022

Creating csv data for 9-a-1 (Net Official Development Assistance (ODA) to infrastructure) with disaggregation of country income group. 

### Input files

Input data are two .ods spreadsheets from Source 1 of the indicator, which should be saved as two .csv files in a sub-folder named "Input" in the 9-a-1 folder. These two spreadsheets cover all available years (2009 to 2020 at present). They are the "Data underlying SID.ods" files from the source. The latest one should be in the primary source link, and the second one (2009-2016) should be linked in the "Other information" section of the Source tab.

After you first open the two .ods spreadsheets, make sure the last column (the net ODA) is formatted as numbers and extended to at least 4 decimal places. Then you can save as .csv and place in the Input folder. 

### Running the code

For the code to run, you will need to edit the example_config.R so the filename_1 and filename_2 match the names of the two .csv spreadsheets (the order is not important) in the Input folder. You will also need to create that Input folder in the 9-a-1 folder. Then save the example_config.R script as config.R (otherwise the script work work)

You can then run the automation script from update_indicator_main.R (make sure you open it via sdg_data_updates.RProject) and the results should be saved in an sub-folder called Output in the 9-a-1 folder.


### Possible future improvements:

- Currently the code is using base R, but perhaps it can be made clearer with tidyverse packages
- Possibly integrate an automated QA
- Include checks for the data that raise errors