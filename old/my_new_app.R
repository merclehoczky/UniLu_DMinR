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
user_id <- keys$api_key[3]
authorization_header <- NULL
redirect_uri <- "http://localhost:1410/"

Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

# Google keys
api_key <- keys$api_key[4]
Sys.setenv(GU_API_KEY = api_key) 



#### UI ----
ui <- fluidPage(
  titlePanel("Spotify Playlist Analyzer"),
  sidebarLayout(
    sidebarPanel(
      textInput("spotify_id", "Enter your Spotify ID:", value = ""),
      actionButton("get_playlists", "Get Playlists"),
      uiOutput("playlist_selector"),
    ),
    mainPanel(
      textOutput("playlist_selector")
    )
  )
)



#### Server ----
server <- function(input, output, session) {
  
  # Function to get user's Spotify playlists
  get_playlists <- get_user_playlists(user_id, limit = 50)
  
  # Event trigger for playlist selection
  output$playlist_selector <- renderUI({
    playlists  <- get_user_playlists(input$spotify_id, limit = 50)
    playlist_names <- playlists$name
    selectInput("selected_playlist", "Select a playlist:", choices = playlist_names)
  })
  
  output$playlist_selector <- renderText({
    paste0("The chosen playlist is: ", input$selected_playlist)
  })
}




#### Run the app ----
shinyApp(ui, server)
