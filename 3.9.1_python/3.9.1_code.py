# -*- coding: utf-8 -*-
"""
Created on Wed Jun  9 13:38:53 2021

@author: jakkiv
"""
import pandas as pd
import numpy as np
import glob # for finding strings of a given pattern
import os
import webbrowser # used to open the ONS site to download csv files
from os import path, rename # to interact with files 
from time import sleep # use to allow time for the file to download before continuing
import getpass # to get username

# Adding automation of data collection section
############################

download_path= "C:/Users/"+getpass.getuser()+"/Downloads/"
download_file_name= download_path+'indicators-CountyUApre419.data.csv'


if path.exists(download_file_name):
    os.remove(download_file_name)
    print("This file already existed and the old version has been removed")
    
for filename in glob.glob(download_path+'indicators-CountyUApre419.data (***).csv'):
    os.remove(filename) # remove anything called 'Data(??).csv'
    print("This file already existed and the old version has been removed")

################# 

def get_data(link):
    webbrowser.open(link, new = 0)    
    # sleep for three seconds to allow the file to download
    sleep(10) 
    df = pd.read_csv(download_file_name)
    return(df)
#################

starting_df = get_data("https://fingertipsws.phe.org.uk/api/all_data/csv/by_indicator_id?v=0-c87ce5b7/&parent_area_code=E92000001&parent_area_type_id=6&child_area_type_id=102&indicator_ids=30101&category_area_code=null&sex_id=4&age_id=230")



# starting_df = pd.read_csv("Y:\Data Collection and Reporting\Jemalex\Extraction tools and macros\indicators-CountyUApre419.data.csv") # importing data - look to make this automated, should be easy as it can be done through opening link and importing from downloads
starting_df.columns = starting_df.columns.str.replace(' ','_') # celan up column names


key = starting_df["Category_Type"].isnull() # make a key of when Category type column in NA
filtered_df = starting_df.loc[key] # use Key to filter main df


cleaned_df = filtered_df[["Parent_Code", "Parent_Name", "Area_Code", "Area_Name", "Area_Type", "Sex", "Time_period", "Value", "Value_note"]] # subsetting columns we need
cleaned_df["Parent_Name"] = cleaned_df["Parent_Name"].str.replace("region", "")

main_regions = cleaned_df[cleaned_df["Area_Code"].isin(["E92000001",
                                                         "E12000001",
                                                         "E12000002",
                                                         "E12000003",
                                                         "E12000004",
                                                         "E12000005",
                                                         "E12000006",
                                                         "E12000007",
                                                         "E12000008",
                                                         "E12000009"])]





local_authority = cleaned_df[cleaned_df["Area_Code"].isin(["E06000001",	"E06000002",	"E06000003",	"E06000004",	"E06000005",	"E06000006",	"E06000007",	"E06000008",
                                                            "E06000009",	"E06000010",	"E06000011",	"E06000012",	"E06000013",	"E06000014",	"E06000015",	"E06000016",
                                                            "E06000017",	"E06000018",	"E06000019",	"E06000020",	"E06000021",	"E06000022",	"E06000023",	"E06000024",
                                                            "E06000025",	"E06000026",	"E06000027",	"E06000028",	"E06000029",	"E06000030",	"E06000031",	"E06000032",
                                                            "E06000033",	"E06000034",	"E06000035",	"E06000036",	"E06000037",	"E06000038",	"E06000039",	"E06000040",
                                                            "E06000041",	"E06000042",	"E06000043",	"E06000044",	"E06000045",	"E06000046",	"E06000047",	"E06000049",
                                                            "E06000050",	"E06000051",	"E06000052",	"E06000053",	"E06000054",	"E06000055",	"E06000056",	"E06000057",
                                                            "E08000001",	"E08000002",	"E08000003",	"E08000004",	"E08000005",	"E08000006",	"E08000007",	"E08000008",
                                                            "E08000009",	"E08000010",	"E08000011",	"E08000012",	"E08000013",	"E08000014",	"E08000015",	"E08000016",
                                                            "E08000017",	"E08000018",	"E08000019",	"E08000021",	"E08000022",	"E08000023",	"E08000024",	"E08000025",
                                                            "E08000026",	"E08000027",	"E08000028",	"E08000029",	"E08000030",	"E08000031",	"E08000032",	"E08000033",
                                                            "E08000034",	"E08000035",	"E08000036",	"E08000037",	"E09000001",	"E09000002",	"E09000003",	"E09000004",
                                                            "E09000005",	"E09000006",	"E09000007",	"E09000008",	"E09000009",	"E09000010",	"E09000011",	"E09000012",
                                                            "E09000013",	"E09000014",	"E09000015",	"E09000016",	"E09000017",	"E09000018",	"E09000019",	"E09000020",
                                                            "E09000021",	"E09000022",	"E09000023",	"E09000024",	"E09000025",	"E09000026",	"E09000027",	"E09000028",
                                                            "E09000029",	"E09000030",	"E09000031",	"E09000032",	"E09000033"])]



county = cleaned_df[cleaned_df["Area_Code"].isin([  "E10000002",	"E10000003",	"E10000006",	"E10000007",	"E10000008",	"E10000009",	"E10000011",	"E10000012",
                                                    "E10000013",	"E10000014"	,"E10000015",	"E10000016"	,"E10000017",	"E10000018","E10000019",	"E10000020",
                                                    "E10000021",	"E10000023"	,"E10000024",	"E10000025"	,"E10000027",	"E10000028",	"E10000029",	"E10000030",
                                                    "E10000031",	"E10000032",	"E10000034"])]

main_regions_subsetted = main_regions.rename(columns = {"Time_period" : "Year", "Area_Name": "Region", "Area_Code": "GeoCode", "Value": "Value"})[["Year", "Region", "GeoCode", "Value"]]

local_authority_subsetted = local_authority.rename(columns = {"Time_period" : "Year", "Parent_Name": "Region", "Area_Name": "Local Authority", "Area_Code": "GeoCode", "Value": "Value"})[["Year", "Region", "Local Authority", "GeoCode", "Value"]]

county_subsetted = county.rename(columns = {"Time_period" : "Year", "Parent_Name": "Region","Area_Name": "County", "Parent_Code": "GeoCode", "Value": "Value"})[["Year", "Region", "County", "GeoCode", "Value"]]



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




