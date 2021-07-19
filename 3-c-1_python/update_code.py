# -*- coding: utf-8 -*-
"""
Created on Tue Mar  2 12:18:42 2021

@author: jakkiv
"""


import webbrowser # used to open the ONS site to download csv files
from os import path, rename # to interact with files 
from time import sleep # use to allow time for the file to download before continuing
import getpass # to get username
import datetime as dt # to get date
import pandas as pd # pandas for dataframe manipulation
import numpy as np # for calculations
import ctypes  # for the pop-up notification box
import glob # for finding strings of a given pattern
import os
#############################################
# PLEASE ENSURE THAT YOU DO NOT HAVE ANY FILES NAMED 'data' in your downloads folder before running this script



def run_update():
##################################################
    
    download_path= "C:/Users/"+getpass.getuser()+"/Downloads/"
    download_file_name= download_path+'data.csv'
    
    ################# 
    
    if path.exists(download_file_name):
        os.remove(download_file_name)
        print("This file already existed and the old version has been removed")
        
    if path.exists(download_path+"Annual_pop_3_C_1.csv"):
        os.remove(download_path+"Annual_pop_3_C_1.csv")
        print("This file already existed and the old version has been removed")
        
    if path.exists(download_path+"occupation_category_3_C_1.csv"):
        os.remove(download_path+"occupation_category_3_C_1.csv")
        print("This file already existed and the old version has been removed")
        
    if path.exists(download_path+"occupation_subcategory_3_C_1.csv"):
        os.remove(download_path+"occupation_subcategory_3_C_1.csv")
        print("This file already existed and the old version has been removed")
        
    for filename in glob.glob(download_path+'data (***).csv'):
        os.remove(filename) # remove anything called 'Data(??).csv'
        print("This file already existed and the old version has been removed")
        
    ####################
    def get_data(link, new_file_name):
        webbrowser.open(link, new = 0)    
        # sleep for three seconds to allow the file to download
        sleep(10) 
    
        rename(download_file_name, download_path+new_file_name)
        df = pd.read_csv(download_path+new_file_name)
        return(df)
    #################
    
    annual_pop_estimates = get_data("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=2092957697&date=latestMINUS9-latest&gender=0...2&c_age=200&measures=20100&select=date_name,geography_name,geography_code,gender_name,c_age_name,obs_value",
                                    "Annual_pop_3_C_1.csv")
    
    occupation_category = get_data("http://www.nomisweb.co.uk/api/v01/dataset/NM_168_1.data.csv?geography=2092957697&date=latestMINUS32,latestMINUS28,latestMINUS24,latestMINUS20,latestMINUS16,latestMINUS12,latestMINUS8,latestMINUS4,latest&c_sex=0...2&c_occpuk11h_0=20005...20007,30003&measure=1&measures=20100,20701&select=date,date_name,c_sex_name,c_occpuk11h_0_name,measures_name,obs_value", 
                                   "occupation_category_3_C_1.csv")
    occupation_category = occupation_category.rename(index = str,
                                                     columns = {'C_SEX_NAME': 'Sex',
                                                                'C_OCCPUK11H_0_NAME': 'Occupation_minor_group',
                                                                'OBS_VALUE':'Value'})
    
    occupation_subcategory = get_data("http://www.nomisweb.co.uk/api/v01/dataset/NM_168_1.data.csv?geography=2092957697&date=latestMINUS32,latestMINUS28,latestMINUS24,latestMINUS20,latestMINUS16,latestMINUS12,latestMINUS8,latestMINUS4,latest&c_sex=0...2&c_occpuk11h_0=58...62,64...72,119...123&measure=1&measures=20100,20701&select=date,date_name,c_sex_name,c_occpuk11h_0_name,measures_name,obs_value", 
                                      "occupation_subcategory_3_C_1.csv")
    occupation_subcategory = occupation_subcategory.rename(index = str,
                                                           columns = {'C_SEX_NAME': 'Sex',
                                                                      'C_OCCPUK11H_0_NAME': 'Occupation_unit_group',
                                                                      'OBS_VALUE':'Value'})
        
    ####################
    
    
    
    # list_of_categories = [occupation_category, occupation_subcategory]
    
    
    
    
    major_occupations = pd.DataFrame({'Occupation_minor_group': occupation_category['Occupation_minor_group'].unique()})  # occupation_minor_group is the major occupation group
    major_occupations['code'] = major_occupations['Occupation_minor_group'].str[:3]
    
    minor_occupations = pd.DataFrame({'Occupation_unit_group': occupation_subcategory['Occupation_unit_group'].unique()})  # occupation_minor_group is the major occupation group
    minor_occupations['code'] = minor_occupations['Occupation_unit_group'].str[:3]
    
    full_occupations = minor_occupations.merge(major_occupations, on = ['code'])
    full_occupations.drop(['code'], inplace=True, axis=1, errors='ignore')
    
    full_occupation_subcategory = occupation_subcategory.merge(full_occupations, on = ['Occupation_unit_group'])
    
    all_occupations = pd.concat([occupation_category, full_occupation_subcategory], ignore_index = True)
    occupation_values = all_occupations[all_occupations['MEASURES_NAME']== 'Value']
    
    
    
    annual_pop_estimates = annual_pop_estimates.rename(index = str,columns = {'GENDER_NAME': 'Sex', 'DATE_NAME': 'Year'})
    annual_pop_estimates.drop(['GEOGRAPHY_NAME', 'GEOGRAPHY_CODE', 'C_AGE_NAME'], inplace=True, axis=1, errors='ignore')
    annual_pop_estimates['Sex'] = annual_pop_estimates['Sex'].replace(['Total', 'Male', 'Female'], ['All persons', 'Males', 'Females'])
    
    
    # Changing DATE column to Year and only taking the year from the column values
    occupation_values['End_Year'] = occupation_values['DATE'].str[:4]
    occupation_values['Year'] =  (occupation_values['End_Year'].astype(int) - 1).astype(str) + "/" + occupation_values['End_Year']
    
    occupation_values.drop(['DATE', 'DATE_NAME'], inplace=True, axis=1, errors='ignore')
    
    # occupation_values.dtypes 
    # annual_pop_estimates.dtypes 
        
    occupation_values['End_Year'] = occupation_values['End_Year'].astype(np.int64)
    occupation_values['Sex'] = occupation_values['Sex'].astype(str)
    annual_pop_estimates['Sex'] = annual_pop_estimates['Sex'].astype(str)
    
    
    # occupation_values = occupation_values[['Year', 'Sex', ]]
    
    ##############
    # Merging based upon Year ans sex, which allows annual population to link up with corresponding Number of health professionals value to allow for calculation
    merged = occupation_values.merge(annual_pop_estimates, left_on = ['End_Year', 'Sex'], right_on = ['Year', 'Sex'])
    
    # Calculation of (Number of health professionals / Population)*10000
    
    merged['Calculated_value'] = (merged['Value']/merged['OBS_VALUE'])*10000
    
    # Dropping Nan rows from Calculated_value
    merged = merged[merged.Calculated_value.apply(lambda x: not np.isnan(x))]
    
    cleaned_data = merged.drop(['MEASURES_NAME', 'Value', 'OBS_VALUE', 'End_Year', 'Year_x'], axis = 1)
    cleaned_data = cleaned_data.rename(index= str, columns= {'Calculated_value': 'Value',
                                                         'Occupation_minor_group':'Occupation minor group',
                                                         'Occupation_unit_group': 'Occupation unit group',
                                                         'Year_y': 'Year'})
    
    # add in columns to match existing data
    cleaned_data.loc[:,'Observation status'] = "Undefined"
    cleaned_data.loc[:,'Unit multiplier'] = "Units"
    cleaned_data.loc[:,'Unit measure'] = "Rate per 10,000 population"
    
    cleaned_data = cleaned_data[['Year', 'Sex', 'Occupation minor group', 'Occupation unit group', 'Unit measure',
                                 'Observation status', 'Unit multiplier', 'Value']]
    
    # Change to whatever drive you have Jemalex on
    os.chdir("Output")
    cleaned_data.to_csv("3.c.1.csv", index = False)
    os.chdir("../..")
    
    
