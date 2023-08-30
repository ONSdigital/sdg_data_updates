
### 3-5-1 automation ###


Data for 3.5.1 are downloaded from different websites:

Source 1 - [National Drug Treatment Monitoring System](https://www.ndtms.net/ViewIt/Adult)
Source 2 - [Fingertips](https://fingertips.phe.org.uk/api)

Source 3 - A further source, Estimated prevalence of alcohol dependency prior to 2018/19, is available in the Input folder. Estimates_of_Alcohol_Dependent_Adults_in_England_for_R



### Downloading and Sourcing Data  
1) In folder 3-5-1 create a new folder called Input. 
2) Go to [Treatment numbers for Local Authorities Source Link](https://www.ndtms.net/ViewIt/Adult).
3) Under download data, select "All in treatment", "Numbers in treatment", "Ethnicity", all reporting periods, all substance categories, all sexes, all age groups. 
4) Save this file in the ?Input? folder as "ViewIt Export Data_England.csv". 
5) Go back to [Treatment numbers for Local Authorities Source Link](https://www.ndtms.net/ViewIt/Adult).
6) Under download data, select "all indicators for all local authorities" download in the top right.
7) Save this file in the ?Input? folder as "ViewIt Export Data_LAs.csv".
8) Go to [Fingertips API Source Link](https://fingertips.phe.org.uk/api#!/Data/Data_GetDataFileForOneIndicator).
9) In the indicator id field select 93532.
10) Click Download indicator-data.csv.
11) Save this file in the Input folder. Rename as unmet_alcohol.csv.
12) Back on [Fingertips API Source Link](https://fingertips.phe.org.uk/api#!/Data/Data_GetDataFileForOneIndicator) in the indicator id field select 93517.
13) Click Download indicator-data.csv.
14) Save this file in the Input folder as well. Rename as unmet_opiates.csv.
15) Copy and paste the "Estimates_of_Alcohol_Dependent_Adults_in_England_for_R" file from the "Example_Input" folder into the "Input" folder. 



The code manipulates the multiple sources, and calculates met need. Prior to 2018/19 this calculation uses the estimates of alcohol dependency (Source 3)and People in treatment (Source 1). From 2018/19 onwards this calculation uses the unmet need figures from fingertips (Source 2).   


  
### Instructions to run update ###
1. *UK SDG data team:* Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository.     
2. Open sdg_data_updates.Rproj
3. Change indicator folder name (indicator <- "3-5-1")
4. If config.R does not exist in the 3-5-1 folder, create it from the example_config.R file
5. Check the configs are correct. In particular, check the input and output folders are as required. 
6. Open update_indicator_main.R .
7. Ensure test_run <- FALSE.
8. Click Source (by default this is in top right of the script window)
9. Check for messages in the console. When the script is run a file titled '3-5-1.csv' will be saved in 3-5-1 > Output. Use this file for the Indicator csv.
10. A file called 3-5-1_checks.html will also be in the outputs folder. Read through this as a QA of the csv.


  
