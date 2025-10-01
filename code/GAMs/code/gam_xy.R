
library(mgcv)
library(ggplot2)
library(reshape2)
library(plotly)

setwd("E:/Colorimetry/Color_correction_protocol/code/GAMs")

channel_name <- "Blue"

# Edit lines that call x_wb_scaling based on desired channel

# Loading the data.
wp_df <- read.csv("data/wp_rgb_scale_with_metadata.csv")

## Fitting the GAM to the specified channel.http://127.0.0.1:36971/graphics/a5f950d9-478a-4dd7-9b83-a4b0dbd5ba1c.png


# Specify smooth function for x and y
gam_wp <- gam(log(B_wb_scaling) ~ s(x, y, k = 10), # Edit depending on channel of interest
              family = gaussian(), # we assume this data will be normally distributed
              data = wp_df)

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

# Making predictions:
# Create a dataset with the x-y values ranges you want.It then outputs every possible x,y value combination
pred_wp_df <- expand.grid(x = seq(from = -8, to = 4, length.out = 350), # length.out will produce equally spaced increments that total 350 between the ranges specified
                          y = seq(from = -4, to = 31, length.out = 350))

# Compute distance to the line for each row in pred_wp_df
pred_wp_df$distance_to_line <- abs(a * pred_wp_df$x + b * pred_wp_df$y + c) / sqrt(a^2 + b^2)

# Filter out rows where distance is greater than average
pred_wp_df <- pred_wp_df[pred_wp_df$distance_to_line <= avg_distance, ]

# Run expanded grid with x,y ranges through the GAM to produce predictions for each x,y coordinate 
pred_wp_df$prediction <- exp(predict(gam_wp, newdata = pred_wp_df)) # exp the white balance scaling values that were logged to force positive number.

# Input real x, y values from data through the GAM to produce a prediction per real x,y value combination 
wp_df$prediction <- exp(predict(gam_wp, newdata = wp_df[, c("x", "y")])) # exp the white balance scaling values that were logged to force positive numbers

# Plotting predictions in 3D space.
grid_of_predictions <- acast(pred_wp_df, y ~ x, value.var = "prediction")
plot_ly(x = colnames(grid_of_predictions),
        y = rownames(grid_of_predictions),
        z = ~grid_of_predictions,
        type = "surface") %>%
  layout(title = paste(channel_name,"Channel Prediction Surface"))

plot_ly(x = colnames(grid_of_predictions),
        y = rownames(grid_of_predictions),
        z = ~grid_of_predictions,
        type = "contour") %>%
  layout(title = paste(channel_name, "Channel Prediction Surface"))

 #Scatter Plots for Predicted and Observed White Balance Scaling Factor at each x Location
p_scatter <- ggplot(wp_df) +
  geom_point(aes(x = x, y = B_wb_scaling, color = "Observed"), alpha = 0.7, size = 2) + # Edit depending on channel of interest
  geom_point(aes(x = x, y = prediction, color = "Predicted"), size = 3) +
  scale_color_manual(values = c("Observed" = "black", "Predicted" = "blue")) +
  labs(
    title = paste("Observed and Predicted", channel_name, "Scaling Factors by X Coordinate"),
    x = "X Coordinate",
    y = paste(channel_name, "White Balance Scaling Value"),
    color = "Legend"
  ) +
  theme_minimal()
p_scatter

#Plot for Observed vs Predicted White Balance Scaling Factor
obs_vs_pred <- ggplot(wp_df, aes(x = prediction, y = B_wb_scaling)) +     # Edit depending on channel of interest
  geom_point(color = "black") +  # observed vs predicted points
  geom_abline(slope = 1, intercept = 0, color = "blue", linetype = "dashed") +  # y = x reference line
  labs(title = paste("Predicted vs Observed", channel_name, "Scaling Values"),
       x = ("Predicted Scaling Value"),
       y = paste("Observed", channel_name, "Scaling Value")) +
  theme_minimal()
obs_vs_pred

# #Plot for smooth function x,y
# plot(gam_wp, select = 1, main = paste("Smooth Function:", channel_name, "Scaling vs X"))
# plot(gam_wp, select = 2, main = paste("Smooth Function:", channel_name, "Scaling vs Y"))

#Plot for residuals vs fitted plots
wp_df$residuals <- residuals(gam_wp) # Get residuals from GAM (observed at x,y - predicted at x,y)
res_vs_pred <- ggplot(wp_df, aes(x = prediction, y = residuals)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "blue") +  # zero residual line
  labs(
    title = paste(channel_name,"Scaling Factor Residuals vs. Fitted Values"),
    x = "Fitted Values",
    y = "Residuals"
  ) +
  theme_minimal()

res_vs_pred

# Quantile Quantile Plot
# The qq plot gets our model's residuals, orders them from smallest to largest and then breaks them up into quantiles.
# Next, it creates theoretical quantiles which assume for example that 0 is the 50th percentile. It then plots the sample's
# quantile values against the theoretical quantiles and if they match they lie on the line representing a 1:1 relationship
# between theoretical quantiles and sample quantiles. If they don't match, the point will be off the line.
qqnorm(wp_df$residuals, main = paste("Q-Q Plot of", channel_name, "GAM Residuals"))  # plots sample quantiles vs normal quantiles
qqline(wp_df$residuals, col = "blue")  # adds the reference line 1:1




