Author(s): Emma Wood
## 3-9-1 update  
### Introduction
Create csv data for 3-9-1 'Fraction of all-cause adult mortality attributable to ambient particulate air pollution (measured as fine particulate matter, PM2.5)' with the following disaggregations:  
- Region
- Local Authority (Districts and Unitary Authorities combined)
- IMD decile
There are two series as there is a long time series for the old method, but this is no longer updated and there are no plans to backdate the series using the new method.  
  
Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs as caveats may change in the future.  
  
### Examples
Example outputs are given in the Example_outut folder.  
Example input is given in the 'Example_automatic_download' folder. This is not a standard 'Example_input' folder because the input is automatically pulled from the fingertips website. The old series in the download actually goes back to 2010, but only more recent years are shown in the example data to reduce filesize.
Example configurations can be run by setting `test_run` in update_indicator_main.R to `TRUE`. Note that the outputs will not exactly match the example output because it will be affected by updates to the Fingertips data.      
          
### USER INSTRUCTIONS (SDG Data team):  

### Downloading and Sourcing Data  
1) In folder 3-9-1 create a new folder called ?Input?. 
2) Go to [Fingertips API Source Link] https://fingertips.phe.org.uk/api#!/Data/Data_GetDataFileForOneIndicator
3) In ?indicator id? select 30101.
4) Click ?Download indicator-data.csv?. 
5) Save this file in the ?Input? folder. Rename as old_method.csv.
6) Back on [Fingertips API Source Link]  https://fingertips.phe.org.uk/api#!/Data/Data_GetDataFileForOneIndicator in ?indicator id? select 93861.
7) Click ?Download indicator-data.csv?.
8) Save this file in the ?Input? folder as well. Rename as new_method.csv.


1) Open RStudio.  
2) Go to File > Open Project, and open sdg_data_updates.Rproj.  
3) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.  
4) Change `indicator` to '3-9-1' (Dashes NOT dots).  
6) Set `test_run` to 'FALSE'.  
7) Navigate to folder 3-9-1. If there is no file called config.R, save the example_config.R file as config.R. Check that all configurations are correct. Check that the new method includes the data for indicator 93861, and the old method includes the data for indicator 30101. 
8) Go back to update_indicator_main.R and click the 'source' button (in the top right of the top left window). This will run the code.  
9) csv and html (QA) files will be exported to the output folder in 3-9-1. 
10) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('./..')` before repeating step 7.  

Please check the data source to check for caveats (e.g in the notes on each tab), and check whether there are any new disaggregations we should include.



### QA PROCESS (SDG Data team):
Read the automatically generated QA report. Pay particular attention to the charts as this is where you are likely to spot any unexpected problems with the code. For
example if a line or point is missing, or looks strange, this may indicate a change in the formatting of the data.  
  
The QA report does not negate checking the source data for notes, but if everything looks fine in the report, the numbers should not need to be checked.  
  
If you get an error on the QA file, run it block by block. Any errors at this stage are usually because there is something unexpected in the data that needs to be addressed.  

 


### TROUBLESHOOTING:
Some possible errors (may not be an exact match) and solutions:    
  
```diff
- Error: Sheets not found: "2017"  
  
There is a typo in one of the tables in the `config.R` file.
  
```
    
```diff
- Error in setwd(indicator) : cannot change working directory
  
The folder name (`indicator`) in `update_indicator_main.R` is incorrectly typed. OR    
  
The script is looking in the wrong working directory. 
To check which directory it is looking in, type `getwd()` in the console and hit enter.
It should not have the indicator folder at the end of the filepath, but should end with 'sdg_data_updates'. 
If it does not end with 'sdg_data_updates' type `setwd('./..')`, this will make R look in the directory above.

```
