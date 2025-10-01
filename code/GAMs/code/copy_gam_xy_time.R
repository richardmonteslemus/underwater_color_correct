library(mgcv)
library(ggplot2)
setwd("E:/Colorimetry/Color_correction_protocol/code/GAMs")

# This script uses a GAM that contains a smooth function with an interaction between x and y, 
# and a smooth function for time to generate predicted white balance scaling factors. 

channel_name <- "Blue"

# Edit lines that call x_wb_scaling based on desired channel

# Loading the data.
#wp_df <- read.csv("E:/Colorimetry/Photos/Perlas/Contadora_28_August_2023/Contadora_28_Aug_2023_0to25/wb_scale_with_metadata_xyd.csv")
wp_df <- read.csv("E:/archive/rgb_depth_bc_/wp_rgb_scale_with_metadata.csv")

# Convert Time column (formatted as "YYYY:MM:DD HH:MM:SS") to POSIXct
wp_df$Time_parsed <- as.POSIXct(wp_df$Time, format = "%Y:%m:%d %H:%M:%S")

# Calculate seconds since 00:00:00 on the same date
midnight_time <- as.POSIXct(format(wp_df$Time_parsed, "%Y-%m-%d 00:00:00"))
wp_df$Seconds_since_midnight <- as.numeric(difftime(wp_df$Time_parsed, midnight_time, units = "secs"))


## Fitting the GAM to the specified channel.
# Specify smooth function for x, y, and time

gam_full <- gam(log(B_wb_scaling) ~ s(x,y, k = 10) + s(Seconds_since_midnight), # Edit depending on channel of interest
                family = gaussian(), # we assume this data will be normally distributed
                data = wp_df)

# Use two points in the orthomosaic to create a line. Then calculate the average distance 
# of each color chart from the line. Use this average to generate grid with predictions 
# that only lie within this range. 

min_sec = min(wp_df$Seconds_since_midnight)

max_sec = max(wp_df$Seconds_since_midnight)

tran_p1_x1 = -1.212925744460637 
tran_p1_y1 = 0.809984302312581
tran_p2_x2 = -4.27017125969671 
tran_p2_y2 = 27.771400095476093

# Slope of line between two points 
# m = (tran_p2_y2 - tran_p1_y1)/(tran_p2_x2 - tran_p1_x1)

a = (tran_p1_y1 - tran_p2_y2)
b = (tran_p2_x2 - tran_p1_x1)
c = (tran_p1_x1*tran_p2_y2) - (tran_p2_x2*tran_p1_y1)

# Equation of the line between two points on the model 

wp_df$distance_to_line <- abs(a * wp_df$x + b * wp_df$y + c) / sqrt(a^2 + b^2)

avg_distance = mean(wp_df$distance_to_line)

# Create a dataset with the x,y,time values ranges you want.It then outputs every possible x,y,time value combination
pred_wp_df <- expand.grid(x = seq(from = -8, to = 4), # length.out will produce equally spaced increments that total 350 between the ranges specified
                          y = seq(from = -4, to = 31),
                          Seconds_since_midnight = seq(from = min_sec, to = max_sec))

# Compute distance to the line for each row in pred_wp_df
pred_wp_df$distance_to_line <- abs(a * pred_wp_df$x + b * pred_wp_df$y + c) / sqrt(a^2 + b^2)

# Filter out rows where distance is greater than average
pred_wp_df <- pred_wp_df[pred_wp_df$distance_to_line <= avg_distance, ]

# Run expanded grid with x,y, time ranges through the GAM to produce predictions for each x,y, time coordinate 
pred_wp_df$prediction <- exp(predict(gam_full, newdata = pred_wp_df)) # exp the white balance scaling values that were logged to force positive numbers

# Input real x, y values from data through the GAM to produce a prediction per real x,y, time value combination 
wp_df$prediction <- exp(predict(gam_full, newdata = wp_df[, c("x", "y", "Seconds_since_midnight")])) # exp the white balance scaling values that were logged to force positive numbers

#Plot for Observed vs Predicted White Balance Scaling Factor
obs_vs_pred <- ggplot(wp_df, aes(x = prediction, y = B_wb_scaling)) +     # Edit depending on channel of interest
  geom_point(color = "black") +  # observed vs predicted points
  geom_abline(slope = 1, intercept = 0, color = "blue", linetype = "dashed") +  # y = x reference line
  labs(title = paste("Predicted vs Observed", channel_name, "Scaling Values"),
       x = ("Predicted Scaling Value"),
       y = paste("Observed", channel_name, "Scaling Value")) +
  theme_minimal()
obs_vs_pred

#Plot for residuals vs fitted plots
wp_df$residuals <- residuals(gam_full) # Get residuals from GAM (observed at x,y,time - predicted at x,y, time)
res_vs_pred <- ggplot(wp_df, aes(x = prediction, y = residuals)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "blue") +  # zero residual line
  labs(
    title = paste(channel_name,"Scaling Factor Residuals vs. Fitted Values"),
    x = "Fitted Values",
    y = "Residuals"
  ) +
  theme_minimal()

print(res_vs_pred)

# Quantile Quantile Plot
# The qq plot gets our model's residuals, orders them from smallest to largest and then breaks them up into quantiles.
# Next, it creates theoretical quantiles which assume for example that 0 is the 50th percentile. It then plots the sample's
# quantile values against the theoretical quantiles and if they match they lie on the line representing a 1:1 relationship
# between theoretical quantiles and sample quantiles. If they don't match, the point will be off the line.
qqnorm(wp_df$residuals, main = paste("Q-Q Plot of", channel_name, "GAM Residuals"))  # plots sample quantiles vs normal quantiles
qqline(wp_df$residuals, col = "blue")  # adds the reference line 1:1

df_full <- data.frame(
  Seconds_since_midnight = min(wp_df$Seconds_since_midnight):max(wp_df$Seconds_since_midnight),
  x = mean(wp_df$x),
  y = mean(wp_df$y)
)  
df_full$pred <- exp(predict(gam_full, newdata = df_full))


