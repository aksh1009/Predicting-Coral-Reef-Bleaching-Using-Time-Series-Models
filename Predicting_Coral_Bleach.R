# Step 1: Load Libraries and Dataset
install.packages("tidyverse")
install.packages("forecast")
install.packages("lubridate")
install.packages("vars")
install.packages("urca")  # for unit root tests
install.packages("reshape2")  # for melting data for heatmap

# Load libraries
library(tidyverse)
library(forecast)
library(lubridate)
library(vars)
library(urca)  # for unit root tests
library(reshape2)  # for melting data

# Load the dataset
coral_data <- read.csv("C:/Users/akshi/Downloads/coral_bleaching_data.csv")

# Step 2: Data Exploration and Preprocessing
coral_data$Date <- as.Date(coral_data$Date, format="%d-%m-%Y")  # Convert Date column to Date format
sum(is.na(coral_data))  # Check for missing values
summary(coral_data)  # Summary statistics

# Plot the Sea Surface Temperature (SST) over time
ggplot(coral_data, aes(x = Date, y = SST, color = Place.Name)) +
  geom_line() +
  labs(title = "Sea Surface Temperature Over Time", y = "SST (°C)", x = "Date")

# Step 3: Exploratory Analysis on Key Variables
ggplot(coral_data, aes(x = SST, y = Solar.Radiation, color = as.factor(Bleaching))) +
  geom_point() +
  labs(title = "SST vs Solar Radiation with Bleaching Events", color = "Bleaching")

# Step 4: Prepare the Data for Time Series Analysis
monthly_data <- coral_data %>%
  group_by(Year = year(Date), Month = month(Date, label = TRUE)) %>%
  summarise(
    SST = mean(SST),
    Solar.Radiation = mean(Solar.Radiation),
    Bleaching = max(Bleaching)  # 1 if bleaching occurred in any day of the month
  )

# Create a time series object for SST (monthly frequency)
sst_ts <- ts(monthly_data$SST, start = c(2018, 1), frequency = 12)

# Step 5: Decompose the Time Series
if(length(sst_ts) > 12) {
  decomp <- stl(sst_ts, s.window = "periodic")
  autoplot(decomp) + labs(title = "Seasonal Decomposition of SST")
} else {
  print("Not enough data for seasonal decomposition.")
}

# Step 6: Build a Predictive Model (ARIMA Example)
arima_model <- auto.arima(sst_ts)
summary(arima_model)
sst_forecast <- forecast(arima_model, h = 12)
autoplot(sst_forecast) + labs(title = "ARIMA Forecast for SST", y = "SST (°C)")

# Step 7: Define SST Threshold for Bleaching Prediction
threshold <- 29.5
predicted_bleaching <- ifelse(sst_forecast$mean > threshold, 1, 0)

# Step 8: Plot Predicted SST and Bleaching Threshold
autoplot(sst_forecast) +
  geom_hline(yintercept = threshold, color = "red", linetype = "dashed") +
  labs(title = "Predicted SST and Bleaching Threshold", y = "SST (°C)")

# Step 9: ARIMAX Model with Exogenous Variables
arima_model_xreg <- auto.arima(sst_ts, xreg = monthly_data$Solar.Radiation)
summary(arima_model_xreg)
sst_forecast_xreg <- forecast(arima_model_xreg, xreg = rep(mean(monthly_data$Solar.Radiation), 12), h = 12)
autoplot(sst_forecast_xreg) + labs(title = "ARIMAX Forecast for SST", y = "SST (°C)")

# Step 10: Exponential Smoothing (ETS) Model
ets_model <- ets(sst_ts)
summary(ets_model)
ets_forecast <- forecast(ets_model, h = 12)
autoplot(ets_forecast) + labs(title = "ETS Model Forecast for SST", y = "SST (°C)")

# Step 11: Vector Autoregression (VAR) Model
var_data <- cbind(sst_ts, monthly_data$Solar.Radiation)
colnames(var_data) <- c("SST", "Solar_Radiation")

# Check for stationarity (ADF Test)
adf_test_sst <- ur.df(var_data[, "SST"], type = "drift", lags = 12)
adf_test_sst
adf_test_sr <- ur.df(var_data[, "Solar_Radiation"], type = "drift", lags = 12)
adf_test_sr

# Fit a VAR model
var_model <- VAR(var_data, p = 2)
summary(var_model)
var_forecast <- predict(var_model, n.ahead = 12)
var_forecast_sst <- ts(var_forecast$fcst$SST[, 1], start = c(2018, 1), frequency = 12)
autoplot(var_forecast_sst) + labs(title = "VAR Model Forecast for SST", y = "SST (°C)")

# Step 12: Model Residuals and Diagnostics
residuals_arima <- residuals(arima_model)
residuals_ets <- residuals(ets_model)
residuals_var <- residuals(var_model)
residuals_var_sst <- residuals_var[, "SST"]

acf(residuals_var_sst)
pacf(residuals_var_sst)
plot(residuals_var_sst)

# Step 13: Comparison of Models (RMSE and AIC)
arima_rmse <- sqrt(mean(residuals_arima^2))
arima_aic <- AIC(arima_model)
ets_rmse <- sqrt(mean(residuals_ets^2))
ets_aic <- AIC(ets_model)
var_rmse <- sqrt(mean(residuals_var_sst^2))
var_aic <- AIC(var_model)

model_comparison <- data.frame(
  Model = c("ARIMA", "ETS", "VAR"),
  RMSE = c(arima_rmse, ets_rmse, var_rmse),
  AIC = c(arima_aic, ets_aic, var_aic)
)
print(model_comparison)

best_model <- model_comparison[which.min(model_comparison$RMSE), "Model"]
cat("The best model based on RMSE is:", best_model, "\n")

# Step 14: Sensitivity Analysis and Additional Visualizations
cor_matrix <- cor(var_data)
melted_cor <- melt(cor_matrix)
ggplot(melted_cor, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_minimal() +
  labs(title = "Correlation Heatmap of SST and Solar Radiation")
