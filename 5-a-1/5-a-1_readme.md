### Instructions to run update for Indicator 5-a-1 ###
1. *UK SDG data team:* (once this code has been reviewed and is on the main branch) Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository.     
2. Open sdg_data_updates.Rproj  
3. Change indicator folder name (`indicator <- "5-a-1"`)  
4. If config.R does not exist in the 5-a-1 folder, create it from the example_config.R file  
5. Check the configs are correct. The nomis links should not need to be edited, unless you want to add or remove selections. 
6. Check that the compile.tables.R script sources the correct config file  
7. Open update_indicator_main.R  
8. Click Source (by default this is in top right of the script window)  
9. Check for messages in the console. When the script is run a file titled '5-a-1.csv' will be saved in 5-a-1 > Output 
   Use this file for the Indicator csv.  
10. A file called <date>_5-a-1_checks.html will also be in the outputs folder. Read through this as a QA of the csv.  


  
### Generation of Nomis link ###
The nomis link should not need to be regenerated unless we decide to e.g. change from count to rate  
or use a different population estimate (e.g. when the new estimates from census 2021 are out).  


The current nomis link was generated as follows:

From Nomis, select Query, then Annual Population Survey/Labour Force Survey >  annual population survey - regional - employment by occupation   
  
Selections:
   countries: all 
   regions: all except the devolved countries
   occupation: deselect any auto ticks. Select 121
   sex: All persons, males, females
   date: select all December dates - equivalent of ANNUAL

To generate link go to format/layout and select API. Then in 'Download data' right click on the csv link and copy link
Check last updated date [here](https://www.nomisweb.co.uk/query/construct/summary.asp?mode=construct&version=0&dataset=168)

