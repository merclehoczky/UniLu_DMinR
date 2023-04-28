library(shiny)
library(httr)
library(jsonlite)
library(plyr)
library(spotifyr)

keys <- read_csv("../capstone/data/keys.csv") %>% 
  data.frame()

#### KEYS ----
# Spotify keys
client_id <- keys$api_key[1]
client_secret <- keys$api_key[2]
authorization_header <- NULL
redirect_uri <- "http://localhost:1410/"

Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

# Google keys
api_key <- keys$api_key[3]
Sys.setenv(GU_API_KEY = api_key) 

#### UI ----
ui <- fluidPage(
  titlePanel("Spotify Playlist Analyzer"),
  sidebarLayout(
    sidebarPanel(
      textInput("spotify_id", "Enter your Spotify ID:", value = ""),
      uiOutput("playlist_selector")
    ),
    mainPanel(
      textOutput("playlist_length"),
      dataTableOutput("restaurant_times")
    )
  )
)