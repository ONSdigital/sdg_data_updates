# figure 1 length by year all UK beaches, one point per survey -----------------
uk_gbbc <- UK_data %>% 
  filter(survey_window == "gbbc") %>% 
  mutate(beach_country = str_to_title(beach_country))

tidy_gbbc <- uk_gbbc %>% 
  pivot_longer(cols = all_of(litter_count_columns),
               names_to = "litter_type",
               values_to = "litter_count") 

lengths_all_surveys <- tidy_gbbc %>% 
  distinct(year, beach_country, beach_id_new, length_surveyed) 

length_plot <- lengths_all_surveys %>% 
  ggplot(.,
         aes(x = as.numeric(year),
             y = length_surveyed)) +
  geom_boxplot(aes(group = year)) +
  facet_wrap(vars(beach_country), 
             nrow = 2) +
  geom_hline(yintercept = 100,
              colour = "red") +
  theme_bw(base_size = 16) +
  ylim(0, 5000) +
  theme(axis.text.x = element_text(angle = 45,
                                   vjust = 1, hjust = 1)) +
  xlab("year") +
  ylab("length surveyed (m)") 
  
ggsave("Output/figure1.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

#-------------------------------------------------------------------------------
# figure 2 litter count per m by length surveyed, one point per survey & -------

GBBC <- UK_data %>% 
  filter(survey_window == "gbbc")

# using all years so redoing some of the steps in 14-1-b_update.R. Some 
# small cleaning steps removed and ALL GBBC cleans stay in no t just first of
# the weekend.
small_pieces_name <- names(GBBC)[which(grepl("plastic", names(GBBC)) & 
                                                   grepl("piece", names(GBBC)) &
                                                   grepl("0_2_5cm", names(GBBC)))]

plastics <- GBBC %>% 
  select(year, survey_id, beach_id_new, beach_id_old, 
         beach_region, beach_country, date,
         time_survey_starts, total_volunteer_hours, total_volunteer_count,
         length_surveyed, average_width_of_surveyed_beach,
         contains(plastic_keywords),
         -!!small_pieces_name) 

tidy <- plastics %>% 
  pivot_longer(cols = all_of(litter_count_columns),
               names_to = "litter_type",
               values_to = "litter_count") 

counts <- tidy %>% 
  group_by(year, beach_id_new, total_volunteer_count, length_surveyed) %>% 
  summarise(item_count = sum(litter_count, na.rm = TRUE)) %>% 
  mutate(density = item_count/length_surveyed)

ggplot(counts,
       aes(x = length_surveyed,
           y = density)) +
  geom_point(alpha = 0.5, 
             colour = "light blue") +
  stat_smooth(colour = "black") +
  geom_vline(xintercept = 100,
             colour = "dark red",
             linetype = 2) +
  xlim(0, 1500) +
  ylim(0, 125) +
  theme_bw(base_size = 16) +
  theme(axis.text.x = element_text(angle = 45,
                                   vjust = 1, hjust = 1)) +
  xlab("length surveyed (m)") +
  ylab("plastic litter count per metre") 

ggsave("Output/figure2.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

#-------------------------------------------------------------------------------
# figure 3, table 2 100m estimates versus all beaches --------------------------

counts <- tidy %>% 
  group_by(year, beach_id_new, beach_region, beach_country,
           total_volunteer_count, length_surveyed) %>% 
  summarise(item_count = sum(litter_count, na.rm = TRUE)) %>% 
  mutate(density = item_count/length_surveyed)

standardised <-  counts %>% 
  filter(length_surveyed == 100) %>% 
  mutate(length_group = "surveys of 100m")

all_lengths <- counts %>% 
  mutate(length_group = "surveys of any length")

length_comparison <- standardised %>%
  bind_rows(all_lengths) %>% 
  select(-item_count) %>% 
  rename(item_count = density) %>% 
  get_count_by_geography(c("year", "length_group")) %>% 
  mutate(source = "all sources",
         country = ifelse(country != "UK",
                          str_to_title(country), country),
         line_thickness = ifelse(country == "UK", "bold", "normal")) %>% 
  filter(beach_region %in% c("", "all") & 
           year >= 2004) 

ggplot(data = length_comparison,
       aes(x = year,
           y = median_count,
           colour = length_group)) +
  geom_point() +
  geom_line(aes(size = line_thickness)) +
  scale_size_manual(values = c(2, 1), guide = "none") +
  scale_x_continuous(breaks = int_breaks) +
  facet_wrap(vars(country), 
             nrow = 2) +
  theme_bw(base_size = 16) +
  theme(axis.text.x = element_text(angle = 45,
                                   vjust = 1, hjust = 1),
        legend.position = c(1, 0),
        legend.justification = c(1, 0)) +
  ylab("median plastic litter count per metre") 

ggsave("Output/figure3.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

# table 2 number of beaches by length type -------------------------------------

table_2 <- standardised %>%
  bind_rows(all_lengths) %>% 
  distinct(year, beach_id_new, length_group) %>% 
  group_by(year, beach_country, length_group) %>% 
  summarise(cases = n()) %>% 
  pivot_wider(names_from = length_group,
              values_from = cases) %>% 
  mutate(not_100m = `surveys of any length` - `surveys of 100m`)
  

#-------------------------------------------------------------------------------
# figures 4 and 5 - width of beach ---------------------------------------------
width <- tidy %>%
  filter(length_surveyed == 100 &
           # year >= 2008 &
           average_width_of_surveyed_beach != 0) %>%
  select(year, beach_id_new, beach_country,
         litter_count, average_width_of_surveyed_beach) %>%
  mutate(beach_country = str_to_title(beach_country)) 
width %>%
  group_by(year, beach_country, beach_id_new, 
           average_width_of_surveyed_beach) %>%
  summarise(item_count = sum(litter_count, na.rm = TRUE)) %>% 
  ggplot(.,
       aes(x = average_width_of_surveyed_beach,
           y = item_count)) +
  geom_point(alpha = 0.5, 
             colour = "light blue") +
  stat_smooth(colour = "black") +
  facet_wrap(vars(beach_country),
             nrow = 2) +
  xlim(0, 150) +
  ylim(0, 5000) +
  theme_bw(base_size = 16) +
  xlab("average width of beach (m)") +
  ylab("litter count per survey") 

ggsave("Output/figure4.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

width %>% 
  distinct(beach_id_new, year, beach_country, 
           average_width_of_surveyed_beach) %>% 
  filter(year >= 2008) %>% 
  ggplot(.,
       aes(x = year,
           y = average_width_of_surveyed_beach)) +
  geom_boxplot(aes(group = year))  +
  facet_wrap(vars(beach_country),
             nrow = 2) +
  ylim(0, 500) +
  theme_bw(base_size = 16) +
  theme(axis.text.x = element_text(angle = 45,
                                   vjust = 1, hjust = 1)) +
  ylab("average width of beach (m)") 

ggsave("Output/figure5.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

#-------------------------------------------------------------------------------
# figure 6 Trends in number of volunteers, by country -----------------------
# just 100m cleans sinc 2008

count_by_beach %>% 
  mutate(country = ifelse(
    beach_region %in% c("northern ireland", "scotland", "wales"),
    str_to_title(beach_region), "England")) %>%  
  ggplot(data = .,
         aes(x = as.numeric(year),
             y = total_volunteer_count)) +
  geom_boxplot(aes(group = year)) +
  facet_wrap(vars(country), 
             nrow = 2) +
  theme_bw(base_size = 16) +
  geom_hline(yintercept = 10,
             colour = "red") +
  scale_x_continuous(breaks = int_breaks) +
  theme() +
  xlab("year") +
  ylab("number of volunteers") 

ggsave("Output/figure6.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

#-------------------------------------------------------------------------------
# repeatability calculation ----------------------------------------------------
library(rptR)
library(lme4)

count_per_beach <- tidy_data %>% 
  group_by(year, beach_id_new, beach_region, 
           total_volunteer_count, survey_duration) %>% 
  summarise(item_count = sum(litter_count, na.rm = TRUE)) %>% 
  mutate(year = as.factor(year),
         beach_id_new = as.factor(beach_id_new)) %>% 
  # there are two surveys where the item cout is 0. this cant be logged, so
  # make these 1 (won't have any real effect on the meaning)
  mutate(item_count = ifelse(item_count == 0,
                             1, item_count))

count_per_beach$z_num_vol <- scale(count_per_beach$total_volunteer_count)
count_per_beach$z_duration <- scale(count_per_beach$survey_duration)
 
full_mod <- lmer(log(item_count) ~
                  scale(z_duration) + I(z_duration^2) +
                   z_num_vol + I(z_num_vol^2) +
                   z_duration:z_num_vol +
                   I(z_duration^2):I(z_num_vol^2) +
                   z_duration:I(z_num_vol^2) +
                   I(z_duration^2):z_num_vol +
                   (1|beach_id_new),
                data = count_per_beach)
summary(full_mod)
 
drop1(full_mod, test = "Chisq")

full_mod_2 <- lmer(log(item_count) ~
                   scale(z_duration) + I(z_duration^2) +
                   z_num_vol + I(z_num_vol^2) +
                   z_duration:z_num_vol +
                   I(z_duration^2):I(z_num_vol^2) +
                   z_duration:I(z_num_vol^2) +
                   (1|beach_id_new),
                 data = count_per_beach)
drop1(full_mod_2, test = "Chisq")

full_mod_3 <- lmer(log(item_count) ~
                     scale(z_duration) + I(z_duration^2) +
                     z_num_vol + I(z_num_vol^2) +
                     z_duration:z_num_vol +
                     z_duration:I(z_num_vol^2) +
                     (1|beach_id_new),
                   data = count_per_beach)
drop1(full_mod_3, test = "Chisq")
plot(resid(full_mod_3) ~ fitted(full_mod_3))


repeatability_by_beach <- rpt(log(item_count) ~ 
                                scale(z_duration) + I(z_duration^2) +
                                z_num_vol + I(z_num_vol^2) +
                                z_duration:z_num_vol +
                                z_duration:I(z_num_vol^2) +
                                (1 | beach_id_new),
                              grname = "beach_id_new", 
                              data = count_per_beach, 
                              datatype = "Gaussian",
                              nboot = 1000, npermut = 0)


#-------------------------------------------------------------------------------
# figure 7 composition of beaches ----------------------------------------------


# beaches are quite repeatable in terms of litter count
# so plot whether dirty beaches cluster at any time points over others
# if a beach is usually in the top half of the count distribution for that year it is classed as 'dirty'
# if it is usually in the lower half it is 'clean'
# if it has an equal number of clean and dirty years it is 'neutral'
# limited to beaches with 2 or more cleans and not including 2020.

medians <- count_per_beach %>%
  mutate(country = case_when(
    beach_region %not_in% c("northern ireland", "scotland", "wales") ~ "England",
    TRUE ~ str_to_title(beach_region))) %>%
  group_by(year, country) %>%
  summarise(median_count = median(item_count))

beach_type <- count_per_beach %>%
  mutate(country = case_when(
    beach_region %not_in% c("northern ireland", "scotland", "wales") ~ "England",
    TRUE ~ str_to_title(beach_region))) %>%
  left_join(medians, by = c("year", "country")) %>%
  mutate(count_group = ifelse(item_count > median_count, 1, -1)) %>%
  mutate(count_group = ifelse(item_count == median_count, 0, count_group)) %>%
  group_by(beach_id_new, country) %>%
  summarise(sum_of_count_group = sum(count_group)) %>%
  mutate(beach_type = case_when(
    sum_of_count_group > 0 ~ "dirty",
    sum_of_count_group == 0 ~ "neutral",
    sum_of_count_group < 0 ~ "clean")) %>%
  mutate(beach = paste0(beach_type, "_", beach_id_new)) %>%
  left_join(count_per_beach, by = "beach_id_new")

beach_type_consistency <- beach_type %>%
  group_by(year, country, beach_type) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = beach_type,
              values_from = count) %>%
  mutate(clean = ifelse(is.na(clean), 0, clean),
         dirty = ifelse(is.na(dirty), 0, dirty),
         neutral = ifelse(is.na(neutral), 0, neutral)) %>%
  mutate(total = clean + dirty + neutral) %>%
  mutate(proportion_clean = clean/total,
         proportion_dirty = dirty/total) %>%
  pivot_longer(cols = c(proportion_clean, proportion_dirty),
               names_to = "group",
               values_to = "proportion")


beach_type_consistency %>%
  ggplot(.,
         aes(x = as.numeric(as.character(year)),
             y = proportion,
             colour = group)) +
  geom_point(position = position_dodge(width = 0.2)) +
  geom_line(position = position_dodge(width = 0.2)) +
  geom_hline(yintercept = 0.5) +
  facet_wrap(vars(country), nrow = 2) +
  theme_bw(base_size = 16) +
  scale_x_continuous(breaks = int_breaks) +
  ylim(0, 1) +
  xlab("year") +
  ylab("proportion of beaches") 

ggsave("Output/figure7.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

#-------------------------------------------------------------------------------
# figure 8 effect of interlude on litter count ---------------------------------



#-------------------------------------------------------------------------------
# figure 9 ---------------------------------------------------------------------

#-------------------------------------------------------------------------------
# figure 10 --------------------------------------------------------------------

#-------------------------------------------------------------------------------
# figure 11 number of plastic items recorded per beach -------------------------

count_summary <- count_by_beach %>%
  group_by(year) %>%
  summarise(quantile = c("Q1", "median", "Q3"),
            value = quantile(item_count, c(0.25, 0.5, 0.75))) %>%
  pivot_wider(names_from = quantile,
              values_from = value)

count_by_beach %>%
  left_join(count_summary, by = "year") %>%
  ggplot(.,
         aes(x = as.factor(year),
             y = item_count)) +
  geom_point(alpha = 0.2,
             position = position_jitter(width = 0.3)) +
  geom_point(aes(y = median),
             size = 3,
             colour = "red") +
  geom_linerange(aes(ymin = Q1,
                     ymax = Q3),
                 colour = "red",
                 size = 1.1) +
  theme_bw(base_size = 16) +
  xlab("year") +
  ylab("plastic litter count")

ggsave("Output/figure11.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")

#-------------------------------------------------------------------------------
# figure 12 100m mean vs median est11ates --------------------------------------

headlines <- count_by_beach %>% 
  get_count_by_geography("year") %>% 
  mutate(source = "all sources") %>% 
  filter(beach_region %in% c("", "all")) %>% 
  pivot_longer(c(mean_count, median_count),
               names_to = "measure",
               values_to = "value") %>% 
  mutate(measure = str_replace(measure, "_", " "),
         line_thickness = ifelse(country == "UK", "bold", "normal"),
         country = str_to_title(country))

ggplot(data = headlines,
       aes(x = year,
           y = value,
           colour = measure)) +
  geom_point() +
  geom_line(aes(size = line_thickness)) +
  scale_size_manual(values = c(2, 1), guide = "none") +
  scale_x_continuous(breaks = int_breaks) +
  facet_wrap(vars(country), 
             nrow = 2) +
  theme_bw(base_size = 16) +
  theme(axis.text.x = element_text(angle = 45,
                                   vjust = 1, hjust = 1),
        legend.position = c(1, 0),
        legend.justification = c(1, 0)) +
  ylab("plastic litter count per metre") 

ggsave("Output/figure12.png", dpi=300, dev='png', 
       height=15, width=24, units="cm")
