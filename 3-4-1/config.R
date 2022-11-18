# define years vector to loop through
years <- c(2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021)

#Link gives all but female data
all_but_female_link_temp <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957715,2092957699,2092957700,2092957703,2092957716,2013265921...2013265930&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098,999345&gender=0,1&age=0...20&measure=2&measures=20100"

#Link gives female data
female_link_temp <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_161_1.data.csv?geography=2092957715,2092957699,2092957700,2092957703,2092957716,2013265921...2013265930&cause_of_death=9700,560,9,1130,1140,1150,1160,1170,1180,11095,11096,11098,999345&gender=2,1&age=0...20&measure=2&measures=20100"

output_folder <- "3-4-1_output"

