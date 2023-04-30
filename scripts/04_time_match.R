# Calculate absolute differences between selected playlist and each place
diffs <- abs(places_df$route_times_sec - playlist_length_sec)

# Find index of closest value
idx <- which.min(diffs)

# Save the closest value
closest_val <- places_df$route_times_sec[idx]
placename <- places_df$place_name[idx]

# Print the result
print(c(closest_val, placename))
