# 2013 onwards
nomis_disaster_deaths_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957715,2092957699,2092957700,2092957703,2092957716&cause_of_death=0,12430...12439&gender=0...2&age=0&measure=1&measures=20100"

# 2013 onwards 
nomis_mortality_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957703&cause_of_death=0,2510&gender=0...2&age=0&measure=2&measures=20100"

# 2001 to 2018 disaster mortality raw and age-standardised rates

ons_disaster_death_link <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/deaths/adhocs/11640numberofdeathsandcrudemortalityratesfromexposuretoforcesofnatureenglandandwales2001to2018/deathsofnaturalforcesv3.0.xlsx"

output_folder <- "Output" 


ons1 <- "Table 1" # Number of deaths for all disasters aggr. by sex aggr. by country
ons2 <- "Table 2" # Number of deaths for all disasters disaggr. by sex aggr. by country
ons3 <- "Table 3" # Number of deaths disaggr. by cause of death and country and aggr. by sex
ons4 <- "Table 4" # Number of deaths disaggr. by cause of death, country and sex