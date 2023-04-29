#install.packages('spotifyr')
library(spotifyr)
library(httr)
library(jsonlite)
library(lubridate)
library(knitr)

client_id <- rstudioapi::askForPassword(prompt = "Please enter your client ID")
client_secret <- rstudioapi::askForPassword(prompt = "Please enter your client secret")
authorization_header <- NULL
redirect_uri <- "http://localhost:1410/"

Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

#response <-  httr::POST(
#  url = 'https://accounts.spotify.com/api/token',
#  accept_json(),
#  #  authenticate(user = client_id, password = client_secret),    # This would also be OK.
#   body = list(grant_type = 'client_credentials',        # This is required, check doc
#               client_id = client_id,                     # Credentials
#               client_secret = client_secret, 
#               content_type = "application/x-www-form-urlencoded"),   
#   encode = 'form',
#   verbose()
# )
# 
# # Extract content from the call and get access token as described in the docs:
# content <- httr::content(response)
# token <- content$access_token
#authorization_header <- str_c(content$token_type, content$access_token, sep = " ")



get_my_recently_played(limit = 50) %>% 
  mutate(artist.name = map_chr(track.artists, function(x) x$name[1]),
         played_at = as_datetime(played_at)) %>% 
  select(track.name, artist.name, track.album.name, played_at) %>% 
  kable()


get_my_top_artists_or_tracks(type = 'artists', time_range = 'long_term', limit = 50) %>% 
  select(name, genres) %>% 
  rowwise %>% 
  mutate(genres = paste(genres, collapse = ', ')) %>% 
  ungroup %>% 
  kable()

my_id <- rstudioapi::askForPassword(prompt = "Please enter your user ID")
my_plists <- get_user_playlists(my_id)

# Create an empty list to store all the tracks
all_tracks <- list()

for (i in 1:nrow(my_plists)) {
     playlist_id<- my_plists$id[i]
     # Try to get the tracks for this playlist
     tracks <- tryCatch(get_playlist_tracks(playlist_id), error = function(e) NULL)
     
     # Only add tracks to the list if they were successfully retrieved
     if (!is.null(tracks)) {
       all_tracks[[i]] <- tracks
     } else {
       cat("Skipping playlist", my_plists$name[i], "due to error\n")
     }
}

     

# Loop through each playlist and get its tracks
for (i in 1:nrow(my_plists)) {
  playlist_id <- my_plists$id[i]
  tracks <- get_playlist_tracks(playlist_id)
  all_tracks[[i]] <- tracks
}

# Combine all the tracks into a single data frame
all_tracks_df <- do.call(rbind, all_tracks)

# Print the resulting data frame
print(all_tracks_df)