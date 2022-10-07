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

#-------------------------------------------------------------------------------
# put this function in SDGupdater
name_columns <- function(dat, pattern, new_name){
  
  column_location <- which(apply(sapply(pattern, grepl, 
                                        names(dat)), 1, all) == TRUE)
  names(dat)[column_location] <- new_name
  return(dat)
  
}

#--------------------------------------------------------------------------------


household_total_included <- combined_data %>% 
  mutate(`length of residence` = ifelse(grepl("all", `length of residence`), 
                                        "", `length of residence`))

# we don't want to keep all disaggregations so remove them here using strings that will only appear in those names
# as we don't know if the names might change slightly in the future
unwanted_column_words <- paste(c("epriv", "omposition", "overty", "orkless", "ength"), collapse = "|")
unwanted_column_locs <- grep(unwanted_column_words, names(household_total_included))
unwanted_columns <- names(household_total_included)[unwanted_column_locs] 

# I'm sure there is a better way that doesn't use a loop but I cant think of it..
unwanted_columns_removed <- household_total_included
for(i in 1:length(unwanted_columns)) {
  unwanted_columns_removed <- unwanted_columns_removed %>% 
    filter(is.na(!!sym(unwanted_columns[i])) | 
             !!sym(unwanted_columns[i]) == "") %>% 
    select(-sym(unwanted_columns[i]))
}

renamed_columns <- name_columns(unwanted_columns_removed, 
                                "area type", "Urbanisation sub-category")
renamed_columns <- name_columns(renamed_columns, 
                                "national area", "Sub-national area")
renamed_columns <- name_columns(renamed_columns, 
                                "age.*old|old.*age", "Age of oldest person")
renamed_columns <- name_columns(renamed_columns, 
                                "age.*young|young.*age", "Age of youngest person")
renamed_columns <- name_columns(renamed_columns, 
                                "income", "Income quintile (household)")
renamed_columns <- name_columns(renamed_columns, 
                                "disab", "Disability status (household)")
renamed_columns <- name_columns(renamed_columns, 
                                "ethnicity", "Ethnicity of household reference person (HRP)")

# annoyingly the urban/rural/suburban residential totals are hidden in with the urbanisation sub-category
# so pull them into their own disaggregation here
urban_rural <- renamed_columns %>% 
  filter(grepl("all", `Urbanisation sub-category`) == TRUE) %>% 
  rename(`Urban or rural` = `Urbanisation sub-category`) 
# suburban residential is both a 'total' and a subcategory so is essentially a repetition
# which is why distinct is used
not_urban_rural <- renamed_columns %>% 
  filter(grepl("all", `Urbanisation sub-category`) == FALSE)%>% 
  distinct()

all_data <- bind_rows(urban_rural, not_urban_rural)

totals_as_blanks <- all_data
if ("government office region" %in% names(all_data)) {
  totals_as_blanks <- totals_as_blanks %>% 
    mutate(`government office region` = ifelse(grepl("all", `government office region`) == TRUE, 
                                               "", `government office region`)
    )
} 
if ("Sub-national area" %in% names(all_data)) {
  totals_as_blanks <- totals_as_blanks %>% 
    mutate(`Sub-national area` = ifelse(grepl("all", `Sub-national area`) == TRUE, 
                                               "", `Sub-national area`)
    )
} 
totals_as_blanks <- totals_as_blanks %>% 
  mutate(`decent homes criteria` = ifelse(`decent homes criteria` == "non_decent", 
                                          "", `decent homes criteria`)) %>% 
  mutate(across(everything(), ~ replace(., is.na(.), "")))


levels_renamed <- totals_as_blanks %>% 
  mutate(
    `decent homes criteria` = str_replace_all(`decent homes criteria`,"_", " "),
    `Age of oldest person` = case_when(
      `Age of oldest person` == "under 60 years" ~ "59 and under",
      `Age of oldest person` == "60 years or more" ~ "60 and over",
      `Age of oldest person` == "75 years or more" ~ "75 and over",
      TRUE ~ `Age of oldest person`),
    `Age of youngest person` = case_when(
      `Age of youngest person` == "under 5 years" ~ "4 and under",
      `Age of youngest person` == "under 16 years" ~ "15 and under",
      `Age of youngest person` == "16 years or more" ~ "16 and over",
      TRUE ~ `Age of youngest person`),
    `Disability status` = case_when(
      `Disability status (household)` == "yes" ~ "Disabled (GSS harmonised)",
      `Disability status (household)` == "no" ~ "Non-disabled (GSS harmonised)",
      TRUE ~ `Disability status (household)`),
    `Urban or rural` = case_when(
      grepl("urban", `Urban or rural`) ~ "Urban",
      grepl("rural", `Urban or rural`) ~ "Rural",
      `Urbanisation sub-category` %in% c("city centre", "other urban centre") ~ "Urban",
      `Urbanisation sub-category` %in% c("rural residential", "village centre", "rural") ~ "Rural",
      `Urbanisation sub-category` == "suburban residential" ~ "suburban residential",
      TRUE ~ `Urban or rural`),
    `Urbanisation sub-category` = ifelse(`Urbanisation sub-category` == "rural",
                                         "Other rural area", `Urbanisation sub-category`)
    ) %>% 
  mutate(across(where(is.character), str_to_sentence)) 

if ("government office region" %in% names(all_data)) {
  gors <- levels_renamed %>% 
    rename(Region = `government office region`) %>% 
    mutate(
      Region = case_when(
        Region == "yorkshire and the humber" ~ "Yorkshire and The Humber",
        TRUE ~ as.character(str_to_title(Region)) 
                          ))
} else { 
  gors <- levels_renamed
}
if ("Sub-national area" %in% names(all_data)) {
  sub_national <- gors %>% 
    mutate(`Sub-national area` = str_to_title(`Sub-national area`))
}else { 
  sub_national <- gors
}

correct_case <- sub_national  %>% 
  mutate(`decent homes criteria` = ifelse(
    grepl("inimum", `decent homes criteria`), "Minimum Standard (HHSRS)",
    `decent homes criteria`))


names(correct_case) <- str_to_sentence(names(correct_case))

if ("Region" %in% names(correct_case) & 
    "Sub-national area" %in% names(correct_case)){
  csv_data <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, `Sub-national area`, Region,
           `Urban or rural`, `Urbanisation sub-category`, 
           `Age of oldest person`, `Age of youngest person`,`Disability status (household)`,
           `Ethnicity of household reference person (hrp)`, `Income quintile (household)`, 
           Units, `Observation status`, Value)
} else if ("Region" %in% names(correct_case)  & 
           "Sub-national area" %not_in% names(correct_case)) {
  csv_data <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, Region,
           `Urban or rural`, `Urbanisation sub-category`, 
           `Age of oldest person`, `Age of youngest person`,`Disability status (household)`,
           `Ethnicity of household reference person (hrp)`, `Income quintile (household)`, 
           Units, `Observation status`, Value)
} else if ("Region" %not_in% names(correct_case)  & 
           "Sub-national area" %in% names(correct_case)) {
  csv_data <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, `Sub-national area`, 
           `Urban or rural`, `Urbanisation sub-category`, 
           `Age of oldest person`, `Age of youngest person`,`Disability status (household)`,
           `Ethnicity of household reference person (hrp)`, `Income quintile (household)`, 
           Units, `Observation status`, Value)
} else {
  csv_data <- correct_case %>% 
    select(Year, Series, Units, 
           `Decent homes criteria`, 
           `Urban or rural`, `Urbanisation sub-category`, 
           `Age of oldest person`, `Age of youngest person`,`Disability status (household)`,
           `Ethnicity of household reference person (hrp)`, `Income quintile (household)`, 
           Units, `Observation status`, Value)
}

