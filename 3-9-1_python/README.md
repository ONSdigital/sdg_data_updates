## Initial Author: Varun Jakki


--------------------
# Overview

This Python code is used to update indicator 3.9.1 (Mortality rate attributed to household and ambient air pollution). 

The source is Fingertips (https://fingertipsws.phe.org.uk/api/all_data/csv/by_indicator_id?v=0-c87ce5b7/&parent_area_code=E92000001&parent_area_type_id=6&child_area_type_id=102&indicator_ids=30101&category_area_code=null&sex_id=4&age_id=230).

This link has been produced from the fingertips website, from this page: 
https://fingertips.phe.org.uk/search/air%20pollution#page/9/gid/1/pat/6/par/E12000001/ati/102/are/E06000047/iid/30101/age/230/sex/4/cid/4/tbm/1

- The script downloads the "Data for Upper tier local authorities (pre 4/19)" under the "Indicator: Fraction of mortality attributable to particulate air pollution" on the above link

Currently the API link has only been tested for a single year (2021). It is possible that the API link can change, you will notice it has changes if no new data comes through on the CSV or the code is not able to call the link. What should be done in this case is to manually go through the steps above from the link (https://fingertips.phe.org.uk/search/air%20pollution#page/9/gid/1/pat/6/par/E12000001/ati/102/are/E06000047/iid/30101/age/230/sex/4/cid/4/tbm/1), then under "Indicator: Fraction of mortality attributable to particulate air pollution" press "Data for Upper tier local authorities (pre 4/19)" and copy the link that flashes in the URL bar before that file starts to download. That link is the new API ink, you should then take this link and replace it in the code where you can see the variable "fingertips_api_link" on line 23.


The output of the code is a CSV that saves in the same folder as the code (Still working on saving to output folder within code folder).
The code also produces a 3.9.1_NA_Values CSV, the user should check this for where values have been made NA (Suprressed) so they are not suprised when there are certain values missing for certain years (e.g. Isle of Scilly - 2011).



- The code will check to remove any files you have that are named the same as what the file form fingertips is going to be downloaded as, a pop up box will appear MAKE SURE TO CHECK BEHIND THE PYTHON CONSOLE and SECOND SCREEN to see the pop up to respond to it.

