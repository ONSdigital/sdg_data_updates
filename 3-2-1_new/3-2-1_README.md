### 3-2-1 automation
  
This automation calculates the under 5 death rate per 1000 live births disaggregated by country and sex.

This code works on the data for 2020 (and hopefully newer), data for 2019 and older is in quite a different table format. There is code that works for the older data on 3-2-1 on the github, hence why this automation is under 3-2-1_new.

### Instructions to run update ###
1. *UK SDG data team:* (once this code has been reviewed and is on the main branch) Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository.     
2. Open sdg_data_updates.Rproj
3. If config.R does not exist in the 3-2-1_new folder, create it from the example_config.R file  
4. Check the configs are correct.
  - To run the example data and get example output, it should be example_config.R.   
5. Open update_indicator_main.R - change indicator folder name (`indicator <- "3-2-1_new"`).
6. Click Source (by default this is in top right of the script window)  
7. Check for messages in the console. When the script is run a file titled '<date>_update_3-2-1.csv' will be saved in 3-2-1_new > Output 
   Use this file for the Indicator csv.  
8. A file called <date>_update_3-2-1_checks.html will also be in the outputs folder. Read through this as a QA of the csv.  

### Code edits that may be needed: ###  
*use this section for any problems or changes you can foresee*
` > setwd(indicator)
Error in setwd(indicator) : cannot change working directory`
You probably need to set your working directory to sdg_data_updates before clicking source in update_indicator_main.R

While the code aims to future-proof column names etc, if you get errors on new data along the lines of 'column not found' or not all of the correct columns being selected, compare the downloaded data tables to their respective code: lines 35-38 in united_kingdom.R and 32-36 in england_and_wales.R

You will get a specific error message if this is not the case, but make sure the file is saved as .xlsx. Should be fine to do this with old .xls files.