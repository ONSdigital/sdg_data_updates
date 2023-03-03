### 8-6-1 automation

Creates csv data for 8-6-1 (Percentage of youth (aged 16-24 years) not in education, employment or training).

Very simple automation that is only involves formatting the data. 

Runtime is less than 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 

### 8-6-1 update instructions

1) Download the latest data from: [https://www.ons.gov.uk/employmentandlabourmarket/peoplenotinwork/unemployment/datasets/youngpeoplenotineducationemploymentortrainingneettable1], This can be found under dropdown for **Current edition of this dataset** of the webpage.
2) Open downloaded file and copy the updated data from 6 different sheets which are (People-SA, Men-SA, Women-SA, People-NSA, Men-NSA, Women-NSA). And Paste the respected sheet data to the tables present in the **"Source 1"** sheet of file 8.6.1.xls, this file is present in the Example_Input folder. ***(Warning! make sure while pasting the table values that it doesn't overwrite the next table in the following rows below )***
3) Once updated all the tables data, **Save** this file as an xlsx file in the 'Input' folder in 8-6-1 (if this doesn't exist, make it inside the 8-6-1 folder).  
4) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
5) If it exists, open the `config.R` file in 8-6-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 8-6-1.
6) Check the configurations (e.g. filename, tab names and tables (start & end row number)) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct.

7) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 8-6-1. Make sure test_run is set to FALSE (so that it sources the correct config file). Click 'Source' button to run the script (top right corner of the script panel).  
8) Outputs will be saved in the Output folder in 8-6-1 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some basic checks and also shows all plots, which should show up any major issues. **Please check this file before copying to the csv.**
