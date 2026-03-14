**Macro Stress Testing Project (2016–2025)**

Overview

This repository contains a complete workflow for macroeconomic stress testing using quarterly GDP, unemployment, and ECB interest rate data from 2016 to 2025. The project demonstrates how economic shocks propagate across key macro variables, and simulates moderate and severe stress scenarios for decision-making and risk assessment purposes.

The analysis is designed to mirror central bank and financial institution stress testing frameworks, making it practical for finance, risk, and consulting applications.

**Objectives**

**Data Preparation and Cleaning**
Convert monthly and irregular data into consistent quarterly frequency

Calculate GDP growth and aggregate unemployment 
Align ECB interest rate data to quarterly periods

**Scenario Analysis**

Create moderate and severe stress scenarios for GDP, unemployment, and ECB rates

Visualize scenario impacts on GDP using line plots

**Vector Autoregression (VAR) Modeling**

Estimate VAR(2) model to capture interdependencies between GDP growth, unemployment, and ECB rates

**Packages Required**
dplyr, lubridate, zoo, readr, tidyr, ggplot2, vars

**Potential Use Cases**

Banking & Finance: Simulate economic downturns and assess policy impacts

Consulting: Demonstrate analytical skills and scenario planning

Risk Management: Quantify macroeconomic risks to investment portfolios

Academia: Illustrate VAR and stress testing methodology
