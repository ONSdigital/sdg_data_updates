# example configuration for type 4 (Nomis) data - 5-a-1

# link for data - see the readme
# Nomis link generation instructions should be explained in the README file
#   i.e. which selections to use to generate the link. 

# This link gives data for every year
NOMIS_data <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_168_1.data.csv?geography=2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923,2092957697...2092957703&date=latestMINUS68,latestMINUS64,latestMINUS60,latestMINUS56,latestMINUS52,latestMINUS48,latestMINUS44,latestMINUS40,latestMINUS36,latestMINUS32,latestMINUS28,latestMINUS24,latestMINUS20,latestMINUS16,latestMINUS12,latestMINUS8,latestMINUS4,latest&c_sex=0...2&c_occpuk11h_0=10008&measure=1,3&measures=20100,20701"

# if annual data are are available up to different months/quarters, we want to 
# make sure we are always using the data up to the same month each year. This 
# will usually be data up to the end of the year (month 12), but can be specified here.
required_month <- "12"

output_folder <- "Example_output"
