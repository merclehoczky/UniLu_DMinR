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

# UI
ui <- fluidPage(
  titlePanel("Spotify Playlist Analyzer"),
  sidebarLayout(
    sidebarPanel(
      textInput("spotify_id", "Enter your Spotify ID:", value = ""),
      actionButton("get_playlists", "Get Playlists"),
      uiOutput("playlist_selector"),
      actionButton("run_function", "Run Function", disabled = TRUE)
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
  
  # Event trigger for playlist selection
  output$playlist_selector <- renderUI({
    if (input$get_playlists == 0) {
      return()
    }
    
    playlists <- get_playlists(input$spotify_id, access_token)
    playlist_names <- sapply(playlists, function(p) p$name)
    selectInput("selected_playlist", "Select a playlist:", choices = playlist_names)
    
    # Enable "Run Function" button when playlist is selected
    observeEvent(input$selected_playlist, {
      updateActionButton(session, "run_function", label = "Run Function", disabled = FALSE)
    })
  })
  
  # Event trigger for playlist length calculation
  playlist_length <- reactive({
    if (is.null(input$selected_playlist)) {
      return(NULL)
    }
    
    playlists <- get_playlists(input$spotify_id, access_token)
    playlist_id <- playlists[grep(input$selected_playlist, sapply(playlists, function(p) p$name))[[1]]]$id
    playlist_length <- get_playlist_length(playlist_id, access_token)
    return(playlist_length)
  })
  
  # Output for playlist length calculation
  output$playlist_length <- renderText({
    if (is.null(playlist_length())) {
      return("")
    }
    paste0("Length of ", input$selected_playlist, " playlist: ", playlist_length(), " songs")
  })
  
  # Event trigger for restaurant times calculation
  restaurant_times <- reactive({
    if (input$run_function == 0) {
      return(NULL)
    }
    
    restaurants <- get_restaurants(api_key)
    route_times <- get_route_times(restaurants, api_key)
    data.frame(Restaurant = restaurants, Route_Time = route_times)
  })
  
  # Output for restaurant times calculation
  output$restaurant_times <- renderDataTable({
    if (is.null(restaurant_times())) {
      return(NULL)
    }
    restaurant_times()
  })
  
}

#### Run the app ----
shinyApp(ui, server)
