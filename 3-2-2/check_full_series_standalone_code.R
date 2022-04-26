# script for QAing full series (early and late neonatal data have been added for all years 06/10/2021)

library(dplyr)
library(ggplot2)

old_data <- read.csv("Y:/Data Collection and Reporting/Jemalex/CSV/indicator_3-2-2.csv") %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(Region = case_when(
    Region == "East of England" ~ "East", 
    Region == "Yorkshire and the Humber" ~ "Yorkshire and The Humber",
    TRUE ~ as.character(Region))) %>% 
  rename(Birthweight = Birth.weight,
         `Health board` = Health.Board,
         Units = Unit.measure,
         `Unit multiplier` = Unit.multiplier,
         `Observation status` = Observation.status) %>% 
  filter(`Health board` == "") %>% 
  select(-`Health board`) %>% 
  mutate(dataset = "live") %>% 
  mutate(Value = round(Value, 1))

new_data <- read.csv("D:/coding_repos/sdg_data_updates/3-2-2/Output/years_compiled.csv") %>% 
  mutate(dataset = "new") %>% 
  rename(`Unit multiplier` = Unit.multiplier,
         `Observation status` = Observation.status) 

all_data <- old_data %>% 
  bind_rows(new_data) %>% 
  mutate(Neonatal.period = ifelse(is.na(Neonatal.period), "Neonatal", 
                                  as.character(Neonatal.period))) %>% 
  mutate(period_and_dataset = paste0(Neonatal.period, "_", dataset)) %>% 
  mutate(reliability = ifelse(`Observation status`== "Low reliability", Value, NA))

plot_data <- function(dat) {
  
  ggplot(data = dat,
         aes(x = Year,
             y = Value)) +
    geom_point(aes(colour = period_and_dataset)) +
    geom_point(y = dat$reliability, 
               size = 2, shape = 1) +
    geom_line(aes(colour = period_and_dataset)) +
    # facet_grid(Sex ~ Country) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))
  
}

country_sex_plot_data <- all_data %>% 
  filter(Birthweight == "" &
           Region == "" &
           Age == "" & 
           (Country.of.birth == "" | is.na(Country.of.birth))) 
plot_data(country_sex_plot_data) + 
  facet_grid(Sex ~ Country)


age_weight_plot_data <- all_data %>% 
  filter(Region == "" &
           Sex == "" &
           # Birthweight == "" &
           Age != "Not stated" &
           (Country == "England and Wales" | Country == "England and Wales linked deaths") & 
           (Country.of.birth == "" | is.na(Country.of.birth))) 
plot_data(age_weight_plot_data) + 
  facet_grid(Birthweight ~ Age)
# remove cross-disaggregation as it is largely unreliable (except for the grouped ones, which can be kept)

region_plot_data <- all_data %>% 
  filter(Birthweight == "" &
           Sex == "" &
           Age == "" &
           Country == "England" & 
           (Country.of.birth == "" | is.na(Country.of.birth)))  
plot_data(region_plot_data) + 
  facet_grid(. ~ Region) 
  
  

