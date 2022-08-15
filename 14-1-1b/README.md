## Create csv and publication data for 14-1-1b plastic beach litter
### Introduction
This code creates both the csv for the SDG data platform, and the publication tables. Tables are published either in the Natural Capital Habitat and Condition
Accounts or (if these accounts are not published before June in the year following the GBBC) as an ad-hoc.  
  
Input data are ingested from the Marine Conservation Society (MCS) through DAO and DAP. See the contacts list, goal updates, and emails folder in Sharepoint for more information.
  
### Data in Example_input folder
The example data are dummy data and are not a true reflection of data obtained from MCS. 
They also do not include all the columns in the real dataset.  
  
The sources.csv sheet gives the suspected source of each plastic related litter item. This was created by MCS.
  
### User instructions (SDG Data team): 

1) Save the data as a csv. Ensure that all number columns are formatted as numeric *without* the thousands separator before saving.
2) If it has not already been done, save the cover_sheet.xlsx file and the 'sources.csv' file in the Example_input folder into a folder called 'Input'. 
Check with MCS that we have the most recent sources sheet.
3) Open RStudio.
4) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
5) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
6) Change the indicator number to '14-1-1b' (Dashes NOT dots).
7) Open the example_config file in the 14-1-1b folder. Save it (in the same place) as config.R, and edit as required. Unlike in many updates, the full filepath of the main data is required. No other configs are likely to need editing.
8) Go back to update_indicator_main.R. Click the 'source' button (in the top right of the top left window). This will run the code. 
You may need to install some packages if they are not already installed. Use `install.packages('name_of_package', dependencies = TRUE, type = 'win.binary')` to install packages, 
then try running the code (using the source button) again. If you need to install SDGupdater, the code is slightly different: 
First type `getwd()` in the console to check that it points at the sdg_data_updates folder. If it points at an indicator folder type `setwd('..')`. This is so your computer
is looking for the SDGupdater package (folder) in the right place. Then use `install.packages("SDGupdater", repos = NULL, type="source", force = TRUE)` to install it.
9) csv, publication, and html (QA) files will be exported to the Output folder. Read through the QA file, and if there are no issues, copy the csv into the csv tab of the In progress/Indicator xlsx file.
10) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('..')` before repeating step 7.
11) Before publication, email MCS (see contacts list in Sharepoint).

### QA process (SDG Data team):
Read the automatically generated QA report. Pay particular attention to the charts as this is where you are likely to spot any unexpected problems with the code. For
emaple if a line or point is missing, or looks strange, this may indicate a change in the formatting of the data.

If everythig looks fine in the report, numbers should not need to be checked.

### Troubleshooting
An error similar to "Problem while computing `total_volunteer_hours = as.numeric(total_volunteer_hours)` NAs introduced by coercion" will occur if the thousands separator has
not been removed from the source data.

