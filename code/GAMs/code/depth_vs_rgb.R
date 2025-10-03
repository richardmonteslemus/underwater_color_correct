library(ggplot2)
library(tidyr)
library(dplyr)
setwd( "E:/Colorimetry/underwater_color_correct/code/GAMs")

# Plot that checks if there is a relationship between RGB Pixel Intensity Value vs Depth
# Results so far have found no relationship 

wp_df <- read.csv("data/wp_rgb_scale_with_metadata.csv")

long_wp_df <- wp_df %>% 
  select(gray3_Red, gray3_Green, gray3_Blue, depth) %>% 
  pivot_longer(cols = starts_with("gray3"),
               names_to = "Channel",
               values_to = "Value") %>% 
  mutate(Channel = case_when(
    Channel == "gray3_Red" ~ "Red",
    Channel == "gray3_Green" ~ "Green",
    Channel == "gray3_Blue" ~ "Blue"
  ))

ggplot(long_wp_df, aes(x = depth, y = Value, color = Channel)) +
  geom_point() +
  labs(
    title = "Pixel Intensity vs. Depth",
    x = "Depth (m)",
    y = "Pixel Intensity"
  ) +
  theme_minimal()
