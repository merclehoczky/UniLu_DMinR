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

# Construct API request URL
url <- sprintf("https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%s&location=%s&radius=%d&types=%s&pagetoken=%s",
               api_key, 
               location, 
               radius, 
               types,  
               next_page_token
)

# Send GET request to API
response <- GET(url)

# Parse JSON response
content <- content(response, as = "text", encoding = "UTF-8")
data <- fromJSON(content, flatten = TRUE)

# Add results to list
results <- c(results, data$results)