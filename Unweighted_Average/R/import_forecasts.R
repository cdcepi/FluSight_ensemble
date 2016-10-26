require(dplyr)


import_forecasts <- function(this_dir, forecast_wk) {
  file_names <- list.files(this_dir, recursive=T)
  if (length(file_names) == 0) stop("No files found; check directory.")
  
  # Only take files of week of interest
  these_files <- grep(paste0("EW", forecast_wk), file_names, value = TRUE)
  if (length(these_files) == 0) stop("No files found for that week; check week number")
  # these_files <- file_names
  forecast_data <- data.frame()
  for (this_file in these_files) {
    if (grepl("\\.csv", this_file)) {
      this_sub <- read.csv(paste0(this_dir, this_file),
                            stringsAsFactors = FALSE) #%>%
                          # mutate(forecast_wk = as.numeric(gsub("EW","",regmatches(this_file,
                          #                         regexpr("(?:EW)[0-9]{2}", this_file)))),
                          #        team = gsub("\\/.*$", "", this_file))
      forecast_data <- rbind(forecast_data, this_sub)
    }
  }
  return(forecast_data)
}

