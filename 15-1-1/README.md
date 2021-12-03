### 15.1.1 update instructions

For the UK data team, all files and folders mentioned below are in Jemalex > sdg_data_updates 
  
1. Download and save the Forest Research Woodland Statistics excel file in the 'Input' folder in the 15-1-1 folder (if the Input folder doesn't exist, make it).  
2. Download the latest Standard Area Measurements for Administrative Areas folder from the geoportal. This will be a zip folder - 
you only need to save the country UK file in the 'Input' folder in the 15-1-1 folder. 
3. Open the `sdg_data_updates.Rproj` from inside RStudio. 
4. If it exists, open the `config.R` file in 15-1-1 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel). 
If not, save `example_config.R` as `config.R` in 15-1-1.  
5. Check the configurations (filenames and tab names) are correct for the files you have saved, and if not correct them and save `config.R`.  
     1. `woodland_area_tabname` is the name of the tab containing area data on all woodland area FOR EVERY YEAR. Check that 'Year' is one of the column headings (case is not important).
     2. `certified_area_tabname` is the name of the tab containing area data on certified woodland area FOR EVERY YEAR. Check that 'AREALHECT' is one of the column headings (case is not important).
     3. Check that areas are given in millions of hectares in the above two tabs. If not, the calculation will need to be changed
6. Open `update_indicator_main.R` (from `sdg_data_updates.Rproj`) and click 'Source' button to run the script (top right corner of the script panel).  
7. Outputs will be saved in the Outputs folder in 15-1-1 (which the script will create if it doesn't already exist).  
8. An html file will also be created in the Outputs folder. This contains some basic checks and also shows all plots, which should show up any major issues. 
**Please check this file before copying to the csv**
9. IMPORTANT: the code does not run any checks on the footnotes - please check the footnotes in the source files for information that may need to be added to the metadata.
