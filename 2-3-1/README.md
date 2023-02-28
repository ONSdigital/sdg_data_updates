### 2-3-1 automation

Creates csv data  SDG indicator 2-3-1 (Total factor and labour productivity of the United Kingdom agriculture industry).

Simple automation that uses one excel table from one source, and only involves formatting the data (no calculations). 

Runtime is less than 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 

### 2-3-1 update instructions

1) Download the latest data from: https://www.gov.uk/government/statistics/total-factor-productivity-of-the-agricultural-industry.
2) Save the file as an xlsx file in the 'Input' folder in 2-3-1 (if this folder doesn't exist, make it inside the 2-3-1 folder).
3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it.
4) If it exists, open the config.R file in 2-3-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as config.R in 2-3-1.
5) Check the configurations (e.g. filename and tab names) are correct, and if not, correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct.
6) Open update_indicator_main.R (from sdg_data_updates.Rproj) and set indicator as 2-3-1. When running a real update, make sure test_run is set to FALSE (so that it sources the correct config file).
7) Click 'Source' button to run the script (top right corner of the script panel). This automated update generates a csv file for each of the dissagregation types (productivity, outputs and inputs). These csv files are saved in the “CSVs” folder within the “2-3-1” folder. The “update-2-3-1” script then combines these into one output.
8) The combined csv output (to be copied into the indicator file) will be saved in the Output (or Example_output) folder in 2-3-1 (which the script will create if it doesn't already exist).
9) An html file will also be created in the Outputs folder. This contains some basic checks to identify any discrepancies between the old data (currently live on the platform) and new data (produced by the automation code), which should show up any major issues. **Please check this file before copying to the csv.**