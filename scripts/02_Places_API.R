library(httr)
library(jsonlite)

# Set up Google API key and endpoint URL
api_key <- rstudioapi::askForPassword()
Sys.setenv(GU_API_KEY = api_key) 


# Set up parameters for the API request
location <- "47.050168,8.309307"  # Coordinates for Lucerne
radius <- 5000  # Search radius in meters
types <- "restaurant"  # Restrict results to restaurants
query = "Italian restaurants"
next_page_token <- ""

# Initialize empty list to hold results
results <- list()