# Author: Atanaska Nikolova (August 2023)
# code to get data for indicator 17.7.1 
# the function takes arguments data_underlying_SID_1 and data_underlying_SID_2 (as csv files)
# These are the ods SID spreadsheets downloaded from the source (currently two sets covering all available years)
# save the SID file as .csv but BEFORE you do that:
#   make sure the last column (the net ODA) is formatted as numbers and extend to 4 decimal places 
# output is year x net ODA for Environmentally Sound Technologies (EST)


# example datasets SID files: #USE ODA renamed

#data_underlying_SID_1 <- read.csv("D:\\SDG general\\SDG_updates\\dataunderSID-Final2020.csv",header=T)
#data_underlying_SID_2 <- read.csv("D:\\SDG general\\SDG_updates\\data-underlying-sid-2017.csv",header=T)


#ODA_17.7.1 <- function(data_underlying_SID_1,data_underlying_SID_2){
  #oda_renamed <- list(data_underlying_SID_1, data_underlying_SID_2)
  #library(stringr)
  
  
  
  
  #creating some empty lists that will be populated in the loop below
  #SID_filtered <- vector(mode = "list", length = length(oda_renamed))
  #EST_funding <- vector(mode = "list", length = length(oda_renamed))
  
#  for(i in 1:length(oda_renamed)){
 #   colnames(oda_renamed[[i]])[ncol(oda_renamed[[i]])] <- "ODA"
  
  #  oda_renamed[[i]]$LongDescription <- tolower(oda_renamed[[i]]$LongDescription)
   # oda_renamed[[i]]$ProjectTitle <- tolower(oda_renamed[[i]]$ProjectTitle)
  
    oda_renamed$EST_ProjectTitle <- sapply(str_extract_all(oda_renamed$projecttitle, paste("\\b", EST, "\\b", sep="", collapse="|")), paste, collapse=",")
    oda_renamed$EST_LongDesc <- sapply(str_extract_all(oda_renamed$longdescription, paste("\\b", EST, "\\b", sep="", collapse="|")), paste, collapse=",")
  
    oda_renamed <- oda_renamed[oda_renamed$EST_ProjectTitle != "" | oda_renamed$EST_LongDesc != "", ]
  
    EST_funding <- aggregate(oda_renamed$net_oda,
                           by = list(Year = oda_renamed$year),
                           FUN = sum)
  
    colnames(EST_funding)[2] <- "Value"
  #}
  #EST_funding <- do.call("rbind", EST_funding)
  #EST_funding <- EST_funding[order(EST_funding$Year),]
  #return(EST_funding)
#}

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
#example call
#EST_funding <- ODA_17.7.1(data_underlying_SID_1, data_underlying_SID_2)

#write.csv(EST_funding,"D:\\SDG general\\SDG_updates\\17.7.1.csv")
