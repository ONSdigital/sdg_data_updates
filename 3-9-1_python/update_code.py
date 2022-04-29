# -*- coding: utf-8 -*-
"""
Created on Fri Aug  6 12:11:54 2021

@author: jakkiv
"""

import pandas as pd
import glob # for finding strings of a given pattern
import webbrowser # used to open the ONS site to download csv files
from os import path, remove # to interact with files
from time import sleep # use to allow time for the file to download before continuing
import getpass # to get username
import ctypes



def run_update():
    # Adding automation of data collection section
    ############################
    download_path= "C:/Users/"+getpass.getuser()+"/Downloads/"
    download_file_pattern = 'indicators-*.csv' # this is more future-proof as we don't know what bits of the filename will change next year
    fingertips_api_link = "https://fingertipsws.phe.org.uk/api/all_data/csv/by_indicator_id?v=0-c87ce5b7/&parent_area_code=E92000001&parent_area_type_id=6&child_area_type_id=102&indicator_ids=30101&category_area_code=null&sex_id=4&age_id=230"
   
    def check_download_filepath(download_path, file_pattern):
    
        for name in glob.glob(download_path + file_pattern):
            if path.exists(name):
                print('a message box will appear. If you cannot see it check behind open windows.')
                response = ctypes.windll.user32.MessageBoxW(0, 
                                                            "The file " + name + " already exists in " + download_path + ". Delete file? If you do not want to delete files, please click cancel. Closing the dialogue box will prompt file deletion.",
                                                            "File download warning",
                                                            1)
                if response == 1:
                    remove(name)
                    print(name+" has been deleted")
                else:
                    raise ValueError("No files have been deleted, code aborted")
                return()

    check_download_filepath(download_path, download_file_pattern)
    ################# 
    
    def get_data(link):
        webbrowser.open(link, new = 0)    
        # sleep for three seconds to allow the file to download
        sleep(10)
        download_file_name = glob.glob(download_path + download_file_pattern)[0]
        df = pd.read_csv(download_file_name)
        return(df)
    #################
    
    starting_df = get_data(fingertips_api_link)
    
    
    
    starting_df.columns = starting_df.columns.str.replace(' ','_') # celan up column names
    
    
    key = starting_df["Category_Type"].isnull() # make a key of when Category type column in NA
    filtered_df = starting_df.loc[key] # use Key to filter main df
    
    
    cleaned_df = filtered_df[["Parent_Code", "Parent_Name", "Area_Code", "Area_Name", "Area_Type", "Sex", "Time_period", "Value", "Value_note"]] # subsetting columns we need
    cleaned_df["Parent_Name"] = cleaned_df["Parent_Name"].str.replace("region", "")
    
    main_regions = cleaned_df[cleaned_df["Area_Type"].isin(["Region","England"])]
    
    
    local_authority = cleaned_df[cleaned_df["Area_Code"].str.startswith("E0")]
    
    
    county = cleaned_df[cleaned_df["Area_Code"].str.startswith("E1")]
    
    
    main_regions_subsetted = main_regions.rename(columns = {"Time_period" : "Year",
                                                            "Area_Name": "Region",
                                                            "Area_Code": "GeoCode",
                                                            "Value": "Value"})[["Year", "Region", "GeoCode", "Value"]]
    
    main_regions_subsetted["Region"] = main_regions_subsetted["Region"].str.replace(" region", "")
    
    local_authority_subsetted = local_authority.rename(columns = {"Time_period" : "Year",
                                                                  "Parent_Name": "Region",
                                                                  "Area_Name": "Local Authority",
                                                                  "Area_Code": "GeoCode",
                                                                  "Value": "Value"})[["Year", "Region", "Local Authority", "GeoCode", "Value"]]
    
    local_authority_subsetted["Region"] = local_authority_subsetted["Region"].str.replace(" region", "")
    
    county_subsetted = county.rename(columns = {"Time_period" : "Year",
                                                "Parent_Name": "Region",
                                                "Area_Name": "County",
                                                "Parent_Code": "GeoCode",
                                                "Value": "Value"})[["Year", "Region", "County", "GeoCode", "Value"]]
    
    
    
    csv_concat = pd.concat([main_regions_subsetted, local_authority_subsetted, county_subsetted], axis = 0)
    csv_concat =csv_concat.sort_values(by = "Year")
    
    default_columns_for_csv = {"Observation status": "Undefined", "Unit multiplier": "Units", "Unit measure": "Percentage (%)"}
    csv_concat = csv_concat.assign(**default_columns_for_csv)
    
    csv_concat = csv_concat[["Year", "Region", "Local Authority", "County", "Observation status", "Unit multiplier", "GeoCode", "Value"]]
    
    csv_concat.to_csv('3.9.1.csv', index = False)

# next step - notes 11/06/2021
# Isle of Scilly comes through as NA so we can filter for all values that are NA and put them in a df and output in a file to say these values are NA - these values should be removed 
# from csv_concat as we do not want NA's in the final csv
    NA_values = csv_concat[csv_concat["Value"].isin(["nan"])] # This df contains all areas that had NA values 
    csv_concat = csv_concat.dropna(subset = ["Value"]) # Df with no NA values - to use in indicator file
    
    NA_values.to_csv("3.9.1_NA_values.csv", index = False)
    # os.chdir("Output")
    csv_concat.to_csv("3.9.1.csv", index = False) # The current code does not save to the output folder but saves to where the code is
    # os.chdir("../..")


