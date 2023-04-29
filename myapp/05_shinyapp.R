library(shiny)
library(httr)
library(jsonlite)
library(plyr)
library(spotifyr)
library(tidyverse)
library(rdist)
library(geosphere)
library(shinythemes)
library(leaflet)


keys <- read_csv("../capstone/data/keys.csv") %>% 
  data.frame()

#### KEYS ----
# Spotify keys
client_id <- keys$api_key[1]
client_secret <- keys$api_key[2]
user_id <- keys$api_key[3]
authorization_header <- NULL
redirect_uri <- "http://localhost:1410/"

Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

# Google keys
api_key <- keys$api_key[4]
Sys.setenv(GU_API_KEY = api_key) 
origin <- "Frohburgstrasse 3, 6002 Lucerne, Switzerland"


#### UI ----
ui <- fluidPage(
  titlePanel("Spotify Playlist Analyzer"),
  sidebarLayout(
    sidebarPanel(
      textInput("spotify_id", "Your Spotify ID:", value = user_id),
      uiOutput("playlist_selector")
    ),
    mainPanel(
      textOutput("playlist_length"),
      textOutput("matched"),
      leafletOutput("map"),
      dataTableOutput("restaurant_times")
    )
  )
)

#### Server ----
server <- function(input, output, session) {
  
  # Function to get user's Spotify playlists
#  playlists <- get_user_playlists(user_id, limit = 50)

 
   # Event trigger for playlist selection
   output$playlist_selector <- renderUI({
     playlists # <- get_user_playlists(user_id, limit = 50)
     playlist_names <- playlists$name
     selectInput("selected_playlist", "Select a playlist:", choices = playlists$name)
   })
   
   
   # Event trigger for playlist length calculation
   playlist_length <- reactive({
     # Find the selected playlist and get its ID
     selected_name <- input$selected_playlist
     selected_id <- ""
     for (i in seq_along(playlists)) {
       if (playlists[[i]]$name == selected_name) {
         playlist_id <- playlists[[i]]$id
         break
       }
     }
     #playlists
     playlist_length <- get_playlist_length(playlist_id, access_token)
     return(playlist_length)
   })
  # # Event trigger for playlist length calculation
  # playlist_length <- reactive({
  #   playlist_id <- playlists[grep(input$selected_playlist, sapply(playlists, function(p) p$name))[[1]]]$id
  #   playlist_length <- get_playlist_length(playlist_id)
  #   
  #   return(playlist_length)
  # })
  
  # Function to get the length of a Spotify playlist
  get_playlist_length <- function(playlist_id) {
   # playlists <- get_user_playlists(user_id, limit = 50)
    playlist_tracks <- get_playlist_tracks(playlist_id)
    playlist_length  <- sum(playlist_tracks$track.duration_ms)/1000
    return(playlist_length)
  }
 

  
  # Output for playlist length calculation
  output$playlist_length <- renderText({
    paste0("Length of ", input$selected_playlist, " playlist: ", playlist_length(), " sec")
  })
  
  
  
  # Output for restaurant times calculation
  output$restaurant_times <- renderDataTable({
    restaurant_times()
  })
  
  #Calculation of time matching
  # Calculate absolute differences
  time_matched <- reactive({
    # Calculate absolute differences
     diffs <- abs(places$route_times_sec - playlist_length)
   
   # Find index of closest value
     idx <- which.min(diffs)
   
   # Print closest value and the name of the restaurant
       closest_val <- places$route_times_sec[idx]
       placename <- places$place_name[idx]
       destination <- places$place_address[idx]
       matched <- as.character(print(c(closest_val, placename)))
   return(matched)}) 
  
  # Event trigger for restaurant times calculation
  restaurant_times <- reactive({
    
    data.frame(matched)
  })
  
  # Output for restaurant times calculation
  output$out <- renderText(matched)
  
  # Get route 
  get_route_coordinates <- function(origin, destination, api_key) {
    endpoint <- paste0("https://maps.googleapis.com/maps/api/directions/json",
                       "?origin=", origin,
                       "&destination=", destination,
                       "&mode=walking",
                       "&key=", api_key)
    res <- GET(endpoint)
    stop_for_status(res)
    data <- fromJSON(content(res, "text"), simplifyDataFrame = TRUE)
    route_coordinates <- data$routes[[1]]$legs[[1]]$steps$lat_lngs
    return(route_coordinates)

  }
  
  # Event trigger for getting route coordinates
  observeEvent(input$submit, {
    route_coordinates <- get_route_coordinates(input$origin, input$destination, api_key)
    output$map <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolylines(data = route_coordinates)
    })
  })
}


#### Run the app ----
shinyApp(ui, server)

