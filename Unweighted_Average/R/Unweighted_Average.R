rm(list=ls())

##### Packages #####
require(dplyr)

# Set directories ---------------------------------------------------
setwd("..") # Set working directory one level up to access data more easily
dir_2015 <- "Data/2015-2016/"
dir_2016 <- "Data/2016-2017/"

# Get forecast data -------------------------------------------------
source("Unweighted_Average/R/import_forecasts.R")
forecast_data <- import_forecasts(dir_2015, forecast_wk = 12)

##### Create equal weight ensemble forecast for 2015/2016 season #####
weights <- data.frame(team = unique(forecast_data$team),
                      weight = rep(1/length(unique(forecast_data$team)),
                                   length(unique(forecast_data$team))))

#Create shell to hold results
source("Unweighted_Average/R/create_ensemble.R")

ensemble <- create_ensemble(forecast_data, forecast_wk = 12)

wk_results <- NULL




#Output to csv
write.table(ensemble_data, file="Ensemble_Team_Forecasts.csv", sep=",",
            row.names=F,col.names=T)


