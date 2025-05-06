# Set libraries
rm(list=ls())

library(glmmTMB)
library(caret)       # for confusionMatrix
library(dplyr)       # for data manipulation
library(stringr)     # for string formatting

# Set seed for reproducibility
set.seed(123)

# Set the working directory
setwd("C:/Users/giova/Documents/School/Classes/Spring 2025/Capstone Project/MenBasketball2024")

# Load data
dat <- read.csv("cleaned_men_basketball_2024.csv", stringsAsFactors = TRUE)
dat <- na.omit(dat)

# Convert appropriate variables to factor
categorical_columns <- c('OPPONENT_RANKED', 'ISRESOLD',
                         'FAN_PHONE_MARKETABLE', 'FAN_POSTAL_MARKETABLE', 
                         'FAN_INITIAL_LEAD_SOURCE', 'FAN_LAST_LEAD_SOURCE', 'TICKETING_CURRENTYEARSTM',
                         'TICKETING_PREVSEASONSTM', 'DONATION_CURRENT_DONOR',
                         'HAS_OPENED_EMAIL', 'HAS_DONATED', 'HAS_MADE_PURCHASE')

dat[categorical_columns] <- lapply(dat[categorical_columns], as.factor)
dat$ISATTENDED <- as.factor(dat$ISATTENDED)

# Columns to standardize
columns_to_standardize <- c(
  'REVENUETOTAL', 'RESOLDTOTALAMOUNT', 
  'TICKETING_STM_TENURE', 'TICKETING_GAMES_SCANNED', 
  'TICKETING_TICKETS_SCANNED', 'TICKETING_GAMES_SOLD_SECONDARY', 
  'TICKETING_GAMES_PURCHASED_SECONDARY', 'TICKETING_TICKET_TOTAL_SPEND', 
  'DONATION_MAX_DONATION_AMOUNT', 'DONATION_TOTAL_DONATION_AMOUNT', 'DONATION_CURRENT_DONATION_AMOUNT', 
  'EMAIL_EMAIL_OPEN_COUNT', 'MERCH_TOTALSPENT_30DAYS', 'MERCH_TOTALSPENT_90DAYS', 
  'MERCH_TOTALSPENT_365DAYS', 'MERCH_TOTALSPENT_LIFETIME', 
  'EMAIL_OPEN_TIME_DIFF', 'DAYS_SINCE_LAST_DONATION', 'DAYS_SINCE_LAST_PURCHASE'
)

# Helper function for standardization
standardize_columns <- function(train_df, test_df, columns) {
  for (col in columns) {
    mu <- mean(train_df[[col]], na.rm = TRUE)
    sigma <- sd(train_df[[col]], na.rm = TRUE)
    if (sigma == 0) sigma <- 1
    train_df[[col]] <- (train_df[[col]] - mu) / sigma
    test_df[[col]]  <- (test_df[[col]] - mu) / sigma
  }
  return(list(train = train_df, test = test_df))
}

# Number of folds
K <- 5

# Group variable
groups <- unique(dat$GRMCONTACTID)
folds <- sample(rep(1:K, length.out = length(groups)))
group_folds <- data.frame(GRMCONTACTID = groups, fold = folds)

# Merge fold info back into data
dat <- merge(dat, group_folds, by = "GRMCONTACTID")

# Prepare storage
fold_results <- list()
accuracies <- numeric(K)
conf_matrices <- list()
models <- list()

for (k in 1:K) {
  cat("\n===== Fold", k, "=====\n")
  
  # Train/test split
  train_data <- dat %>% filter(fold != k)
  test_data  <- dat %>% filter(fold == k)
  
  # Standardize numeric columns
  standardized <- standardize_columns(train_data, test_data, columns_to_standardize)
  train_data <- standardized$train
  test_data  <- standardized$test

  factor_vars <- names(Filter(is.factor, train_data))
  for (var in factor_vars) {
    test_data[[var]] <- factor(test_data[[var]], levels = levels(train_data[[var]]))
  
    # Check for and handle NAs due to unmatched levels
    if (any(is.na(test_data[[var]]))) {
      cat("Warning: NA introduced in", var, "due to unmatched levels.\n")
    
      # Drop rows with NA (safe but reduces data)
      test_data <- test_data[!is.na(test_data[[var]]), ]
    }
  }

  starttime = Sys.time()
  # Fit model
  model <- glmmTMB(
    ISATTENDED ~ DONATION_CURRENT_DONATION_AMOUNT + FAN_PHONE_MARKETABLE + TICKETING_CURRENTYEARSTM + TICKETING_PREVSEASONSTM + DONATION_CURRENT_DONOR + HAS_OPENED_EMAIL + HAS_DONATED + HAS_MADE_PURCHASE + SEATING + FAN_INITIAL_LEAD_SOURCE + FAN_LAST_LEAD_SOURCE + FAN_POSTAL_MARKETABLE + ISRESOLD + EVENTNAME + PLANCODE + TICKETING_TICKETS_SCANNED + TICKETING_TICKET_TOTAL_SPEND + TICKETING_STM_TENURE + TICKETING_GAMES_SOLD_SECONDARY + TICKETING_GAMES_SCANNED + TICKETING_GAMES_PURCHASED_SECONDARY + TICKETING_ATTENDANCE_SEASON_PCT + TICKETING_ATTENDANCE_LIFETIME_PCT + REVENUETOTAL + RESOLDTOTALAMOUNT + MERCH_TOTALSPENT_LIFETIME + MERCH_TOTALSPENT_90DAYS + MERCH_TOTALSPENT_365DAYS + MERCH_TOTALSPENT_30DAYS + FAN_UNIQUE_SOURCESYSTEM_COUNT + ENGAGEMENT + EMAIL_OPEN_TIME_DIFF + EMAIL_EMAIL_OPEN_PCT + EMAIL_EMAIL_OPEN_COUNT + EMAIL_EMAIL_CLICK_PCT + DONATION_TOTAL_DONATION_AMOUNT + DONATION_MAX_DONATION_AMOUNT + (1 | GRMCONTACTID),
    data = train_data,
    family = binomial
  )
  endtime = Sys.time()
  endtime-starttime

  summary(model)
  # Predict on test
  probs <- predict(model, newdata = test_data, type = "response", allow.new.levels = TRUE)
  preds <- ifelse(probs > 0.5, 1, 0)
  actual <- as.numeric(as.character(test_data$ISATTENDED))
  
  # Accuracy
  acc <- mean(preds == actual)
  
  # Confusion matrix
  cm <- confusionMatrix(as.factor(preds), as.factor(actual), positive = "1")
  
  # Save everything into fold_results
  fold_results[[k]] <- list(
    model = model,
    accuracy = acc,
    confusion_matrix = cm,
    fold_number = k
  )

  saveRDS(fold_results[[k]], file = paste0("fold_results_fold", k, ".rds"))
  
  # Output
  print(paste("Fold", k, "Accuracy:", round(acc, 4)))
  print(cm$table)
}

# Print overall results
cat("\n=== Summary ===\n")
for (k in 1:K) {
  cat(paste0("Fold ", k, ": Accuracy = ", round(fold_results[[k]]$accuracy, 4), "\n"))
}

# Best model
best_fold <- which.max(sapply(fold_results, function(x) x$accuracy))
cat(paste0("\nBest fold: Fold ", best_fold, " with accuracy ", round(fold_results[[best_fold]]$accuracy, 4), "\n"))

# Save best model to file
saveRDS(fold_results, file = "all_fold_results.rds")
saveRDS(fold_results[[best_fold]]$model, file = paste0("best_fold_model", best_fold, ".rds"))