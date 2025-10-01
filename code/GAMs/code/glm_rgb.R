library(dplyr)
library(tidyr)
library(glmmTMB)
library(glue)

setwd("E:/Colorimetry/Color_correction_protocol/code/GAMs")

savePath <- "E:/Colorimetry/Photos/Perlas/Contadora_28_August_2023/Contadora_28_Aug_2023_0to25"

# Specify your chosen patch
patch <- "gray3"

reflectance = 0.50

# Load data
wb_df <- read.csv(file.path(savePath, "wb_scale_with_metadata.csv"))

# Dynamically select the patch columns
patch_cols <- c(
  paste0(patch, "_Red"),
  paste0(patch, "_Green"),
  paste0(patch, "_Blue")
)

long_wb_df <- wb_df %>%
  select(all_of(c(patch_cols, "ColorChartNumber"))) %>%
  pivot_longer(
    cols = all_of(patch_cols),
    names_to = "Channel",
    values_to = "Value"
  ) %>%
  mutate(Channel = case_when(
    Channel == paste0(patch, "_Red") ~ "Red",
    Channel == paste0(patch, "_Green") ~ "Green",
    Channel == paste0(patch, "_Blue") ~ "Blue"
  ))

long_wb_df$ColorChartNumber <- as.factor(long_wb_df$ColorChartNumber)

# Separate by channel
red_long_wb_df <- long_wb_df %>% filter(Channel == "Red")
green_long_wb_df <- long_wb_df %>% filter(Channel == "Green")
blue_long_wb_df <- long_wb_df %>% filter(Channel == "Blue")

# Fit models
m_red <- lm(log(Value) ~ 1, data = red_long_wb_df)
m_red_re <- glmmTMB(log(Value) ~ (1 | ColorChartNumber), data = red_long_wb_df, family = gaussian())

m_green <- lm(log(Value) ~ 1, data = green_long_wb_df)
m_green_re <- glmmTMB(log(Value) ~ (1 | ColorChartNumber), data = green_long_wb_df, family = gaussian())

m_blue <- lm(log(Value) ~ 1, data = blue_long_wb_df)
m_blue_re <- glmmTMB(log(Value) ~ (1 | ColorChartNumber), data = blue_long_wb_df, family = gaussian())

# Print exponentiated intercept for red
exp(summary(m_red_re)$coefficients$cond["(Intercept)", "Estimate"])

# Create data frame with one row (patch) and 3 exponentiated intercepts
patch_rgb_table <- data.frame(
  Red   = exp(summary(m_red_re)$coefficients$cond["(Intercept)", "Estimate"]),
  Green = exp(summary(m_green_re)$coefficients$cond["(Intercept)", "Estimate"]),
  Blue  = exp(summary(m_blue_re)$coefficients$cond["(Intercept)", "Estimate"]),
  row.names = patch
)

patch_rgb_table$Red_scale <- reflectance/patch_rgb_table$Red

patch_rgb_table$Green_scale <- reflectance/patch_rgb_table$Green

patch_rgb_table$Blue_scale <- reflectance/patch_rgb_table$Blue


# View the result
print(patch_rgb_table)

# === Save RGB Averages and Scales ===
output_file <- file.path(savePath, glue("glm_scale.csv"))
write.csv(patch_rgb_table, output_file, row.names = FALSE)
cat("Saved RGB white balance scales to:\n", output_file, "\n")


#RGB Average Across All Channels 
ggplot(long_wb_df, aes(x = ColorChartNumber, y = Value, color = Channel)) +
  geom_point(size = 3, alpha = 0.8) +
  labs(title = "Gray 3 RGB Average Values Per Color Chart",
       x = "Color Chart",
       y = "Gray3 RGB Values",
       color = "Channel")

# === Red Channel RGB Average ===
red_plot_title <- glue("Red Channel {patch} RGB Average Per Color Chart")
red_y_label <- glue("{patch} RGB Values")

red_pi_plot <- ggplot(filter(long_wb_df, Channel == 'Red'),
                      aes(x = ColorChartNumber, y = Value)) +
  geom_point(aes(color = "Observed"), size = 3, alpha = 0.8) +
  geom_hline(aes(yintercept = patch_rgb_table$Red, color = "Predicted"), 
             linetype = "dashed", size = 1) +
  scale_color_manual(name = "Legend",
                     values = c("Observed" = "black", "Predicted" = "red"),
                     labels = c("Observed Red Channel Pixel Intensity",
                                "Predicted Red Channel Pixel Intensity")) +
  labs(title = red_plot_title,
       x = "Color Chart",
       y = red_y_label) +
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white", color = "black"),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9))
print(red_pi_plot)

# === Green Channel RGB Average ===
green_plot_title <- glue("Green Channel {patch} RGB Average Per Color Chart")
green_y_label <- glue("{patch} RGB Values")

green_pi_plot <- ggplot(filter(long_wb_df, Channel == 'Green'),
                        aes(x = ColorChartNumber, y = Value)) +
  geom_point(aes(color = "Observed"), size = 3, alpha = 0.8) +
  geom_hline(aes(yintercept = patch_rgb_table$Green, color = "Predicted"), 
             linetype = "dashed", size = 1) +
  scale_color_manual(name = "Legend",
                     values = c("Observed" = "black", "Predicted" = "green"),
                     labels = c("Observed Green Channel Pixel Intensity",
                                "Predicted Green Channel Pixel Intensity")) +
  labs(title = green_plot_title,
       x = "Color Chart",
       y = green_y_label) +
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white", color = "black"),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9))
print(green_pi_plot)

# === Blue Channel RGB Average ===
blue_plot_title <- glue("Blue Channel {patch} RGB Average Per Color Chart")
blue_y_label <- glue("{patch} RGB Values")

blue_pi_plot <- ggplot(filter(long_wb_df, Channel == 'Blue'),
                       aes(x = ColorChartNumber, y = Value)) +
  geom_point(aes(color = "Observed"), size = 3, alpha = 0.8) +
  geom_hline(aes(yintercept = patch_rgb_table$Blue, color = "Predicted"), 
             linetype = "dashed", size = 1) +
  scale_color_manual(name = "Legend",
                     values = c("Observed" = "black", "Predicted" = "blue"),
                     labels = c("Observed Blue Channel Pixel Intensity",
                                "Predicted Blue Channel Pixel Intensity")) +
  labs(title = blue_plot_title,
       x = "Color Chart",
       y = blue_y_label) +
  theme(legend.position = c(0.9, 0.8),
        legend.background = element_rect(fill = "white", color = "black"),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9))
print(blue_pi_plot)
