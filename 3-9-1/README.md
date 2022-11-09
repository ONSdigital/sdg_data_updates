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
Example configurations can be run by setting `test_run` in update_inidcator_main.R to `TRUE`. Note that the outputs will not exactly match the example output because it will be affected by updates to the Fingertips data.      
          
### USER INSTRUCTIONS (SDG Data team):  

### Generating Fingertips links  
The links in the example_config file should work every year. However, if they fail they will need to be regenerated: 
The current links were generated as following in **Google Chrome**:  
1) Go to the [source link](https://fingertips.phe.org.uk/profile/public-health-outcomes-framework/data#page/9/gid/1000043/pat/159/par/K02000001/ati/15/are/E92000001/iid/93861/age/230/sex/4/cat/-1/ctp/-1/yrr/1/cid/4/tbm/1)
2) Select Data view > Download   
3) Scroll down and select 'data for all area types'. This will automatically download a csv to your downloads folder, which you can ignore.    
4) Go to the three dots in the top right of the browser and select Downloads (or just use Ctrl+J).   
5) Right click on the link and 'copy link' - this is the link used in the config file. 
1) Open RStudio.  
2) Go to File > Open Project, and open sdg_data_updates.Rproj.  
3) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.  
4) Change `indicator` to '3-9-1' (Dashes NOT dots).  
6) Set `test_run` to 'FALSE'.  
7) If there is no file called config.R, save the example_config.R file as config.R. Check that all configurations are correct. Ensure `areas_filename` and `households_filename` in config.R match the filenames of your downloads in step 1. `input_folder` must be 'Input', not 'example_input'.    
> The `header_row` settings refer to the row number of the main column names (the row number on which the headings 'non-decent', 'repair' etc are found).  
8) Go back to update_indicator_main.R and click the 'source' button (in the top right of the top left window). This will run the code.  
9) csv and html (QA) files will be exported to the output folder in 11-1-1.  
10) If an error occurs (see troubleshooting section below), you will need to run the following code in the console: `setwd('./..')` before repeating step 7.  
  
Please check the data source to check for caveats (e.g in the notes on each tab), and check whether there are any new disaggregations we should include.
  
### QA PROCESS (SDG Data team):
Read the automatically generated QA report. Pay particular attention to the charts as this is where you are likely to spot any unexpected problems with the code. For
examaple if a line or point is missing, or looks strange, this may indicate a change in the formatting of the data.  
  
The QA report does not negate checking the source data for notes, but if everythig looks fine in the report, the numbers should not need to be checked.  
  
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
