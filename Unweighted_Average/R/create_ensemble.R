require(dplyr)

source("Unweighted_Average/R/import_forecasts.R")

create_ensemble <- function(this_dir, this_week) {
  
  forecast_data <- import_forecasts(this_dir, this_week)
  
  probs <- create_probs(forecast_data)
  
  points <- create_point(probs)
  
  entry <- bind_rows(probs, points)
  
  # Reorder to match valid entry
  region.order <- c("US National", "HHS Region 1", "HHS Region 2", "HHS Region 3", "HHS Region 4",
                    "HHS Region 5", "HHS Region 6", "HHS Region 7", "HHS Region 8",
                    "HHS Region 9", "HHS Region 10")
  target.order <- c("Season onset", "Season peak week", "Season peak percentage",
                    "1 wk ahead", "2 wk ahead", "3 wk ahead", "4 wk ahead")
  
  entry$location <- factor(entry$location, region.order)
  entry$target <- factor(entry$target, target.order)
  
  entry <- entry %>% 
              arrange(location, target, desc(type)) %>%
              mutate_if(is.factor, as.character)
  
  return(entry)
  
}


create_probs <- function(forecast_data) {
  
  # Create ensemble probabilities
  ensemble <- forecast_data %>%
                filter(type == "Bin") %>%
                group_by(location, target, type, unit, bin_start_incl, 
                         bin_end_notincl) %>%
                summarize(avg = mean(value)) %>%
                rename(value = avg) %>%
                ungroup
   
  # Normalize all probabilities so they sum to 1
  to_normal <- ensemble %>%
                group_by(location, target) %>%
                summarize(total = sum(value)) %>%
                filter(abs(total[1] - 1) > 1e-8) %>%
                ungroup
  
  # Loop through groups identified and normalize probabilities
  for(i in 1:nrow(to_normal)) {
    ensemble$value[ensemble$location == to_normal$location[i] & 
                     ensemble$target == to_normal$target[i]] <-
      ensemble$value[ensemble$location == to_normal$location[i] & 
                       ensemble$target == to_normal$target[i]] /
      sum(ensemble$value[ensemble$location == to_normal$location[i] & 
                           ensemble$target == to_normal$target[i]])
    
  }
  
  # Reorder to match valid entry
  percent <- ensemble %>%
              filter(unit == "percent") %>%
              mutate(bin_start_incl = as.numeric(bin_start_incl)) %>%
              arrange(location, target, bin_start_incl)
  
  weeks <- ensemble %>%
              filter(unit == "week") %>%
              mutate(bin_start_incl = suppressWarnings(as.numeric(bin_start_incl)))
  
  weeks$bin_start_incl[weeks$bin_start_incl < 40 & !(is.na(weeks$bin_start_incl))] <- 
    weeks$bin_start_incl[weeks$bin_start_incl < 40 & !(is.na(weeks$bin_start_incl))] + 52
  
  weeks <- weeks %>%
              arrange(location, target, bin_start_incl)
  
  weeks$bin_start_incl[weeks$bin_start_incl > 52 & !(is.na(weeks$bin_start_incl))] <- 
    weeks$bin_start_incl[weeks$bin_start_incl > 52 & !(is.na(weeks$bin_start_incl))] - 52
  
  weeks$bin_start_incl <- as.character(weeks$bin_start_incl)
  
  weeks$bin_start_incl[weeks$bin_end_notincl == "none"] <- "none"
  
  # Recombine weeks and percents to output
  output <- rbind(percent, weeks)

  return(output)
}


create_point <- function(ensemble_probs) {
  
  points <- ensemble_probs %>%
              group_by(location, target) %>%
              # Season onset has `none` as a possible bin_start_incl thus we
              # exclude it from the point forecast by turning bin_start_incl
              # into numeric and removing the none with na.omit
              mutate(probability = value/sum(value),
                            value       = suppressWarnings(as.numeric(bin_start_incl))) %>%
              na.omit() 
            
  
  # Adjust week values in new year to keep in proper order
  points$value[points$unit == "week" & points$value < 40] <- 
    points$value[points$unit == "week" & points$value < 40] +52
              
  points <- points %>%
              summarize(value = sum(value*probability)) %>%
              mutate(type = "Point") %>%
              ungroup
 
  # Add units
  points$unit <- NA
  points$unit[points$target %in% c("Season onset", "Season peak week")] <- "week"
  points$unit[!(points$target %in% c("Season onset", "Season peak week"))] <- "percent"

  # Round point forecasts as needed
  points$value[points$unit == "week"] <- 
    round(points$value[points$unit == "week"], 0)
  points$value[points$unit == "percent"] <- 
    round(points$value[points$unit == "percent"], 1)
  
  # Reset any week point values >52
  points$value[points$unit == "week" & points$value > 52] <- 
    points$value[points$unit == "week" & points$value >52] - 52
  
  
  return(points)
  
}

