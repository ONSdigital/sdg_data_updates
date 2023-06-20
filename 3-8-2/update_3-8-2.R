# author: Abhishek Singh
# date: 23/04/2023

# Code to automate data update for indicator 3-8-2 
# Proportion of population with large household expenditures on health
# as a share of total household expenditure or income

# Create a function for getting year

get_year <- function(df) {
  
  year = df$`X1`[3]
  year = str_sub(year, start= -2)
  pre= as.integer(year)-1
  pre = toString(pre)
  prep="20"
  year = capture.output( cat(prep,pre,"/",year, sep=" "))
  year <- gsub(" ","",year)
  return(year)
}

# function to retun main header list
g_header <- function(){
  
  mheader = c("Year","Series","Age","Disposable income decile","Health product or service",
              "Health product or service category", "Health product or service sub-category",
              "Tenure category","Tenure sub-category","Occupation category",
              "Observation status","Unit multiplier","Units","Value") 
  return(mheader)
  }

# get data from workbook 4 tabname A22, process and format it
data_wb4_A22 <- get_type1_data(header_row, filename_wb4, household_expd_socioeconomic_data)
year <- get_year(data_wb4_A22)

data_A22 = data_wb4_A22[data_wb4_A22$`X2` == 'Health',] %>% drop_na()

colnames(data_A22) [3] <- "Large employers and higher managerial"
colnames(data_A22) [4] <- "Higher professional"
colnames(data_A22) [5] <- "Lower managerial and professional"
colnames(data_A22) [6] <- "Intermediate"
colnames(data_A22) [7] <- "Small employers"
colnames(data_A22) [8] <- "Lower supervisory"
colnames(data_A22) [9] <- "Semi-routine"
colnames(data_A22) [10] <- "Routine"
colnames(data_A22) [11] <- "Long term unemployed"
colnames(data_A22) [12] <- "Students"
colnames(data_A22) [13] <- "Occupation not stated"

data_A22 <- subset(data_A22, select = -c(1, 14))
data_A22 <- data_A22 %>% 
    pivot_longer(
      cols = !`X2`, 
      names_to = "Occupation category", 
      values_to = "Value"
    )

data_A22<- data_A22  %>%
  mutate("Year" = year,
         "Series" = "Average weekly household expenditure on health",
         "Age" =  "",
         "Disposable income decile" = "",
         "Health product or service" = "",
         "Health product or service category" = "",
         "Health product or service sub-category" = "",
         "Tenure category"= "",
         "Tenure sub-category" = "",
         "Observation status" = "Normal value",
         "Unit multiplier" = "Units",
         "Units" = "GBP (£)") %>% 
                      select(g_header()) 

# Remove unnecessary data from global environment
rm(data_wb4_A22)


# get data for workbook 1 and Tabname A11, process and format it
data_wb1_A11 <- get_type1_data(header_row, filename_wb1, Age_group_data)         
year_A11 <- get_year(data_wb1_A11)       

data_wb1_A11 <- data_wb1_A11  %>% drop_na(X4)

data_wb1_A11 = data_wb1_A11[data_wb1_A11$`X2` == 'Health'|
                            data_wb1_A11$`X2` == 'Medical products, appliances and equipment'|
                            data_wb1_A11$`X2` == '6.1.1'|
                            data_wb1_A11$`X2` == '6.1.2'|
                            data_wb1_A11$`X2` == 'Hospital services',] %>% drop_na(X4)
  
data_wb1_A11$`X2`  <- gsub("6.1.1","Medical products appliances and equipment",data_wb1_A11$`X2`)
data_wb1_A11$`X2`  <- gsub("6.1.2","Medical products appliances and equipment",data_wb1_A11$`X2`)
data_wb1_A11$`X2`  <- gsub(",","",data_wb1_A11$`X2`)
data_wb1_A11$`X3`  <- gsub(",","",data_wb1_A11$`X3`)
data_wb1_A11$`X2`  <- gsub("Health","",data_wb1_A11$`X2`) 

colnames(data_wb1_A11) [4] <- "29 and under"
colnames(data_wb1_A11) [5] <- "30 to 49"
colnames(data_wb1_A11) [6] <- "50 to 64"
colnames(data_wb1_A11) [7] <- "65 to 74"
colnames(data_wb1_A11) [8] <- "75 and over"

data_wb1_A11 <- within(data_wb1_A11, rm("X1", "X9"))

data_wb1_A11 <- data_wb1_A11 %>% 
  pivot_longer(
    cols = ! c(`X2`,`X3`), 
    names_to = "Age", 
    values_to = "Value",
    values_drop_na = TRUE
  )

colnames(data_wb1_A11) [1] <- "Health product or service"
colnames(data_wb1_A11) [2] <- "Health product or service category"

data_A11<- data_wb1_A11  %>%
  mutate("Year" = year,
         "Series" = "Average weekly household expenditure on health",
         "Disposable income decile" = "",
         "Health product or service sub-category" = "",
         "Tenure category" = "",
         "Tenure sub-category" = "",
         "Occupation category" = "",
         "Observation status" = "Normal value",
         "Unit multiplier" = "Units",
         "Units" = "GBP (£)")

data_A11$Value  <- gsub("\\[|\\]", "",data_A11$Value)

data_A11<- data_A11  %>% select(g_header()) 

# Remove unnecessary data from global environment
rm(data_wb1_A11)



# Get data from tab 4.2 workbook 1, process and format it
data_wb1_42 <- get_type1_data(header_row, filename_wb1, percentage_total_expd_data)         

data_wb1_42 = data_wb1_42[data_wb1_42$`X2` == 'Health',] %>% drop_na()

data_wb1_42["Value"] <- data_wb1_42[ , ncol(data_wb1_42)]

data_42 <- data_wb1_42 %>% 
  mutate("Year" = year,
       "Series" = "Average weekly household expenditure on health",
       "Age" =  "",
       "Disposable income decile" = "",
       "Health product or service" = "",
       "Health product or service category" = "",
       "Health product or service sub-category" = "",
       "Tenure category"= "",
       "Tenure sub-category" = "",
       "Occupation category" = "",
       "Observation status" = "Normal value",
       "Unit multiplier" = "Units",
       "Units" = "Percentage of total expenditure (%)") %>%
        select(g_header()) 

# Remove unnecessary data from global environment
rm(data_wb1_42)



# get data for tab 3.1 WB1

data_wb1_31<- get_type1_data(header_row, filename_wb1, income_decile_group_data) 


data_wb1_31 <- data_wb1_31  %>% drop_na(X4)


data_wb1_31 = data_wb1_31[data_wb1_31$`X2` == 'Health'|
                              data_wb1_31$`X2` == 'Medical products, appliances and equipment'|
                              data_wb1_31$`X2` == '6.1.1'|
                              data_wb1_31$`X2` == '6.1.2'|
                              data_wb1_31$`X2` == 'Hospital services',] %>% drop_na(X4)


data_wb1_31$`X2`  <- gsub("6.1.1","Medical products appliances and equipment",data_wb1_31$`X2`)
data_wb1_31$`X2`  <- gsub("6.1.2","Medical products appliances and equipment",data_wb1_31$`X2`)
data_wb1_31$`X2`  <- gsub(",","",data_wb1_31$`X2`)
data_wb1_31$`X3`  <- gsub(",","",data_wb1_31$`X3`)
data_wb1_31$`X3`  <- gsub("etc.","",data_wb1_31$`X3`)
data_wb1_31$`X2`  <- gsub("Health","",data_wb1_31$`X2`)


colnames(data_wb1_31) [4] <- "Lowest ten percent"
colnames(data_wb1_31) [5] <- "Second"
colnames(data_wb1_31) [6] <- "Third"
colnames(data_wb1_31) [7] <- "Fourth"
colnames(data_wb1_31) [8] <- "Fifth"
colnames(data_wb1_31) [9] <- "Sixth"
colnames(data_wb1_31) [10] <- "Seventh"
colnames(data_wb1_31) [11] <- "Eighth"
colnames(data_wb1_31) [12] <- "Ninth"
colnames(data_wb1_31) [13] <- "Highest ten percent"

data_wb1_31 <- within(data_wb1_31, rm("X1", "X14"))
 
data_wb1_31 <- data_wb1_31 %>%
  pivot_longer(
    cols = ! c(`X2`,`X3`),
    names_to = "Disposable income decile",
    values_to = "Value",
    values_drop_na = TRUE
  )

colnames(data_wb1_31) [1] <- "Health product or service"
colnames(data_wb1_31) [2] <- "Health product or service category"


data_31<- data_wb1_31  %>%
  mutate("Year" = year,
         "Series" = "Average weekly household expenditure on health",
         "Age" = "",
         "Health product or service sub-category" = "",
         "Tenure category" = "",
         "Tenure sub-category" = "",
         "Occupation category" = "",
         "Observation status" = "Normal value",
         "Unit multiplier" = "Units",
         "Units" = "GBP (£)") %>% 
                         select(g_header())

# Remove unnecessary data from global environment
rm(data_wb1_31)


# get data for tab 3.2 WB1, process and format it

data_wb1_32<- get_type1_data(header_row, filename_wb1, percent_total_expd_decile_group_data) 

data_wb1_32 <- data_wb1_32  %>% drop_na(X4)

data_wb1_32 = data_wb1_32[data_wb1_32$`X2` == 'Health'|
                            data_wb1_32$`X2` == 'Medical products, appliances and equipment'|
                            data_wb1_32$`X2` == '6.1.1'|
                            data_wb1_32$`X2` == '6.1.2'|
                            data_wb1_32$`X2` == 'Hospital services',] %>% drop_na(X4)

data_wb1_32$`X2`  <- gsub("6.1.1","Medical products appliances and equipment",data_wb1_32$`X2`)
data_wb1_32$`X2`  <- gsub("6.1.2","Medical products appliances and equipment",data_wb1_32$`X2`)
data_wb1_32$`X2`  <- gsub(",","",data_wb1_32$`X2`)
data_wb1_32$`X3`  <- gsub(",","",data_wb1_32$`X3`)
data_wb1_32$`X3`  <- gsub("etc.","",data_wb1_32$`X3`)
data_wb1_32$`X2`  <- gsub("Health","",data_wb1_32$`X2`)

colnames(data_wb1_32) [4] <- "Lowest ten percent"
colnames(data_wb1_32) [5] <- "Second"
colnames(data_wb1_32) [6] <- "Third"
colnames(data_wb1_32) [7] <- "Fourth"
colnames(data_wb1_32) [8] <- "Fifth"
colnames(data_wb1_32) [9] <- "Sixth"
colnames(data_wb1_32) [10] <- "Seventh"
colnames(data_wb1_32) [11] <- "Eighth"
colnames(data_wb1_32) [12] <- "Ninth"
colnames(data_wb1_32) [13] <- "Highest ten percent"

data_wb1_32 <- within(data_wb1_32, rm("X1", "X14"))

data_wb1_32 <- data_wb1_32 %>%
  pivot_longer(
    cols = ! c(`X2`,`X3`),
    names_to = "Disposable income decile",
    values_to = "Value",
    values_drop_na = TRUE
  )

colnames(data_wb1_32) [1] <- "Health product or service"
colnames(data_wb1_32) [2] <- "Health product or service category"


data_32<- data_wb1_32  %>%
  mutate("Year" = year,
         "Series" = "Average weekly household expenditure on health",
         "Age" = "",
         
         "Health product or service sub-category" = "",
         "Tenure category" = "",
         "Tenure sub-category" = "",
         "Occupation category" = "",
         "Observation status" = "Normal value",
         "Unit multiplier" = "Units",
         "Units" = "Percentage of total expenditure (%)") %>% 
                        select(g_header())

# Remove unnecessary data from global environment
rm(data_wb1_32)



# Get data from Wb1 tab name A1, process and format it
data_wb1_A1<- get_type1_data(header_row, filename_wb1, household_expd_data) 

data_wb1_A1 = data_wb1_A1[data_wb1_A1$`X2` == 'Health'|
                            data_wb1_A1$`X2` == 'Medical products, appliances and equipment'|
                            data_wb1_A1$`X2` == '6.1.1'|
                            data_wb1_A1$`X2` == '6.1.2'|
                            data_wb1_A1$`X2` == 'Hospital services'|
                            data_wb1_A1$`X3` == 'Medicines, prescriptions and healthcare products'|
                            data_wb1_A1$`X3` == '6.1.1.1'|
                            data_wb1_A1$`X3` == '6.1.1.2'|
                            data_wb1_A1$`X3` == '6.1.1.3'|
                            data_wb1_A1$`X3` == '6.1.1.4'|
                            data_wb1_A1$`X4` == 'for hearing aids, shoe build-up)'|
                            data_wb1_A1$`X3` == 'Spectacles, lenses, accessories and repairs'|
                            data_wb1_A1$`X3` == '6.1.2.1'|
                            data_wb1_A1$`X3` == '6.1.2.2'|
                            data_wb1_A1$`X3` == 'Out patient services'|
                            data_wb1_A1$`X3` == '6.2.1.1'|
                            data_wb1_A1$`X3` == '6.2.1.2', ]  %>% drop_na(X6)
data_wb1_A1$X3[is.na(data_wb1_A1$X3) == 1 & data_wb1_A1$X4 == 'for hearing aids, shoe build-up)'] <- "6.1.1.4"
data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.1.1.1'] <- "6.1.1.1"
data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.1.1.2'] <- "6.1.1.2"
data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.1.1.3'] <- "6.1.1.3"
data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.1.1.4'] <- "6.1.1.4"



data_wb1_A1$`X2`  <- gsub("6.1.1.1","Medical products appliances and equipment", data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.1.1.2","Medical products appliances and equipment", data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.1.1.3","Medical products appliances and equipment", data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.1.1.4","Medical products appliances and equipment", data_wb1_A1$`X2`)

data_wb1_A1$`X2`  <- gsub("6.1.1","Medical products appliances and equipment", data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub(",", "", data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("Health", "", data_wb1_A1$`X2`)


data_wb1_A1$`X3`  <- gsub("6.1.1.1","Medicines prescriptions and healthcare products", data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("6.1.1.2","Medicines prescriptions and healthcare products", data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("6.1.1.3","Medicines prescriptions and healthcare products", data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("6.1.1.4","Medicines prescriptions and healthcare products", data_wb1_A1$`X3`)

data_wb1_A1$`X3`  <- gsub("Medicines, prescriptions and healthcare products","Medicines prescriptions and healthcare products",data_wb1_A1$`X3`)



data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.1.2.1'] <- "6.1.2.1"
data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.1.2.2'] <- "6.1.2.2"

data_wb1_A1$`X2`  <- gsub("6.1.2.1","Medical products appliances and equipment",
                          data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.1.2.2","Medical products appliances and equipment",
                          data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.1.2","Medical products appliances and equipment",
                          data_wb1_A1$`X2`)

data_wb1_A1$`X3`  <- gsub("6.1.2.1","Spectacles lenses accessories and repairs",
                          data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("6.1.2.2","Spectacles lenses accessories and repairs",
                          data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("Spectacles, lenses, accessories and repairs",
                          "Spectacles lenses accessories and repairs",
                          data_wb1_A1$`X3`)



data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.2.1.1'] <- "6.2.1.1"
data_wb1_A1$X2[is.na(data_wb1_A1$X2) == 1 & data_wb1_A1$X3 == '6.2.1.2'] <- "6.2.1.2"

data_wb1_A1$`X2`  <- gsub("6.2.1.1","Hospital services", data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.2.1.2","Hospital services", data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.2.1","Hospital services", data_wb1_A1$`X2`)

data_wb1_A1$`X3`  <- gsub("6.2.1.1","Outpatient services", data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("6.2.1.2","Outpatient services", data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("Out patient services","Outpatient services", data_wb1_A1$`X3`)

data_wb1_A1$`X4`  <- gsub("NHS prescription charges and payments",
                          "National Health Service (NHS) prescription charges and payments",
                          data_wb1_A1$`X4`)

data_wb1_A1$`X4`  <- gsub("Other medical products (e.g. plasters, condoms, hot water bottle etc.)",
                          "Other medical products (plasters condoms hot water bottles)",
                          data_wb1_A1$`X4`)

data_wb1_A1$`X4`  <- gsub("for hearing aids, shoe build-up)",
                          "Nonoptical appliances and equipment (wheelchairs batteries for hearing aids shoe buildup)", data_wb1_A1$`X4`)
data_wb1_A1$`X4`  <- gsub("Purchase of spectacles, lenses, prescription sunglasses",
                          "Purchase of spectacles lenses prescription sunglasses",
                          data_wb1_A1$`X4`)
data_wb1_A1$`X4`  <- gsub("Accessories/repairs to spectacles/lenses",
                          "Accessories or repairs to spectacles or lenses",
                          data_wb1_A1$`X4`)
data_wb1_A1$`X4`  <- gsub("NHS medical, optical, dental and medical auxiliary services",
                          "National Health Service (NHS) medical optical dental and medical auxiliary services", data_wb1_A1$`X4`)
data_wb1_A1$`X4`  <- gsub("Private medical, optical, dental and medical auxiliary services",
                          "Private medical optical dental and medical auxiliary services",
                          data_wb1_A1$`X4`)


data_wb1_A1$`X2`  <- gsub("6.1.1","Medical products appliances and equipment",data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub("6.1.2","Medical products appliances and equipment",data_wb1_A1$`X2`)
data_wb1_A1$`X2`  <- gsub(",","",data_wb1_A1$`X2`)
data_wb1_A1$`X3`  <- gsub(",","",data_wb1_A1$`X3`)
data_wb1_A1$`X3`  <- gsub("etc.","",data_wb1_A1$`X3`)
data_wb1_A1$`X2`  <- gsub("Health","",data_wb1_A1$`X2`)

colnames(data_wb1_A1) [2] <- "Health product or service"
colnames(data_wb1_A1) [3] <- "Health product or service category"
colnames(data_wb1_A1) [4] <- "Health product or service sub-category"
colnames(data_wb1_A1) [6] <- "Value"

data_wb1_A1 <- within(data_wb1_A1, rm("X1", "X5","X7" ,"X8" ,"X9"))


data_A1<- data_wb1_A1  %>%
  mutate("Year" = year,
         "Series" = "Average weekly household expenditure on health",
         "Age" = "",
         "Disposable income decile" = "",
         "Tenure category" = "",
         "Tenure sub-category" = "",
         "Occupation category" = "",
         "Observation status" = "Normal value",
         "Unit multiplier" = "Units",
         "Units" = "GBP (£)") %>% 
                      select(g_header())

# Remove unnecessary data from global environment
rm(data_wb1_A1)




# Get data from Wb2 tabname A32, process and format it
data_wb2_A32<- get_type1_data(header_row, filename_wb2, household_expd_tenure_data) 

data_wb2_A32 = data_wb2_A32[data_wb2_A32$`X2` == 'Health',]

data_wb2_A32 <- data_wb2_A32 %>% drop_na(X2)

colnames(data_wb2_A32) [3] <- "Owner occupied-Owned outright"
colnames(data_wb2_A32) [4] <- "Owner occupied-Owner occupied buying with a mortgage"
colnames(data_wb2_A32) [5] <- "Owner occupied-All"
colnames(data_wb2_A32) [6] <- "Social rented-Council"
colnames(data_wb2_A32) [7] <- "Social rented-Registered social landlord"
colnames(data_wb2_A32) [8] <- "Social rented-All" 
colnames(data_wb2_A32) [9] <- "Private rented-Rent free"
colnames(data_wb2_A32) [10] <- "Private rented-Rent paid unfurnished"
colnames(data_wb2_A32) [11] <- "Private rented-Rent paid furnished"
colnames(data_wb2_A32) [12] <- "Private rented-All"

data_wb2_A32 <- within(data_wb2_A32, rm("X1", "X13"))


data_wb2_A32 <- data_wb2_A32 %>%
  pivot_longer(
    cols = !`X2`,
    names_to = "Tenure sub-category",
    values_to = "Value",
    values_drop_na = TRUE
  )

data_wb2_A32 <- within(data_wb2_A32, rm("X2"))
data_wb2_A32["Tenure category"]=""

data_wb2_A32$`Tenure category` <- sub("-.*", "", data_wb2_A32$`Tenure sub-category`)
data_wb2_A32$`Tenure sub-category`  <- sub(".*-", "", data_wb2_A32$`Tenure sub-category`)

data_wb2_A32$`Tenure sub-category`  <- gsub("All","",data_wb2_A32$`Tenure sub-category`)

data_A32<- data_wb2_A32  %>%
  mutate("Year" = year,
         "Series" = "Average weekly household expenditure on health",
         "Age" = "",
         "Disposable income decile" = "",
         "Health product or service"= "",
         "Health product or service category"= "",
         "Health product or service sub-category"= "",
         "Occupation category" = "",
         "Observation status" = "Normal value",
         "Unit multiplier" = "Units",
         "Units" = "GBP (£)")  %>% 
                       select(g_header())

# Remove unnecessary data from global environment
rm(data_wb2_A32)



# Combine all data into single table with identical columns

csv_output <- rbind(data_A1,data_A32, data_A22, data_A11,
                        data_31, data_32, data_42)

# final formatting
csv_output$`Observation status`[grepl("[", csv_output$Value, fixed = TRUE)] <- "Low reliability"


csv_output$Value <- gsub("\\[|\\]", "", csv_output$Value)
# Running Confirm
csv_output$`Health product or service category` <-gsub(
   "Medicines prescriptions and healthcare products",
   "Medicines, prescriptions and healthcare products",
   csv_output$`Health product or service category` )

 csv_output$`Health product or service category` <-gsub(
   "Medicines prescriptions healthcare products",
   "Medicines, prescriptions and healthcare products",
   csv_output$`Health product or service category` )

 csv_output$`Health product or service sub-category` <-gsub(
   "optical dental","optical, dental",
   csv_output$`Health product or service sub-category`)


csv_output$Value <- gsub("~", "", csv_output$Value)

csv_output <- csv_output %>%
  mutate(across(everything(), ~ replace(.x, is.na(.x), ""))) 
  







