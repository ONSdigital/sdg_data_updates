# configurations for type 4 (Nomis) data
# This is edited for Indicator 3-4-1

# link for data - see the readme
# Nomis link generation instructions should be explained in the README file
#   i.e. which selections to use to generate the link. 

# Use Age-standardised mortality rate.

# This link gives all data
numerator_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,1190&gender=0...2&age=0...20&measure=2&measures=20100"

# If needed:
# This link gives data for data not disaggregated by sex
numerator_link_total <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098&gender=0&age=0...20&measure=2&measures=20100"

# This link gives data for male
numerator_link_male <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098&gender=1&age=0...20&measure=2&measures=20100"

# This link gives data for female
numerator_link_female <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957703,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098&gender=2&age=0...20&measure=2&measures=20100"



# if annual data are are available up to different months/quarters, we want to 
# make sure we are always using the data up to the same month each year. This 
# will usually be data up to the end of the year (month 12), but can be specified here.
required_month <- "12"

output_folder <- "3-4-1_output" 



