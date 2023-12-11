library(tidyverse)
data <- read_csv("raw/ObservationalData.csv") %>%
  filter(is.na(a_ketdose) | str_detect(a_ketdose, "mcg$", negate = TRUE)) %>%
  mutate(
    a_ketdose_numeric = case_when(
      a_ketamine == 0 ~ 0,
      str_detect(a_ketdose, "mg$") ~ as.numeric(str_extract(a_ketdose, "[\\d.]+")),
      TRUE ~ as.numeric(a_ketdose)
    ),
    phq_delta = phq_day7_total_v2 - phq_preop_totalsc
  )
surgery_types <- unique(data$surg_type) %>% subset(subset = !is.na(.)) %>% sort()
for (surgery in surgery_types) {
  data[[paste0("surg_type__", surgery)]] <- as.numeric(data$surg_type == surgery)
}
#Rename the preop and postop variables to 'day0' and 'day7'
data <- data %>% mutate(day0 = phq_preop_totalsc,
                        day7 = phq_day7_total_v2,
                        .keep = 'unused')
#Create ket per kg
data <- data %>% mutate(ket_per_kg = a_ketdose_numeric / weight) %>%
  mutate(ket_per_kg = replace_na(ket_per_kg, 0))
#Mutate ethnicities
ethnicity_types <- unique(data$ethnicity) %>% subset(subset = !is.na(.)) %>% sort()
for (ethnicity in ethnicity_types) {
  data[[paste0("ethnicity__", ethnicity)]] <- as.numeric(data$ethnicity == ethnicity)
}
write_csv(data, "processed/Observational_Data.csv")