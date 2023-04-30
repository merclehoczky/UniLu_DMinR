library(httr)
library(jsonlite)

# Set up Google API key and endpoint URL
api_key <- rstudioapi::askForPassword()
Sys.setenv(GU_API_KEY = api_key) 


# Define API endpoint and API key
api_endpoint <- "https://maps.googleapis.com/maps/api/place/textsearch/json"

# Define the search query
search_query <- "restaurants in Lucerne"

# Initialize empty list to hold results
results <- list()

# Make the initial API request
query_url <- paste0(api_endpoint,
                    "?query=", URLencode(search_query),
                    "&type=restaurant",
                    "&key=", api_key)
api_response <- GET(query_url)

# Convert the response to JSON
response_json <- fromJSON(content(api_response, "text"), simplifyVector = FALSE)

# Add results to list
results <- response_json$results


# Check if there are more results
while (length(response_json$next_page_token) > 0) {
  # Wait for a few seconds before making the next request
  Sys.sleep(5)
  
  # Make the next API request with the next_page_token
  query_url <- paste0(api_endpoint,
                      "?pagetoken=", response_json$next_page_token,
                      "&key=", api_key)
  api_response <- GET(query_url)
  
  # Convert the response to JSON
  response_json <- fromJSON(content(api_response, "text"), simplifyVector = FALSE)
  
  # Add the results to the list
  results <- c(results, response_json$results)
}

# Convert the list to a data frame
places <- data.frame(place_name = sapply(results, function(x) x$name),
                        place_address = sapply(results, function(x) x$formatted_address),
                        place_id = sapply(results, function(x) x$place_id),
                        lat = sapply(results, function(x) x$geometry$location$lat),
                        lng = sapply(results, function(x) x$geometry$location$lng),
                        open_now = sapply(results, function(x) ifelse(is.null(x$opening_hours), NA, x$opening_hours$open_now)),
                        stringsAsFactors = FALSE)


# Print the data frame
print(places)
