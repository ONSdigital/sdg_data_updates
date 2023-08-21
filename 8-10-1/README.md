Authors(s): Katie Uzzell
Date: 26/07/2023

### 8-10-1 automation

Creates csv data for 8-10-1 (Part (a) only - Number of commercial bank branches per 100,000 adults).

Automation involves formatting the data and calculating the number of banks and building societies per 100,000 people, disaggregated by country, region, and local authority and formatting the data into csv format ready for the platform. 

Runtime is less than 60 seconds.

Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 

### 8-10-1 update instructions

1) Download the latest data from NOMIS and save the 9 files as xlsx files in the 'Input' folder in 8-10-1 (if this doesn't exist, make it inside the 8-10-1 folder).  

## Instructions for downloading the 9 datasets

**Banks by country** 
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=141 
- Geography = Countries > tick all and deselect 'Great Britain' and 'England and Wales'
- Date = All years
- Employment Size Band = Total
- Industry = 64191 : Banks
- Legal Status = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as banks_by_country.xlsx

**Banks by region**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=141 
- Geography = Regions > tick all and deselect 'Northern Ireland', 'Scotland' and ' Wales'
- Date = All years
- Employment Size Band = Total
- Industry = 64191 : Banks
- Legal Status = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as banks_by_region.xlsx

**Banks by local authority**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=141 
- Geography = local authority: district / unitary (as of April 2021) > tick all
- Date = All years
- Employment Size Band = Total
- Industry = 64191 : Banks
- Legal Status = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as banks_by_LA.xlsx

**Building societies by country**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=141 
- Geography = Countries > tick all and deselect 'Great Britain' and 'England and Wales'
- Date = All years
- Employment Size Band = Total
- Industry = 64192 : Building societies
- Legal Status = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as bs_by_country.xlsx

**Building societies by region**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=141 
- Geography = Regions > tick all and deselect 'Northern Ireland', 'Scotland' and ' Wales'
- Date = All years
- Employment Size Band = Total
- Industry = 64192 : Building societies
- Legal Status = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as bs_by_region.xlsx

**Building societies by local authority**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=141 
- Geography = local authority: district / unitary (as of April 2021) > tick all
- Date = All years
- Employment Size Band = Total
- Industry = 64192 : Building societies
- Legal Status = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as bs_by_LA.xlsx 

**Population estimates by country**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=2002
- Geography = Countries > tick all and deselect 'Great Britain' and 'England and Wales'
- Date = select all years from 2010 to latest year
- Age = Aged 16+
- Sex = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as pop_ests_country.xlsx 

**Population estimates by region**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=2002
- Geography = Regions > tick all and deselect 'Northern Ireland', 'Scotland' and ' Wales'
- Date = select all years from 2010 to latest year
- Age = Aged 16+
- Sex = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as pop_ests_region.xlsx 

**Population estimates by local authority**
- Go to https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=2002
- Geography = local authority: district / unitary (as of April 2021) > tick all
- Date = select all years from 2010 to latest year
- Age = Aged 16+
- Sex = Total
- Download Data > Download data for Excel 2007 (.xlsx) 
- Save in Input folder as pop_ests_LA.xlsx 

2) Download the region to LAs lookup file and save as a csv file in the 'Input' folder in 8-10-1.

## Instructions for downloading the region to LAs lookup file

- Go to https://geoportal.statistics.gov.uk/datasets/ons::local-authority-district-to-region-december-2022-lookup-in-england/explore
- Download as csv file and save in 'Input' folder in 8-10-1.

3) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj from Jemalex (not local drive). It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 

4) If it exists, open the `config.R` file in 8-10-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 8-10-1.

5) Check the configurations (e.g. filename and tab names) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file name is correct. **Make sure the latest year config is correct - if you are updating this indicator, it is likely you will have to edit this**  

6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 8-10-1. Make sure test_run is set to FALSE (so that it sources the correct config file). 

7) Click 'Source' button to run the script (top right corner of the script panel).  

8) Outputs will be saved in the Output folder in 8-10-1 (which the script will create if it doesn't already exist). 

9) An html file will also be created in the Outputs folder. This contains some basic checks and also shows new data plotted over old data (i.e., what is on the live site), which should show up any major issues. **Please check this file before copying to the csv.**
