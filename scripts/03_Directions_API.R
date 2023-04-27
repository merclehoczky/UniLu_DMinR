library(httr)
library(jsonlite)

# Set up Google API key and endpoint URL
api_key <- rstudioapi::askForPassword()
Sys.setenv(GU_API_KEY = api_key) 


# Define API endpoint and API key
api_endpoint <- "https://maps.googleapis.com/maps/api/directions/json"
#api_key <- "YOUR_API_KEY"

# Define the start location
start_location <- "University of Lucerne, Switzerland"

# Define a list of restaurant locations
restaurant_locations <- places$place_address

# Create an empty list to store the route times
route_times <- list()