# -*- coding: utf-8 -*-
"""
Created on Wed Jun 16 18:11:15 2021

@author: woode
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




def check_download_filepath():
    
    # search for csv files in the same format as the time series, which will
    # break the download
    for name in glob.glob(config.download_path+'series-??????.csv'):
        if path.exists(name):
            response = ctypes.windll.user32.MessageBoxW(0, 
                                                        "The file " + name + " already exists in " + config.download_path + ". Delete file?",
                                                        "File download warning",
                                                        0x40000)
            if response == 1:
                remove(name)
                print(name+" has been deleted")
            else:
                raise ValueError("No files have been deleted, code aborted")
            return()

def check_output_filepath():
    # create list of other file names that would interrupt the function
    # as well as the download name, any of the names the files will be
    # renamed to will also cause an error
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
                                                    ". Delete files?", 
                                                    "File download warning",
                                                     0x40000)
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
        # sleep for three seconds to allow the file to download
        sleep(3)  
        # get name of the filedownload
        for name in glob.glob(config.download_path + 'series-??????.csv'):
            downloaded_file = name 
            # rename file to food type
            rename(downloaded_file, config.download_path + key + ".csv")   

# function to read the downloaded files and pass the data to two_c_one_indicator
# takes file, a string of the file name (e.g. all_food.csv)
def read_data(file):
 
    # read file
    dataframe = pd.read_csv(config.download_path + file, header=None)            
    return(dataframe)

def get_relevant_data(dataframe):
    # find the index of 1988 JAN, which is the earliest monthly data
    start_index = dataframe.loc[dataframe[0] == "1988 JAN"].index[0]

    # create a new dataframe of rows start_index onwards
    # this relies on the dataframe being ordered and the order being preserved
    monthly_dataframe = dataframe.loc[start_index:,]
    
    # rename columns and reset index
    monthly_dataframe = monthly_dataframe.rename(columns={0: "year", 1: "value"})
    monthly_dataframe = monthly_dataframe.reset_index()
    
    return(monthly_dataframe)


# define function to produce the latest vintage of the indicator
def months_to_numbers(index_df):
    # convert months to numbers - for each year, read in using strptime and print out using strftime
    for i in range(0, len(index_df)):
        index_df.loc[i, 'year'] = dt.datetime.strftime(dt.datetime.strptime(index_df.loc[i, 'year'], '%Y %b' ), '%Y %m')
    return(index_df)

def sort_by_year(index_df):
    sorted_by_year = index_df.sort_values(by = ['year'])
    return(sorted_by_year)

def get_start_year(index_df):
    start_year = int(index_df['year'][0][0:4])
    return(start_year)

def get_growth_rates(index_df): # pretty sure this is not needed here
    
    # reduce down to year & value
    index_df = index_df[['year', 'value']] # do we ever use the index value? If not get rid of it in n earlier function


    
def calculate_growth_rates(index_df, period):
    # add growth rate columns up to len(index_df['value']), which is the CGR of the previous 3 months
    
    if period == "annual":
        months = 12 
        column = "annual_growth_rate"
    if period == "quarterly":
        months = 3
        column = ["quarterly_growth_rate"]
    
    index_df[column] = np.nan
    
    for i in range(0, len(index_df)):
        if i >= months:
            index_df.loc[i, column] =+ (pd.to_numeric(index_df.loc[i, 'value']) / pd.to_numeric(index_df.loc[i - months, 'value']))**(1/months) - 1
            
    return(index_df)


def add_weights_by_year(index_df, start_year):
    # add weight according to year - first year has weight 1, second has 2, etc. calc with numeric(year) - (start year - 1)
    index_df['weight'] = pd.to_numeric(index_df['year'].str[0:4]) - (start_year - 1)
              
    return(index_df)

def calculate_rolling_values():
    
  
def two_c_one_indicator(index_df, start_year):



    
    # create rolling weighted average and weighted standard deviation of quarterly and annual growth rates
    
    # quarterly
    # create column to be filled
    index_df['average_quarterly'] = np.nan
    index_df['quart_w*(x-mu)^two_quart'] = np.nan
    index_df['st_dev_quarterly'] = np.nan

    # create weight*value column
    index_df['quart_weight*value'] = index_df['weight']*index_df['quarterly_growth_rate']

    # weighted mean
    index_df['average_quarterly'] = sum(index_df.loc[3:len(index_df['value']),'quart_weight*value']) / sum(index_df.loc[3:len(index_df['value']),'weight'])
    
    # weighted standard deviation
    index_df['quart_w*(x-mu)^two'] = index_df['weight']*(index_df['quarterly_growth_rate'] - index_df['average_quarterly'])**2
    quart_var_numerator = sum(index_df['quart_w*(x-mu)^two'][3:])
    quart_var_denom = sum(index_df['weight'][3:])*(len(index_df['weight'][3:])-1)/len(index_df['weight'][3:])
    index_df['st_dev_quarterly'] = (quart_var_numerator / quart_var_denom)**0.5
    
    # annual
    index_df['average_annual'] = np.nan
    index_df['annual_w*(x-mu)^two'] = np.nan
    index_df['st_dev_annual'] = np.nan    

    # create weight*value column
    index_df['annual_weight*value'] = index_df['weight']*index_df['annual_growth_rate']

    # weighted mean
    index_df['average_annual'] = sum(index_df.loc[12:len(index_df['value']),'annual_weight*value']) / sum(index_df.loc[12:len(index_df['value']),'weight'])
    
    # weighted standard deviation
    index_df['annual_w*(x-mu)^two'] = index_df['weight']*(index_df['annual_growth_rate'] - index_df['average_annual'])**2
    annual_var_numerator = sum(index_df['annual_w*(x-mu)^two'][12:])
    annual_var_denom = sum(index_df['weight'][12:])*(len(index_df['weight'][12:])-1)/len(index_df['weight'][12:])
    index_df['st_dev_annual'] = (annual_var_numerator / annual_var_denom)**0.5
    
    # create z-scores, calculated (x - mu) / st.dev.
    
    # quarterly
    index_df['z-score_quarterly'] = (index_df['quarterly_growth_rate'] - index_df['average_quarterly']) / index_df['st_dev_quarterly']

    # annual
    index_df['z-score_annual'] = (index_df['annual_growth_rate'] - index_df['average_annual']) / index_df['st_dev_annual']

    # indicator
    index_df['indicator'] = 0.4*index_df['z-score_quarterly'] + 0.6*index_df['z-score_annual']
    
    return(index_df[['year','indicator']])


# coordinatoin function that calls the data functions to download the files, 
# read the files and call the indicator function
def two_c_one_main():
        
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


    # download data
    check_download_filepath()
    check_output_filepath()
    download_data(time_series)
    
    # set file names to pass to the read_data function 
    input_names = [("all_food.csv","all_food"),("bread.csv","bread"),
                   ("meat.csv","meat"),("fish.csv","fish"),
                   ("dairy.csv","dairy"),("oil_fat.csv","oil_fat"),
                   ("fruit.csv","fruit"),("vegetables.csv","vegetables"),
                   ("sugars.csv","sugars"), ("nec.csv","nec")]

    # create empty dictionary to pass indicator dataframes to
    data_dict = {}
    
    # cycle through names
    for name in input_names:
        
        # read in data
        dataframe = read_data(name[0])
        index_df = get_relevant_data(dataframe)
        
        index_df_with_months = months_to_numbers(index_df)
        df_sorted_by_year = sort_by_year(index_df_with_months)
        
        start_year = get_start_year(df_sorted_by_year)


        # perform calculations
        annual_growth_rates = calculate_growth_rates(df_sorted_by_year, "annual")
        quarterly_growth_rates = calculate_growth_rates(annual_growth_rates, "quarterly")
        
        
        
        
        
        indicator = two_c_one_indicator(index_df)
        
        # add to dictionary
        data_dict[name[1]] = indicator
    
    # reformat data_df to sdg csv format

    # create a dataframe for each disaggregation type, including headline data"
    columns = ['Units','Food price index']
    
    # Calculating rolling averages
    df0 =  data_dict['all_food'].copy() # copy added to prevent changing value in original data_dict
    df0["indicator"] = df0["indicator"].rolling(window=12).mean()
    df0.loc[:,'Food price index'] = ''
    df0.loc[:,'Units'] = '12 month rolling average'
    
    df1 = data_dict['bread'].copy()
    df1["indicator"] = df1["indicator"].rolling(window=12).mean()
    df1.loc[:,'Food price index'] = 'Bread and cereal'
    df1.loc[:,'Units'] = '12 month rolling average'
    
    df2 = data_dict['meat'].copy()
    df2["indicator"] = df2["indicator"].rolling(window=12).mean()
    df2.loc[:,'Food price index'] = 'Meat'
    df2.loc[:,'Units'] = '12 month rolling average'
    
    df3 = data_dict['fish'].copy()
    df3["indicator"] = df3["indicator"].rolling(window=12).mean()
    df3.loc[:,'Food price index'] = 'Fish'
    df3.loc[:,'Units'] = '12 month rolling average'
    
    df4 = data_dict['dairy'].copy()
    df4["indicator"] = df4["indicator"].rolling(window=12).mean()
    df4.loc[:,'Food price index'] = 'Dairy and eggs'
    df4.loc[:,'Units'] = '12 month rolling average'
    
    df5 = data_dict['oil_fat'].copy()
    df5["indicator"] = df5["indicator"].rolling(window=12).mean()
    df5.loc[:,'Food price index'] = 'Oils and fats'
    df5.loc[:,'Units'] = '12 month rolling average'
    
    df6 = data_dict['fruit'].copy()
    df6["indicator"] = df6["indicator"].rolling(window=12).mean()
    df6.loc[:,'Food price index'] = 'Fruit'
    df6.loc[:,'Units'] = '12 month rolling average'
    
    df7 = data_dict['vegetables'].copy()
    df7["indicator"] = df7["indicator"].rolling(window=12).mean()
    df7.loc[:,'Food price index'] = 'Vegetables'
    df7.loc[:,'Units'] = '12 month rolling average'
    
    df8 = data_dict['sugars'].copy()
    df8["indicator"] = df8["indicator"].rolling(window=12).mean()
    df8.loc[:,'Food price index'] = 'Sugars'
    df8.loc[:,'Units'] = '12 month rolling average'

    df9 = data_dict['nec'].copy()
    df9["indicator"] = df9["indicator"].rolling(window=12).mean()
    df9.loc[:,'Food price index'] = 'Food not elsewhere classified'
    df9.loc[:,'Units'] = '12 month rolling average'
    
    
    # Calculate unaveraged monthly values
    
    df10 =  data_dict['all_food'].copy()
    df10.loc[:,'Food price index'] = ''
    df10.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df11 = data_dict['bread'].copy()
    df11.loc[:,'Food price index'] = 'Bread and cereal'
    df11.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df12 = data_dict['meat'].copy()
    df12.loc[:,'Food price index'] = 'Meat'
    df12.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df13 = data_dict['fish'].copy()
    df13.loc[:,'Food price index'] = 'Fish'
    df13.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df14 = data_dict['dairy'].copy()
    df14.loc[:,'Food price index'] = 'Dairy and eggs'
    df14.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df15 = data_dict['oil_fat'].copy()
    df15.loc[:,'Food price index'] = 'Oils and fats'
    df15.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df16 = data_dict['fruit'].copy()
    df16.loc[:,'Food price index'] = 'Fruit'
    df16.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df17 = data_dict['vegetables'].copy()
    df17.loc[:,'Food price index'] = 'Vegetables'
    df17.loc[:,'Units'] = 'Unaveraged monthly value'
    
    df18 = data_dict['sugars'].copy()
    df18.loc[:,'Food price index'] = 'Sugars'
    df18.loc[:,'Units'] = 'Unaveraged monthly value'

    df19 = data_dict['nec'].copy()
    df19.loc[:,'Food price index'] = 'Food not elsewhere classified'
    df19.loc[:,'Units'] = 'Unaveraged monthly value'
    
    dfs = [df0, df1, df2, df3, df4, df5, df6, df7, df8, df9,
           df10, df11, df12,df13, df14, df15, df16, df17, df18, df19]
    
    df=pd.concat(dfs, axis=0, ignore_index=True)
    
    df = df.rename(index = str, columns = {'year' : 'Year', 'indicator' : 'Value'})

    # add SDMX columns
    df["Unit measure"] = "Index"
    df["Unit multiplier"] = "Units"
    df["Observation status"] = "Undefined"
    
    
    df=df[["Year", *columns, "Unit measure", "Unit multiplier", "Observation status", "Value"]] # reorder columns

    # write df to csv
    df.to_csv(config.output_filepath, index=False) 

if __name__ == "__main__":
    two_c_one_main()
