Authors(s): Michael Nairn
Date: 18/05/2023

### 4-1-1 automation

Creates csv data for 4-1-1 (Proportion of children and young people - (a) in grades 2/3; (b) at the end of primary; and (c) at the end of lower secondary achieving at least a minimum proficiency level in (i) reading and (ii) mathematics, by sex). PLEASE NOTE - this automation produces Key Stage 1 (Age 7) data starting in 2015 to 2016, Key Stage 2 (Age 11) data starting in 2018 to 2019, and Key Stage 4 (Age 16) data starting in 2009 to 2010. Key Stage 2 (Age 11) data prior to 2018 to 2019 is sourced from https://www.gov.uk/government/collections/statistics-key-stage-2 (Source 4 on Jemalex) and is already in the Jemalex csv sheet. 

It is a fairly simple automation that only involves formatting the data (no calculations). However, there are a lot of disaggregations and data points (nearly 100,000 by 2021 to 2022).


Output includes the data in csv format, and an html QA report. Users should still look at the source data and check footnotes and information tabs for anything that needs to be manually changed in the csv output (e.g., if any figures are estimated) or caveats that need to be included in the metadata. 


### 4-1-1 sourcing data instructions

1) Download the latest Key Stage 1 pupil characteristics data from: https://explore-education-statistics.service.gov.uk/data-tables/key-stage-1-and-phonics-screening-check-attainment. 
Under Step 2 select "Create your own table" and "Key stage 1 attainment by pupil characteristics" as the subject.
Under Step 3 select England.
Under Step 4 select time period from 2015/16 to the most recent year.
Under Step 5 - Indicators select  "Percentage of pupils meeting the expected standard in maths TA" and "Percentage of pupils meeting the expected standard in reading TA".
Under Step 5 - Gender select all options.
Under Step 5 - Pupil characteristics select Total, all options under Disadvantage status, all options under Ethnic major, no options under ethnic minor, all options under First language, all options under Free school meal status, and "All SEN" and "No SEN" under SEN status.
Click Create table. 
Under Step 6 select "Table in CSV format" and Download table. 


2) Save the file as a csv file in the 'Input' folder in 4-1-1.  If this doesn't exist, make it inside the 4-1-1 folder.

3) Download the latest Key Stage 1 pupil geography data from: https://explore-education-statistics.service.gov.uk/data-tables/key-stage-1-and-phonics-screening-check-attainment. 
Under Step 2 select "Create your own table" and "Key stage 1 attainment by region and local authority" as the subject.
Under Step 3 select all options for Local Authority and Region. Do not select England.
Under Step 4 select time period from 2015/16 to the most recent year.
Under Step 5 - Indicators select  "Percentage of pupils meeting the expected standard in maths TA" and "Percentage of pupils meeting the expected standard in reading TA".
Under Step 5 - Gender select all options.
Under Step 5 - Pupil characteristics select Total, all options under Ethnic major, all options under First language, all options under Free school meal status, and "All SEN" and "No SEN" under SEN status. 
Click Create table.
Under Step 6 select "Table in CSV format" and Download table. 

4) Save the file as a csv file in the 'Input' folder in 4-1-1.  If this doesn't exist, make it inside the 4-1-1 folder.

5) Download the latest Key Stage 2 attainment data from: https://explore-education-statistics.service.gov.uk/data-tables/key-stage-2-attainment. 
Under Step 2 select "Create your own table" and "Key stage 2 attainment by region, local authority, and pupil characteristics" as the subject.
Under Step 3 select all options for Local Authority, Region, and National. 
Under Step 4 select time period from 2018/19 to the most recent year.
Under Step 5 - Indicators select  "Percentage of pupils meeting the expected standard in maths" and "Percentage of pupils meeting the expected standard in reading".
Under Step 5 - Categories select all options under Disadvantage status, all options under Ethnic major, no options under ethnic minor, all options under First language, all options under Free school meal status, "All SEN" and "No SEN" under SEN status, and "Total" under School type.
Under Step 5 - Gender select all options.
Click Create table. 
Under Step 6 select "Table in CSV format" and Download table. 


6) Save the file as a csv file in the 'Input' folder in 4-1-1.  If this doesn't exist, make it inside the 4-1-1 folder.

7) Download the latest Key Stage 4 attainment data from: https://explore-education-statistics.service.gov.uk/data-tables/key-stage-4-performance-revised. 
Under Step 2 select "Create your own table" and "KS4 subject timeseries data" as the subject.
Under Step 3 select England. 
Under Step 4 select time period from 2009/10 to the most recent year.
Under Step 5 - Indicators select  "The percentage of pupils achieving the designated grade".
Under Step 5 - Categories select all options under gender, "94AstarC" under The grade achieved, English, English Language, and Mathematics under The subject pupils are entered for. 
Click Create table. 
Under Step 6 select "Table in CSV format" and Download table. 


8) Save the file as a csv file in the 'Input' folder in 4-1-1.  If this doesn't exist, make it inside the 4-1-1 folder.






### 4-1-1 update instructions

1) In RStudio, go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. Update_indicator_main.R should open. If it doesn't go to File > Open File, and open it. 
4) If it exists, open the `config.R` file in 4-1-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). If not, save example_config.R as `config.R` in 4-1-1.
5) Check the configurations (e.g. filename) are correct, and if not correct them and save. For example, if you have had to save example_config.R as config.R, make sure 'Example_Input' and 'Example_Output' are changed to 'Input' and 'Output' and the file names are correct. 
6) Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and set indicator as 4-1-1. Make sure test_run is set to FALSE (so that it sources the correct config file). 
7) Click 'Source' button to run the script (top right corner of the script panel).  
8) Outputs will be saved in the Output folder in 4-1-1 (which the script will create if it doesn't already exist).  
9) An html file will also be created in the Outputs folder. This contains some basic checks and relevant information for the person who will be QAing the update. **Please check this file before copying to the csv.** 
10) Attainment at age 11 data prior to 2018 to 2019 is not generated by this automation. Therefore, ensure this data in the csv sheet of the indicator file is not overriden when adding the automation generated csv output. 
