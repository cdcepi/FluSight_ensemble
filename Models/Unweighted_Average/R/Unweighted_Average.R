rm(list=ls())

# Packages 
require(dplyr)
require(FluSight)

# Set data directories --------------------------------------------------------
dir_2015 <- "../../Data/2015-2016/"
dir_2016 <- "../../Data/2016-2017/"

# Include necessary functions
source("R/create_ensemble.R")


# Generate forecast for a particular week ----------------------------------

# Set year and MMWR week forecasts are based on - must be character
forecast_week <- "50"

# Create ensemble
ensemble <- create_ensemble(dir_2016, forecast_week)

#Output to csv
out_dir <- "Forecasts/2016-2017/"

forecast_date <- get_forecast_date(dir_2016, forecast_week)

write.table(ensemble, file = paste0(out_dir, "EW", forecast_week, 
                                    "_UnwghtAvg_", forecast_date, ".csv"),
            sep = ",", row.names = FALSE)


# Generate forecasts for multiple weeks ---------------------------------------

# Set MMWR weeks to forecast
forecast_weeks <- c("42","43", "44", "45", "46", "47","48", "49", "50", "51",
                    "52", "01", "02", "03", "04", "05", "06", "07", "08", "09",
                    "10", "11", "12", "13", "14", "15", "16", "17", "18")

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
