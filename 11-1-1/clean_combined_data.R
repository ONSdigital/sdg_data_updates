# author: Emma Wood
# date: 22/02/2022
# Most of the data cleaning happens in get_data, but there are a few extra bits to do 
#   once household and dwelling data have been combined, which is what this script does

## Still to do - 
# settle on final wording of disaggs
# Is urban/rural column wanted?
# Settle on column order
# order rows


# readme - note that if the order of disaggregations changes in the source file,
# the totals will get picked up incorrectly

#--------------------------------------------------------------------------------

# If we decide not to keep all disaggregations we could remove them here using
# strings that will only appear in those names ( as we don't know if the names
# might change slightly in the future)
unwanted_column_words <- paste(c("deprived districts", "arget"
                                 #, "epriv", "omposition", "overty", "orkless", "ength"
                                 ), collapse = "|")
unwanted_column_locs <- grep(unwanted_column_words, names(combined_data))
unwanted_columns <- names(combined_data)[unwanted_column_locs] 

# I'm sure there is a better way that doesn't use a loop but I cant think of it..
unwanted_columns_removed <- combined_data

if (length(unwanted_columns) > 0) {
  for(i in 1:length(unwanted_columns)) {
    unwanted_columns_removed <- unwanted_columns_removed %>%
      filter(is.na(!!sym(unwanted_columns[i])) |
               !!sym(unwanted_columns[i]) == "") %>%
      select(-sym(unwanted_columns[i]))
  }
}

renamed_columns <- unwanted_columns_removed %>% 
  rename_column(primary = "area type", 
                new_name = "Urbanisation sub-category") %>% 
  # rename_column(primary = "national area",
  #               new_name = "Sub-national area") %>% 
  rename_column(primary = "age.*old|old.*age",
                new_name = "Age of oldest person") %>% 
  rename_column(primary =  "age.*young|young.*age",
                new_name = "Age of youngest person") %>% 
  rename_column(primary = "income",
                new_name = "Income quintile (household)") %>% 
  rename_column(primary = "disab",
                new_name = "Disability status (household)") %>% 
  rename_column(primary = "ethnicity",
                new_name = "Ethnicity of household reference person (HRP)") %>% 
  rename_column(primary = "deprived local areas",
                new_name = "Deprivation decile") %>% 
  rename_column(primary = "poverty",
                new_name = "Poverty status") 

# There are some breakdowns we know are not in every year. Wrap these in if 
# statements so they don't throw a warning 
if ("Sub-national area" %in% names(renamed_columns)) {
  sub_national <- renamed_columns %>% 
    mutate(`Sub-national area` = str_to_title(`Sub-national area`)) %>% 
    mutate(across(where(is.character), str_to_sentence)) 
}else { 
  sub_national <- renamed_columns %>% 
    mutate(across(where(is.character), str_to_sentence)) 
}

if (any(grepl("region", names(renamed_columns)))) {
  gors <- sub_national %>% 
    rename_column(primary = "region",
                  new_name = "Region") %>% 
    mutate(
      Region = case_when(
        Region == "Yorkshire and the humber" ~ "Yorkshire and The Humber",
        TRUE ~ as.character(str_to_title(Region)) 
      ))
} else { 
  gors <- sub_national
}

names(gors) <- str_to_sentence(names(gors))

# annoyingly the data aren't broken down by our standard urban/rural grouping.
# Instead the 'totals' are 'all city and urban centres', 'suburban residential'
# and 'all rural areas'. I think if you sum the first 2 you would get 'urban'
# but I can't find anything to confirm that, so will stick to urbanisation sub-category.
# The other not-quite-Urban/Rural disagg needs to be removed 
urbanisation_cleaned <- gors %>% 
  filter(grepl("all", tolower(`Urbanisation sub-category`)) == FALSE) %>% 
  # suburban residential is both a 'total' and a subcategory so remove the repeat
  distinct()

totals_as_blanks <- urbanisation_cleaned
if ("Region" %in% names(urbanisation_cleaned)) {
  totals_as_blanks <- totals_as_blanks %>% 
    mutate(Region = ifelse(grepl("all", Region) == TRUE, 
                           "", Region)
    )
} 
if ("Sub-national area" %in% names(urbanisation_cleaned)) {
  totals_as_blanks <- totals_as_blanks %>% 
    mutate(`Sub-national area` = ifelse(grepl("all", `Sub-national area`) == TRUE, 
                                               "", `Sub-national area`)
    )
} 
totals_as_blanks <- totals_as_blanks %>% 
  mutate(`Decent homes criteria` = ifelse(
    grepl("non", tolower(`Decent homes criteria`)), "", `Decent homes criteria`)
  ) 

levels_renamed <- totals_as_blanks %>% 
  mutate(
    `Decent homes criteria` = str_replace_all(`Decent homes criteria`,"_", " "),
    `Age of oldest person` = case_when(
      `Age of oldest person` == "Under 60 years" ~ "59 and under",
      `Age of oldest person` == "60 years or more" ~ "60 and over",
      `Age of oldest person` == "75 years or more" ~ "75 and over",
      TRUE ~ `Age of oldest person`),
    
    `Length of residence` = str_replace(`Length of residence`, "-", " to "),
    
    `Age of youngest person` = case_when(
      `Age of youngest person` == "Under 5 years" ~ "4 and under",
      `Age of youngest person` == "Under 16 years" ~ "15 and under",
      `Age of youngest person` == "16 years or more" ~ "16 and over",
      TRUE ~ `Age of youngest person`),
    
    `Disability status (household)` = case_when(
      `Disability status (household)` == "Yes" ~ "Disabled (GSS harmonised)",
      `Disability status (household)` == "No" ~ "Non-disabled (GSS harmonised)",
      TRUE ~ `Disability status (household)`),

    `Urbanisation sub-category` = ifelse(`Urbanisation sub-category` == "Rural",
                                         "Other rural area", 
                                         `Urbanisation sub-category`),
    
    `Poverty status` = case_when(
      grepl("no", tolower(`Poverty status`)) ~ "Not living in poverty", 
      grepl("no", tolower(`Poverty status`)) == FALSE & 
        grepl("in", tolower(`Poverty status`)) ~ "Living in poverty",
      TRUE ~ `Poverty status`),
    
    `Deprivation decile` = case_when(
      grepl("most", tolower(`Deprivation decile`)) ~ "Decile 10 (most deprived)",
      `Deprivation decile` == "2nd" ~ "Decile 9",
      `Deprivation decile` == "3rd" ~ "Decile 8",
      `Deprivation decile` == "4th" ~ "Decile 7",
      `Deprivation decile` == "5th" ~ "Decile 6",
      `Deprivation decile` == "6th" ~ "Decile 5",
      `Deprivation decile` == "7th" ~ "Decile 4",
      `Deprivation decile` == "8th" ~ "Decile 3",
      `Deprivation decile` == "9th" ~ "Decile 2",
      grepl("least", tolower(`Deprivation decile`)) ~ "Decile 1 (least deprived)",
      TRUE ~ `Deprivation decile`),
    
    `Sub-national area` = case_when(
      `Sub-national area` == "London and south east" ~"London and South East",
      `Sub-national area` == "Rest of england" ~ "Rest of England",
      TRUE ~ `Sub-national area`),
    
    `Ethnicity of household reference person (hrp)` = case_when(
      grepl("all", tolower(`Ethnicity of household reference person (hrp)`)) &
        grepl("minority", tolower(`Ethnicity of household reference person (hrp)`)) ~ "All minority",
      TRUE ~ str_to_sentence(`Ethnicity of household reference person (hrp)`))
    )

all_required_columns <- levels_renamed %>% 
  mutate(Units = "Percentage (%)",
         `Observation status` = "Normal value")

correct_case <- all_required_columns  %>% 
  mutate(`Decent homes criteria` = ifelse(
    grepl("inimum", `Decent homes criteria`), "Minimum standard (HHSRS)",
    `Decent homes criteria`))

columns_order <- c("Urbanisation sub-category", 
                   "Age of oldest person", "Age of youngest person",
                   "Deprivation decile",
                   "Disability status (household)",
                   "Ethnicity of household reference person (hrp)",
                   "Household composition",
                   "Income quintile (household)", "Length of residence",
                   "Poverty status", "Workless households",
                   "Observation status")

# If a column unexpectedly gets added to the source data, they will get dropped
# during the ordering of the columns unless we account for them. The values 
# associated with those columns will then look like headline figures, and it will
# be tricky to figure out the issue. Hence inclusion of `unexpected_columns`
unexpected_columns <- setdiff(names(correct_case),
                              c(columns_order, 
                                "Decent homes criteria", "Sub-national area", "Region",
                                "Year", "Series", "Units", "Value"))

if ("Region" %in% names(correct_case) & 
    "Sub-national area" %in% names(correct_case)){
  ordered_cols <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, `Sub-national area`, Region,
           all_of(columns_order), all_of(unexpected_columns),
           Value
           )
} else if ("Region" %in% names(correct_case)  & 
           "Sub-national area" %not_in% names(correct_case)) {
  ordered_cols <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, Region,
           all_of(columns_order), all_of(unexpected_columns),
           Value)
} else if ("Region" %not_in% names(correct_case)  & 
           "Sub-national area" %in% names(correct_case)) {
  ordered_cols <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, `Sub-national area`, 
           all_of(columns_order), all_of(unexpected_columns),
           Value)
} else {
  ordered_cols <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, 
           all_of(columns_order), all_of(unexpected_columns),
           Value)
}

# put disaggregation levels in the right order, as this determines the order 
# they show up on the platform dropdowns
ordered_data <- ordered_cols %>% 
  arrange(Region)

csv_data <- ordered_data %>% 
  mutate(Value = round(Value, 1)) %>% 
  distinct()
