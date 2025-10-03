
library(mgcv)
library(ggplot2)
library(dplyr)

# === Setup paths ===
setwd("E:/Colorimetry/underwater_color_correct/code/GAMs")
savePath <- "E:/Colorimetry/Photos/Perlas/Contadora_28_August_2023/Contadora_28_Aug_2023_0to25"

# === Load data ===
wp_df <- read.csv(file.path(savePath, "wb_scale_with_metadata_xyd.csv"))

# === Define transect line ===
tran_p1 <- c(-1.212925744460637, 0.809984302312581)
tran_p2 <- c(-4.27017125969671, 27.771400095476093)

a <- tran_p1[2] - tran_p2[2]
b <- tran_p2[1] - tran_p1[1]
c <- tran_p1[1] * tran_p2[2] - tran_p2[1] * tran_p1[2]

# === Compute distance from line and average distance ===
wp_df$distance_to_line <- abs(a * wp_df$x + b * wp_df$y + c) / sqrt(a^2 + b^2)
avg_distance <- mean(wp_df$distance_to_line)

# === Define channel mappings ===
channels <- list(
  R = "R_wb_scaling",
  G = "G_wb_scaling",
  B = "B_wb_scaling"
)

# === Initialize combined prediction grid ===
combined_preds <- NULL

# === Loop over each channel ===
for (channel in names(channels)) {
  
  scaling_col <- channels[[channel]]
  channel_name <- switch(channel, R = "Red", G = "Green", B = "Blue")
  
  # === Fit GAM ===
  gam_model <- gam(
    formula = as.formula(paste("log(", scaling_col, ") ~ s(x, y, k = 10 ) + s(Seconds_since_midnight, k = 5)")),
    data = wp_df,
    family = gaussian()
  )
  
  # === Predict for observed data ===
  wp_df$prediction <- exp(predict(gam_model, newdata = wp_df[, c("x", "y", "Seconds_since_midnight")]))
  wp_df$residuals <- residuals(gam_model)
  
  # === Predict over grid ===
  pred_wp_df <- expand.grid(
    x = seq(from = -8, to = 4, length.out = 80),
    y = seq(from = -4, to = 31, length.out = 80),
    Seconds_since_midnight = seq(min(wp_df$Seconds_since_midnight), max(wp_df$Seconds_since_midnight), by = 1)
  )
  pred_wp_df$distance_to_line <- abs(a * pred_wp_df$x + b * pred_wp_df$y + c) / sqrt(a^2 + b^2)
  pred_wp_df <- pred_wp_df[pred_wp_df$distance_to_line <= avg_distance, ]
  pred_wp_df[[paste0(channel, "_pred")]] <- exp(predict(gam_model, newdata = pred_wp_df))
  
  # === Merge into combined prediction table ===
  if (is.null(combined_preds)) {
    combined_preds <- pred_wp_df[, c("x", "y", "Seconds_since_midnight", paste0(channel, "_pred"))]
  } else {
    combined_preds <- merge(combined_preds, pred_wp_df[, c("x", "y", "Seconds_since_midnight", paste0(channel, "_pred"))],
                            by = c("x", "y", "Seconds_since_midnight"), all = TRUE)
  }
  
  # === Plot: Observed vs Predicted ===
  ggplot(wp_df, aes(x = prediction, y = .data[[scaling_col]])) +
    geom_point() +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "blue") +
    labs(title = paste("Predicted vs Observed", channel_name, "Scaling Values"),
         x = "Predicted", y = paste("Observed", channel_name)) +
    theme_minimal() -> p1
  print(p1)
  
  # === Plot: Residuals vs Fitted ===
  ggplot(wp_df, aes(x = prediction, y = residuals)) +
    geom_point(alpha = 0.6) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "blue") +
    labs(title = paste(channel_name, "Residuals vs Fitted"),
         x = "Fitted", y = "Residuals") +
    theme_minimal() -> p2
  print(p2)
  
  # === Plot: QQ Plot ===
  qqnorm(wp_df$residuals, main = paste("Q-Q Plot of", channel_name, "Residuals"))
  qqline(wp_df$residuals, col = "blue")
}

# === Save combined RGB prediction grid ===
output_csv <- file.path(savePath, "gam_txy_scale.csv")
write.csv(combined_preds, output_csv, row.names = FALSE)
cat("Saved combined RGB prediction grid to:\n", output_csv, "\n")
