require(dplyr)
require(FluSight)


import_forecasts <- function(this_dir, this_week) {
  file_names <- list.files(this_dir, recursive=T, pattern = "*.csv")
  if (length(file_names) == 0) stop("No files found; check directory.")
  
  # Only take files of week of interest
  these_files <- grep(paste0("EW", this_week), file_names, value = TRUE)
  if (length(these_files) == 0) stop("No files found for that week; check week number")
  
  # Remove historical average predictions - only want to average submitted models
  if (any(grepl("Hist-Avg", these_files))) these_files <- these_files[-(grep("Hist-Avg", these_files))]
  
  # these_files <- file_names
  forecast_data <- data.frame()

  for (this_file in these_files) {
    
      this_sub <- read_entry(paste0(this_dir, this_file)) %>%
                    filter(type == "Bin")

      this_sub$forecast_week <- NULL

      forecast_data <- rbind(forecast_data, this_sub)
  }

  return(forecast_data)
}

get_forecast_date <- function(this_dir, this_week) {
  file_names <- list.files(this_dir, recursive=T)
  if (length(file_names) == 0) stop("No files found; check directory.")
  
  # Take first file from week of interest
  this_file <- grep(paste0("EW", this_week), file_names, value = TRUE)[1]
  forecast_date <- regmatches(this_file, regexpr("[0-9]{4}-[0-9]{2}-[0-9]{2}",
                                                 this_file))
  return(forecast_date)
}