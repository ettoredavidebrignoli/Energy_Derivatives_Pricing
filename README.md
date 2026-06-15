# Multi-Commodity-Derivatives-Pricing-
HJM-based multi-commodity energy model with PCA calibration and Monte Carlo pricing of structured derivatives.
 
## Overview

This project develops a multi-commodity model for European electricity markets, focusing on German (DE) and French (FR) power swaps.

The framework combines:
- Statistical analysis of market data  
- Forward curve reconstruction  
- Principal Component Analysis (PCA) for factor reduction  
- Monte Carlo simulation for pricing structured derivatives  

The modeling approach follows a reduced-factor Heath-Jarrow-Morton (HJM) framework.

---

## Data
The dataset includes 10 years of daily electricity swap prices (2015–2025), covering:
- Monthly, quarterly, and yearly contracts  
- German and French markets  

---

## Methodology

- Data cleaning & diagnostics  
  Stationarity, independence, and distributional properties of returns are analyzed  

- Forward curve construction  
  Monthly forward curves are reconstructed from swap contracts  

- PCA calibration  
  Dimensionality reduction identifies a small number of common risk factors  

- HJM modeling  
  The forward curve dynamics are modeled in a no-arbitrage setting  

---

## Pricing

Two types of derivatives are considered:

- Chooser option  
  Priced via Monte Carlo with analytical benchmarks and bounds  

- Swing option  
  Energy-specific derivative with flexible daily exercise, analyzed under different constraints  

---

## Usage

All results can be reproduced by running: [Run_final.m](Run_final.m)


