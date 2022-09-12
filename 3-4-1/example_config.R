# configurations for type 4 (Nomis) data

# link for data - see the readme
# Nomis link generation instructions should be explained in the README file
#   i.e. which selections to use to generate the link. 

#Link gives all totals excluding regional data 
total_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957715,2092957699,2092957700,2092957703,2092957716&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098&gender=0&age=0...20&measure=2&measures=20100"

#Link gives male data (excluding regions)
male_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957715,2092957699,2092957700,2092957703,2092957716&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098&gender=1&age=0...20&measure=2&measures=20100"

#Link gives female data (excluding regions )
female_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957715,2092957699,2092957700,2092957703,2092957716&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098&gender=2&age=0...20&measure=2&measures=20100"  
  
# This link gives data for UK regions
regions_link <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2013265921...2013265930&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11096,11098&gender=0...2&age=0,8...20&measure=2&measures=20100"

output_folder <- "3-4-1_output"


