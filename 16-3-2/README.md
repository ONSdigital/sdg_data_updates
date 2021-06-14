### 16.3.2 update instructions

1) Save the Annual Prison Population tables as an xlsx file in the 'Input' folder in 16-3-2 (if this doesn't exist, make it inside the 16.3.2 folder).  
2) Open the sdg_data_updates.Rproj from inside RStudio.  
3) Open the config.R file in 16-3-2 (you can do this in the 'Files' panel in RStudio (usually a tab in the bottom right panel).  
4) Check the configurations (e.g. filename and tab names) are correct, and if not correct them and save.  
5) Check that all the headings in the file are correct (found a typo in 2021, where in A1_11 Nationality Not Recorded, 'Remand' was incorrectly labelled 'British national'). 
If there are issues such as this, change them to be correct in the excel file. While this is not ideal, I don't know how to make the code cover every eventuality like this.
6) Open update_indicator_main.R (from sdg_data_updates.Rproj) and click 'Source' button to run the script (top right corner of the script panel).  
7) Outputs will be saved in the Outputs folder in 16-3-2 (which the script will create if it doesn't already exist).  
