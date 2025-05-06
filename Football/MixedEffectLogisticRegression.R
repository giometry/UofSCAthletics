rm(list=ls())

library(glmmTMB)

library(caret)       # for confusionMatrix
library(dplyr)       # for data manipulation
library(stringr)     # for string formatting

set.seed(123)

# Set the working directory
setwd("C:/Users/giova/Documents/School/Classes/Spring 2025/Capstone Project/Football2024")

# Load data
dat <- read.csv("cleaned_football_2024.csv", stringsAsFactors = TRUE)
dat <- na.omit(dat)

# Convert appropriate variables to factor
categorical_columns <- c('ISRESOLD',
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

    print(col)
    print(mu)
    print(sigma)
    
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

k=1
for (k in 1:K) {
  cat("\n===== Fold", k, "=====\n")
  
  # Train/test split
  train_data <- dat %>% filter(fold != k)
  test_data  <- dat %>% filter(fold == k)

  # write.csv(train_data, "train_data.csv", row.names = FALSE)
  
  # Compute the class counts
  # n_0 <- sum(train_data$ISATTENDED == 0)
  # n_1 <- sum(train_data$ISATTENDED == 1)

  # Apply your custom weighting
  # train_data$my_weights <- ifelse(train_data$ISATTENDED == 0, n_1 / n_0, 1)

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
    ISATTENDED ~ DONATION_CURRENT_DONATION_AMOUNT + FAN_PHONE_MARKETABLE + TICKETING_CURRENTYEARSTM + TICKETING_PREVSEASONSTM + DONATION_CURRENT_DONOR + HAS_OPENED_EMAIL + HAS_DONATED + HAS_MADE_PURCHASE + SEATING + FAN_INITIAL_LEAD_SOURCE + FAN_LAST_LEAD_SOURCE + FAN_POSTAL_MARKETABLE + ISRESOLD + EVENTNAME + PLANCODE + TICKETING_TICKETS_SCANNED + TICKETING_TICKET_TOTAL_SPEND + TICKETING_STM_TENURE + TICKETING_GAMES_SOLD_SECONDARY + TICKETING_GAMES_SCANNED + TICKETING_GAMES_PURCHASED_SECONDARY + TICKETING_ATTENDANCE_SEASON_PCT + TICKETING_ATTENDANCE_LIFETIME_PCT + REVENUETOTAL + RESOLDTOTALAMOUNT + MERCH_TOTALSPENT_LIFETIME + MERCH_TOTALSPENT_90DAYS + MERCH_TOTALSPENT_365DAYS + MERCH_TOTALSPENT_30DAYS + FAN_UNIQUE_SOURCESYSTEM_COUNT + ENGAGEMENT + EMAIL_EMAIL_OPEN_PCT + EMAIL_EMAIL_OPEN_COUNT + EMAIL_EMAIL_CLICK_PCT + DONATION_TOTAL_DONATION_AMOUNT + DONATION_MAX_DONATION_AMOUNT + (1 | GRMCONTACTID),
    data = train_data,
    family = binomial
  )
  endtime = Sys.time()
  endtime-starttime

  summary(model)
}