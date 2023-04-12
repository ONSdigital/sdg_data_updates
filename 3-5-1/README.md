
### 3-5-1 automation ###


Data for 3.5.1 are all produced (or commissioned) by PHE However, they are downloaded from 2 different websites:

Source 1 - [National Drug Treatment Monitoring System] https://www.ndtms.net/ViewIt/Adult
Source 2 - [Fingertips] https://fingertips.phe.org.uk/api



### Downloading and Sourcing Data  
1) In folder 3-5-1 create a new folder called ?Input?. 
2) Go to [Treatment numbers for Local Authorities Source Link] https://www.ndtms.net/ViewIt/Adult. 
3) Under download data, select "All in treatment", "Numbers in treatment", ""Ethnicity", all reporting periods, all substance categories, all sexes, all age groups. 
4) Save this file in the ?Input? folder as "ViewIt Export Data_England.csv". 
5) Go back to [Treatment numbers for Local Authorities Source Link] https://www.ndtms.net/ViewIt/Adult. 
6) Under download data, select "all indicators for all local authorities" download in the top right.
7) Save this file in the ?Input? folder as "ViewIt Export Data_LAs.csv".
8) Go to [Fingertips API Source Link] https://fingertips.phe.org.uk/api#!/Data/Data_GetDataFileForOneIndicator
9) In ?indicator id? select 93532.
10) Click ?Download indicator-data.csv?. 
11) Save this file in the ?Input? folder. Rename as unmet_alcohol.csv.
12) Back on [Fingertips API Source Link]  https://fingertips.phe.org.uk/api#!/Data/Data_GetDataFileForOneIndicator in ?indicator id? select 93517.
13) Click ?Download indicator-data.csv?.
14) Save this file in the ?Input? folder as well. Rename as unmet_opiates.csv.




The calculation for MET need is 100 - unmet need. We need to calculate met need for all other available years ourselves as (number in treatment / number estimated to have that substance use disorder) * 100



The code does the following checks and calculations (currently just for alcohol):

  
### Instructions to run update ###
1. Use information and data source links in Jemalex > Indicators > 3.9.2 to add raw death counts for Scotland and Northern Ireland to "Scotland_NI_data.csv" within the Input folder. 
2. *UK SDG data team:* Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository.     
3. Open sdg_data_updates.Rproj
4. Change indicator folder name (indicator <- "3-9-2")
5. If config.R does not exist in the 3-9-2 folder, create it from the example_config.R file
6. Check the configs are correct. In particular, check the years variable as the latest year will likely need to be     added when running an update. The nomis links should not need to be edited, unless you want to add or remove ICD-10 classification codes following UN or Topic Expert guidance.
7. Open update_indicator_main.R .
8. Ensure test_run <- FALSE.
9. Click Source (by default this is in top right of the script window)
10. Check for messages in the console. When the script is run a file titled '3-9-2.csv' will be saved in 3-9-2 > Output Use this file for the Indicator csv.
11. A file called 3-9-2_checks.html will also be in the outputs folder. Read through this as a QA of the csv.


  
### Code edits that may be needed: ###  
*use this section for any problems or changes you can foresee*
  
