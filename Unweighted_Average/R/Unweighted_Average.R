rm(list=ls())

# Packages 
require(dplyr)

# Set data directories --------------------------------------------------------
dir_2015 <- "../Data/2015-2016/"
dir_2016 <- "../Data/2016-2017/"

# Include necessary functions
source("R/create_ensemble.R")


# Generate forecast for a particular week ----------------------------------

# Set year and MMWR week forecasts are based on - must be character
forecast_week <- "52"

# Create ensemble
ensemble <- create_ensemble(dir_2015, forecast_week)

#Output to csv
out_dir <- "Forecasts/2015-2016/"

forecast_date <- get_forecast_date(dir_2015, forecast_week)

write.table(ensemble, file = paste0(out_dir, "EW", forecast_week, 
                                    "_UnwghtAvg_", forecast_date, ".csv"),
            sep = ",", row.names = FALSE)


# Generate forecasts for multiple weeks ---------------------------------------

# Set MMWR weeks to forecast
forecast_weeks <- c("44", "45", "46")

# Set output directory
out_dir <- "Forecasts/2015-2016/"

for (this_week in forecast_weeks) {
  # Create ensemble
  ensemble <- create_ensemble(dir_2015, this_week)
  
  forecast_date <- get_forecast_date(dir_2015, this_week)
  
  write.table(ensemble, file = paste0(out_dir, "EW", this_week, 
                                      "_UnwghtAvg_", forecast_date, ".csv"),
              sep = ",", row.names = FALSE)
}
