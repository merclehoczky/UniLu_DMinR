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

# Enter playlist name
plist <- rstudioapi::askForPassword(prompt = "Please choose your playlist")


