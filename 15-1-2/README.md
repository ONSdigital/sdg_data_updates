## 15-1-2 update and data checks

### Background and QA information
The geospatial team (Rob Shava) provide us with data for this indicator, and we publish the ad-hoc they produce as well as updating the indicator. Environmental Accounts, Natural Capital and Forest Research should be informed of this update. Some of the data for this indicator also fill the 15.2.1 series 'Percentage of woodland within protected areas'.  
    
The data do not come with quite the right layout, so this script aggregates some of the data and adds the required columns for the csv.  
  
The script also creates a pdf of plots, which should be checked after any run for any odd looking lines. If something has gone wrong it will likely be apparent in the plots. However, a sense check can also be performed by comparing the numbers with those published on [IBAT](). You will need to log on, but doing so is free. Go to Country Profiles > UK > Key Biodiversity Areas.
  
Our numbers differ slightly with theirs because in our data Key Biodiversity Areas (KBAs) include by both Important Bird and Biodiversity Areas (IBAs) and Important Plant Areas (IPAs) combined. IBAT only include IBAs. The UK is one of the few countries with IPA geographic data.
  
### Instructions for updating
1) Save the all_data table from geospatial as a csv file in the 'Input' folder in 15-1-2. Make sure the numbers are formatted as numbers (use a large number of decimal places) and ensure the **thousands separator is NOT used**. Also check that there are no
2) Open the `sdg_data_updates.Rproj` from inside RStudio (in Jemalex > sdg_data_updates).  
3) Open the `config.R` file in 15-1-2 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). 
4) Check the configurations are correct, and if not correct them and save.  
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and click 'Source' button to run the script (top right corner of the script panel).  
7) Outputs will be saved in the Outputs folder in 15-1-2 (which the script will create if it doesn't already exist).  
8) A pdf file will also be created in the Outputs folder. This contains all plots, which should show up any major issues. **Please check this file before copying to the csv**
9) If you have any concerns about the data contact geospatial.
10) Create a feature branch and get it signed off by geospatial. Also run it past NatCap, Environmental Accounts, and Forest Research (see step 11).
11) Add the woodland data to 15.2.1 Percentage of woodland within protected areas series and get it signed off by Forest Research
12) Check the ad-hoc tables comply with ONS requirements.
13) Publish the ad-hoc. Instructions for this can be found in Sharepoint in the data_team guidance folder.
14) Push 15.1.2 and 15.2.1 to live.
