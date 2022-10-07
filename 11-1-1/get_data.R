# author: Emma Wood
# date: 22/02/2022
# Script to QA 11-1-1 and practice reducing hardcode (there is a different code already written by Max)
# reformat data on dwellings

get_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# read in data------------------------------------------------------------------
source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                         sheet = tabname,
                                         startRow = header_row,
                                         colNames = TRUE) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), tolower)) %>% 
  mutate(across(where(is.character), str_squish)) 

names(source_data) <- SDGupdater::remove_superscripts(names(source_data)) 
  
source_data <- janitor::clean_names(source_data)

# remove unwanted columns
data <- source_data[, -grep("group|sample", names(source_data))]

# make sure NAs are seen by R as real NAs
data[data == "N/A" | data == "n/a"] <- NA


# In the spreadsheet breakdown types  names (e.g. 'area type' )are in bold and 
# don't have any numbers in their row (unlike each breakdown, e.g. 'city centre')
# By counting the number of NAs in each row we can therefore identify them.
 
number_of_nas <- apply(X = is.na(data), MARGIN = 1, FUN = sum)
mode_nas <- get_mode(number_of_nas)

groups_defined <- data %>% 
  rename(group = x1) %>%
  mutate(nas_in_row = number_of_nas) %>% 
  mutate(heading = ifelse(nas_in_row > mode_nas & !is.na(group), group, NA)) %>% 
  fill(heading) %>% 
  filter(heading != group) %>% 
  select(-nas_in_row) 

# in the households data the 'percentage' title was put in its own column so needs removing
unwanted_columns <- which(substr(names(groups_defined), 1,1) == "x")

if(length(unwanted_columns) > 0){
  true_columns <- groups_defined[, -unwanted_columns]
} else {
  true_columns <- groups_defined
}

non_numerical_removed <- true_columns %>% 
  mutate(across(c(where(is.character), 
                  -c(group, heading)), as.numeric))

# FIX THIS BIT #################################################################
# The headline figure is lumped in with whichever the last heading is.
# Identify it as the heading while we only need to search one column. 
# If we did this later in the code we would have to know which column to look in.
headline_identified <- non_numerical_removed %>% 
  mutate(heading = ifelse(grepl("all"),
                        "headline", heading))
################################################################################

tidy <- headline_identified %>% 
  pivot_longer(cols = -c(group, heading),
               names_to = "decent homes criteria",
               values_to = "value") %>% 
  mutate(across(where(is.character), tolower)) %>% 
  filter(!is.na(value)) %>% 
  distinct() # because suburban residential is given twice

csv_format <- tidy %>% 
  pivot_wider(
    names_from = heading,
    values_from = group)

# disaggregations <- unique(tidy$heading)
# csv_format <- tidy
# for(j in 1:length(disaggregations)) {
#   csv_format <- csv_format %>% 
#     mutate(!!sym(disaggregations[j]) := ifelse(heading == disaggregations[j], 
#                                                group, ""))
# }

# pre_compilation_csv <- csv_format %>% 
#   select(-c(group, heading)) %>% 
#   mutate(Year = tabname,
#          `Observation status` = "Undefined",
#          `Unit multiplier` = "Units",
#          `Units` = "Percentage (%)") 


