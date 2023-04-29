library(shiny)
library(httr)
library(jsonlite)
library(plyr)

keys <- read_csv("../capstone/keys.csv") %>% 
  data.frame()

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


all_tracks <- list()
# UI
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

# Server
server <- function(input, output, session) {
  
  # Function to get user's Spotify playlists
  get_playlists <- function(user_id, access_token) {
    endpoint <- paste0("https://api.spotify.com/v1/users/", user_id, "/playlists")
    res <- GET(endpoint, add_headers(Authorization = paste0("Bearer ", access_token)))
    stop_for_status(res)
    playlists <- content(res)$items
    return(playlists)
  }
  
  # Function to get the length of a Spotify playlist
  get_playlist_length <- function(playlist_id, access_token) {
    endpoint <- paste0("https://api.spotify.com/v1/playlists/", playlist_id)
    res <- GET(endpoint, add_headers(Authorization = paste0("Bearer ", access_token)))
    stop_for_status(res)
    playlist_length <- content(res)$tracks$total
    return(playlist_length)
  }
  
  # Function to get walking route times from University of Lucerne to restaurants
  get_route_times <- function(restaurants, api_key) {
    times <- list()
    for (i in seq_along(restaurants)) {
      endpoint <- paste0("https://maps.googleapis.com/maps/api/directions/json",
                         "?origin=University+of+Lucerne+Switzerland",
                         "&destination=", restaurants[i], "+Lucerne+Switzerland",
                         "&mode=walking",
                         "&key=", api_key)
      res <- GET(endpoint)
      stop_for_status(res)
      data <- fromJSON(content(res, "text"), simplifyDataFrame = TRUE)
      route_time <- data$routes[[1]]$legs[[1]]$duration$value
      times[[i]] <- route_time
    }
    return(times)
  }
  
  # Event trigger for playlist selection
  output$playlist_selector <- renderUI({
    playlists <- get_playlists(input$spotify_id, access_token)
    playlist_names <- sapply(playlists, function(p) p$name)
    selectInput("selected_playlist", "Select a playlist:", choices = playlist_names)
  })
  
  # Event trigger for playlist length calculation
  playlist_length <- reactive({
    playlist_id <- playlists[grep(input$selected_playlist, sapply(playlists, function(p) p$name))[[1]]]$id
    playlist_length <- get_playlist_length(playlist_id, access_token)
    return(playlist_length)
  })
  
  # Output for playlist length calculation
  output$playlist_length <- renderText({
    paste0("Length of ", input$selected_playlist, " playlist: ", playlist_length(), " songs")
  })
  
  # Event trigger for restaurant times calculation
  restaurant_times <- reactive({
    restaurants <- get_restaurants(api_key)
    route_times <- get_route_times(restaurants, api_key)
    data.frame(Restaurant = restaurants, Route_Time = route_times)
  })
  
  # Output for restaurant times calculation
  output$restaurant_times <- renderDataTable({
    restaurant_times()
  })
  
}

# Run the app
shinyApp(ui, server)

