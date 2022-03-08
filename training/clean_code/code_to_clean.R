library('openxlsx')
library('dplyr')
library('tidyr')
library('stringr')

#---- Import the datasets ----#
# import the 'all' woodland data and change all factors to uppercase characters
df1<-openxlsx::read.xlsx("training/clean_code/Input/PWS_2021.xlsx",sheet="Data for figure 1",colNames=FALSE)%>%
  mutate(across(where(is.factor),as.character))%>%
  mutate(across(where(is.character),toupper))
# import the 'certified' woodland data and change all factors to uppercase characters
df2<-openxlsx::read.xlsx("training/clean_code/Input/PWS_2021.xlsx",sheet="Data for figure 2",colNames=FALSE)%>%
  mutate(across(where(is.factor),as.character))%>%
  mutate(across(where(is.character),toupper))
# import the land area data and change all factors to uppercase characters
df3<-read.csv("training/clean_code/Input/SAM_CTRY_DEC_2020_UK.csv")%>%
  mutate(across(where(is.factor),as.character))%>%
  mutate(across(where(is.character),toupper))

#---- Get relevant area data(of all land)----#
# The UK area data has got more measures than we need (AREALHECT is the one we use)
# The name of the columns containing country names and codes will change depending on the year. 
# We therefore need to identify these columns and give them a standard name that 
#  we can refer to in the code, without having to change it every year:
# Identify which column has "CTRY" as the first four characters and "NM" as the 7th and 8th characters. This column will be the country name column.
name<-which(substr(names(df3),1,4)=="CTRY"&substr(names(df3),7,8)=="NM")
# identify which column has "CTRY" as the first four characters and "CD" as the 7th and 8th characters. This column will be the country code column.
code<-which(substr(names(df3),1,4)=="CTRY"&substr(names(df3),7,8)=="CD")
# name the Country name column
names(df3)[name]<-"Country"
# name the Country code column
names(df3)[code]<-"Geocode"
# select the AREALHECT data and the country info. We don't need the other measures
df3_new<-select(df3,Geocode,Country,AREALHECT)%>%
  add_row(Geocode="",Country="UK",AREALHECT=sum(df3$AREALHECT))

#---- get woodland area data (for all woodland)----#
# The column names (headers) for the woodland data are not in the first row,
#  as there is metadata above the data.
# The row the headers are in may differ for different years, so we identify
#  which row they are in, using a column name we know will always exist
# Get the number of the row containing the headers (column names)
rownum<-which(df1$X1=="YEAR")
# Name the columns in df1 
names(df1)<-df1[rownum,]
# Remove the metadata rows and put data in a tidy format
df1<-df1%>%
  # Identify metadata rows by using the year column. 
  # We know year should have 4 numbers as the first 4 characters, 
  # so if it doesn't it isn't a data entry.
  mutate(keep=grepl('[0-9][0-9][0-9][0-9]',substr(YEAR,1,4)))%>%
  filter(keep==TRUE)%>%
  select(-keep)%>%
  # tidy the data so the values for each country are in a single column,
  # and there is a column for the country name etc.
  pivot_longer(-YEAR,names_to="Country",values_to="woodland_area")

# get certified woodland area data, following the same approach as above.
rownum<-which(df2$X1=="YEAR")
names(df2)<-df2[rownum,]
df2<-df2%>%
  mutate(keep=grepl('[0-9][0-9][0-9][0-9]',substr(YEAR,5,9)))%>%
  mutate(YEAR=substr(YEAR,5,9))%>%
  filter(keep==TRUE)%>%
  select(-keep)%>%
  pivot_longer(-YEAR,names_to="Country",values_to="certified_area")

# join the dataframes together 
all<-df1%>%
  # join df1 and df2 on the year and country columns
  left_join(df2,by=c("YEAR","Country"))%>%
  # then join the result of that to df3 using just the country column
  left_join(df3_new,by="Country")%>%
  # make sure the columns with numbers are seen as numeric columns so that we can do calculations on them
  mutate(YEAR=as.numeric(YEAR),AREALHECT=as.numeric(AREALHECT),woodland_area=as.numeric(woodland_area),certified_area=as.numeric(certified_area))

#---- do calculations ----#
all<-all%>% 
  # do calculations 
  mutate(woodland_proportion=(woodland_area*1000000)/AREALHECT*100,certified_proportion=(certified_area*1000000)/AREALHECT*100,non_certified_proportion=((woodland_area-certified_area)*1000000)/AREALHECT*100)%>% 
  # remove woodland area certified area and area of the countries because we have used them in the calculations and we don't need them in the final csv
  select(-c(woodland_area, certified_area, AREALHECT))

#---- make the csv ----#
# Add required columns, rename disaggregation levels, 
# and filter out values we don't want to display
final<-all%>%pivot_longer(-c(YEAR,Country,Geocode),names_to="Sustainably managed status",values_to="Value")%>%
  # rename the levels of the Sustainably managed status column
  mutate(`Sustainably managed status`=case_when(
    `Sustainably managed status`=="woodland_proportion"~"",
    `Sustainably managed status`=="certified_proportion"~"Certified",
    `Sustainably managed status`=="non_certified_proportion"~"Non-certified"),
    # Make Country blank for totals (i.e. UK)
    Country=ifelse(Country=="UK","",Country))%>%
  # Put country information in title case (e.g. Northern Ireland not NORTHERN IRELAND)
  mutate(Country=str_to_title(Country))%>%
  # NI had a different method for calculating the area of non-certified woodland area before 2013, 
  #  so we need to get rid of rows that are impacted by that different methodology
  # Identify which rows we don't want: all Northern Ireland and UK total and non-certified woodland 
  #  figures prior to 2013
  mutate(different_method=ifelse((Country=="Northern Ireland"|Country=="")&YEAR<2013&`Sustainablymanagedstatus`%in%c("","Non-certified"),TRUE,FALSE))%>%
  # Remove the rows identified above
  filter(!is.na(Value)&different_method==FALSE&YEAR>=2004)%>%
  # add the extra columns needed for the csv
  mutate(`Observation status`="Undefined",`Unit multiplier`="Units",`Unit measure`="percentage(%)")%>%
  # Reformat the name of the year column
  rename(Year=YEAR)%>%
  # use select to put the columns in the right order
  select(Year,Country,`Sustainablymanagedstatus`,`Observationstatus`,`Unitmeasure`,`Unitmultiplier`,Value)

#---- save the csv ----#
write.csv(final,'training/clean_code/15-1-1_data.csv',row.names=TRUE)