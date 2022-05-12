# configurations for type 4 (Nomis) data
# This is edited for Indicator 3-9-3

# link for data - see the readme
# Nomis link generation instructions should be explained in the README file
#   i.e. which selections to use to generate the link. 

# Note that Age-standardised mortality rate is only available for countries.
  # therefore need raw deaths alongside population data to calculate proportion for regions.

# Here I have only selected raw deaths 

# This link gives data for total
numerator_link_total <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=12440,12443,12444,12446,12447,12449&gender=0&age=0...20&measure=1&measures=20100"

# This link gives data for male
numerator_link_male <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=12440,12443,12444,12446,12447,12449&gender=1&age=0...20&measure=1&measures=20100"

# This link gives data for female
numerator_link_female <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=12440,12443,12444,12446,12447,12449&gender=2&age=0...20&measure=1&measures=20100"


# Population
population_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_31_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&date=latestMINUS7-latest&sex=5...7&age=1...19&measures=20100"




# if annual data are are available up to different months/quarters, we want to 
# make sure we are always using the data up to the same month each year. This 
# will usually be data up to the end of the year (month 12), but can be specified here.
required_month <- "12"

output_folder <- "3-9-3_output" 

