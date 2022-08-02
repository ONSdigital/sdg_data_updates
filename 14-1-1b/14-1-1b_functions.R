
`%not_in%` <- Negate(`%in%`)

get_count_by_geography <- function(dataset, grouping_vars) {
  
  region_count <- dataset %>% 
    get_average_item_count(c("beach_region", grouping_vars)) %>%
    relabel_levels_region() 
  
  # NI, wales and scotland fall under 'region', so just need an additional total for England
  england_count <- dataset %>%
    filter(beach_region %not_in% c("northern ireland", "scotland", "wales")) %>%
    get_average_item_count(grouping_vars) %>%
    mutate(country = "england",
           beach_region = "all")
  
  UK_count <- dataset %>%
    get_average_item_count(grouping_vars) %>%
    mutate(country = "UK",
           beach_region = "")
  
  all_data <- bind_rows(region_count, england_count, UK_count)
  return(all_data)
}

relabel_levels_region <- function(dataset) {
  dataset %>% 
    mutate(beach_region = stringr::str_to_lower(beach_region)) %>% 
    mutate(
      country = case_when(
        beach_region %not_in% c("northern ireland", "scotland", "wales") ~ "england",
        TRUE ~ as.character(beach_region)),
      beach_region = case_when(
        beach_region %in% c("northern ireland", "scotland", "wales") ~ "",
        TRUE ~ as.character(beach_region))) 
}

get_average_item_count <- function(dataset, grouping_vars) {
  dataset %>% 
    group_by(!!! syms(grouping_vars)) %>% 
    summarise(mean_count = mean(item_count),
              median_count = median(item_count))
}


# calculating x axis breaks on ggplots
int_breaks <- function(x, n = 5){
  round_values <- pretty(x, n)
  round_values[abs(round_values %% 1) < .Machine$double.eps^0.5 ]
}