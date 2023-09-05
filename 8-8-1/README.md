Authors(s): Katie Uzzell
Date: 05/09/2023

### 8-8-1 automation

Creates csv data for 8-8-1 (Rates of fatal and non-fatal occupational injuries (excluding injuries arising from road traffic accidents)).

Automation involves formatting and joining the data from 8 tables into csv format ready for the platform (no calculations). 

Runtime is less than 60 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are provisional) or caveats that need to be included in the metadata. 

### 8-8-1 update instructions

1) Download the fatal injuries data files from https://www.hse.gov.uk/statistics/tables/index.htm#riddor. The files used for this indicator are:

- RIDHIST (Table 1)
- RIDREG - RIDDOR (Table 1)
- RIDAGEGEN - RIDDOR (Table 1) 

Save each file as an xlsx file in the 'Input' folder in 8-8-1 (if the input folder doesn't exist, make it inside the 8-8-1 folder).  

2) Download the non-fatal injuries data files from http://www.hse.gov.uk/statistics/lfs/index.htm. The files used for this indicator are:

- LFSINJSUM (Table 1)
- LFSINJREG (Table 1)
- LFSINJAGE (Table 1)
- LFSINJIND(Table 1)
- LFSINJOCC (Table 1) 

Note that LFSINJOCC covers different three year periods and data is only available to the period 2017/18 - 2019/20. 

Save each file as am xlsx file in the 'Input' folder in 8-8-1.

3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj from Jemalex (not local drive). It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 

4) If it exists, open the `config.R` file in 8-8-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 8-8-1.

5) Check the configurations (e.g. file names and tab names) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct. 

6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 8-8-1. Make sure test_run is set to FALSE (so that it sources the correct config file). 

7) Click 'Source' button to run the script (top right corner of the script panel).  

8) Outputs will be saved in the Output folder in 8-8-1 (which the script will create if it doesn't already exist). 

9) An html file will also be created in the Outputs folder. This contains some basic checks and also shows new data plotted over old data (i.e., what is on the live site), which should show up any major issues. **Please check this file before copying to the csv.**
