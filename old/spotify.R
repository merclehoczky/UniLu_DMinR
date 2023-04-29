library(httr)
library(jsonlite)

# Set up API credentials
client_id <- rstudioapi::askForPassword(prompt = "Please enter your client ID")
client_secret <- rstudioapi::askForPassword(prompt = "Please enter your client secret")
authorization_header <- NULL
redirect_uri <- "http://localhost:3000"

response <-  httr::POST(
  url = 'https://accounts.spotify.com/api/token',
  accept_json(),
  #  authenticate(user = client_id, password = client_secret),    # This would also be OK.
  body = list(grant_type = 'client_credentials',        # This is required, check doc
              client_id = client_id,                     # Credentials
              client_secret = client_secret, 
              content_type = "application/x-www-form-urlencoded"),   
  encode = 'form',
  verbose()
)

# Extract content from the call and get access token as described in the docs:
content <- httr::content(response)
token <- content$access_token
authorization_header <- str_c(content$token_type, content$access_token, sep = " ")

user_url <- "https://api.spotify.com/v1/me"
#user_headers <- list(Authorization = paste0("Bearer ", token))
user_response <- GET(
                     user_url, 
                     query = 
                     add_headers("Authorization" = authorization_header))
user_data <- content(user_response, as = "parsed")
user_id <- user_data$id

authorization_header <- str_c(content$token_type, content$access_token, sep = " ")
