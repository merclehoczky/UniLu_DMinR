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

# Loop through each restaurant location and make a request to the Directions API
for (i in seq_along(restaurant_locations)) {
  # Define the destination
  destination <- restaurant_locations[i]
  
  # Build the API query URL
  query_url <- paste0(api_endpoint,
                      "?origin=", URLencode(start_location),
                      "&destination=", URLencode(destination),
                      "&mode=walking",
                      "&key=", api_key)
  
  # Make the API request
  api_response <- GET(query_url)
  
  # Convert the response to JSON
  response_json <- fromJSON(content(api_response, "text"), simplifyVector = FALSE)
  
  # Extract the route time in seconds and add it to the list
  route_time <- response_json$routes[[1]]$legs[[1]]$duration$value
  route_times[[i]] <- route_time
}

# Save the route times for each restaurant
for (i in seq_along(route_times)) {
  places$route_times_sec[i] <- as.numeric(route_times[[i]])
}

