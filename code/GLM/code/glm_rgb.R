
library(ggplot2)
library(tidyr)
library(dplyr)
library(glmmTMB)
setwd("E:/Colorimetry/Color_correction_protocol/code/GAMs")

wp_df <- read.csv("data/wp_rgb_scale_with_metadata.csv")

long_wp_df <- wp_df %>% 
  select(gray3_Red, gray3_Green, gray3_Blue, ColorChartNumber) %>% 
  pivot_longer(cols = starts_with("gray3"),
                                  names_to = "Channel",
                                  values_to = "Value") %>% 
  mutate(Channel = case_when(
    Channel == "gray3_Red" ~ "Red",
    Channel == "gray3_Green" ~ "Green",
    Channel == "gray3_Blue" ~ "Blue"
  ))

long_wp_df$ColorChartNumber <- as.factor(long_wp_df$ColorChartNumber)


red_long_wp_df <- long_wp_df %>% 
  filter(Channel == "Red")

m_red <- lm(log(Value) ~ 1, data = red_long_wp_df)
m_red_re <- glmmTMB(log(Value) ~ (1|ColorChartNumber), data = red_long_wp_df, family = gaussian())

green_long_wp_df <- long_wp_df %>% 
  filter(Channel == "Green")

m_green <- lm(log(Value) ~ 1, data = green_long_wp_df)
m_green_re <- glmmTMB(log(Value) ~ (1|ColorChartNumber), data = green_long_wp_df, family = gaussian())

blue_long_wp_df <- long_wp_df %>% 
  filter(Channel == "Blue")

m_blue <- lm(log(Value) ~ 1, data = blue_long_wp_df)
m_blue_re <- glmmTMB(log(Value) ~ (1|ColorChartNumber), data = blue_long_wp_df, family = gaussian())

exp(summary(m_red_re)$coefficients$cond["(Intercept)", "Estimate"])

# Define row name
patch_names <- c("gray3")

# Create data frame with one row (gray3) and 3 exponentiated intercepts
patch_table <- data.frame(
  Red   = exp(summary(m_red_re)$coefficients$cond["(Intercept)", "Estimate"]),
  Green = exp(summary(m_green_re)$coefficients$cond["(Intercept)", "Estimate"]),
  Blue  = exp(summary(m_blue_re)$coefficients$cond["(Intercept)", "Estimate"]),
  row.names = patch_names
)

# View the result
patch_table

write.csv(patch_table, file = "data/gray3_rgb_patch_table.csv", row.names = TRUE)

#All Channels 
ggplot(long_wp_df, aes(x = ColorChartNumber, y = Value, color = Channel)) +
  geom_point(size = 3, alpha = 0.8) +
  labs(title = "Gray 3 RGB Values Per Color Chart",
       x = "Color Chart",
       y = "Gray3 RGB Values",
       color = "Channel")


#Red Channel 

red_pi_values <- ggplot(filter(long_wp_df, Channel == 'Red'),
       aes(x = ColorChartNumber, y = Value)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_hline(yintercept = patch_table$Red, 
             linetype = "dashed", color = "red", size = 1) +
  labs(title = "Red Channel Gray 3 RGB Values Per Color Chart",
       x = "Color Chart",
       y = "Gray3 RGB Values",
       color = "Channel")

ggplot(filter(long_wp_df, Channel == 'Red'),
       aes(x = ColorChartNumber, y = Value)) +
  # Observed points
  geom_point(aes(color = "Observed"), size = 3, alpha = 0.8) +
  
  # Predicted line
  geom_hline(aes(yintercept = patch_table$Red, color = "Predicted"), 
             linetype = "dashed", size = 1) +
  
  # Custom legend
  scale_color_manual(name = "Legend",
                     values = c("Observed" = "black", "Predicted" = "red"),
                     labels = c("Observed Red Channel Pixel Intensity",
                                "Predicted Red Channel Pixel Intensity")) +
  
  labs(title = "Red Channel Gray 3 RGB Values Per Color Chart",
       x = "Color Chart",
       y = "Gray3 RGB Values") +
  
  # Move legend inside the plot
  theme(legend.position = c(0.9, 0.8),  # adjust x, y as needed
        legend.background = element_rect(fill = "white", color = "black"),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9))


