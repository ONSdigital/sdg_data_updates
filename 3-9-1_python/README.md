## Initial Author: Varun Jakki


--------------------
# Overview

This Python code is used to update indicator 3.9.1 (Mortality rate attributed to household and ambient air pollution). 

The source is Fingertips (https://fingertipsws.phe.org.uk/api/all_data/csv/by_indicator_id?v=0-c87ce5b7/&parent_area_code=E92000001&parent_area_type_id=6&child_area_type_id=102&indicator_ids=30101&category_area_code=null&sex_id=4&age_id=230).

The link used for this indicator is an API link from fingertips.

The output of the code is a CSV that saves in the same folder as the code (Still working on saving to output folder within code folder)

- The code will automatically remove any files you have that are named the same as what the file form fingertips is going to be downloaded as. (indicators-CountyUApre419.data.csv)

