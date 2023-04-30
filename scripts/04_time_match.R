# Calculate absolute differences between selected playlist and each place
diffs <- c()
for (i in seq_along(route_info)) {
  diffs[i] <- abs(route_info$route_time_sec[i] - playlist_length_sec)
}

# Find index of closest value
idx <- which.min(diffs)

# Save the closest value
closest_val <- route_info$route_time_sec[idx]
placename <- route_info$place_name[idx]

# Print the result
print(c(closest_val, placename))
