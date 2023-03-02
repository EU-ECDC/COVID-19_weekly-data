###########################################################
# Update the EU-ECDC/COVID-19_weekly-data repo
#
# Script to push new weekly COVID-19 case and death data by
# - loading the new data frame from the server
# - adjust the dataframe (e.g., rename column names, etc)
# - save the file into .csv
# - automatically push into the EU-ECDC/COVID-19_weekly-data repo
# 
# ECDC General Surveillance and Data  & Modelling Teams
###########################################################

# Create a dataframe to connect country 'long' name with the country code
countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", 
               "Czechia", "Denmark", "Estonia", "Finland", "France", 
               "Germany", "Greece", "Hungary", "Iceland", "Ireland", 
               "Italy", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", 
               "Malta", "Netherlands", "Norway", "Poland", "Portugal", 
               "Romania", "Slovakia", "Slovenia", "Spain", "Sweden")

countries_short <- c("AT", "BE", "BG", "HR", "CY", 
                     "CZ", "DK", "EE", "FI", "FR", 
                     "DE", "GR", "HU", "IS", "IE", 
                     "IT", "LV", "LI", "LT", "LU", 
                     "MT", "NL", "NO", "PL", "PT", 
                     "RO", "SK", "SI", "ES", "SE")

df_countries <- as_tibble(bind_cols(countries, countries_short,
                                    .name_repair = ~ vctrs::vec_as_names(c("country", "location"), 
                                                                         repair = "unique", quiet = TRUE)) ) 
# Define the path of the weekly COVID-19 case and death data
path_S = paste0('ABSOLUTE PATH TO THE WEB SERVER')
# Load the file and make some adjustments
df <- read_excel(path_S) %>% 
  left_join(df_countries) %>% 
  mutate(location_name = country,
         date = year_week,
         value = weekly_count) %>%
  select(location_name, location, indicator, date, value, source ) 


# Save the files
date_max <- today()
write.csv(df, paste0('./data/COVID_19_weekly_cases_and_deaths_current.csv'), row.names = FALSE)
write.csv(df, paste0('./data/COVID_19_weekly_cases_and_deaths_current_',date_max,'.csv'), row.names = FALSE)

# Add to git
system("git add data/")
system(paste0("git commit -m '",
              "commit_as_of_",
              Sys.Date(), 
              "'"))


