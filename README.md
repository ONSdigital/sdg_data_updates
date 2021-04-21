# sdg_data_updates

### General info ###
sg_data_updates contains code for updating UK SDG data files ready for uploading to the [SDG data platform](https://sdgdata.gov.uk/). For each indicator data from the source file(s) (usually excel) are read in, calculations required for the indicator are performed, and data are reshaped to fit the tidy format required to upload data to the SDG data platform.

Contact: SustainableDevelopment@ons.gov.uk


### Framework ###
- Indicator specific files can be found in the indicator folders with the name structure xx-xx-xx. Each of these has a README giving specific directions for use. update_indicator_main.R is the control script from which all update scripts are run (from within the sdg_data_updates.Rproj project)
- Indicator folders with a different name structure (e.g. NCMP_for_2-2-1_and_2-2-2) do not give an output ready for uploading to the SDG data platform and are not clled by update_indicator_main.R. See specific READMEs for details.
- [https://rstudio.github.io/packrat/](packrat) is used to manage dependencies (all required packages are stored locally)
- SDGupdater is a package containing functions frequently used for creating indicator update data.

### Running updates (SDG data team) ###
1) The main branch of this repo can be found on the UK SDG shared drive. 
2) Open RStudio
3) Go to File > Open Project, and open sdg_data_updates.Rproj. It may take a few minutes to load, please be patient. sdg_data_updates.Rproj is a packrat project. This means that R looks in the packrat folder for packages. You therefore do not need to install any packages.
4) update_indicator_main.R should open. If it doesnt go to File > Open File, and open it.
5) Read the README in the folder for the indicator you want to update and follow instructions. This may include instructions for downloading data, however if it doesn't, links to source data can be found in the relevant indicator page on the [SDG data platform](https://sdgdata.gov.uk/) in the Sources tab.
6) Back in RStudio, change the indicator number using the format x-x-x (Dashes NOT dots).
7) Click the 'Source' button (top right of the script). This will run the code.
8) Check any warnings, read QA outputs (if there are any) and copy the csv file into the In Progress Indicator file.
9) Remember to look at the source data to check for caveats and other information that needs to be entered into the metadata file.

### Contributing to code ###
Please see CONTRIBUTING.md for guidelines
