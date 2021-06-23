# -*- coding: utf-8 -*-
"""
Created on Wed Jun 16 18:11:15 2021

@author: Emma Wood after Ben Hillman
"""
import glob # for finding strings of a given pattern
from os import path, rename, remove # to interact with files 
import ctypes  # for the pop-up notification box
import webbrowser # used to open the ONS site to download csv files
from time import sleep # use to allow time for the file to download before continuing
import pandas as pd # pandas for dataframe manipulation
import numpy as np # for calculations
import datetime as dt # to get date

import config

def create_2_c_1_csv():
    get_data()
    data_dict = compile_data_for_all_food_types()
    csv_data = get_final_values_for_csv(data_dict)
    csv = finalise_csv_columns(csv_data)
    
    csv.to_csv(config.output_filepath, index=False) 
    print("Complete: csv data have been saved to " + config.output_filepath )
    
###---------------------------------------------------------------------------

def get_data():
    time_series = {
        "all_food": "d7c8",
        "bread": "l52i",
        "meat": "l52j",
        "fish": "l52k",
        "dairy": "l52l",
        "oil_fat": "l52m",
        "fruit": "l52n",
        "vegetables": "l52o",
        "sugars": "l52p",
        "nec": "l52q"
        }
    
    print("""During the download process a message window may appear behind other windows. 
          If downloads stop early or do not seem to be happening please check for a message window""")
    check_download_filepath()
    check_output_filepath()
    download_data(time_series)

def check_download_filepath():
    # if files with the same naming convention as the files we want to use
    # already exist in the download filepath location, 
    # the new downloads may be given an unexpected name (eg ending in '(1)')
    # and the indicator data will be created from the old downloads. 
    # We therefore need to delete the old files, but we check with the user first that this is ok.
    for name in glob.glob(config.download_path+'series-??????.csv'):
        if path.exists(name):
            response = ctypes.windll.user32.MessageBoxW(0, 
                                                        "The file " + name + " already exists in " + config.download_path + ". Delete file? If you do not want to delete files, please click cancel. Closing the dialogue box will prompt file deletion.",
                                                        "File download warning",
                                                        1)
            if response == 1:
                remove(name)
                print(name+" has been deleted")
            else:
                raise ValueError("No files have been deleted, code aborted")
            return()

def check_output_filepath():
    # if these files already exist in the download filepath location, 
    # the new downloads will be given an unexpected name (eg ending in '(1)')
    # and the indicator data will be created from the old downloads. 
    # We therefore need to delete the old files, but we check with the user first that this is ok.
    names = ["all_food.csv","bread.csv","meat.csv","fish.csv",
             "dairy.csv","oil_fat.csv","fruit.csv","vegetables.csv","sugars.csv",
             "nec.csv"]
    
    # set a flag to check if listed files already exist in Downloads
    file_flag = 0
    # check whether there are already 2.c.1 files there
    for name in names:
        if path.exists(config.download_path+name):
            file_flag = 1
    
    # if files exist, check with user whether to delete
    if file_flag == 1:
        response = ctypes.windll.user32.MessageBoxW(0, "Files already exist in "+ 
                                                    config.download_path + 
                                                    ". Delete files? If you do not want to delete files, please click cancel. Closing the dialogue box will prompt file deletion.", 
                                                    "File download warning",
                                                     1)
        if response == 1:
            for name in names:
                try:
                    remove(config.download_path+name)
                    print(config.download_path + name + " has been deleted")
                except FileNotFoundError:
                    pass
        else:
            raise ValueError("No files have been deleted, code aborted")
            

def download_data(time_series):
    for key in time_series:
        webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/" + time_series[key] + "/mm23", new=0)
        sleep(config.sleep_time)  # leaves time to allow the file to download 
        
        for name in glob.glob(config.download_path + 'series-??????.csv'):
            downloaded_file = name 
            # rename file to food type as the original names are not informative
            rename(downloaded_file, config.download_path + key + ".csv")   

###----------------------------------------------------------------------------

def compile_data_for_all_food_types():
    input_names = [("all_food.csv","all_food"),("bread.csv","bread"),
               ("meat.csv","meat"),("fish.csv","fish"),
               ("dairy.csv","dairy"),("oil_fat.csv","oil_fat"),
               ("fruit.csv","fruit"),("vegetables.csv","vegetables"),
               ("sugars.csv","sugars"), ("nec.csv","nec")]
    
    data_dict = {}
    
    for name in input_names:
        dataframe = read_data(name[0])
        index_df = get_relevant_data(dataframe)
        
        index_df_with_months = convert_months_to_numbers(index_df)
        
        df_sorted_by_year = sort_by_year(index_df_with_months)
        
        start_year = get_start_year(df_sorted_by_year)
        
        indicator = calculate_indicator(df_sorted_by_year, start_year)
        
        data_dict[name[1]] = indicator
        
    return(data_dict)


def read_data(file):
    dataframe = pd.read_csv(config.download_path + file, header=None)            
    return(dataframe)

def get_relevant_data(dataframe):
    start_index = dataframe.loc[dataframe[0] == config.earliest_available_data].index[0]

    # this relies on the dataframe being ordered and the order being preserved
    monthly_dataframe = dataframe.loc[start_index:, ]
    
    monthly_dataframe = monthly_dataframe.rename(columns={0: "year", 1: "value"})
    monthly_dataframe = monthly_dataframe.reset_index()
    
    return(monthly_dataframe)
    
# define function to produce the latest vintage of the indicator
def convert_months_to_numbers(index_df):
    for i in range(0, len(index_df)):
        index_df.loc[i, 'year'] = dt.datetime.strftime(dt.datetime.strptime(index_df.loc[i, 'year'], '%Y %b' ), '%Y %m')
    return(index_df)

def sort_by_year(index_df):
    sorted_by_year = index_df.sort_values(by = ['year'])
    return(sorted_by_year)

def get_start_year(index_df):
    start_year = int(index_df['year'][0][0:4])
    return(start_year)

#-----------------------
def calculate_indicator(df, start_year):
    # z-scores are based on a single weighted mean and a single weighted standard deviation
    # so that it is easier to compare between years (rather than calculating each up to each timepoint).
    # Therefore, each time the indicator is updated, values for past years will change slighlty.

    annual_lookup = {
        "growth_rate": "annual_growth_rate",
        "weighted_growth_rate": "annual_weighted_growth_rate",
        "deviation_numerator_by_row": "annual_deviation_numerator_by_row",
        "months": 12,
        "z-score": "z-score_annual"}
    quarterly_lookup = {
        "growth_rate": "quarterly_growth_rate",
        "weighted_growth_rate": "quarterly_weighted_growth_rate",
        "deviation_numerator_by_row": "quart_deviation_numerator_by_row",
        "months": 3,
        "z-score": "z-score_quarterly"}
      
    annual_growth_rates = calculate_growth_rates(df, annual_lookup)
    quarterly_growth_rates = calculate_growth_rates(annual_growth_rates, quarterly_lookup)
    
    weights_by_year = add_weights_by_year(quarterly_growth_rates, start_year)
    annual_weighted_growth_rates = calculate_weighted_growth_rates(weights_by_year, annual_lookup)
    all_weighted_growth_rates = calculate_weighted_growth_rates(annual_weighted_growth_rates, quarterly_lookup)
    
    annual_weighted_mean =  calculate_weighted_mean(all_weighted_growth_rates, annual_lookup)
    quarterly_weighted_mean = calculate_weighted_mean(all_weighted_growth_rates, quarterly_lookup)
    
    annual_weighted_standard_deviation = calculate_weighted_standard_deviation(all_weighted_growth_rates, annual_lookup, annual_weighted_mean)
    quarterly_weighted_standard_deviation = calculate_weighted_standard_deviation(all_weighted_growth_rates, quarterly_lookup, quarterly_weighted_mean)
    
    annual_z_scores = calculate_z_scores(all_weighted_growth_rates, annual_lookup, annual_weighted_mean, annual_weighted_standard_deviation)
    all_z_scores = calculate_z_scores(annual_z_scores, quarterly_lookup, quarterly_weighted_mean, quarterly_weighted_standard_deviation)
    
    indicator = calculate_indicator_z_scores(all_z_scores)
    
    return(indicator)


def calculate_growth_rates(index_df, lookup):
    index_df[lookup["growth_rate"]] = np.nan
    
    for i in range(0, len(index_df)):
        if i >= lookup["months"]:
            index_df.loc[i, lookup["growth_rate"]] =+ (pd.to_numeric(index_df.loc[i, 'value']) / pd.to_numeric(index_df.loc[i - lookup["months"], 'value']))**(1/lookup["months"]) - 1
            
    return(index_df)

def add_weights_by_year(index_df, start_year):
    # weight increases with year, as more recent years are more important - first year has weight 1, second has 2, etc. 
    index_df['weight'] = pd.to_numeric(index_df['year'].str[0:4]) - (start_year - 1)
    return(index_df)

def calculate_weighted_growth_rates(index_df, lookup):
    index_df[lookup["weighted_growth_rate"]] = np.nan
    index_df[lookup["weighted_growth_rate"]] = index_df['weight']*index_df[lookup["growth_rate"]]
    return(index_df)

def calculate_weighted_mean(index_df, lookup):
    weighted_mean = sum(index_df.loc[lookup["months"]:len(index_df['value']), lookup["weighted_growth_rate"]]) / sum(index_df.loc[lookup["months"]:len(index_df['value']), 'weight'])   
    return(weighted_mean)

def calculate_weighted_standard_deviation(index_df, lookup, weighted_mean):
    index_df[lookup["deviation_numerator_by_row"]] = index_df['weight'] * (index_df[lookup["growth_rate"]] - weighted_mean)**2 
    numerator = sum(index_df[lookup["deviation_numerator_by_row"]][lookup["months"]:])
    denominator = (sum(index_df['weight'][lookup["months"]:])*(len(index_df['weight'][lookup["months"]:]) - 1)/
                   len(index_df['weight'][lookup["months"]:]))
    standard_deviation = (numerator / denominator)**0.5
    return(standard_deviation)

def calculate_z_scores(index_df, lookup, weighted_mean, weighted_standard_deviation):
    index_df[lookup["z-score"]] = (index_df[lookup["growth_rate"]] - weighted_mean) / weighted_standard_deviation
    return(index_df)

def calculate_indicator_z_scores(index_df):
    index_df['indicator'] = 0.4*index_df['z-score_quarterly'] + 0.6*index_df['z-score_annual']
    return(index_df[['year','indicator']])

###----------------------------------------------------------------------------

def get_final_values_for_csv(data_dict):
    indicator_groups = {
        "all_food": "",
        "bread": "Bread and cereal",
        "meat": "Meat",
        "fish": "Fish",
        "dairy": "Dairy and eggs",
        "oil_fat": "Oils and fats",
        "fruit": "Fruit",
        "vegetables": "Vegetables",
        "sugars": "Sugars",
        "nec": "Food not elsewhere classified"}
    
    rolling_averages = calculate_rolling_averages(data_dict, indicator_groups)
    unaveraged_monthly_values = calculate_unaveraged_monthly_values(data_dict, indicator_groups)
    
    csv_data = unaveraged_monthly_values.append(rolling_averages)
    
    return(csv_data)

def calculate_rolling_averages(data_dict, indicator_groups):    
    csv_rolling_averages_dict = {}
    
    for key in data_dict:
        csv_data = data_dict[key].copy()
        csv_data["indicator"] = csv_data["indicator"].rolling(window=12).mean()
        csv_data.loc[:,'Food price index'] = indicator_groups[key]
        csv_data.loc[:,'Units'] = '12 month rolling average'
        csv_rolling_averages_dict[key] = csv_data
        
    csv_rolling_averages = pd.concat(csv_rolling_averages_dict.values(), ignore_index=True)
    return(csv_rolling_averages)

def calculate_unaveraged_monthly_values(data_dict, indicator_groups):
    csv_monthly_values_dict = {}
    
    for key in data_dict:
        csv_data = data_dict[key].copy()
        csv_data.loc[:,'Food price index'] = indicator_groups[key]
        csv_data.loc[:,'Units'] = 'Unaveraged monthly value'
        csv_monthly_values_dict[key] = csv_data
        
    csv_monthly_values = pd.concat(csv_monthly_values_dict.values(), ignore_index=True)
    return(csv_monthly_values)

def finalise_csv_columns(csv_data):
    csv_data = csv_data.rename(index = str, columns = {'year' : 'Year', 'indicator' : 'Value'})
        
    csv_data["Unit measure"] = "Index"
    csv_data["Unit multiplier"] = "Units"
    csv_data["Observation status"] = "Undefined"
    
    csv_data = csv_data[["Year", 'Units', 'Food price index', "Unit measure", "Unit multiplier", "Observation status", "Value"]] 
    
    return(csv_data)    
    
###############################################################################

if __name__ == "__main__":
    create_2_c_1_csv()
