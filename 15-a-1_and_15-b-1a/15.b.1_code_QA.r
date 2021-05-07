library(dplyr)
library(readr)

setwd("Y:\\Data Collection and Reporting\\Jemalex\\QA\\15.a.1_15.b.1")
                               
biodiversity_ODA_VJ <- function(data_underlying_SID, CRScode){
  data_underlying_SID %>%
    select(Year, SectorPurposeCode.CRScode.,IncomeGroup, HeadlineMeasureofODA..thousands. ) %>% 
    filter(SectorPurposeCode.CRScode. == CRScode) %>% 
    group_by(IncomeGroup, Year) %>% 
    summarise(`ODA(£thousands)` = sum(HeadlineMeasureofODA..thousands.))
}

bio_201719 <- biodiversity_ODA_VJ(data_underlying_SID = read.csv("Data_Underlying_SID_2019.csv"), CRScode = 41030)

data_underlying_SID2 <- read.csv("data-underlying-the-sid2017-revision-March.csv")

data_underlying_SID2 <- data_underlying_SID2 %>% 
  rename(HeadlineMeasureofODA..thousands. = NetODA..thousands.)

bio_200916 <- biodiversity_ODA_VJ(data_underlying_SID = data_underlying_SID2, CRScode = 41030)

output_table_no_headline <- bind_rows(bio_200916, bio_201719)

headline_figs <- output_table_no_headline %>% 
  group_by(Year) %>% 
  summarise(`ODA(£thousands)` = sum(`ODA(£thousands)`))

output_table <- bind_rows(output_table_no_headline, headline_figs) %>% 
  mutate(CRS_code = "41030") 
output_table$IncomeGroup <- as.character(output_table$IncomeGroup)

output_table <- output_table %>% 
  mutate(IncomeGroup = ifelse(IncomeGroup == "0" | IncomeGroup == "Part I unallocated by income", "Undefined", IncomeGroup),
         IncomeGroup = ifelse(is.na(IncomeGroup), "", IncomeGroup)) %>% 
  select(Year, IncomeGroup, CRS_code, `ODA(£thousands)`)

write_csv(output_table, "Ind_15a1_15b1_a_QA.csv")


