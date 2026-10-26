# ---- ONLY RUN THESE LINES THE FIRST TIME ON THIS COMPUTER ----
# (You don't need to reinstall packages every time.)ddddddstall.packages("moments")
install.packages("car")#for vif test
install.packages("estimatr")
install.packages("lmtest")
install.packages(c("ggplot2", "GGally", "glmnet"))
install.packages("leaps")#used for best subset method 
install.packages("tidyverse")
install.packages("boot")

############################################################
# 0. PACKAGES
#    First block: install (ONLY FIRST TIME)
#    Second block: load (EVERY TIME)
############################################################

# ---- ONLY RUN THESE LINES THE FIRST TIME ON THIS COMPUTER ----
# install.packages("moments")
# install.packages("car")      # VIF test
# install.packages("estimatr") # robust inference
# install.packages("lmtest")
# install.packages(c("ggplot2", "GGally", "glmnet"))
# install.packages("leaps")    # best subset selection
# install.packages("tidyverse")
# install.packages("boot")

############################################################
# 0. PACKAGES
############################################################

# ---- RUN ONLY FIRST TIME ----
# install.packages(c(
#   "moments","car","estimatr","lmtest",
#   "ggplot2","GGally","glmnet",
#   "leaps","tidyverse","boot",
#   "caret","corrplot"
# ))

# ---- LOAD PACKAGES ----
library(ggplot2)
library(moments)
library(GGally)
library(car)
library(lmtest)
library(glmnet)
library(estimatr)
library(leaps)
library(tidyverse)
library(boot)
library(caret)
library(corrplot)
library(dplyr)

############################################################
# 1. DATA PREPARATION
############################################################

setwd("C:/Users/samar/OneDrive/Documents/microeconometrics")

housing <- read.csv("Housing.csv", stringsAsFactors = FALSE)

str(housing)
summary(housing)

# Missing values & duplicates
colSums(is.na(housing))
sum(duplicated(housing))

############################################################
# CONVERT CATEGORICAL VARIABLES TO FACTORS
############################################################

housing$mainroad         <- factor(housing$mainroad)
housing$guestroom        <- factor(housing$guestroom)
housing$basement         <- factor(housing$basement)
housing$hotwaterheating  <- factor(housing$hotwaterheating)
housing$airconditioning  <- factor(housing$airconditioning)
housing$prefarea         <- factor(housing$prefarea)
housing$furnishingstatus <- factor(housing$furnishingstatus)

############################################################
# DESCRIPTIVE STATISTICS
############################################################

mean(housing$price)
median(housing$price)
sd(housing$price)

############################################################
# OUTLIER CHECK
############################################################

Q1      <- quantile(housing$price, 0.25)
Q3      <- quantile(housing$price, 0.75)
IQR_val <- Q3 - Q1

lower <- Q1 - 1.5 * IQR_val
upper <- Q3 + 1.5 * IQR_val

boxplot(
  housing$price,
  main = "Boxplot of House Prices",
  horizontal = TRUE
)

hist(
  housing$price,
  breaks = 30,
  main = "Histogram of Prices",
  col = "lightblue"
)

############################################################
# CORRELATION ANALYSIS
############################################################

numeric_data <- housing[sapply(housing, is.numeric)]

cor_matrix <- cor(numeric_data)

corrplot(
  cor_matrix,
  method = "square",
  type = "upper",
  col = colorRampPalette(c("red", "white", "blue"))(200),
  addCoef.col = "black",
  tl.col = "black",
  tl.srt = 45
)

############################################################
# SCATTER PLOT
############################################################

ggplot(housing, aes(x = area, y = price)) +
  geom_point() +
  labs(
    title = "Scatter Plot of Price vs Area",
    x = "Area",
    y = "Price"
  ) +
  theme_minimal()

############################################################
# 2. OLS MODEL (INFERENCE)
############################################################

model_price <- lm(
  price ~ area + bedrooms + bathrooms + stories +
    mainroad + guestroom + basement +
    hotwaterheating + airconditioning +
    parking + prefarea + furnishingstatus,
  data = housing
)

summary(model_price)

confint(model_price)

############################################################
# RESIDUAL DIAGNOSTICS
############################################################

plot(
  fitted(model_price),
  resid(model_price),
  xlab = "Fitted values",
  ylab = "Residuals",
  main = "Residuals vs Fitted"
)

abline(h = 0, col = "red")

############################################################
# MULTICOLLINEARITY TEST
############################################################

vif(model_price)

############################################################
# BREUSCH-PAGAN TEST
############################################################

bptest(model_price)

############################################################
# ROBUST OLS
############################################################

lm.fit <- lm_robust(
  price ~ area + bedrooms + bathrooms + stories +
    mainroad + guestroom + basement +
    hotwaterheating + airconditioning +
    parking + prefarea + furnishingstatus,
  data = housing,
  se_type = "stata"
)

summary(lm.fit)

############################################################
# BEST SUBSET SELECTION USING ADJUSTED R²
############################################################

set.seed(123)

# Dependent variable
y.name <- "price"

# Candidate predictors
x.names <- c(
  "area", "bedrooms", "bathrooms", "stories",
  "parking", "mainroad", "guestroom", "basement",
  "hotwaterheating", "airconditioning",
  "prefarea", "furnishingstatus"
)

# Number of predictors
p <- length(x.names)

############################################################
# GENERATE ALL POSSIBLE SUBSETS
############################################################

all.subsets <- unlist(
  lapply(0:p, function(k) {
    combn(x.names, k, simplify = FALSE)
  }),
  recursive = FALSE
)

############################################################
# COMPUTE ADJUSTED R² FOR EACH MODEL
############################################################

adj.r2 <- numeric(length(all.subsets))

for(i in seq_along(all.subsets)) {
  
  # Intercept-only model
  if(length(all.subsets[[i]]) == 0) {
    
    fit <- lm(price ~ 1, data = housing)
    
  } else {
    
    rhs <- paste(all.subsets[[i]], collapse = " + ")
    
    fit <- lm(
      as.formula(paste(y.name, "~", rhs)),
      data = housing
    )
  }
  
  # Store adjusted R²
  adj.r2[i] <- summary(fit)$adj.r.squared
}

############################################################
# SELECT BEST MODEL
############################################################

best.index <- which.max(adj.r2)

best.subset <- all.subsets[[best.index]]

############################################################
# RESULTS
############################################################

cat("Best subset of predictors:\n")
print(best.subset)

cat("\nHighest Adjusted R²:\n")
print(adj.r2[best.index])

############################################################
# 4. 10-FOLD CROSS-VALIDATION COMPARISON
############################################################

set.seed(123)

k <- 10

folds <- createFolds(
  housing[[y.name]],
  k = k,
  list = TRUE,
  returnTrain = FALSE
)

############################################################
# OLS CV RMSE
############################################################

ols_predictions <- numeric(nrow(housing))

for(i in seq_along(folds)){
  
  val_idx <- folds[[i]]
  train_idx <- setdiff(1:nrow(housing), val_idx)
  
  train_data <- housing[train_idx, ]
  val_data   <- housing[val_idx, ]
  
  ols_model <- lm(
    price ~ area + bedrooms + bathrooms + stories +
      parking + mainroad + guestroom + basement +
      hotwaterheating + airconditioning +
      prefarea + furnishingstatus,
    data = train_data
  )
  
  ols_predictions[val_idx] <- predict(
    ols_model,
    newdata = val_data
  )
}

ols_rmse <- sqrt(mean(
  (housing$price - ols_predictions)^2
))


############################################################
# OLS CV R2
############################################################

ols_r2 <- 1 - sum((housing$price - ols_predictions)^2) /
  sum((housing$price - mean(housing$price))^2)

############################################################
# BEST SUBSET CV RMSE
############################################################

best_predictions <- numeric(nrow(housing))

formula_best <- as.formula(
  paste(y.name, "~", paste(best.subset, collapse = " + "))
)

for(i in seq_along(folds)){
  
  val_idx <- folds[[i]]
  train_idx <- setdiff(1:nrow(housing), val_idx)
  
  train_data <- housing[train_idx, ]
  val_data   <- housing[val_idx, ]
  
  best_model <- lm(
    formula_best,
    data = train_data
  )
  
  best_predictions[val_idx] <- predict(
    best_model,
    newdata = val_data
  )
}

best_rmse <- sqrt(mean(
  (housing$price - best_predictions)^2
))
############################################################
# BEST SUBSET CV R2
############################################################
best_r2 <- 1 - sum((housing$price - best_predictions)^2) /
  sum((housing$price - mean(housing$price))^2)
############################################################
# RIDGE CV RMSE
############################################################

ridge_predictions <- numeric(nrow(housing))

for(i in seq_along(folds)){
  
  val_idx <- folds[[i]]
  train_idx <- setdiff(1:nrow(housing), val_idx)
  
  train_data <- housing[train_idx, ]
  val_data   <- housing[val_idx, ]
  
  x_train <- model.matrix(price ~ ., data = train_data)[, -1]
  y_train <- train_data$price
  
  x_val <- model.matrix(price ~ ., data = val_data)[, -1]
  
  ridge_cv <- cv.glmnet(
    x = x_train,
    y = y_train,
    alpha = 0
  )
  
  ridge_pred <- predict(
    ridge_cv,
    newx = x_val,
    s = "lambda.min"
  )
  
  ridge_predictions[val_idx] <- ridge_pred
}

ridge_rmse <- sqrt(mean(
  (housing$price - ridge_predictions)^2
))
############################################################
# RIDGE CV R2
############################################################
ridge_r2 <- 1 - sum((housing$price - ridge_predictions)^2) /
  sum((housing$price - mean(housing$price))^2)
############################################################
# 5. FINAL MODEL COMPARISON
############################################################

results <- data.frame(
  Model = c("OLS", "Best Subset", "Ridge"),
  RMSE  = c(ols_rmse, best_rmse, ridge_rmse),
  R2    = c(ols_r2, best_r2, ridge_r2)
)

############################################################
# BEST MODEL
############################################################

best_rmse_model <- results$Model[which.min(results$RMSE)]

best_r2_model <- results$Model[which.max(results$R2)]
cat("Best model based on RMSE:", best_rmse_model, "\n")

cat("Best model based on R-squared:", best_r2_model, "\n")
############################################################
# BEST MODELS
############################################################

best_rmse_model <- results$Model[which.min(results$RMSE)]
best_rmse_value <- min(results$RMSE)

best_r2_model <- results$Model[which.max(results$R2)]
best_r2_value <- max(results$R2)

############################################################
# PRINT RESULTS TABLE
############################################################

print(results)

############################################################
# PRINT BEST MODELS + VALUES
############################################################

cat(
  "\nBest model based on RMSE:",
  best_rmse_model,
  "\nRMSE value:",
  round(best_rmse_value, 3),
  "\n"
)

cat(
  "\nBest model based on R-squared:",
  best_r2_model,
  "\nR-squared value:",
  round(best_r2_value, 4),
  "\n"
)
