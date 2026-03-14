install.packages("zoo")
install.packages("lubridate")
install.packages("dplyr") 
install.packages("readr")
install.packages("tidyr")
install.packages("ggplot2")
install.packages("vars")
library(dplyr)
library(lubridate)
library(zoo)
library(readr)
library(tidyr)
library(ggplot2)
library(vars)
gdp <- read.csv(file.choose(),stringsAsFactors = FALSE)
nemp<- read.csv(file.choose(),stringsAsFactors = FALSE)
ecb<- read.csv(file.choose(),stringsAsFactors = FALSE)
# Convert Month column to Date
nemp$Month <- as.Date(paste0(nemp$Month, "-01"), format="%Y %B-%d")
View(nemp)
# Convert Quarter column to yearqtr type
gdp$Quarter <- as.yearqtr(gdp$Quarter, format = "%YQ%q")
gdp <- gdp %>%
  select(-Statistic.Label, -State, -UNIT)
gdp <- gdp %>% 
  rename(GDP = VALUE)
gdp <- gdp %>%
  arrange(Quarter) %>%
  mutate(GDP_Growth = 100 * (GDP / lag(GDP) - 1))
View(gdp)

# Convert monthly unemployment to quarterly (average per quarter)
nemp_quarterly <- nemp %>%
  mutate(Quarter = as.yearqtr(Month)) %>%  # convert month to quarter
  group_by(Quarter) %>%
  summarise(Unemployment = mean(VALUE, na.rm = TRUE))
View(nemp_quarterly)


# Rename columns to simpler names
colnames(ecb) <- c("DATE", "ECB_Rate")

# Convert DATE column to Date format
ecb$DATE <- dmy(ecb$DATE)
View(ecb)
# Keep only data between 2016 and 2025
ecb <- ecb %>%
  dplyr::filter(DATE >= as.Date("2016-01-01") &
                  DATE <= as.Date("2025-12-31"))

# Convert dates to quarters
ecb <- ecb %>%
  mutate(Quarter = as.yearqtr(DATE))

# Create full sequence of quarters from 2016 Q1 to 2025 Q4
all_quarters <- data.frame(
  Quarter = seq(as.yearqtr("2016 Q1"),
                as.yearqtr("2025 Q4"),
                by = 0.25)
)

# Merge ECB data with all quarters
ecb_quarterly <- all_quarters %>%
  left_join(ecb[, c("Quarter","ECB_Rate")], by = "Quarter")

# Fill missing quarters with last available ECB rate
ecb_quarterly$ECB_Rate <- na.locf(ecb_quarterly$ECB_Rate)

# View final dataset
View(ecb_quarterly)

stress_data <- stress_data %>%
  select(Quarter, GDP_Growth, Unemployment, ECB_Rate)

#  Create a full sequence of quarters (2016 Q1 to 2025 Q4)
all_quarters <- data.frame(
  Quarter = seq(as.yearqtr("2016 Q1"), as.yearqtr("2025 Q4"), by = 0.25)
)

#  Join GDP growth
stress_data <- all_quarters %>%
  left_join(gdp %>% select(Quarter, GDP_Growth), by = "Quarter")

# Step 3 — Join Unemployment
stress_data <- stress_data %>%
  left_join(nemp_quarterly %>% select(Quarter, Unemployment), by = "Quarter")

# Step 4 — Join ECB Rate
stress_data <- stress_data %>%
  left_join(ecb_quarterly %>% select(Quarter, ECB_Rate), by = "Quarter")

# Step 5 — Optional: check the merged dataset
View(stress_data)


#Stress Testing 

# Add severe stress scenario
stress_data <- stress_data %>%
  mutate(
    GDP_Severe = GDP_Growth - 3,         # drop 3% in GDP growth
    Unemp_Severe = Unemployment + 3,     # rise 3% in unemployment
    ECB_Severe = ECB_Rate - 0.5          # rate cut by 0.5%
  )

# Add moderate stress scenario
stress_data <- stress_data %>%
  mutate(
    GDP_Moderate = GDP_Growth - 1.5,
    Unemp_Moderate = Unemployment + 1.5,
    ECB_Moderate = ECB_Rate - 0.25
  )

# Pivot longer for plotting
plot_data <- stress_data %>%
  select(Quarter, GDP_Growth, GDP_Severe, GDP_Moderate) %>%
  pivot_longer(cols = -Quarter, names_to = "Scenario", values_to = "GDP")

ggplot(plot_data, aes(x = Quarter, y = GDP, color = Scenario)) +
  geom_line(size = 1.2) +
  labs(title = "GDP Growth under Different Stress Scenarios",
       y = "GDP Growth (%)") +
  theme_minimal()

# Use baseline data
var_data <- stress_data %>%
  dplyr::select(GDP_Growth, Unemployment, ECB_Rate) %>%
  na.omit()  # remove rows with NA

# Fit VAR with 2 lags
var_model <- VAR(var_data, p = 2, type = "const")

# Forecast 8 quarters under baseline
forecast_baseline <- predict(var_model, n.ahead = 8)

summary(var_model)
