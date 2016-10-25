require(dplyr)

create_ensemble <- function(forecast_data) {
  
}


create_probs <- function(forecast_data) {
  
  # Create ensemble probabilities
  ensemble <- forecast_data %>%
                filter(type == "Bin") %>%
                group_by(location, target, type, unit, bin_start_incl, 
                         bin_end_notincl) %>%
                summarize(avg = mean(value)) %>%
                rename(value = avg)
   
  # Normalize all probabilities so they sum to 1
  to_normal <- ensemble %>%
                group_by(location, target) %>%
                summarize(total = sum(value)) %>%
                filter(abs(total[1] - 1) > 1e-8)
  
  # Loop through groups identified and normalize probabilities
  for(i in 1:nrow(to_normal)) {
    ensemble$value[ensemble$location == to_normal$location[i] & 
                     ensemble$target == to_normal$target[i]] <-
      ensemble$value[ensemble$location == to_normal$location[i] & 
                       ensemble$target == to_normal$target[i]] /
      sum(ensemble$value[ensemble$location == to_normal$location[i] & 
                           ensemble$target == to_normal$target[i]])
    
  }

  return(ensemble)
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
              mutate(type = "Point")
 
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
  
}

