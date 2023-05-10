### 3-8-2 automation

Creates csv data for 3-8-2 (Proportion of population with large household expenditures on health as a share of total household expenditure or income). PLEASE NOTE - this automation only produces the data for the most **recent year** (not the back series). This means QAing the output is slightly different to usual, please see the QA html output for details.

It is a fairly simple automation that only involves formatting the data (no calculations).

Runtime is less than 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata.

### 3-8-2 update instructions

1) Download the latest data from: [https://www.ons.gov.uk/peoplepopulationandcommunity/personalandhouseholdfinances/expenditure/bulletins/familyspendingintheuk/april2019tomarch2020/relateddata], This automation require three workbooks (Family spending workbook 1: detailed expenditure and trends, Family spending workbook 2: expenditure by income,  Family spending workbook 4: expenditure by household characteristic), download the respective workbooks, which can be found on the page [link]("https://www.ons.gov.uk/peoplepopulationandcommunity/personalandhouseholdfinances/expenditure/bulletins/familyspendingintheuk/april2019tomarch2020/relateddata") (This is same link as above). Make sure to download the latest workbooks with all the workbook from same year (latest year).
2) Save the files as an xlsx file in the 'Input' folder in 3-8-2 (if this doesn't exist, make Input folder inside the 3-8-2 folder). 
3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
4) If it exists, open the `config.R` file in 3-8-2 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 3-8-2.
5) Check the configurations (e.g. filename, tabname) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct.

6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 3-8-2. Make sure test_run is set to FALSE (so that it sources the correct config file). In addition to this, ensure the working directory is set to sdg_data_updates before running update_indicator_main.R. Click 'Source' button to run the script (top right corner of the script panel).  
7) Outputs will be saved in the Output folder in 3-8-2 (which the script will create if it doesn't already exist).  
8) An html file will also be created in the Outputs folder. This contains some basic checks and relevant information for the person who will be QAing the update. **Please check this file before copying to the csv. IMPORTANT - The output csv only contains the most recent year of data, that needs to be copied and pasted to the bottom of the existing csv in the indicator file (rather than overwrite the existing data)**
