require(dplyr)


import_forecasts <- function(this_dir, forecast_wk) {
  file_names <- list.files(this_dir, recursive=T)
  if (length(file_names) == 0) stop("No files found; check directory.")
  
  # Only take files of week of interest
  these_files <- grep(paste0("EW", forecast_wk), file_names, value = TRUE)
  
  forecast_data <- data.frame()
  for (this_file in these_files) {
    if (grepl("\\.csv", this_file)) {
      this_sub <- read.csv(paste0(this_dir, this_file),
                            stringsAsFactors = FALSE)
      forecast_data <- rbind(forecast_data, this_sub)
    }
  }
  return(forecast_data)
}
