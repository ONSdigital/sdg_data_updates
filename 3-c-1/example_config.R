# Author: Emma Wood
# Initial date: 16/12/2021
# purpose: configurations for 3-c-1 indicator update
# for nomis link generation instructions see the README file

## For back series (health workers)
## 2004 to 2019, year ending December
# nomis_employment_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_168_1.data.csv?geography=2092957699,2092957702,2092957701,2092957697,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&date=latestMINUS66,latestMINUS62,latestMINUS58,latestMINUS54,latestMINUS50,latestMINUS46,latestMINUS42,latestMINUS38,latestMINUS34,latestMINUS30,latestMINUS26,latestMINUS22,latestMINUS18,latestMINUS14,latestMINUS10,latestMINUS6,latestMINUS2&c_sex=0&c_occpuk11h_0=20005,58...66,20006,67...70,20007,71,72,30003,119...123&measure=1&measures=20100,20701"

# Health workers past 2 years, every quarter
nomis_employment_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_168_1.data.csv?geography=2092957699,2092957702,2092957701,2092957697,2092957700,2013265926,2013265924,2013265927,2013265921,2013265922,2013265928,2013265929,2013265925,2013265923&date=latestMINUS7-latest&c_sex=0&c_occpuk11h_0=20005,58...66,20006,67...70,20007,71,72,30003,119...123&measure=1&measures=20100,20701"

# Population
nomis_population_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=2092957699,2092957702,2092957701,2092957697,2092957700,2013265921...2013265932&date=latestMINUS16-latest&gender=0...2&c_age=200&measures=20100"

output_folder <- "Example_output"
