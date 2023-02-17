# Michael Nairn 17/02/2023

# configurations for Indicator update 3-9-2 (Nomis) data

# link for data - see the readme
# Nomis link generation instructions are explained in the README file


# Mortality statistics that meet the UN metadata ICD-10 codes 
  # https://unstats.un.org/sdgs/metadata/files/Metadata-03-09-02.pdf

england_wales_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957699,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&cause_of_death=10100,10101,10103,10104,10106...10109,10276,10277,10279,590,10865,10866,1100,1110,1120,11623&gender=0...2&age=0&measure=1&measures=20100"

scotland <- xxx

northern_ireland <- yyy

# Population
population_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_31_1.data.csv?geography=2092957699,2092957703,2092957698,2092957702,2092957701,2092957697,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&date=latestMINUS8-latest&sex=5...7&age=0&measures=20100"

output_folder <- "Output"
