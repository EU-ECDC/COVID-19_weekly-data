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

# Load sensitive configuration. This file should never be committed.
source('config.R')

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
path_S = Sys.getenv('CASEDEATHXLSX')

tryCatch({
        # Load the file and make some adjustments
        df <- readxl::read_xlsx(path_S) %>% 
            left_join(df_countries) %>% 
            mutate(location_name = country,
                   date = year_week,
                   value = weekly_count) %>%
            select(location_name, location, indicator, date, value, source ) 
        
        
        # Save the files
        write.csv(df, paste0('./data/COVID_19_weekly_cases_and_deaths_current.csv'), row.names = FALSE)
        write.csv(df, paste0('./data/snapshots/COVID_19_weekly_cases_and_deaths_', Sys.Date(),'.csv'), row.names = FALSE)
        
        # Add to git
        system("git add data/*")
        system(paste0('git commit -m "',
                      'commit_as_of_',
                      Sys.Date(), 
                      '"'))
        
        # Push it to the repository
        system("git push")
        
        if(strptime(Sys.Date(), '%Y-%M-%d') - file.info(path_S)$mtime > 3){
            msg = glue("Files have been pushed to the repository, but the last time they were update was on {file.info(path_S)$mtime}.\n\n")
            sbj = "[COVID files] Files pushed - some issues"
        } else {
            msg = glue("Files have been pushed to the repository.\n\n")
            sbj = "[COVID files] Files pushed"
        }
        
    },
    error = function(e) {
        msg <<- glue("There was an error when running the script:\n\n{e$message}\n\n\n\n")
        sbj <<- "[COVID files] Something went terribly wrong."
    })



send_email(msg = msg, sbj = sbj)
