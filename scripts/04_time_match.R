# Calculate absolute differences
diffs <- abs(places$route_times_sec - playlist_length_sec)

# Find index of closest value
idx <- which.min(diffs)

# Print closest value
closest_val <- places$route_times_sec[idx]
placename <- places$place_name[idx]
print(c(closest_val, placename))
