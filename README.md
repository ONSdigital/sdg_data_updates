## General info ##
Open source code for updating SDG data files. For each indicator, data from the source file(s) (usually either excel or a weblink to a csv) are read in, calculations required for the indicator are performed, and data are reshaped to fit the tidy format required to upload data to the SDG data platform.

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
but with the exception of the config file you should notr need to open these unless you are doning development work. 

### R ###
Indicators updated with R scripts have folder names that are just the indicator name (name structure xx-xx-xx)

Work from `sdg_data_updates.Rproj` and use `update_indicator_main.R` to run all indicator update scripts. *Emma: change name of main script to `update_R_indicator.R`*

SDGupdater is a package used by R indicator update scripts. 

#### developer notes ####
*to do:* 
- *note about packrat*
- *note about SDGupdater*

### Python ###
Indicators updated with Python scripts have folder names that are the indicator name followed by _ python (name structure xx-xx-xx_python)

Use `update_python_indicator.py` to run all indicator update scripts. *Varun - does it have to be run from a project or does it work without?*

#### developer notes ####
*to do:*
- *note about the difference between using api and download link and why we switched*
- *links to useful documents (e.g. Ben's docs). If these are on the shared drive move them to sharepoint data_team > projects_across_indicators > automation*
- *Anything else useful you can think of*


### To do ### 
Manage dependencies using packrat (all required packages are stored locally). 
