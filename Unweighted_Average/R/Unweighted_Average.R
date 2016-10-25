rm(list=ls())

##### Packages #####
require(dplyr)

# Set directories ---------------------------------------------------
setwd("..") # Set working directory one level up to access data more easily
dir_2015 <- "Data/2015-2016/"
dir_2016 <- "Data/2016-2017/"

# Get forecast data -------------------------------------------------
source("Unweighted_Average/R/import_forecasts.R")
forecast_data <- import_forecasts(dir_2015)

##### Create equal weight ensemble forecast for 2015/2016 season #####
weights <- data.frame(team = unique(forecast_data$team),
                      weight = rep(1/length(unique(forecast_data$team)),
                                   length(unique(forecast_data$team))))

#Create shell to hold results
ensemble.results <- NULL

for(this_wk in unique(forecast_data$forecast_wk)){
  date.results <- NULL
  for(this_location in unique(forecast_data$location)){
    for(this_target in unique(forecast_data$target)){
      
      #Filter data for particular date/location/target combination
      these_data <- filter(forecast_data, 
                           forecast_wk == this_wk & location == this_location & 
                               target == this_target & type == "Bin" & !is.na(value))
      
      for(this_bin in unique(these_data$bin_start_incl)){
        
        #Determine which teams submitted predictions and normalize relevant weights
        these.values <- filter(these.data, name==this.bin & !is.na(value))
        these.weights <- filter(weights, team %in% these.values$team) %>%
                            select(weight) %>% 
                            as.matrix()
        these.weights <- these.weights/sum(these.weights)
        
        #Create row with ensemble forecast
        this.pred <- these.values[1,]
        this.pred$team <- "ensemble"
        this.pred$value <- weighted.mean(these.values$value, these.weights)
        
        date.results <- rbind(date.results,this.pred)
      }
    }
  }
  ensemble.results <- rbind(ensemble.results,date.results)
}

#Combine with forecasts from other teams
ensemble_data <- rbind(forecast_data,ensemble.results)

#Output to csv
write.table(ensemble_data, file="Ensemble_Team_Forecasts.csv", sep=",",
            row.names=F,col.names=T)


