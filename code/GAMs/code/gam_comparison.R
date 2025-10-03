library(mgcv)
library(ggplot2)

setwd("E:/Colorimetry/underwater_color_correct/code/GAMs")

# Load data
wp_df <- read.csv("data/wp_rgb_scale_with_metadata.csv")

# Convert Time to POSIXct
wp_df$Time_parsed <- as.POSIXct(wp_df$Time, format = "%Y:%m:%d %H:%M:%S")

# Calculate seconds since midnight
midnight_time <- as.POSIXct(format(wp_df$Time_parsed, "%Y-%m-%d 00:00:00"))
wp_df$Seconds_since_midnight <- as.numeric(difftime(wp_df$Time_parsed, midnight_time, units = "secs"))

# *** GAM for time ONLY ***

# Fit GAM model
gam_time_only <- gam(log(B_wb_scaling) ~ s(Seconds_since_midnight, k = 5), data = wp_df)

# Prediction grid
df <- data.frame(Seconds_since_midnight = seq(
  from = min(wp_df$Seconds_since_midnight),
  to = max(wp_df$Seconds_since_midnight),
  length.out = 1000
))
df$pred <- exp(predict(gam_time_only, newdata = df))

# Plot showing how observed and predicted white balance scaling factors for the blue channel change over time 
gam_time_plot <- ggplot() +
  geom_point(data = wp_df, aes(x = Seconds_since_midnight, y = B_wb_scaling, color = "Observed"), 
             size = 1.5, alpha = 0.6) +
  geom_line(data = df, aes(x = Seconds_since_midnight, y = pred, color = "Predicted"), 
            size = 1.2) +
  scale_color_manual(name = "Legend", 
                     values = c("Observed" = "blue", "Predicted" = "black")) +
  labs(
    title = "Observed and Predicted White Balance Scaling Factor (Blue Channel)",
    x = "Time (seconds since midnight)",
    y = "White Balance Scaling Factor"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 21, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 21),
    axis.text = element_text(size = 21),
    legend.title = element_text(size = 19),
    legend.text = element_text(size = 19),
    legend.position = c(0.95, 0.95),       # Top-right inside the plot
    legend.justification = c("right", "top"),
    legend.background = element_rect(fill = "white", color = "black", size = 0.3)
  )

gam_time_plot
# *** GAM for time and x,y interaction ***

gam_full <- gam(log(B_wb_scaling) ~ s(x, y, k = 5) 
                + s(Seconds_since_midnight), family = gaussian(), data = wp_df)
df_full <- data.frame(
  Seconds_since_midnight = min(wp_df$Seconds_since_midnight):max(wp_df$Seconds_since_midnight),
  x = mean(wp_df$x),
  y = mean(wp_df$y)
)  
df_full$pred <- exp(predict(gam_full, newdata = df_full))

#Plot showing how observed and predicted white balance scaling factors change for the blue channel over time

gam_full_plot <- ggplot() +
  geom_point(data = wp_df, aes(x = Seconds_since_midnight, y = B_wb_scaling, color = "Observed"), 
             size = 1.5, alpha = 0.6) +
  geom_line(data = df_full, aes(x = Seconds_since_midnight, y = pred, color = "Predicted"), 
            size = 1.2) +
  scale_color_manual(name = "Legend", 
                     values = c("Observed" = "blue", "Predicted" = "black")) +
  labs(
    title = "Observed and Predicted White Balance Scaling Factor (Blue Channel)",
    x = "Time (seconds since midnight)",
    y = "White Balance Scaling Factor"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 21, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 21),
    axis.text = element_text(size = 21),
    legend.title = element_text(size = 19),
    legend.text = element_text(size = 19),
    legend.position = c(0.95, 0.95),       # Top-right inside the plot
    legend.justification = c("right", "top"),
    legend.background = element_rect(fill = "white", color = "black", size = 0.3)
  )

gam_full_plot

# Compare time-only model vs full model

gam_time_only <- gam(log(R_wb_scaling) ~ s(Seconds_since_midnight), 
                     family = gaussian(), data = wp_df)
gam_full <- gam(log(R_wb_scaling) ~ s(x, y, k = 5) 
                + s(Seconds_since_midnight), family = gaussian(), data = wp_df)
# Model comparison

summary(gam_time_only)
summary(gam_full_plot)

anova(gam_time_only, gam_full, test = "F")
