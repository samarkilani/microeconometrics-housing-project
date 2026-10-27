# 🏠 Housing Prices: Inference and Prediction Using Regression Methods

An empirical microeconometrics project evaluating the determinants of housing prices and comparing out-of-sample predictive performance using cross-sectional data of 545 residential properties from Kaggle[cite: 5, 7].

## 📋 Project Description
This microeconometrics project examines the determinants of residential property values using a cross-sectional dataset of 545 residential properties[cite: 5, 7]. The study clearly distinguishes between two primary objectives[cite: 6]:
* **Inference:** Identifying the structural characteristics and amenities that significantly drive property values (such as floor area, bathrooms, stories, climate control, and location) using multiple linear regression estimated via OLS with heteroskedasticity-robust standard errors[cite: 5, 11, 13].
* **Prediction:** Evaluating the out-of-sample predictive performance of alternative models (full OLS, best subset selection via adjusted $R^2$, and cross-validated Ridge regression)[cite: 5, 11, 12]. 

*Key Findings:* While property size, comfort amenities, and prime locations play a decisive role in pricing[cite: 13, 16], Ridge regression delivers a modest improvement in predictive accuracy through coefficient stabilization[cite: 15, 16].

---

## 💻 Code Architecture (`analysis.R`)

The R script is structured into modular sections corresponding to the econometric methodology:

1. **Package Loading & Data Preparation**
   * Imports essential libraries (`tidyverse`, `estimatr`, `glmnet`, `leaps`, `car`, `lmtest`, `ggplot2`, `corrplot`).
   * Loads the dataset, checks for missing values/duplicates, and converts categorical and binary variables into factors[cite: 5, 7].

2. **Descriptive & Exploratory Analysis**
   * Computes summary statistics (mean, median, standard deviation)[cite: 5].
   * Detects outliers via IQR and generates diagnostic histograms and boxplots[cite: 6, 7].
   * Generates correlation matrices, heatmaps, and scatter plots to visualize relationships between area and price[cite: 7, 8, 9].

3. **OLS Model (Inference) & Diagnostics**
   * Fits a baseline multiple linear regression model[cite: 10].
   * Conducts residual diagnostics, checks multicollinearity (VIF), and tests for heteroskedasticity using the Breusch-Pagan test (`bptest`)[cite: 12].
   * Re-estimates the model using heteroskedasticity-robust standard errors (`lm_robust` via `estimatr`)[cite: 5, 11, 13].

4. **Best Subset Selection**
   * Exhaustively evaluates all subsets of explanatory variables to find the optimal specification based on adjusted $R^2$[cite: 11, 12].

5. **10-Fold Cross-Validation & Predictive Comparison**
   * Partitions data into $k = 10$ folds to evaluate out-of-sample performance[cite: 14].
   * Compares Root Mean Squared Error (RMSE) and test $R^2$ across Full OLS, Best Subset, and cross-validated Ridge regression (`cv.glmnet`)[cite: 12, 14].

6. **Final Model Comparison & Summary**
   * Compiles performance metrics to determine the optimal model for market price prediction[cite: 14, 15].

---

## 📂 Repository Structure
* `analysis.R`: Comprehensive R script covering data preparation, descriptive statistics, robust OLS, best subset selection, and cross-validated Ridge modeling.
* `Microeconometrics_project.pdf`: The complete written research report.

## 🛠️ Tech Stack
* **Language:** R
* **Key Packages:** `tidyverse`, `estimatr`, `glmnet`, `leaps`, `car`, `lmtest`, `ggplot2`, `corrplot`
* **Version Control:** Git & GitHub
* 
