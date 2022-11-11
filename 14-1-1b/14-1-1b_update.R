# Author: Emma Wood
# Date of original script: June 2022
# Purpose: 1. To create tables for publication (originally ad-hoc, but to go in 
#             NatCap accounts in the future)
#          2. To create csv for SDG website
# Other info: This script is called by compile_tables.R

# read in and clean data -------------------------------------------------------
original_data <- read.csv(paste0(input_folder, "/", filename_main_data))

main_clean <- original_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), tolower)) %>% 
  mutate(across(where(is.character), str_squish)) %>% 
  janitor::clean_names() %>% 
  mutate(date = as.Date(date_of_survey, format = "%d/%m/%Y"),
         last_cleaned = as.Date(date_beach_was_last_cleaned, format = "%d/%m/%Y"),
         # time_survey_starts = strptime(time_survey_starts, "%H:%M"),#
         total_volunteer_hours = as.numeric(total_volunteer_hours),
         total_volunteer_count = as.numeric(total_volunteer_count),
         length_surveyed = as.numeric(length_surveyed))

# Retain the original format of the sources data for use in the table output
sources_data_original <- read.csv(paste0(input_folder, "/", filename_sources)) 

sources_data <- sources_data_original %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), tolower)) %>% 
  mutate(across(where(is.character), str_squish)) %>% 
  janitor::clean_names()

# In the first data we were sent the stretch of beach cleaned was referred to as 
# 'beach'. In the second data set beach was replace with stretch. 
# This bit of code just makes sure that it will still run regardless of which 
# term is used. 
# I didn't change 'beach' to 'stretch' because in the newer data set there are 
# more columns with 'beach' in the name. Instead I change 'stretch' back to 'beach'. 
names(main_clean)[grepl("stretch", names(main_clean))] <- str_replace(
  names(main_clean)[grepl("stretch", names(main_clean))], "stretch", "beach")

sources <- sources_data %>% 
  SDGupdater::rename_column(primary = "item", new_name = "type") %>% 
  mutate(type = make_clean_names(type)) %>% 
  # there were a few discrepancies between litter names in the main data and in
  # the sources data. This removes the differences:
  mutate(type = ifelse(str_sub(type, -4, -1) == "_old",
                       str_replace(type, "_old", ""), type),
         type = ifelse(str_sub(type, -4, -1) == "_new",
                       str_replace(type,"_new", ""), type)) 

# remove unwanted data ---------------------------------------------------------
UK_data <- main_clean %>% 
  mutate(remove = case_when(
    beach_name == "" & is.na(beach_latitude) & beach_region == "" ~ TRUE,
    beach_region %in% c("channel islands", "republic of ireland") ~ TRUE,
    TRUE ~ FALSE)) %>% 
  filter(remove == FALSE)

GBBC_from_2008 <- UK_data %>% 
  filter(survey_window == "gbbc" &
           year >= 2008 & 
           length_surveyed == 100)

# we don't want to include unidentified small plastic pieces (under 2.5cm), 
# but can't be 100% sure the name will stay the same, so find out which column 
# it is and drop this
small_pieces_name <- names(GBBC_from_2008)[which(grepl("plastic", names(GBBC_from_2008)) & 
                                             grepl("piece", names(GBBC_from_2008)) &
                                             grepl("0_2_5cm", names(GBBC_from_2008)))]

plastics <- GBBC_from_2008 %>% 
  select(year, survey_id, beach_id_new, beach_id_old, beach_region, beach_country, date,
         time_survey_starts, total_volunteer_hours, total_volunteer_count,
         length_surveyed, average_width_of_surveyed_beach, survey_duration,
         last_cleaned,
         contains(plastic_keywords),
         -!!small_pieces_name) 

# checks for Rmarkdown file ----------------------------------------------------

# There is potential for a typo to lead to some wanted columns (especially 
# litter types) being removed in the last block of code. 
# This object (columns_removed) is used in the Rmarkdown file as a check that 
# this hasn't occurred.
columns_removed <- setdiff(names(GBBC_from_2008), names(plastics))

# In any new data we will need to check cleans that look like repeats to see if 
# they conflict (in which case they may need to be deleted) or should clearly be
# added together (e.g. if a form from one volunteer is forgotten then added on 
# later the date, time, number of volunteers etc will all be the same, but one
# entry will have lower litter counts)
cleans_count <- plastics %>% 
  group_by(beach_id_new, date, time_survey_starts, last_cleaned) %>% 
  count() 

multi_cleans <- filter(cleans_count, n > 1)

possible_repeats <- multi_cleans %>% 
  left_join(plastics, by = c("beach_id_new", "date", 
                             "time_survey_starts", "last_cleaned"))

# join specific cleans to be a single entry ------------------------------------

# identify which columns contain counts of litter items as these are the columns 
# we need to add, and which we don't (we don't want to accidentally add 
# e.g. volunteer numbers or length of survey)
litter_columns <- str_subset(names(plastics), "plastic|rubber|sanitary|medical|faeces")
litter_count_columns <- litter_columns[-grep("desc", litter_columns)]

cleans_to_merge <- plastics %>%
  filter(survey_id %in% surveys_to_sum) %>%
  group_by(year, beach_id_new) 

cols_not_summed <- cleans_to_merge %>%
  select(-c(all_of(litter_columns))) %>%
  distinct()

counts_summed <- cleans_to_merge %>% 
  # it is possible we will want to look at the descriptive columns in the 
  # future so that info is also summed though we don't currently use it.
  summarise(across(!!litter_columns & where(is.character), 
                   ~ paste0(., collapse = ", ")),
            across(!!litter_columns & where(is.numeric), 
                   sum)) %>% 
  left_join(cols_not_summed, by = c("year", "beach_id_new"))

# all other entries need to be kept as they are, and then the summed counts 
# joined back on
multi_cleans_removed <- plastics %>% 
  filter(survey_id %not_in% c(surveys_to_sum)) %>% 
  bind_rows(counts_summed)

# remove all but the first clean for each beach in each year--------------------

# Because we are only using one clean from each beach for each year, we need to 
# make sure we are systematic in which ones are selected.
# This can almost entirely be done by arranging the data so that the first clean
# is the one that is kept. However, in a very few cases, there is more than one
# clean that starts at the same time. We therefore arrange by all columns first
# before arranging by date and time. This means that it doesn't matter what 
# order the rows are in when we first get it - we will always get the same 
# selection provided the columns are in the same order.
extra_cleans_removed <- multi_cleans_removed %>% 
  arrange(across(everything())) %>% 
  arrange(date, time_survey_starts) %>%
  group_by(year, beach_id_new) %>%
  filter(row_number() == 1) %>% 
  ungroup()

# get data ready for calculations/ summaries -----------------------------------
tidy_data <- extra_cleans_removed %>% 
  pivot_longer(cols = all_of(litter_count_columns),
               names_to = "litter_type",
               values_to = "litter_count") %>% 
  mutate(litter_count = ifelse(is.na(litter_count), 0, litter_count)) %>% 
  mutate(litter_type = ifelse(str_sub(litter_type, -4, -1) == "_old",
                              str_replace(litter_type,"_old", ""), litter_type),
         litter_type = ifelse(str_sub(litter_type, -4, -1) == "_new",
                              str_replace(litter_type,"_new", ""), litter_type)) %>%
  left_join(sources, by = c("litter_type" = "type")) 

# for use in Rmarkdown ---------------------------------------------------------
# in case there are changes in names, we can check all litter types are 
# matched with a source, and also print out what is classifies into what source
unmatched_litter_types <- unique(tidy_data$litter_type[is.na(tidy_data$source)])
types_classified_by_source <- tidy_data %>% 
  distinct(litter_type, source)

# # commented out region as we are not reporting this at the moment - unknown boundaries
# # and some small sample sizes
# beach_count_region <- tidy_data %>% 
#   distinct(year, beach_id_new, beach_region) %>% 
#   group_by(year, beach_region) %>% 
#   count() %>% 
#   filter(beach_region %not_in% c("northern ireland", "scotland", "wales")) %>% 
#   mutate(beach_country = "england")

beach_count_country <- tidy_data %>% 
  distinct(year, beach_id_new, beach_country) %>% 
  group_by(year, beach_country) %>% 
  count() 

beach_count_uk <- beach_count_country %>% 
  group_by(year) %>% 
  summarise(n = sum(n)) %>% 
  mutate(beach_country = "UK")

beach_count <- bind_rows(#beach_count_region, 
  beach_count_country, beach_count_uk)

# Calculations -----------------------------------------------------------------
count_by_beach <- tidy_data %>% 
  group_by(year, beach_id_new, beach_region, total_volunteer_count, 
           date, last_cleaned) %>% 
  summarise(item_count = sum(litter_count, na.rm = TRUE)) 

headline_counts <- count_by_beach %>% 
  get_count_by_geography("year") %>% 
  mutate(source = "all sources")

count_by_beach_by_source <- tidy_data %>% 
  group_by(year, beach_id_new, beach_region, source) %>%
  summarise(item_count = sum(litter_count, na.rm = TRUE))

source_counts <- count_by_beach_by_source %>% 
  get_count_by_geography(c("year", "source")) 

output_data <- bind_rows(source_counts, headline_counts) %>% 
  ungroup() %>% 
  # not reporting beach region for now - we don't know what boundaries have been used
  # as they are not the standard regions, and some sample sizes are pretty low.
  # Revisit this decision at some point!
  filter(beach_region %in% c("", "all"))  %>% 
  left_join(beach_count, by = c("country" = "beach_country", "year")) %>% 
  rename(`Number of beaches` = n) %>% 
  # filter(source != "non-sourced") %>% 
  mutate(source = ifelse(source == 'sewage related debris (srd)', 
                         'sewage related debris', 
                         source)) %>% 
  mutate(country = ifelse(country == "UK", "UK", str_to_title(country)),
         # source = ifelse(source != "all plastic related litter",
                         # paste0('suspected source: ', source), source)
         ) %>% 
  mutate(source = str_to_sentence(source))

# Tables for publication -------------------------------------------------------
all_tables <- output_data %>% 
  select(year, 
         source,
         `Number of beaches`, 
         median_count,
         country) %>% 

  mutate(
    year = case_when(
    year == 2020 ~ "2020 [note 1]",
    year == 2021 ~ "2021 [note 2]",
    TRUE ~ as.character(year)
    )) %>% 
  arrange(source, country, year) %>% 
  rename(`Suspected source [note 3]` = source,
         `Median count over 100m` = median_count)
names(all_tables) <- str_to_sentence(names(all_tables))

sources_sheet <- sources_data_original
names(sources_sheet) <- c("Litter type", "Suspected source")
sources_sheet_subset <- sources_sheet %>% 
  filter(grepl("plastic|rubber|sanitary|medical|faeces", 
               str_to_lower(`Litter type` )) == TRUE) %>% 
  arrange(`Suspected source`, `Litter type`)

notes <- cbind(
  c("Notes",
    "This worksheeet contains one table.",
    "Note number",
    "note 1", 
    "note 2",
    "note 3"),
  c("",
    "",
    "Note text",
    "2020 data are not comparable to any other year: The number of volunteers participating in each beach clean was significantly lower than in any other year. As the estimate of beach litter increases with volunteer number, this is likely to have led to an under-estimation of litter present. Due to Covid restrictions the frequency of beach cleans throughout the year is also likely to have been different to other years. This may also have impacted the estimate for 2020",
    "Volunteer numbers in 2021 were higher than usual. As the estimate of beach litter increases with volunteer number, this is likely to have led to an over-estimation of litter present compared to other years.",
    "Not all litter types have been assigned a suspected source. Prevalence of litter from one source cannot therefore be compared to prevalence of litter from another source. For example, these data cannot be used to say what is the biggest or smalllest source of plastic litter. They can, however, be used to assess the trends in each litter source over time.")) 

uk <- all_tables %>% 
  filter(Country == "UK") %>% 
  select(-Country)
england <- all_tables %>% 
  filter(Country == "England") %>% 
  select(-Country)
ni <- all_tables %>% 
  filter(Country == "Northern Ireland") %>% 
  select(-Country)
scotland <- all_tables %>% 
  filter(Country == "Scotland") %>% 
  select(-Country)
wales <- all_tables %>% 
  filter(Country == "Wales") %>% 
  select(-Country)


# Create indicator csv_output ---------------------------------------------------------

# # In trying to decide what should be classed as a small sample size, I did some
# # googling - as we are not conducting significance tests there is no clear way
# # to go about this.
# # As a broad brush approach I imagined we would want to know if a change of
# # about 100 items (based on the change we see in the data over the whoe series)
# # between any two time-points is 'real'.
# # I would say we are therefore looking to detect a 'large' effect size.
# # 
# # I used the pwr package to estimate what a minimum sample size would be to
# # detect a significant 'large' effect (d - see below) at the 0.05 significance
# # level and 0.9 power level
# # According to https://www.statmethods.net/stats/power.html, for a two-sided
# # t-tests 'Cohen suggests that d values of 0.2, 0.5, and 0.8 represent small,
# # medium, and large effect sizes respectively.'
# pwr.t.test(d=0.8, sig.level=.05, power = .90, type = 'two.sample')
# # This gives a sample size of 33.8. 
# # To err on the side of caution I have therefore marked samples of less than
# # 35 beaches as having a 'small sample size'

csv_output_all <- output_data %>% 
  mutate(
    `Observation status` = case_when(
      `Number of beaches` < 35 & year != 2020 ~ "Low reliability",
      year == 2020 & `Number of beaches` >= 35~ "Time series break",
      `Number of beaches` < 35 & year == 2020 ~ "Low reliability; Time series break",
      TRUE ~ "Normal value"),
    Series = "Plastic beach litter density",
    source = case_when(
      grepl('Suspected source', source) ~ substr(source, 19, length(source)),
      grepl('all', tolower(source)) ~ '',
      TRUE ~ as.character(source)),
    country = ifelse(
      country == "UK", "", country),
    Units = "Median count") %>% 
  select(year, country, source, Units, `Observation status`, median_count, `Number of beaches`) %>% 
  rename(Value = median_count,
         `Suspected source` = source) 

if (remove_unreliable_values == TRUE) {
  csv_output <- csv_output_all %>% 
    mutate(Value = ifelse(`Number of beaches` < 4, NA, Value),
           `Observation status` = ifelse(`Number of beaches` < 4, 
                                         "Missing value; suppressed", 
                                         `Observation status`)) %>% 
    select(-`Number of beaches`)
} else {
  csv_output <- csv_output_all %>% 
    select(-`Number of beaches`)
}

names(csv_output) <- str_to_sentence(names(csv_output))


