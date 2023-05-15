# configurations for type 4 (Nomis) data

# link for data - see the readme
# Nomis link generation instructions should be explained in the README file
#   i.e. which selections to use to generate the link. 


NOMIS_data <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_168_1.data.csv?geography=2092957697...2092957703,2013265921...2013265932&date=latestMINUS68,latestMINUS64,latestMINUS60,latestMINUS56,latestMINUS52,latestMINUS48,latestMINUS44,latestMINUS40,latestMINUS36,latestMINUS32,latestMINUS28,latestMINUS24,latestMINUS20,latestMINUS16,latestMINUS12,latestMINUS8,latestMINUS4,latest&c_sex=0...2&c_occpuk11h_0=0,10008,22,23&measure=1&measures=20100,20701"

# if annual data are are available up to different months/quarters, we want to 
# make sure we are always using the data up to the same month each year. This 
# will usually be data up to the end of the year (month 12), but can be specified here.
required_month <- "12"

output_folder <- "Output"
