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
    """
    Creates the csv required for upating SDG indicator 2-c-1 (Food price 
    anomalies).
    This is a high level function - see documentation for lower level functions 
    further dow the script for details.
    
    Requires
    -------
    Requires a config.py file containing:
        - download_path: where files from ONS will be downloaded
        - output_filepath: where csv file will be saved
        - sleep_time: allows time between downloads (3 should be 
        sufficient for most computers)
        - earliest_available_data: the earliest date available as written in 
        the source data (string)
    
    Returns
    -------
    saves a csv file to the output_filepath defined in config.py
    may return a message box if certain files already exist in the
    download location
    returns a message in the console when complete

    Examples
    --------
    >>> create_2_c_1_csv()

    """
    get_data()
    data_dict = compile_data_for_all_food_types()
    csv_data = get_final_values_for_csv(data_dict)
    csv = finalise_csv_columns(csv_data)
    
    csv.to_csv(config.output_filepath, index=False) 
    print("Complete: csv data have been saved to " + config.output_filepath )
    
###---------------------------------------------------------------------------

def get_data():
    """
    Checks that data can be downloaded and downloads it to config.download_path

    Raises
    ------
    Message box
        if files to be downloaded, or files with the names we use already exist

    """
    print("""During the download process a message window may appear behind other windows. 
          If downloads stop early or do not seem to be happening please check for a message window""")
    check_download_filepath()
    check_output_filepath()
    download_data()

def check_download_filepath():
    """
    Checks whether there are any files in the download location that look like 
    the file that we want to download. If they do, they are deleted following
    user interaction.
    
    Details
    -------
    If files with the same naming convention as the files we want to use
    already exist in the download filepath location, 
    the new downloads may be given an unexpected name (eg ending in '(1)')
    and the indicator data will be created from the old downloads. 
    We therefore need to delete the old files, but we check with the user first
    that this is ok.

    Raises
    ------
    Message box
        if files to be downloaded already exist
 
    """
    for name in glob.glob(config.download_path+'series-*.csv'):
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
    """
    Checks whether there are any files in the download location with the names
    of the files we will be using.

    Details
    ----------
    # if these files already exist in the download filepath location, 
    # the new downloads will be given an unexpected name (eg ending in '(1)')
    # and the indicator data will be created from the old downloads. 
    # We therefore need to delete the old files, but we check with the user 
    first that this is ok.

    Raises
    ------
    Message box
        if files with the names we want our downloaded files to have already
        exist

    """
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
            

def download_data():
    """
    Downloads data from the ONS for each of the series listed in time_series.

    """
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
        
    for key in time_series:
        webbrowser.open("https://www.ons.gov.uk/generator?format=csv&uri=/economy/inflationandpriceindices/timeseries/" + time_series[key] + "/mm23", new=0)
        sleep(config.sleep_time)  # leaves time to allow the file to download 
        
        for name in glob.glob(config.download_path + 'series-??????.csv'):
            downloaded_file = name 
            # rename file to food type as the original names are not informative
            rename(downloaded_file, config.download_path + key + ".csv")   

###----------------------------------------------------------------------------

def compile_data_for_all_food_types():
    """
    Takes the CPIH Index data for each food group and calculates the indicator
    data required.

    Returns
    -------
    dictionary 
        each key is a food type

    """
    input_names = [("all_food.csv","all_food"),("bread.csv","bread"),
               ("meat.csv","meat"),("fish.csv","fish"),
               ("dairy.csv","dairy"),("oil_fat.csv","oil_fat"),
               ("fruit.csv","fruit"),("vegetables.csv","vegetables"),
               ("sugars.csv","sugars"), ("nec.csv","nec")]
    
    data_dict = {}
    
    for name in input_names:
        dataframe = pd.read_csv(config.download_path + name[0], header=None)  
        index_df = get_relevant_data(dataframe)
        
        index_df_with_months = convert_months_to_numbers(index_df)
        
        df_sorted_by_year = index_df_with_months.sort_values(by = ['year'])
        
        start_year = int(df_sorted_by_year['year'][0][0:4])
        
        indicator = calculate_indicator(df_sorted_by_year, start_year)
        
        data_dict[name[1]] = indicator
        
    return(data_dict)

def get_relevant_data(dataframe):
    """
    Selects the required data from the dataframe. Removes information such as
    important notes, CDID, release date etc.

    Parameters
    ----------
    dataframe : dataframe
        contains the CPIH data for one food group.
    
    Requires
    --------
    config.earliest_available_data: the earliest date available as written in 
        the source data (string)

    Returns
    -------
    dataframe
        CPIH data for one food group.

    """
    start_index = dataframe.loc[dataframe[0] == config.earliest_available_data].index[0]

    # this relies on the dataframe being ordered and the order being preserved
    monthly_dataframe = dataframe.loc[start_index:, ]
    
    monthly_dataframe = monthly_dataframe.rename(columns={0: "year", 1: "value"})
    monthly_dataframe = monthly_dataframe.reset_index()
    
    return(monthly_dataframe)
    
# define function to produce the latest vintage of the indicator
def convert_months_to_numbers(dataframe):
    """
    Converts months to numbers (e.g. 'JAN' to 01)

    Parameters
    ----------
    dataframe : dataframe
        The CPIH data for one food group.

    Returns
    -------
    dataframe : dataframe
        The CPIH data for one food group with months as numbers.

    """
    for i in range(0, len(dataframe)):
        dataframe.loc[i, 'year'] = dt.datetime.strftime(dt.datetime.strptime(dataframe.loc[i, 'year'], '%Y %b' ), '%Y %m')
    return(dataframe)

#-----------------------
def calculate_indicator(df, start_year):
    """
    Calculates the indicator value for each quater and year.
    
    Details
    -------
    Z-scores are based on a single weighted mean and a single weighted standard
    deviation so that it is easier to compare between years (rather than 
    calculating each up to each timepoint). Therefore, each time the indicator 
    is updated, values for past years will change slighlty.

    Parameters
    ----------
    df : dataframe
        CPIH data for one indicator, sorted by date
        
    start_year : int or float
        The first year found in the source data

    Returns
    -------
    dataframe
        CPIH data for one indicator, sorted by date, with indicator value as a 
        new column

    """
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
    
    year_count = add_year_count(quarterly_growth_rates, start_year)
    annual_weighted_growth_rates = calculate_weighted_growth_rates(year_count, annual_lookup)
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
    """
    Calculates growth rates

    Parameters
    ----------
    index_df : dataframe
        CPIH data for one indicator, sorted by date
    lookup : dictionary
        Column names and numbers specific to the index_data and data being
        caluclated for:
            growth_rate: column for growth rates 
            months: 3 for quarterly, 12 for annual

    Returns
    -------
   dataframe
        CPIH data for one indicator, sorted by date, including growth rate 
        column

    """
    index_df[lookup["growth_rate"]] = np.nan
    
    for i in range(0, len(index_df)):
        if i >= lookup["months"]:
            index_df.loc[i, lookup["growth_rate"]] =+ (pd.to_numeric(index_df.loc[i, 'value']) / pd.to_numeric(index_df.loc[i - lookup["months"], 'value']))**(1/lookup["months"]) - 1
            
    return(index_df)

def add_year_count(index_df, start_year):
    """
    In older version of code was add_weights_by_year
    Adds a column giving the sum of the years up to that point. It isn't clear
    to me whether year count for the quarters should start before the annuals 
    (as some quarterly growth rates can be calculated during the first year in 
    the dataset). For now we use the same year 1 for both quarterly and annual
    data as both are required to calculate the final value.
    
    Details
    -------
    Weight increases with year. We class the first year as the 
    first year for which we can calculate growth rates, which is the second 
    year in the dataframe.

    Parameters
    ----------
    index_df : dataframe
        CPIH data for one indicator, containing growth rates.
    start_year : int
        first year of available data.

    Returns
    -------
   dataframe
        CPIH data for one indicator including weight column

    """
    index_df['sum_years'] = pd.to_numeric(index_df['year'].str[0:4]) - start_year
    return(index_df)

def calculate_weighted_growth_rates(index_df, lookup):
    """
    Calculates weighted growth rates

    Parameters
    ----------
    index_df : dataframe
        CPIH data for one indicator containing growth rates and year weights
    lookup : dictionary
        Column names specific to the index_data and data being caluclated:
            growth_rate: column for growth rates 
            weighted_growth_rate: column for weighted growth rates 
     
    Returns
    -------
   dataframe
        CPIH data for one indicator, sorted by date, including weighted growth 
        rate column.

    """
    index_df[lookup["weighted_growth_rate"]] = np.nan
    index_df[lookup["weighted_growth_rate"]] = index_df['weight']*index_df[lookup["growth_rate"]]
    return(index_df)

def calculate_weighted_mean(index_df, lookup):
    """
    Calculates weighted mean
    Need to edit this so that it is the weighted mean up to each year, done 
    separately for each month. (I think)

    Parameters
    ----------
   dataframe
        CPIH data for one indicator, sorted by date, including weighted growth 
        rate column.
    lookup : dictionary
        Column names and numbers specific to the index_data and data being
        caluclated for:
            weighted_growth_rate: column for weighted growth rates 
            months: 3 for quarterly, 12 for annual

    Returns
    -------
    float 
    
    """
    #index_df['annual_weight']
    # index_df['quarterly_weight']
    weighted_mean = sum(index_df.loc[lookup["months"]:len(index_df['value']), lookup["weighted_growth_rate"]]) / sum(index_df.loc[lookup["months"]:len(index_df['value']), 'weight'])   
    return(weighted_mean)

def calculate_weighted_standard_deviation(index_df, lookup, weighted_mean):
    """
    Calculates weighted standard deviation

    Parameters
    ----------
   dataframe
        CPIH data for one indicator, sorted by date, including growth 
        rate column.
    lookup : dictionary
        Column names and numbers specific to the index_data and data being
        caluclated for:
            growth_rate: column for growth rates 
            deviation_numerator_by_row: column to hold the calculation 
                w*(x-mu)^two
            months: 3 for quarterly, 12 for annual

    Returns
    -------
    float 

    """
    index_df[lookup["deviation_numerator_by_row"]] = index_df['weight'] * (index_df[lookup["growth_rate"]] - weighted_mean)**2 
    numerator = sum(index_df[lookup["deviation_numerator_by_row"]][lookup["months"]:])
    denominator = (sum(index_df['weight'][lookup["months"]:])*(len(index_df['weight'][lookup["months"]:]) - 1)/
                   len(index_df['weight'][lookup["months"]:]))
    standard_deviation = (numerator / denominator)**0.5
    return(standard_deviation)

def calculate_z_scores(index_df, lookup, weighted_mean, weighted_standard_deviation):
    """
    Calculates z-scores for each quarter or year

    Parameters
    ----------
    index_df : dataframe
        CPIH data for one indicator, sorted by date
    lookup : dictionary
        Column names and numbers specific to the index_data and data being
        caluclated for:
            growth_rate: column for growth rates 
            z-score: column to hold z-scores 
    weighted_mean : float
    weighted_standard_deviation : float    

    Returns
    -------
    dataframe
        CPIH data for one indicator, with column for z-scores

    """
    index_df[lookup["z-score"]] = (index_df[lookup["growth_rate"]] - weighted_mean) / weighted_standard_deviation
    return(index_df)

def calculate_indicator_z_scores(index_df):
    """
    Calculates indicator specific z-scores, which take into account both 
    quarterly and yearly changes.

    Parameters
    ----------
    index_df : dataframe
        CPIH data for one indicator containing columns 'z-score_quarterly' and 
        'z-score_annual', both of which contain floats

    Returns
    -------
    dataframe
        CPIH data for one indicator, with column for indicator z-scores
    """

    index_df['indicator'] = 0.4*index_df['z-score_quarterly'] + 0.6*index_df['z-score_annual']
    return(index_df[['year','indicator']])

###----------------------------------------------------------------------------

def get_final_values_for_csv(data_dict):
    """
    Add rolling averages and unaveraged monthly valuse to dataframe.

    Parameters
    ----------
    data_dict : dictionary of dataframes
        Each key is a different food group

    Returns
    -------
    dataframe
        Dataframe containing all required information for the indicator for all
        food groups.

    """
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
    unaveraged_monthly_values = label_unaveraged_monthly_values(data_dict, indicator_groups)
    
    csv_data = unaveraged_monthly_values.append(rolling_averages)
    
    return(csv_data)

def calculate_rolling_averages(data_dict, indicator_groups):   
    """
    Calculates annual rolling averages.

    Parameters
    ----------
     data_dict : dictionary of dataframes
        Each key is a different food group
    indicator_groups : dictionary
        Dictionary containing the names of each food group as they will appear
        in the csv, where the key is the name of that food group as it 
        currently stands in data_dict        

    Returns
    -------
    dataframe
        Dataframe containing annual rolling averages.
        
    """
    csv_rolling_averages_dict = {}
    
    for key in data_dict:
        csv_data = data_dict[key].copy()
        csv_data["indicator"] = csv_data["indicator"].rolling(window=12).mean()
        csv_data.loc[:,'Food price index'] = indicator_groups[key]
        csv_data.loc[:,'Units'] = '12 month rolling average'
        csv_rolling_averages_dict[key] = csv_data
        
    csv_rolling_averages = pd.concat(csv_rolling_averages_dict.values(), ignore_index=True)
    return(csv_rolling_averages)

def label_unaveraged_monthly_values(data_dict, indicator_groups):
    """
    Labels monthly values as monthly values (to distinguish them from rolling
    averages).

    Parameters
    ----------
     data_dict : dictionary of dataframes
        Each key is a different food group
    indicator_groups : dictionary
        Dictionary containing the names of each food group as they will appear
        in the csv, where the key is the name of that food group as it 
        currently stands in data_dict        

    Returns
    -------
    dataframe
        
    """
    csv_monthly_values_dict = {}
    
    for key in data_dict:
        csv_data = data_dict[key].copy()
        csv_data.loc[:,'Food price index'] = indicator_groups[key]
        csv_data.loc[:,'Units'] = 'Unaveraged monthly value'
        csv_monthly_values_dict[key] = csv_data
        
    csv_monthly_values = pd.concat(csv_monthly_values_dict.values(), ignore_index=True)
    return(csv_monthly_values)

def finalise_csv_columns(csv_data):
    """
    Arranges dataframe as it is required to be for indictaor csv file.

    Parameters
    ----------
    csv_data : Dataframe containing all required information for the indicator 
        for all food groups.

    Returns
    -------
    dataframe
        Dataframe as it needs to be for csv.
        
    """
    csv_data = csv_data.rename(index = str, columns = {'year' : 'Year', 'indicator' : 'Value'})
        
    csv_data["Unit measure"] = "Index"
    csv_data["Unit multiplier"] = "Units"
    csv_data["Observation status"] = "Undefined"
    
    csv_data = csv_data[["Year", 'Units', 'Food price index', "Unit measure", "Unit multiplier", "Observation status", "Value"]] 
    
    return(csv_data)    
    
###############################################################################

if __name__ == "__main__":
    create_2_c_1_csv()
