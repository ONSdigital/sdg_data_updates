# Author: Atanaska Nikolova (October 2021)
# function code to get data for part a) for indicator 15.a.1 and duplicate 15.b.1
# Part a) is Official development assistance on conservation and sustainable use of biodiversity
# the function takes arguments data_underlying_SID (as a csv file)
# output is year x country income group (DAC classification) breakdown of gross ODA (AmountExtended variable)


ODA_15.a.1 <- function(data_underlying_SID){
  CRScode <- 41030
  
  # putting the data frame columns in lower case and renaming the key column for the sums,
  # so if it changes order in the source file the code won't get affected
  names(data_underlying_SID) <- tolower(names(data_underlying_SID))
  data_underlying_SID <- rename_column(dat = data_underlying_SID,
                primary = "amountsextended",
                alternate = "extended",
                new_name = "GrossODA")
 
  
  # removing blank cells for GrossODA - equalising to 0 to avoid NAs
  data_underlying_SID[which(is.na(data_underlying_SID$GrossODA)),"GrossODA"] <- 0
  
  biodiversity <- aggregate(data_underlying_SID$GrossODA,
                            by = list(Year = data_underlying_SID$year, 
                                      `Country income classification` = data_underlying_SID$incomegroup,
                                      CRS_code = data_underlying_SID$sectorpurposecode.crscode. == CRScode), 
                            FUN = sum)
  biodiversity <- biodiversity[biodiversity$CRS_code == TRUE,]
  biodiversity <- biodiversity[ , -3]
  
  colnames(biodiversity)[which(names(biodiversity) == "x")] <- "Value"
  
  # grouping up income group that doesn't follow official DAC into "Undefined" for consistency
  biodiversity[(biodiversity$`Country income classification` == 
                  "0" | biodiversity$`Country income classification` == 
                  "Part I unallocated by income"),
                  "Country income classification"] <- "Unspecified"
  
  # adding totals to the headline and combine with the final table
  headline <- aggregate(biodiversity$`Value`, 
                        by=list(Year = biodiversity$Year),
                        FUN = sum)
  colnames(headline)[2] <- "Value"
  headline$`Country income classification` <- ""
  
  biodiversity <- rbind(biodiversity,headline)
  
  # divide by 1000 to get millions instead of thousands (will change the col name after)
  biodiversity$`Value` <- biodiversity$`Value` / 1000
  
  return(biodiversity)
}


