# configurations for type 4 (Nomis) data

# link for data - see the readme
# Nomis link generation instructions should be explained in the README file
#   i.e. which selections to use to generate the link. 

# This link gives data for every quarter
numerator_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_168_1.data.csv?geography=2092957699,2092957702,2092957701,2092957697,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&date=latestMINUS7-latest&c_sex=0&c_occpuk11h_0=20005,58...66,20006,67...70,20007,71,72,30003,119...123&measure=1&measures=20100,20701"

# Population
population_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=2092957699,2092957702,2092957701,2092957697,2092957700,2013265921...2013265932&date=latestMINUS16-latest&gender=0...2&c_age=200&measures=20100"

output_folder <- "Output"
