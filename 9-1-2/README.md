Authors(s): Katie Uzzell
Date: 02/03/2023

### 9-1-2 automation

Creates csv data and QA checks file for 9-1-2 (Air passenger and air freight volumes).

Very simple automation that only involves formatting the data. 

Runtime is less than 30 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 

### 9-1-2 update instructions

1) Download the AVI0102 data series from: https://www.gov.uk/government/statistical-data-sets/aviation-statistics-data-tables-avi.
2) Save the file as an xlsx file in the 'Input' folder in 9-1-2 (if this doesn't exist, make it inside the 9-1-2 folder).  
3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
4) If it exists, open the `config.R` file in 9-1-2 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 9-1-2.
5) Check the configurations (e.g. filename and tab names) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct. NOTE: The tabnames tend to change year on year, so make sure you are using the tabs that include data tables named "Terminal passengers at reporting airports by service type" (for passenger_tabname) and "Freight handled by at reporting airports by service type" (for freight_tabname).     
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 9-1-2. Make sure test_run is set to FALSE (so that it sources the correct config file). 
7) Make sure your working directory is set to sdg_data_updates (At top of R, click: Session > Set working directory > To project directory). Click 'Source' button to run the script (top right corner of the script panel).  
8) Outputs will be saved in the Output folder in 9-1-2 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some basic checks and also shows all plots, which should show up any major issues. **Please check this file before copying to the csv.**

### TROUBLESHOOTING:

Some possible errors (may not be an exact match) and solutions:

```
Error in setwd(indicator) : cannot change working directory

Set the working directory to the sdg_data_updates folder.
```

```
Error in getChildlessNode(xml = workbookRelsXML, tag = "Relationship") : function 'Rcpp_precious_remove' not provided by package 'Rcpp'

This is caused by an issue in SDGupdater that occurs when the automation is being run on an older version of RStudio. To fix this, you need to update RStudio to version 4.1.3. To do this, close RStudio and re-open, then on the pop-up (before clicking Run RStudio), click on settings and change the 'Select' drop down to R-4.1.3 (if this version isn't there, you may need to update RStudio in the software centre). Save settings and then Run RStudio.
```