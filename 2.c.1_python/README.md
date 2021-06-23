## Update 2-c-1 food price anomalies data
  
`2_c_1.py` pulls UK [consumer price inflation time series data](https://www.ons.gov.uk/economy/inflationandpriceindices) for all the food groups from the ONS website, 
e.g. [all food](https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/d7c8/mm23?referrer=search&searchTerm=d7c8), 
[bread](https://www.ons.gov.uk/economy/inflationandpriceindices/timeseries/l52i/mm23?referrer=search&searchTerm=l52i) etc.   
  
It performs calculations for the food price anomalies index as described in the methodology document 
[Identifying food price anomalies to support the Sustainable Development Goals](https://www.ons.gov.uk/economy/inflationandpriceindices/methodologies/identifyingfoodpriceanomaliestosupportthesustainabledevelopmentgoals).  
  
Finally, the data are formatted to fit the csv requirements of the [UK SDG data website](https://sdgdata.gov.uk/).

### Instructions for updating 2-c-1 data

Every time new data is added to this series, the values for all earlier timepoints will change slightly. 
This is because the values are based on a weighted mean and standard deviation calculated from the *entire* series,
not just the values up to the time point in question. For more information see the methodology document 
[Identifying food price anomalies to support the Sustainable Development Goals](https://www.ons.gov.uk/economy/inflationandpriceindices/methodologies/identifyingfoodpriceanomaliestosupportthesustainabledevelopmentgoals).  
   
The script should only take a minute or so to run.  
     
1) Save `example_config.py` as `config.py` and edit the configurations for your system.   
**Data team:** the `config.py` file with the required settings already exists in Jemalex, so you can skip this step.
2) Run `2_c_1.py`. A message will be displayed in the console when the csv file has been completed and saved. 
Please note that a message box may appear when data are being downloaded. This may appear behind other windows on your desktop, 
so if the download process does not occur (your browser will open and you will see the downloads appearing), 
or the script is taking longer than a couple of minutes to run, please check for this message box.
3) **Data team:** Copy the csv into the Indicator file and proceed with the update as usual.
