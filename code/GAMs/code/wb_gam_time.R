library(mgcv)
library(ggplot2)

setwd("E:/Colorimetry/underwater_color_correct/code/GAMs")

savePath <- "E:/Colorimetry/Photos/Perlas/Contadora_28_August_2023/Contadora_28_Aug_2023_0to25"

# Load data
wb_df <- read.csv(file.path(savePath, "wb_scale_with_metadata.csv"))
meta_wb_df <- read.csv(file.path(savePath, "metadata.csv"))

# === Fit GAM models for R, G, B === 
gam_time_r <- gam(log(R_wb_scaling) ~ s(Seconds_since_midnight, k = 5), data = wb_df)
gam_time_g <- gam(log(G_wb_scaling) ~ s(Seconds_since_midnight, k = 5), data = wb_df)
gam_time_b <- gam(log(B_wb_scaling) ~ s(Seconds_since_midnight, k = 5), data = wb_df)

# === Create prediction grid for plotting ===
df <- data.frame(Seconds_since_midnight = seq(
  from = min(wb_df$Seconds_since_midnight),
  to = max(wb_df$Seconds_since_midnight),
  length.out = 1000
))

df$red_pred   <- exp(predict(gam_time_r, newdata = df))
df$green_pred <- exp(predict(gam_time_g, newdata = df))
df$blue_pred  <- exp(predict(gam_time_b, newdata = df))


# === Plot for red channel ===

gam_time_r_plot <- ggplot() +
  geom_point(data = wb_df, aes(x = Seconds_since_midnight, y = R_wb_scaling, color = "Observed"), 
             size = 1.5, alpha = 0.6) +
  geom_line(data = df, aes(x = Seconds_since_midnight, y = red_pred, color = "Predicted"), 
            size = 1.2) +
  scale_color_manual(name = "Legend", 
                     values = c("Observed" = "red", "Predicted" = "black")) +
  labs(
    title = "Observed and Predicted White Balance Scaling Factor (Red Channel)",
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
    legend.position = c(0.95, 0.95),
    legend.justification = c("right", "top"),
    legend.background = element_rect(fill = "white", color = "black", size = 0.3)
  )

print(gam_time_r_plot)

# === Plot for green channel ===

gam_time_g_plot <- ggplot() +
  geom_point(data = wb_df, aes(x = Seconds_since_midnight, y = G_wb_scaling, color = "Observed"), 
             size = 1.5, alpha = 0.6) +
  geom_line(data = df, aes(x = Seconds_since_midnight, y = green_pred, color = "Predicted"), 
            size = 1.2) +
  scale_color_manual(name = "Legend", 
                     values = c("Observed" = "green", "Predicted" = "black")) +
  labs(
    title = "Observed and Predicted White Balance Scaling Factor (Green Channel)",
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
    legend.position = c(0.95, 0.95),
    legend.justification = c("right", "top"),
    legend.background = element_rect(fill = "white", color = "black", size = 0.3)
  )

print(gam_time_g_plot)


# === Plot for blue channel ===
gam_time_b_plot <- ggplot() +
  geom_point(data = wb_df, aes(x = Seconds_since_midnight, y = B_wb_scaling, color = "Observed"), 
             size = 1.5, alpha = 0.6) +
  geom_line(data = df, aes(x = Seconds_since_midnight, y = blue_pred, color = "Predicted"), 
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
    legend.position = c(0.95, 0.95),
    legend.justification = c("right", "top"),
    legend.background = element_rect(fill = "white", color = "black", size = 0.3)
  )

print(gam_time_b_plot)

# === Create CSV prediction grid (1-second intervals) === 
csv_df <- data.frame(Seconds_since_midnight = seq(
  from = min(meta_wb_df$Seconds_since_midnight),
  to = max(meta_wb_df$Seconds_since_midnight),
  by = 1
))

csv_df$red_pred   <- exp(predict(gam_time_r, newdata = csv_df)) 
csv_df$green_pred <- exp(predict(gam_time_g, newdata = csv_df))
csv_df$blue_pred  <- exp(predict(gam_time_b, newdata = csv_df))

# === Join predictions into metadata ===
meta_with_scale <- merge(
  meta_wb_df,
  csv_df,
  by = "Seconds_since_midnight",
  all.x = TRUE
)

# === Save merged metadata with predictions ===
output_file <- file.path(savePath, "gam_t_scale.csv")
write.csv(meta_with_scale, output_file, row.names = FALSE)
cat("Saved metadata with scaling factors to:\n", output_file, "\n")











