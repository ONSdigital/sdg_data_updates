# Author: Atanaska Nikolova (March 2021)
# function and code to get data for part a) for indicator 15.a.1 and duplicate 15.b.1
# Part a) is Official development assistance on conservation and sustainable use of biodiversity
# the function takes arguments data_underlying_SID (as a csv file) and CRScode (41030 is biodiversity)
# currently only a single CRS code is supported, but can be extended to multiple (if such disaggregation is needed)
# output is year x income group (DAC classification) breakdown of net ODA


setwd("W:\\Data Collection and Reporting\\Jemalex\\QA\\15.a.1_15.b.1") #wd where the SID input files are

# main function to run

biodiversity_ODA<- function(data_underlying_SID, CRScode){
  
  colnames(data_underlying_SID)[ncol(data_underlying_SID)] <- "ODA"
  
  biodiversity <- aggregate(data_underlying_SID$ODA,
                            by=list(Year=data_underlying_SID$Year, 
                                    IncomeGroup=data_underlying_SID$IncomeGroup,
                                    CRS_code=data_underlying_SID$SectorPurposeCode.CRScode.==CRScode), 
                            FUN=sum)
  
  biodiversity <- biodiversity[biodiversity$CRS_code==TRUE,]
  
  biodiversity[biodiversity$CRS_code==TRUE,"CRS_code"] <- 41030
  
  colnames(biodiversity)[4] <- "ODA(£thousands)"
  
  return(biodiversity)
}


# example run on two separate SID files:
# save the SID file as .csv
# NB: make sure the last column (the net ODA) is formatted as numbers- no mixture of comma or fullstop in the values
# the function takes arguments data_underlying_SID (the csv file) and CRScode (41030 is biodiversity)


bio_201719 <- biodiversity_ODA(data_underlying_SID = read.csv("Data_Underlying_SID_2019.csv",header=T), 
                              CRScode = 41030)
bio_200916 <- biodiversity_ODA(data_underlying_SID = read.csv("data-underlying-the-sid2017-revision-March.csv",
                                                             header=T), CRScode = 41030)


# creating a final table to use in the Indicator csv
final_table<- rbind(bio_200916,bio_201719)  

#grouping up income group that doesn't follow official DAC into "Undefined"
final_table[(final_table$IncomeGroup=="0" | final_table$IncomeGroup== "Part I unallocated by income"),"IncomeGroup"]<-"Undefined"

#adding totals for the headline and combining with the final table
headline <- aggregate(final_table$`ODA(£thousands)`, by=list(Year = final_table$Year), FUN = sum)

colnames(headline)[2] <- "ODA(£thousands)"

headline$IncomeGroup < - ""
headline$CRS_code <- 41030

final_table <- rbind(final_table, headline)

write.csv(final_table,"Ind_15a1_15b1_a.csv")
