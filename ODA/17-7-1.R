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
  
  
  scripts_run <- c(scripts_run, "17-7-1")
