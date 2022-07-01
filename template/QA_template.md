---
title: "template QA"
author: "Emma Wood"
date: "29/06/2022"
output: html_document
---
*This is only a template and will not produce real output as the variables *
*referred to in the code do not exist - in a real one they will be pulled from*
*the other scripts. For a working QA file similar to this template see 13-2-2*  

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

```{r load-packages, include=FALSE}
library(tidyr)
library(dplyr)
library(ggplot2)
library(DT)
```
**Run date and time: `r Sys.time()`**  
  
## Introduction

Short explanation that can include details such as:   
  
- why the indicator has been automated  
  
- what this htmml output is for e.g. 'This file runs some basic checks on the 
csv output and highlights some specific things that should manually be checked.'  
  
- specific things that should be checked in addition to reading this document 
e.g. if provisional figures are likely to be included but this info is not 
picked up by the automation you may put something like "Before putting the csv 
in the indicator file please check in the source data if the most recent 
figures are provisional. If they are, in the indicator csv file change the 
observation status to 'Provisional'."  
  
- other important info you think the user needs to be aware of.
  
## Configurations
in this section list the settings (configurations) and use snippets of code to 
print the user input. The double asterisks make the text bold, while `r` tells 
markdown to read the text inside the back-ticks as code. 

An example of what you may put in this section -
  
The configurations are:  
  
- filepath for the input data: **`r paste0(getwd(), "/", input_folder, "/", filename)`**
- name of the tab the data are in: **`r tab_name`**  
- row number of the column names: **`r header_row`** 
- location of the outputs: **`r output_folder`**  
  
  
## Basic checks
Use this section to highlight anything you think may have gone wrong in the 
code. You may want to use chunks of code within this file to perform some basic 
checks, or you may just pull in variables that were created in the main scripts 
(like with the configurations above). 

For example, when pulling data from nomis, where there are multiple year
types (e.g. Jan to Dec, Apr to March etc), it may not be clear just from the 
output which data have been pulled from nomis. In such a case this section may read


We should only use data for the calendar year (Jan-Dec). The months contained in 
the data for this run are: `r unique_months_retained`.  If the given months are 
incorrect please check the nomis selections are correct, and regenerate the link 
(see the 3-c-1 README file).

```{r, include=FALSE}
if (not_all_data_available == TRUE) {
  print(paste("NOTE: Data for", dataset_behind, "data are only available up to", 
              max_years$max_year[max_years$dataset == dataset_behind], 
              ", though data for", max_years$dataset[max_years$dataset != dataset_behind],
              "are available up to", max_years$max_year[max_years$dataset != dataset_behind]))
}
```
In other updates, this section may be much more basic, for example just checking 
that the geography given in the table title matches the geography in the output.
  
Sometimes, there may not be anything that needs to go in here, in which case 
feel free to leave the section out.  

## Plots
Please check the plots below for any differences between the live and new data.
Live data will appear over the top of new data, so if you don't see points for
the new data on dates where there is also live data this is a good thing.  

```{r, echo = FALSE, fig.width=10}
live_data <- read.csv('https://raw.githubusercontent.com/ONSdigital/sdg-data/master/data/indicator_3-c-1.csv')
if("Sex" %in% names(live_data)){
  live_data <- live_data %>% 
    filter(Sex %in% c("All persons", ""))
}
new_data <- csv_formatted %>% 
  mutate(Year = as.integer(Year),
         dataset = "new") %>% 
  rename("Occupation.minor.group" = "Occupation minor group",
         "Occupation.unit.group" = "Occupation unit group") 

# join to the new data
joined_data <- live_data %>% 
  mutate(dataset = "live") %>% 
  bind_rows(new_data) %>% 
  mutate(Region = ifelse(is.na(Region), "", Region),
         Country = ifelse(is.na(Country), "", Country))
# plot the data
country_minor_plot <- joined_data %>% 
  filter(Region == "" & Occupation.unit.group == "" ) %>% 
  ggplot(.,
         aes(x = Year,
             y = Value,
             colour = dataset)) +
  geom_point() +
  geom_line() +
  facet_grid(Occupation.minor.group ~ Country) +
  theme_bw() +
  ggtitle("Country by Occupation minor group")
# country by unit group
country_unit_plot <- joined_data %>% 
  filter(Region == "" & Occupation.unit.group != "" ) %>% 
  ggplot(.,
         aes(x = Year,
             y = Value,
             colour = dataset)) +
  geom_point() +
  geom_line() +
  facet_grid(Occupation.unit.group ~ Country) +
  theme_bw() +
  ggtitle("Country by Occupation unit group")
# region by minor group
region_minor_plot <- joined_data %>% 
  filter(Country == "England" & Occupation.unit.group == "" ) %>% 
  ggplot(.,
         aes(x = Year,
             y = Value,
             colour = dataset)) +
  geom_point() +
  geom_line() +
  facet_grid(Region ~ Occupation.minor.group) +
  theme_bw() +
  ggtitle("Region by Occupation minor group")
region_unit_plot <- joined_data %>% 
  filter(Country == "England" & Occupation.unit.group != "" ) %>% 
  ggplot(.,
         aes(x = Year,
             y = Value,
             colour = dataset)) +
  geom_point() +
  geom_line() +
  facet_grid(Region ~ Occupation.unit.group) +
  theme_bw()  +
  ggtitle("Region by Occupation unit group")
```

```{r, echo = FALSE, fig.width=10, fig.height = 10}
suppressMessages(print(country_minor_plot))
```

```{r, echo = FALSE, fig.width=10, fig.height=15}
suppressMessages(print(country_unit_plot))
```

```{r, echo = FALSE, fig.width=10, fig.height=15}
suppressMessages(print(region_minor_plot))
```

```{r, echo = FALSE, fig.width=15, fig.height = 15}
suppressMessages(print(region_unit_plot))
```

## Introduction

## Things to check manually
Are the most recent figures provisional? Check this in the source data. If they 
are, in the indicator csv file change the observation status to 'Provisional'.