### ODA indicator updates

## Introduction
There are multiple ODA indicators that use the same source table. It therefore makes sense to run all these automations at the same time. It is possible to run only a subset of these indicators by removing the indicators you do not wish to run from the indicator list in the config file.  
The full list of indicators, and whether they are based on net ODA or amounts extended is:
#### Net ODA  
-  1-a-1
-  2-a-2  
-  3-b-2  
-  7-a-1  
-  9-a-1  
-  17-9-1  
-  17-19-1  
#### Gross ODA (Amounts extended)
-  4-b-1  
-  6-a-1  
-  8-a-1  
-  15-a-1  
  
Additional source data used for these automations are:  
- exchange rate and deflator data for converting GBP to constant USD (used in several indicators)  
- GNI data from OECD for calculating ODP as a % of GNI (used for 1-a-1)   
- Biodiversity taxes data from OECD for 15-a-1b (duplicate of 15-b-1b)  
  
The following ODA indicators are not included in this automation as they use a different source: 10-b-1, 17-2-1, 17-3-1.  
  
## Instructions  
For the UK data team, all files and folders mentioned below are in Jemalex > sdg_data_updates 
  
**IF YOU ARE RUNNING 1-a-1, OR 15-a-1b/15-b-1b USE A NON-ONS INTERNET NETWORK** as the OECD APIs won't work on the ONS network.  
1. Download and save the ODA, Deflators, and Exchange rates data in 'Input' in the ODA folder (if the Input folder doesn't exist, make it). See [Data sources](#data-sources) for more information.  
2. Open the `sdg_data_updates.Rproj` from inside RStudio. 
3. If it exists, open the `config.R` file in ODA (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). 
If not, save `example_config.R` as `config.R` in ODA.  
4. Check that test_run in update_indicator_main is FALSE.
5. Check the configurations are correct for the files you have saved, and if not correct them and save `config.R`.  
     1. `filename_newdat` is the name of file (including the .csv extension) containing ODA data that you have saved in the Input file.  
     2. `filename_2017` is the name of file (including the .csv extension) containing archived data. This file should already be in the Input folder so there is no need to download it again or edit it in the config file. 
     3. `deflators_filename` is the name of the most recent deflators data, including the .xls extension
     4. `exchange_filename` is the name of the most recent exchange rates data, including the .xls extension
6. Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and click 'Source' button to run the script (top right corner of the script panel).  
7. Outputs will be saved in the Outputs folder in ODA (which the script will create if it doesn't already exist).  
8. An html file will also be created in the Outputs folder. This contains some basic checks and also shows all plots, which should show up any major issues. **Please check this file before copying to the csv tabs in the Indicator files**  
9. IMPORTANT: the code does not run any checks on the footnotes - please check the footnotes in the source files for information that may need to be added to the metadata.  
  
**See [troubleshooting](#troubleshooting) for common errors and how to fix them**
  
## Data sources
Data are imported into R in a variety of ways:  
- the ODA dataset is manually downloaded and saved as a csv. It is then imported into R from the Input folder
- the deflator and exchange rate data are manually downloaded and saved as xlsx files
- GNI data are imported using the OECD API. 
  
#### ODA data
The main data required for all the indicators in the ODA folder are the same table 'Statistics on International Development: final UK aid spend'. This can be found on the [Overseas Aid Effectiveness page](https://www.gov.uk/international/overseas-aid-effectiveness) under 'Research and Statistics'.  
  
Download the most recent 'final' table and save it in ODA > Input as a **csv**    
  
The most recent data file probably only goes back to 2017. Pre 2017 data are in data-underlying-sid-2017_110322.csv, which should already be in the Inputfolder. If not, the 'Data underlying the SID publication' should be downloaded from [Statistics on International Development 2017](https://www.gov.uk/government/statistics/statistics-on-international-development-2017) and saved as a csv.  
  
#### Deflators and exchange rates
Deflators and exchange rates are taken from the [OECD Development finance data page](https://www.oecd.org/dac/financing-sustainable-development/development-finance-data/). The required tables are in the data tables section e.g.:  
-  Deflators for Resource Flows from DAC Countries (2019=100).xls
-  Annual Exchange Rates for DAC Donor Countries from 1960 to 2020.xls
  
Download both tables and save them in ODA > Input as **xlsx** files (NOT xls)
  
#### GNI (Gross National Income) data  
The API link for GNI data should not need to be generated again. 
However, for information only, it was generated by going to [OECD.Stat](https://stats.oecd.org/Index.aspx?ThemeTreeId=3#), searching for DAC1 in 'Find in Themes', opening 'Total flows by donor', selecting 'GNI' in Aid type, and 'United Kingdom' in DAC countries. The sdmx data url was accessed by going to Export > SDMX.

## Troubleshooting
Some possible errors (may not be an exact match) and solutions:    
    

```diff
- Error in setwd(indicator) : cannot change working directory  

The folder name you have given for `indicator` in update_indicator_main.R may be incorrectly typed. Check you are using 'ODA'.  
OR     
The script is looking in the wrong working directory. 
To check which directory it is looking in, type `getwd()` in the console and hit enter.
It should not have the indicator folder at the end of the filepath, but should end with 'sdg_data_updates'. 
If it does not end with 'sdg_data_updates' type `setwd('./..')`, this will make R look in the directory above.

```
```diff
- Error in curl::curl_fetch_memory(url, handle = handle) : schannel: failed to receive handshake, SSL/TLS connection failed  
  
This will result in indicator 1-a-1 not being updated. It occurs when internet speed is very low, so ask someone
with a faster connection to try, or try later. It may also be caused in future by issues with Firewalls. This is
not currently an issue. If it becomes an issue with ONS, this part of the code may need to be rewritten to use a
manual download
```

```diff
- Error in curl::curl_fetch_memory(url, handle = handle) : Timeout was reached: [stats.oecd.org] Send failure: Connection was reset. 
- Error in as.data.frame(gni_sdmx) : object 'gni_sdmx' not found

The API connection to OECD is not working. In tests it did not work on the ONS internet network so try using your home network.  
If necessary this *could* be changed to a manual download (see the instructions for downloading the data in cource 2 of 15-a-1),
and the data read in as a csv from the Input folder. 

```
