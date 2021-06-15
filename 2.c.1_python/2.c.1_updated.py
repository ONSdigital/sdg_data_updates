# -*- coding: utf-8 -*-
"""
Created on Fri Oct  2 10:28:41 2020

2.c.1 code

These are functions that calculate the food price anomalies time series:
    - download_data (downloads and renames csv files from the ONS site)
    - read_data (reads the csv file passed to it)
    - two_c_one_indicator (performs the calculations on the monthly time series
                           passed to it)
    - two_c_one_main (produces an upload-ready single file, 2_c_1.csv, in
                      downloads using all of the above functions)

@author: Ben Hillman
"""

# imports
import webbrowser # used to open the ONS site to download csv files
from os import path, rename, remove # to interact with files 
from time import sleep # use to allow time for the file to download before continuing
import datetime as dt # to get date
import pandas as pd # pandas for dataframe manipulation
import numpy as np # for calculations
import ctypes  # for the pop-up notification box
import glob # for finding strings of a given pattern
import config
# function to open each of the input data csv files on the ONS site
# be aware that as they these are pointed at csv files, so the browser will
# download them directly on reaching the page 
download_path = config.download_path

def download_data():
    
    # get download filepath:
    
    # search for csv files in the same format as the time series, which will
    # break the download
    for name in glob.glob(download_path+'series-??????.csv'):
        if path.exists(name):
            response = ctypes.windll.user32.MessageBoxW(0, "The file "+name+" already exists in "+download_path+". Delete file?", "File download warning", 1)
            if response == 1:
                remove(name)
                print(name+" has been deleted")
            else:
                raise ValueError("No files have been deleted, code aborted")
            return()

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
        if path.exists(download_path+name):
            file_flag=1
    
    # if files exist, check with user whether to delete
    if file_flag == 1:
        response = ctypes.windll.user32.MessageBoxW(0, "Files already exist in "+download_path+". Delete files?", "File download warning", 1)
        if response == 1:
            for name in names:
                try:
                    remove(download_path+name)
                    print(download_path+name+" has been deleted")
                except FileNotFoundError:
                    pass
        else:
            raise ValueError("No files have been deleted, code aborted")
            
            """
            response = ctypes.windll.user32.MessageBoxW(0, "The file "+name+" already exists in "+download_path+". Delete file?", "File download warning", 1)
            if response == 1:
                remove(download_path+name)
                print(download_path+name+" has been deleted")
            else:
                raise ValueError("No files have been deleted, code aborted")
            return()
            """
        
    # all food - d7c8
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/d7c8/mm23",new=0)    
    # sleep for three seconds to allow the file to download
    sleep(3) 
    
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to all_food
    rename(downloaded_file,download_path+"all_food.csv")

    # bread - l52i
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52i/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to bread
    rename(downloaded_file,download_path+"bread.csv")
    
    # meat - l52j
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52j/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to meat
    rename(downloaded_file,download_path+"meat.csv")
    
    # fish - l52k
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52k/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to fish
    rename(downloaded_file,download_path+"fish.csv")

    # milk, cheese & eggs - l52l
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52l/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to dairy
    rename(downloaded_file,download_path+"dairy.csv")

    # oil & fats - l52m
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52m/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to oil_fat
    rename(downloaded_file,download_path+"oil_fat.csv")

    # fruit - l52n
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52n/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to fruit
    rename(downloaded_file,download_path+"fruit.csv")

    # vegetables - l52o
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52o/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to vegetables
    rename(downloaded_file,download_path+"vegetables.csv")
    
    # sugars - l52p
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52p/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to sugars
    rename(downloaded_file,download_path+"sugars.csv")    

    # nec - l52q
    webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/l52q/mm23",new=0)
    # sleep for three seconds to allow the file to download
    sleep(3)  
    # get name of the filedownload
    for name in glob.glob(download_path+'series-??????.csv'):
        downloaded_file = name 
    # rename file to nec
    rename(downloaded_file,download_path+"nec.csv")   


# function to read the downloaded files and pass the data to two_c_one_indicator
# takes file, a string of the file name (e.g. all_food.csv)
def read_data(file):
 
    
    # read file
    dataframe = pd.read_csv(download_path+file, header=None)            

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
def two_c_one_indicator(index_df):
    
    # convert months to numbers - for each year, read in using strptime and print out using strftime
    for i in range(0,len(index_df)):
    
        index_df.loc[i,'year'] = dt.datetime.strftime( dt.datetime.strptime( index_df.loc[i,'year'] ,'%Y %b' ) ,'%Y %m')
    
    # sort by year
    index_df = index_df.sort_values(by=['year'])
    
    # derive start year - sort by year column then take year value of first year
    start_year = int(index_df['year'][0][0:4])
    
    # reduce down to year & value
    index_df = index_df[['year','value']]

    # add quarterly growth rate column up to len(index_df['value']), which is the CGR of the previous 3 months
    index_df['quarterly_growth_rate'] = np.nan
    index_df['annual_growth_rate'] = np.nan


    for i in range(0, len(index_df)):
        
        if i > 2:
        
            index_df.loc[i,'quarterly_growth_rate'] = + ( pd.to_numeric(index_df.loc[i,'value']) / pd.to_numeric(index_df.loc[i-3,'value']) )**(1/3) - 1

    # same for annual

    for i in range(0, len(index_df['value'])):
        
        if i > 11:
        
            index_df.loc[i, 'annual_growth_rate'] = + ( pd.to_numeric(index_df.loc[i,'value']) / pd.to_numeric(index_df.loc[i-12,'value']) )**(1/12) - 1

    # add weight according to year - first year has weight 1, second has 2, etc. calc with numeric(year) - (start year - 1)
    index_df['weight'] = pd.to_numeric(index_df['year'].str[0:4]) - (start_year - 1)
    
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
    
    # download data
    download_data()
    
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
        index_df = read_data(name[0])

        # perform calculations
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
