Data for 3.5.1 are all produced (or commissioned) by PHE However, they are downloaded from 3 different websites:

UNMET need estimates for England and Local Authorities are from standard PHE tables but are only given for 2018/19. The calculation for 2018/19 MET need is therefore just 100 - unmet need. We need to calculate met need for all other available years ourselves as (number in treatment / number estimated to have that substance use disorder) * 100

Treatment numbers for England (not for LAs) are standard PHE tables (see link in Source 1) Treatment numbers for Local Authorities are from ViewIt (see link in Source 2) Estimated prevalence figures for LAs are from the Public Health Dashboard, but only go up to 2017/18 (see link in Source 3)

The code does the following checks and calculations (currently just for alcohol):

makes sure LA names match in the 3 datasets
calculates met need
creates charts so we can check that our calculations for years up to and including 2017/18 look reasonable compared to the figures PHE publishes for unmet need in 2018/19.
shows rows with NA values so we can manually check if they should be NA
creates csv (without NA values)
There are a few issues I need to chase up with PHE:

The dates on the the alcohol prevalence data (Public Health Dashboard) appear to be wrong (2010 - 2014 should be 2010/11 to 2014/15)
in the ViewIt data (treatment figures for LAs) the summed 'in treatment' figures for LAs are not quite equal to the 'in treatment' figures given for England in the PHE treatment tables (up to 4 out).
The 2018/19 unmet need figure is given for Cornwall alone, but the 'in treatment' figure used is very similar (2 more) to the 'in treatment' figure given for Cornwall & the Isles of Scilly in the ViewIt table
In 2010/11 treatment numbers are given for 'Bedfordshire (discontinued)' and 'Cheshire (discontinued)'. but separate prevalence estimates are given for 'Bedford' & 'Central Bedford'; and for 'Cheshire East' & 'Cheshire West and Chester'. We thereofre haven't calculated met need for these LAs in 2010/11.
Questions for me to ask PHE:

Is it appropriate for us to aggregate up to Region?
How do we calculate CIs (check query with emily first)
Why are summed 'in treatment' figures for LAs in the ViewIt data not quite equal to the 'in treatment' figures given for England in the PHE treatment tables (up to 4 out)
Is it correct that prevalence is calculated for Cornwall and not IoS in 2017/18 and 2018/19, but is calculated for both previous to that?
Should we drop the Cornwall-only estimate, or treat it as though it is for Cornwall and Isles of Scilly (as seems to be the case in the unmet need file for 2018/19)?
in PHE treatment table 11_4, which gives trends in treatment numbers by agegroup, the sum of people in treatment in each age group does not equal the figure given for England (I was going to use this, but noticed the discrancy so used a different table). Why is this?
Agegroups for OCU in treatment don't match agegroups in prevalence, so we can't calculate headline figures for England - is it possible they may publish these figures, or backdate unmet need in the future? For now we will just report the published 2018/19 figure for OCU.
Is there any chance there has been double counting (e.g. change in Local Authority - count as one person)- Quality and Methodology Information.

### 3-5-1 automation ###
  
This automation pulls together all relevant ICD-10 classification codes
from the UN metadata https://unstats.un.org/sdgs/metadata/files/Metadata-03-09-02.pdf
off NOMIS to display their mortality rate per 100,000 disaggregated by 
country, region, sex, and type of disease.
  
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
  
