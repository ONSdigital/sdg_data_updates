## General info ##
Open source code for updating SDG data files. For each indicator, data are either manually stored in the Input folder, or automatically taken from a predictable weblink to a csv. Scripts read in the data, reshape it and join dataframes where necessary. Required calculations are performed, and data are reshaped to fit the tidy format required to upload data to the SDG data platform. QA html files are created to help users identify issues with the code and store run information (e.g. what configurations are used). The csv output is then uploaded to the [sdg-data repo](https://github.com/ONSdigital/sdg-data/).

Contact: SDG team
SustainableDevelopment@ons.gov.uk

Links to source data can be found in the relevant indicator page on the [SDG data platform](https://sdgdata.gov.uk/) in the Sources tab.
  
Automated updates have been written in eithe R or Python. Historically, code that used an API or weblink to a csv were written in Python,
however choice of language is down to the preference of the author.
  
## Instructions ##
UK SDG data team: updates are run from the Jemalex > sdg_data_updates folder
  
To run an update open the folder of the indicator you want to update and read the readme.  
Usually, you will need to edit the config file.

Indicator specific files can be found in each indicator folder, 
but with the exception of the config file you should not need to open these unless you are doning development work. 

### How to run updates written in R ###
Indicators updated with R scripts have folder names that are just the indicator name (name structure xx-xx-xx)

Work from `sdg_data_updates.Rproj` and use `update_indicator_main.R` to run all indicator update scripts. 
  
Specific instructions for each indicator should be given in the README file in the indicator folder. General instructions are as follows:  
  
1) Open the folder for the indicator you want to update.
2) Open RStudio.
3) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. 
4) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
5) Change the indicator number to the relevant idicator e.g. '3-2-2' (Dashes NOT dots).
6) Open the config file for your indicator and check and edit the configs (see the README file for your indicator).
7) Click the 'source' button (in the top right of the top left window). This will run the code. You may need to install some packages if they are not already installed. ~Use `install.packages('name_of_package', dependencies = TRUE)` to install packages, then try running the code (using the source button) again.
8) csv and html (QA) files will be exported to Output folder.

![file_structure](https://user-images.githubusercontent.com/52452377/154540640-0ed8c673-60fa-4286-8c13-7009de6f620f.JPG)


### How to run updates written in Python ###
Indicators updated with Python scripts have folder names that are the indicator name followed by _ python (name structure xx-xx-xx_python)

Use `update_python_indicator.py` to run all indicator update scripts. *Varun - does it have to be run from a project or does it work without?*

#### developer notes ####
*to do:*
- *note about the difference between using api and download link and why we switched*
- *links to useful documents (e.g. Ben's docs). If these are on the shared drive move them to sharepoint data_team > projects_across_indicators > automation*
- *Anything else useful you can think of*

Template files for R automations can be found in the template folder (currently in template branch)


### To do ### 
Manage dependencies using renv (all required packages are stored locally). 
