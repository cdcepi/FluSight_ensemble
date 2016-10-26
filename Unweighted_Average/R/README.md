## R code  

### Files
`Unweighted_Average.R` - this file contains interactive function calls and allows the user to define which season and week the ensemble will be generated for.

`create_ensemble.R` - this file contains helper functions `create_ensemble`, `create_probs`, and `create_point`

`import_forecasts.R` - this file contains helper functions `import_forecasts` and `get_forecast_date`



#### Functions
1. `create_ensemble`: Generates ensemble forecast. 

  Inputs: 
  - `this_dir` - a valid directory path to submission data from a specific season
  - `this_week` - a valid MMWR week as a character value, i.e. "01" for week 1, "44" for week 44

  Outputs:
  Data.frame in valid submission format


2. `import_forecasts`: Pulls user-submitted forecasts data. Called by `create_ensemble`

  Inputs:
  - `this_dir` - a valid directory path to submission data from a specific season
  - `this_week` - a valid MMWR week as a character value, i.e. "01" for week 1, "44" for week 44

  Outputs:
  Data.frame of all user-generated submission for given MMWR week


3. `create_probs`: Generates probabilistic values. Called by `create_ensemble`

  Inputs: 
  - `forecast_data` - data.frame generated from `import_forecasts`

  Outputs:
  Data.frame of average probabilistic forecasts


4. `create_point`: Generates point forecasts. Called by `create_ensemble`

  Inputs:
  - `probs` - data.frame generated from `create_probs`

  Outputs:
  Data.frame of point forecasts


5. `get_forecast_date`: Extracts date of forecast submissions

  Inputs: 
  - `this_dir` - a valid directory path to submission data from a specific season
  - `this_week` - a valid MMWR week as a character value, i.e. "01" for week 1, "44" for week 44

  Outputs:
  Character vector of length one containing submission date
