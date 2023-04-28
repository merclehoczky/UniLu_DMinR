library(spotifyr)
library(httr)
library(jsonlite)
library(lubridate)
library(knitr)
library(tidyverse)

# Ask for client_id and client_secret
client_id <- rstudioapi::askForPassword(prompt = "Please enter your client ID")
client_secret <- rstudioapi::askForPassword(prompt = "Please enter your client secret")
authorization_header <- NULL
redirect_uri <- "http://localhost:1410/"

Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

# Ask for user id
my_id <- rstudioapi::askForPassword(prompt = "Please enter your user ID")

# Scrape playlists from user
my_plists <- get_user_playlists(my_id, limit = 50)

# Get all the tracks AND LENGTHS from ALL the playlists
my_plists$playlist_length_sec <- NA
for (i in 1:length(my_plists)) {
  if(my_plists$owner.display_name[i] == "Spotify" | my_plists$owner.id[i] != "my_id"){
    next
  }
  tryCatch({
    temp <- get_playlist_tracks(my_plists$id[i])
    my_plists$playlist_length_sec[i] <- sum(temp$track.duration_ms)/1000 })
  }



# Enter playlist name
plist <- rstudioapi::askForPassword(prompt = "Please choose your playlist")

# Get the ID of the playlist with the specified name
playlist_id
for (i in 1:length(my_plists)) {
  if(plist == my_plists$name[i] ){
    playlist_id <- my_plists$id[i]
  }
}


# Get all the tracks from the playlist
playlist_tracks <- get_playlist_tracks(playlist_id)

# Get the length of the playlists
playlist_length_sec <- sum(playlist_tracks$track.duration_ms)/1000

#Save value mm:ss time format
pl_length_in_minsec <- format( as.POSIXct(Sys.Date())+playlist_length_sec/1000, "%M:%S")
