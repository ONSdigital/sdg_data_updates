# author: Katie Uzzell
# date: 16/06/2023

# Code to automate data update for indicator 9-b-1 (Proportion of medium and high-tech industry value added in total value added)

# read in data 

gdp_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

gdp_main_data <- extract_data(gdp_source_data, header_row)

# rename column 1

colnames(gdp_main_data) [1] <- "Year"

# select wanted columns and rows

gdp_main_data <- select(gdp_main_data, c("Year","KL8V", "KL5Q", "KL5X", "KL68", 
                                         "KL6A", "KL6B", "KL6C", "KL6D", "KL6G", "KL6H"))

gdp_main_data <- gdp_main_data[!grepl("Q", gdp_main_data$Year),]

# change format and sum rows

gdp_main_data$KL8V <- as.numeric(as.character(gdp_main_data$KL8V)) 
gdp_main_data$KL5Q <- as.numeric(as.character(gdp_main_data$KL5Q))          
gdp_main_data$KL5X <- as.numeric(as.character(gdp_main_data$KL5X)) 
gdp_main_data$KL68 <- as.numeric(as.character(gdp_main_data$KL68)) 
gdp_main_data$KL6A <- as.numeric(as.character(gdp_main_data$KL6A)) 
gdp_main_data$KL6B <- as.numeric(as.character(gdp_main_data$KL6B)) 
gdp_main_data$KL6C <- as.numeric(as.character(gdp_main_data$KL6C)) 
gdp_main_data$KL6D <- as.numeric(as.character(gdp_main_data$KL6D)) 
gdp_main_data$KL6G <- as.numeric(as.character(gdp_main_data$KL6G)) 
gdp_main_data$KL6H <- as.numeric(as.character(gdp_main_data$KL6H)) 

gdp_main_data <- gdp_main_data %>% 
  mutate(Total = select(., "KL5Q", "KL5X", "KL68", "KL6A", "KL6B", "KL6C", 
                        "KL6D", "KL6G", "KL6H") %>% rowSums(na.rm = TRUE))

# calculate percentages

gdp_main_data <- gdp_main_data %>% 
  mutate("Chemicals and chemical products" = KL5Q/KL8V*100,
         "Basic pharmaceutical products and pharmaceutical preparations" = KL5X/KL8V*100,
         "Weapons and ammunition" = KL68/KL8V*100,
         "Computer, electronic and optical products" = KL6A/KL8V*100,
         "Electrical equipment" = KL6B/KL8V*100,
         "Machinery and equipment n.e.c." = KL6C/KL8V*100,
         "Motor vehicles, trailers and semi-trailers" = KL6D/KL8V*100,
         "Air, spacecraft and related machinery" = KL6G/KL8V*100,
         "Other" = KL6H/KL8V*100,
         "Total (%)" = Total/KL8V*100)

#select wanted columns
  
gdp_main_data <- select(gdp_main_data, c("Year",
                                         "Chemicals and chemical products", 
                                         "Basic pharmaceutical products and pharmaceutical preparations", 
                                         "Weapons and ammunition", 
                                         "Computer, electronic and optical products", 
                                         "Electrical equipment", 
                                         "Machinery and equipment n.e.c.", 
                                         "Motor vehicles, trailers and semi-trailers", 
                                         "Air, spacecraft and related machinery", 
                                         "Other", 
                                         "Total (%)"))

# format

gdp_csv <- gdp_main_data %>% 
  pivot_longer(-c("Year"), names_to = "Manufacturing industry", values_to = "Value")

gdp_csv[gdp_csv == 'Total (%)'] <- ''

# format csv 

csv_formatted <- gdp_csv %>% 
         mutate("Series" = "Proportion of medium and high-tech manufacturing value added in total value added",
           "Units" = "Percentage (%)",
            "Unit multiplier" =  "Units",
            "Observation status" = "Normal value")

csv_formatted <- csv_formatted %>%            
select("Year", "Series", "Manufacturing industry", "Observation status", "Unit multiplier", "Units", "Value")

csv_output <- csv_formatted[order(csv_formatted$`Manufacturing industry`), ]





