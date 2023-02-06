### 3-1-2 automation

Runtime less than 10 seconds.
  
### Instructions to run update ###
1. *UK SDG data team:* (once this code has been reviewed and is on the main branch) Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository. 
2. Download most recent data from https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/birthcharacteristicsinenglandandwales and save in 3-1-2 > Input
3. Open sdg_data_updates.Rproj  
4. Change indicator folder name (`indicator <- "3-1-2"`)  
5. If config.R does not exist in the 3-1-2 folder, create it from the example_config.R file  
6. Check the configs are correct. If table format has changed you may need to change header_row and tabname. You will need to set the year to be current.
To run the example data and get example output, it should be example_config.R).   
7. Open update_indicator_main.R  
8. Click Source (by default this is in top right of the script window)  
9. Check for messages in the console. When the script is run a file titled '3-1-2.csv' will be saved in 3-1-2 > Output 
   Use this file for the Indicator csv.  
10. A file called <date>_3-1-2_checks.html will also be in the outputs folder. Read through this as a QA of the csv.  
  
### Code edits that may be needed: ###  
*use this section for any problems or changes you can foresee*
update_3-1-2.R chooses the rows that the percentage will be calculated from by name, so if these names change slightly you will need to edit them. They are on row 10 in update_3-1-2.R as:
`main_data <- subset(source_data, `Place of birth` %in% c("Total", "NHS establishments", "Non-NHS establishments"))`
