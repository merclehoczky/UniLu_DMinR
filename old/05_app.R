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
user_id <- keys$api_key[3]

Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

# Google keys
api_key <- keys$api_key[4]
Sys.setenv(GU_API_KEY = api_key) 

#### UI ----
ui <- fluidPage(
  titlePanel("Where to eat today?"),
  sidebarLayout(
    sidebarPanel(
      textInput("user_id", "Spotify User ID:"),
      actionButton("get_playlists", "Get User's Playlists"),
      br(),
      br(),
      selectInput("playlist_id", "Select Playlist:", choices = NULL),
      actionButton("match_playlist", "Match Playlist to Closest Route"),
      br(),
      textOutput("closest_match")
    ),
    mainPanel(
      tableOutput("playlist_table")
    )
  )
)



#### Server ----
server <- function(input, output, session) {
  
  # Reactive function to input user id
  dataInput <- reactive({
   textInput(input$user_id, 
               auto.assign = FALSE)
  })
  # Function to get user's Spotify playlists
  get_playlists <- reactive({
    get_user_playlists(user_id, limit = 50)
 })
  
  
  # Function to get the length of a Spotify playlist
  get_playlist_length <- function(playlist_id) {
    playlist_tracks <- get_playlist_tracks(playlist_id)
    playlist_length  <- sum(playlist_tracks$track.duration_ms)/1000
    return(playlist_length)
  }
  
  
  # Event trigger for playlist selection
  output$playlist_selector <- renderUI({
    playlists  <- get_user_playlists(input$spotify_id, limit = 50)
    playlist_names <- playlists$name
    selectInput("selected_playlist", "Select a playlist:", choices = playlist_names)
  })
  
  # Event trigger for playlist length calculation
  playlist_length <- reactive({
    playlist_id <- playlists[grep(input$selected_playlist, sapply(playlists, function(p) p$name))[[1]]]$id
    playlist_length <- get_playlist_length(playlist_id)
    
    return(playlist_length)
  })
  
  # Output for playlist length calculation
  output$playlist_length <- renderText({
    paste0("Length of ", input$selected_playlist, " playlist: ", playlist_length(), " sec")
  })
  
  # Event trigger for restaurant times calculation
  restaurant_times <- reactive({
    
    data.frame(Restaurant = places$place_name, Route_Time = places$route_times_sec)
  })
  
  
  # Output for restaurant times calculation
  output$restaurant_times <- renderDataTable({
    restaurant_times()
  })
  
}


#### Run the app ----
shinyApp(ui, server)

