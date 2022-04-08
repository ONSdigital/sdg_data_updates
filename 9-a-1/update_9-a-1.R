# date: 29/03/2022
# Author: Atanaska Nikolova



# The code is contained in one large function that does everything
# It is then called from compile_tables.R

ODA_9.a.1 <- function(data_underlying_SID){
  colnames(data_underlying_SID)[ncol(data_underlying_SID)] <- "ODA"
  
  # Renaming the SIDsector rows to have a consistent name 
  # because it differs slightly between the two csv spreadsheets
  rows_to_rename <- which(grepl("Economic Infrastructure",data_underlying_SID$SIDsector))
  data_underlying_SID$SIDsector[rows_to_rename] <- "Economic Infrastructure" 
  
  # This is the SIDsector variable by which we filter the data
  SIDsector = "Economic Infrastructure"
  
  infrastructure <- aggregate(data_underlying_SID$ODA,
                              by = list(Year = data_underlying_SID$Year, 
                                        IncomeGroup = data_underlying_SID$IncomeGroup,
                                        SID_sector = data_underlying_SID$SIDsector==SIDsector), 
                              FUN = sum)
  infrastructure <- infrastructure[infrastructure$SID_sector == TRUE,]
  infrastructure[infrastructure$SID_sector == TRUE,"SID_sector"] <- "Economic Infrastructure and Services"
  colnames(infrastructure)[which(names(infrastructure) == "x")] <- "Value"
  infrastructure[(infrastructure$IncomeGroup 
                  == "0" | infrastructure$IncomeGroup 
                  == "Part I unallocated by income"),
                 "IncomeGroup"] <- "Unspecified"
  
  headline<-aggregate(infrastructure$Value,
                      by = list(Year = infrastructure$Year),
                      FUN = sum)
  headline$IncomeGroup <- ""
  headline$SID_sector <- "Economic Infrastructure and Services"
  headline$Value <- headline$x
  headline <- headline[, -2]
  
  infrastructure <- rbind(infrastructure, headline)
  infrastructure$`Observation status` <- "Definition differs"
  infrastructure$`Unit multiplier` <- "Thousands"
  names(infrastructure)[names(infrastructure) == 'IncomeGroup'] <- 'Country income classification'
  infrastructure$Units <- "GBP (£ thousands)"
  
  # we don't need the SID sector column anymore, so removing it
  infrastructure <- infrastructure[,-3]
  #reordering the columns to make compatible with csv
  infrastructure <- infrastructure[, c(1, 2, 4, 5, 6, 3)]
  infrastructure <- infrastructure[order(infrastructure$`Country income classification`),]
  
  return(infrastructure)
}




