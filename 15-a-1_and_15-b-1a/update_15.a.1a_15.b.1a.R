# Author: Atanaska Nikolova (October 2021)
# function and code to get data for part a) for indicator 15.a.1 and duplicate 15.b.1
# Part a) is Official development assistance on conservation and sustainable use of biodiversity
# the function takes arguments data_underlying_SID (as a csv file)
# output is year x income group (DAC classification) breakdown of gross ODA (AmountExtended variable)


# main function

ODA_15.a.1 <- function(data_underlying_SID){
  CRScode <- 41030
  colnames(data_underlying_SID)[ncol(data_underlying_SID)-2] <- "GrossODA"
  
  # removing blank cells for AmountExtended - equalising to 0 to avoid NAs
  data_underlying_SID[which(is.na(data_underlying_SID$GrossODA)),"GrossODA"] <- 0
  
  biodiversity <- aggregate(data_underlying_SID$GrossODA,
                            by = list(Year = data_underlying_SID$Year, 
                                      IncomeGroup = data_underlying_SID$IncomeGroup,
                                      CRS_code = data_underlying_SID$SectorPurposeCode.CRScode. == CRScode), 
                            FUN = sum)
  biodiversity <- biodiversity[biodiversity$CRS_code == TRUE,]
  biodiversity <- biodiversity[ , -3]
  
  colnames(biodiversity)[3] <- "ODA(£thousands)"
  
  # grouping up income group that doesn't follow official DAC into "Undefined" for consistency
  biodiversity[(biodiversity$IncomeGroup == "0" | biodiversity$IncomeGroup == "Part I unallocated by income"),
               "IncomeGroup"] <- "Unspecified"
  # adding totals to cleare the headline and combine with the final table
  headline <- aggregate(biodiversity$`ODA(£thousands)`, 
                        by=list(Year = biodiversity$Year),
                        FUN = sum)
  colnames(headline)[2] <- "ODA(£thousands)"
  headline$IncomeGroup <- ""
  
  biodiversity <- rbind(biodiversity,headline)
  
  return(biodiversity)
}


