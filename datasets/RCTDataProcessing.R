library(tidyverse)
library(readr)

fill_vars = c(
  'surgery_type', 'department_rct', 'phq_rct', 'age', 'bmi', 'gender', 'ethnic',
  'race___1', 'race___2', 'race___3', 'race___5', 'race___6', 'race___98', 'race___99',
  'a_los'
)
rct <- read_csv("raw/RCT_Data.csv")
#Remove closeout arm and fill in missing values
rct <- rct %>% filter(redcap_event_name != 'closeout_arm_1') %>% 
  select(!rand) %>% 
  group_by(record_id) %>% 
  fill(fill_vars, .direction = 'downup') %>% 
  ungroup()
#Load dataframe containing treatment assignments
rct_assign <- read_csv("raw/RCT_treatment_assignments.csv")
#Merge the dataframes
rct <- rct %>% left_join(rct_assign)
#Pivot wider
rct <- rct %>% pivot_wider(
  names_from = redcap_event_name,
  values_from = madrs_score
)
#Rename the outcome variables
rct <- rct %>% rename(
  screening = screening_arm_1,
  day0 = day_of_surgery_0_arm_1,
  day1 = day_1_arm_1,
  day2 = day_2_arm_1,
  day3 = day_3_arm_1,
  day5 = day_5_arm_1,
  day7 = day_7_arm_1,
  day14 = day_14_arm_1
)
#Clean up extra variables
rm(rct_assign, fill_vars)