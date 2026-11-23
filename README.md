# 🏠 Housing Prices: Inference and Prediction Using Regression Methods

An empirical microeconometrics project evaluating the determinants of housing prices and comparing out-of-sample predictive performance using cross-sectional data of 545 residential properties from Kaggle.

## 📋 Project Description
This microeconometrics project examines the determinants of residential property values using a cross-sectional dataset of 545 residential properties. The study clearly distinguishes between two primary objectives:
* **Inference:** Identifying the structural characteristics and amenities that significantly drive property values (such as floor area, bathrooms, stories, climate control, and location) using multiple linear regression estimated via OLS with heteroskedasticity-robust standard errors.
* **Prediction:** Evaluating the out-of-sample predictive performance of alternative models (full OLS, best subset selection via adjusted $R^2$, and cross-validated Ridge regression). 

*Key Findings:* While property size, comfort amenities, and prime locations play a decisive role in pricing, Ridge regression delivers a modest improvement in predictive accuracy through coefficient stabilization.

---

## 💻 Code Architecture (`analysis.R`)

The R script is structured into modular sections corresponding to the econometric methodology:

1. **Package Loading & Data Preparation**
   * Imports essential libraries (`tidyverse`, `estimatr`, `glmnet`, `leaps`, `car`, `lmtest`, `ggplot2`, `corrplot`).
   * Loads the dataset, checks for missing values/duplicates, and converts categorical and binary variables into factors.

2. **Descriptive & Exploratory Analysis**
   * Computes summary statistics (mean, median, standard deviation).
   * Detects outliers via IQR and generates diagnostic histograms and boxplots.
   * Generates correlation matrices, heatmaps, and scatter plots to visualize relationships between area and price.

3. **OLS Model (Inference) & Diagnostics**
   * Fits a baseline multiple linear regression model.
   * Conducts residual diagnostics, checks multicollinearity (VIF), and tests for heteroskedasticity using the Breusch-Pagan test (`bptest`).
   * Re-estimates the model using heteroskedasticity-robust standard errors (`lm_robust` via `estimatr`).

4. **Best Subset Selection**
   * Exhaustively evaluates all subsets of explanatory variables to find the optimal specification based on adjusted $R^2$.

5. **10-Fold Cross-Validation & Predictive Comparison**
   * Partitions data into $k = 10$ folds to evaluate out-of-sample performance.
   * Compares Root Mean Squared Error (RMSE) and test $R^2$ across Full OLS, Best Subset, and cross-validated Ridge regression (`cv.glmnet`).

6. **Final Model Comparison & Summary**
   * Compiles performance metrics to determine the optimal model for market price prediction.

---

## 📂 Repository Structure
* `analysis.R`: Comprehensive R script covering data preparation, descriptive statistics, robust OLS, best subset selection, and cross-validated Ridge modeling.
* `Microeconometrics_project.pdf`: The complete written research report.

## 🛠️ Tech Stack
* **Language:** R
* **Key Packages:** `tidyverse`, `estimatr`, `glmnet`, `leaps`, `car`, `lmtest`, `ggplot2`, `corrplot`
* **Version Control:** Git & GitHub
