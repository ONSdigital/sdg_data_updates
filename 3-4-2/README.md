
### 3-4-2 automation ###


Data for 3.4.2 is sourced from multiple sheets within the [Suicides in England and Wales Source Link] (https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/suicidesintheunitedkingdomreferencetables) dataset.


This automation only updates Source 1. Source 2 is discontinued so is not updated by this automation. Make sure not to overwrite source 2 data when putting the automated csv file into csv sheet of indicator file.



### Downloading and Sourcing Data  
1) In folder 3-4-2 create a new folder called Input. 
2) Go to [Suicides in England and Wales Source Link] (https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/datasets/suicidesintheunitedkingdomreferencetables) dataset.
3) Download the current edition of the dataset.
4) Save this file in the ?Input? folder. 


The code manipulates the multiple sheets within the source.

  
### Instructions to run update ###
1. *UK SDG data team:* Go to Jemalex > sdg_data_updates.    
   *Others:* Checkout sdg_data_updates main branch to your local repository.     
2. Open sdg_data_updates.Rproj
3. Change indicator folder name (indicator <- "3-4-2")
4. If config.R does not exist in the 3-4-2 folder, create it from the example_config.R file
5. Check the configs are correct. In particular, check the input and output folders are as required. 
6. Open update_indicator_main.R .
7. Ensure test_run <- FALSE.
8. Click Source (by default this is in top right of the script window)
9. Check for messages in the console. When the script is run a file titled '3-4-2.csv' will be saved in 3-4-2 > Output. Use this file for the Indicator csv.
10. A file called 3-4-2_checks.html will also be in the outputs folder. Read through this as a QA of the csv.


  
