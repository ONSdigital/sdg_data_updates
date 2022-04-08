Author: Atanaska Nikolova (October 2021)

Code to get csv output for **part a)** for indicator 15.a.1 and duplicate 15.b.1
Part a) is Official development assistance on conservation and sustainable use of biodiversity. Part b of this indicator is currently done manually, so it will have to be appended to the output csv.

### Input files

Input data are two .ods spreadsheets from Source 1 of the indicator, which should be saved as two .csv files in an input sub-folder in the 15-a-1_and_15-b-1a folder. These two spreadsheets cover all available years (2009 to 2020 at present). They are the "Data underlying SID.ods" files from the source. The latest one should be in the primary source link, and the second one (2009-2016) should be linked in the "Other information" section of the Source tab.

After you first open the two .ods spreadsheets, make sure the third from last column (the gross ODA, called "AmountExtended") is formatted as numbers and extended to at least 4 decimal places. Then you can save as .csv and place in the Input folder. 

### Running the code

For the code to run, you will need to edit the example_config.R so the filename_1 and filename_2 match the names of the two .csv spreadsheets (the order is not important) in your Input folder. You will also need to create that Input folder in the 15-a-1_and_15-b-1a folder folder, and make sure its name is reflected in the input_folder variable in the config.R file. Then save the example_config.R script as config.R (otherwise the script won't work)

You can then run the automation script from update_indicator_main.R (make sure you open it via sdg_data_updates.RProject) and the results should be saved in an sub-folder called Output in the 15-a-1_and_15-b-1a folder.


### Possible future improvements:

- Currently the code is using base R, but perhaps it can be made clearer with tidyverse packages
- Possibly integrate an automated QA
- Include checks for the data that raise errors
- Automate the whole indicator (including part b)
