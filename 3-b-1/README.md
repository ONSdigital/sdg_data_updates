
### 3-b-1 automation
  
Data for 3.b.1 comes from two sources. Each source only provides the latest year of data, so back time series data will not be updated. Furthermore, if more than one year of data is available then this automation will have to be run multiple times, once for each year. 


### Downloading and Sourcing Data 
1) In folder 3-b-1 create a new folder called Input.
2) Go to [Childhood Vaccination Coverage Statistics](https://digital.nhs.uk/data-and-information/publications/statistical/nhs-immunisation-statistics). 
3) Scroll down to Resources and download the Childhood Vaccination Coverage Statistics. 
4) Save this in the 'Input' folder as "Childhood Vaccination Statistics - Main Tables - *YEAR*"
5) Go to [HPV vacciene uptake](https://www.gov.uk/government/collections/vaccine-uptake#hpv-vaccine-uptake). 
6) Scroll down to the HPV vaccine uptake section and click on the required year. 
7) Download the "HPV vaccination coverage in adolescents (England YEAR): appendix" ODS data file.
8) Save this as a .xlsx file in the 'Input' folder as "HPV-data-tables-YEAR"


The code manipulates the multiple sheets within both sources.


### Instructions to run update ###
1. *UK SDG data team:* Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository.     
2. Open sdg_data_updates.Rproj
3. Change indicator folder name (indicator <- "3-b-1")
4. If config.R does not exist in the 3-b-1 folder, create it from the example_config.R file
5. Check the configs are correct. In particular, check the input and output folders are as required, check header_row is the row number where the main table starts, and check the tabnames match the variable names required. Finally ensure "data_year" is correct.
6. Open update_indicator_main.R .
7. Ensure test_run <- FALSE.
8. Click Source (by default this is in top right of the script window)
9. Check for messages in the console. When the script is run a file titled '3-b-1.csv' will be saved in 3-b-1 > Output. Use this file for the Indicator csv.
10. A file called 3-b-1_checks.html will also be in the outputs folder. Read through this as a QA of the csv.

  
### Code edits that may be needed: ###  
*use this section for any problems or changes you can foresee*
  
