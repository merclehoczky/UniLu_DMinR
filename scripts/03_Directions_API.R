library(httr)
library(jsonlite)

# Set up Google API key and endpoint URL
api_key <- rstudioapi::askForPassword()
Sys.setenv(GU_API_KEY = api_key) 


# Define API endpoint and API key
api_endpoint <- "https://maps.googleapis.com/maps/api/directions/json"

# Define the start location
start_location <- "University of Lucerne, Switzerland"

# Define a list of restaurant locations
restaurant_locations <- places$place_address

# Create an empty data frame to store the route information
route_info <- data.frame(place_address = character(length(restaurant_locations)),
                         route_time_sec = numeric(length(restaurant_locations)),
                         stringsAsFactors = FALSE)

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

  
  # Extract the route time in seconds and add it to the data frame
  route_time <- response_json$routes[[1]]$legs[[1]]$duration$value
  route_info[i, "place_address"] <- destination
  route_info[i, "route_time_sec"] <- route_time
}

# Save the route times for each restaurant
places$route_times_sec <- as.numeric(route_info$route_time_sec)
