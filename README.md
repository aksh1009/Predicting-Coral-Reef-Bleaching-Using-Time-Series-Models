
# Predicting Coral Reef Bleaching Using Time Series Models
Probability and Statistics Course Project - October 2024

## Project Overview
Coral bleaching is a severe environmental issue where corals expel the algae (*zooxanthellae*) living in their tissues, causing them to turn white. This process is often triggered by environmental stress—primarily rising **Sea Surface Temperatures (SST)**—and can lead to coral death, reducing marine biodiversity. This project analyzes historical coral bleaching data, identifies key environmental factors, and builds **time series forecasting models** to predict future bleaching events.

---

## Objectives
- Explore and preprocess coral bleaching datasets.
- Identify relationships between **SST**, **Solar Radiation**, and bleaching events.
- Build predictive models (**ARIMA, ARIMAX, ETS, VAR**) for SST.
- Determine bleaching risk based on forecasted SST values.
- Compare models using **RMSE** and **AIC** to select the best predictor.

---

## Dataset Overview
**Attributes:**
- **Date** — Measurement date
- **Place Name** — Location of observation
- **Latitude, Longitude** — Geographic coordinates
- **Environmental Variables:**
    - SST (Sea Surface Temperature)
    - Solar Radiation
    - Chlorophyll-a Concentration
    - Sea Surface Salinity
    - Sea Level Pressure
    - Wind Speed
    - Cloud Cover
    - Wave Height
    - Precipitation
- **Bleaching** — Binary indicator (1 = bleaching observed, 0 = no bleaching)
<img width="1460" height="517" alt="image" src="https://github.com/user-attachments/assets/86e5a790-3a56-4ad9-956a-242a2e29f871" />

---

## Installation & Requirements
**R Packages (install these before running the script):**
    install.packages("tidyverse")
    install.packages("forecast")
    install.packages("lubridate")
    install.packages("vars")
    install.packages("urca")
    install.packages("reshape2")

**Load Libraries (in your script):**
    library(tidyverse)
    library(forecast)
    library(lubridate)
    library(vars)
    library(urca)
    library(reshape2)

---


## Visual Examples 
- SST over time (by location)
  <img width="817" height="795" alt="image" src="https://github.com/user-attachments/assets/f050e1e0-c62a-4ac4-967b-adf38c1b4af5" />

  
- Scatter plot of SST vs Solar Radiation (colored by bleaching)
  <img width="811" height="805" alt="image" src="https://github.com/user-attachments/assets/1d25f3ae-4686-4ce2-924c-9c6a9f1fd60d" />

- Seasonal decomposition of SST (STL)
  <img width="722" height="790" alt="image" src="https://github.com/user-attachments/assets/9a61b10a-159a-4be4-88ac-57a7af0d663d" />

- Model forecasts with bleaching threshold line
  <img width="772" height="844" alt="image" src="https://github.com/user-attachments/assets/8f8bee56-e6e2-4cfc-b2e5-35621c19fbd3" />
  <img width="725" height="794" alt="image" src="https://github.com/user-attachments/assets/75004147-c695-4c71-8725-772eddd60c71" />


- Correlation heatmap of SST and Solar Radiation
<img width="920" height="794" alt="image" src="https://github.com/user-attachments/assets/21c18451-b5ff-4374-9f71-ad115860b7df" />

---
## Results

| Model   | RMSE   | AIC     |                     Notes                          |
|---------|--------|---------|----------------------------------------------------|
| ARIMA   | 0.84   | 120.54  | Baseline time series model                         |
| ARIMAX  | 0.80   | 118.77  | Includes Solar Radiation as exogenous variable     |
| ETS     | 0.78   | 115.32  | Best performance, captures seasonality effectively |
| VAR     | 0.82   | 119.45  | Captures interactions between SST & Solar Radiation|

**Key Insights:**
- **Bleaching Risk Threshold:** SST > 29.5°C strongly correlates with bleaching events.
- **Best Model:** ETS model had the lowest RMSE and best seasonal fit.
- **Environmental Drivers:** High solar radiation and low cloud cover significantly increase SST, heightening bleaching risk.
- **Forecasting Benefit:** Model outputs can help in creating early-warning alerts for reef conservation.

## Authors
- **Sreya Mynampati** (22BAI1163)  
- **Akshita Jawahar** (22BAI1264)
