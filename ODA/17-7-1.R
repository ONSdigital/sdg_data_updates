# Author: Atanaska Nikolova (September 2023)


    oda_renamed$EST_ProjectTitle <- sapply(str_extract_all(oda_renamed$projecttitle, paste("\\b", EST, "\\b", sep="", collapse="|")), paste, collapse=",")
    oda_renamed$EST_LongDesc <- sapply(str_extract_all(oda_renamed$longdescription, paste("\\b", EST, "\\b", sep="", collapse="|")), paste, collapse=",")
  
    oda_renamed <- oda_renamed[oda_renamed$EST_ProjectTitle != "" | oda_renamed$EST_LongDesc != "", ]
  
    EST_funding <- aggregate(oda_renamed$net_oda,
                           by = list(Year = oda_renamed$year),
                           FUN = sum)
  
    colnames(EST_funding)[2] <- "Value"

  csv <- EST_funding %>% 
    #bind_rows(constant_usd_data) %>% 
    mutate(Series = "Official Development Assistance (ODA) for environmentally sound technologies",
           `Country turnover` = "",
           `Observation status` = "Definition differs",
           Units = "GBP (thousands)",
           `Unit multiplier` = "Thousands") %>% 
    select(Year, Series, `Country turnover`,
           `Observation status`, Units, `Unit multiplier`, Value) %>% 
    arrange(Year)
    #replace(is.na(.), "")
  #non-ODA part
  national_EST <- get_type1_data(header_row, filename_lowcarbon, tabname_lowcarbon)
  
  #DRAFT FROM HERE, check how to consolidate with csv without running twice
  national_EST <- extract_data(national_EST, header_row)
  # select wanted columns and rows
  
  national_EST <- national_EST %>% national_EST["Turnover (£ thousand)",]
    select(c("CDID","N3Y6"))
  
  gdp_main_data <- gdp_main_data[gdp_main_data$CDID >= 2000 & gdp_main_data$CDID <= latest_year, ]
  
  gdp_main_data <- gdp_main_data[!grepl("Q", gdp_main_data$CDID),]
  
  # format
  
  gdp_main_data <- gdp_main_data %>% 
    rename("Year" = CDID, "Value" = N3Y6)
  
  scripts_run <- c(scripts_run, "17-7-1")
