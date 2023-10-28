# UniLu_DMinR
University Luzern FS 23 "Data Mining in R" sandbox for the Capstone Project

The project aims to create a personalized "self-care" walking experience for users. In this scenario, users access their Spotify accounts to select a playlist of their choice. The project then leverages three key application programming interfaces (APIs) to enhance this experience: Spotify API, Google Places API, and Google Directions API.

1. **Spotify API**: Allows users to interact with their Spotify accounts and select a playlist. 

2. **Google Places API**: In this context, the starting point is fixed at the University of Lucerne. The API is used to find nearby restaurants or other relevant places within walking distance.

3. **Google Directions API**: Calculates the best walking route from the University of Lucerne to the selected destination.

The end result is a tailored self-care walk. Users choose a playlist that sets the mood, and the project, with the aid of the Google APIs, finds a nearby location for them to visit on foot. 

Used libraries:
- httr
- jsonlite
- tidyverse
- here
- knitr
- spotifyr
- lubridate



In order to interact with Spotify and the Google APIs within this project, users are required to complete several key steps:

1) The user needs to create a Spotify app on <https://developer.spotify.com/> and have their "Client ID" and "Client secret" ready.
Furthermore, their Spotify User ID will also be needed. This can be found in the application Home > Settings > Account > Username or on <https://open.spotify.com> Display name (upper right corner) > Account > Username.

2) For Google API, the user needs an API key from <https://developers.google.com/maps/>. 

Kindly consult the documentations for more precise information.


For further information please see /output/1_final_report.html
