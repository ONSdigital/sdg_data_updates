### 1-a-2 automation
  
This is a very simple automation: we read in one data table, calculate a percentage from two of the rows and output one value per year.
  
### Instructions to run update ###
1. *UK SDG data team:* (once this code has been reviewed and is on the main branch) Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository.
2. Download the data from https://www.gov.uk/government/statistics/public-expenditure-statistical-analyses-2022 (PESA [year] Chapter 4 Tables > Table 4_2) and place it in the Input folder in sdg_data_updates > 1-a-2. Make sure the filename is in the format "PESA_2022_CP_Chapter_4_tables.xlsx". There should only be one file in the input folder - the most recent tables.
3. Open sdg_data_updates.Rproj  
4. Change indicator folder name (`indicator <- "1-a-2"`)  
5. If config.R does not exist in the x-x-x folder, create it from the example_config.R file  
6. Check the configs are correct:
  - You may need to change tabname and header_row if these have changed between years
  - You WILL need to change the most_recent_year to be accurate

To run the example data and get example output, it should be example_config.R).   
6. Open update_indicator_main.R  
7. Click Source (by default this is in top right of the script window)  
8. Check for messages in the console. When the script is run a file titled 'x-x-x.csv' will be saved in x-x-x > Output 
   Use this file for the Indicator csv.  
10. A file called <date>_x-x-x_checks.html will also be in the outputs folder. Read through this as a QA of the csv.  

### Instructions for metadata ###
There are two many superfluous footnotes in the table to generate metadata automatically, so this automation assumes that the metadata stays constant between years. Still advisable to check that nothing has changed just in case.
  
*note: check this link when census 2021 numbers are out.*  
  
### Code edits that may be needed: ###  
*use this section for any problems or changes you can foresee*
  
