# =============================================================================
# data_cleaning/clean_and_save_titanic.R
# Reads:  data/Titanic-Dataset.csv  (place raw Kaggle-style CSV here)
# Writes: data/titanic_cleaned.csv
# Run from project root (MH3511 folder):  setwd(".../MH3511"); source("data_cleaning/clean_and_save_titanic.R")
# =============================================================================

ensure_project_root <- function() {
  if (dir.exists("data")) return(invisible(NULL))
  if (dir.exists("../data")) {
    setwd("..")
    return(invisible(NULL))
  }
  stop("Run this script with working directory = MH3511 (folder containing data/).")
}

ensure_project_root()

raw_path <- file.path("data", "Titanic-Dataset.csv")
if (!file.exists(raw_path)) {
  stop(
    "Missing ", raw_path, ". Copy Titanic-Dataset.csv into data/ then re-run.",
    call. = FALSE
  )
}

df <- utils::read.csv(raw_path, stringsAsFactors = FALSE, na.strings = c("", "NA"))

# --- Embarked: impute rare missing with overall mode ---
emb <- df$Embarked
emb[emb == ""] <- NA
mode_emb <- names(sort(table(emb, useNA = "no"), decreasing = TRUE))[1]
df$Embarked[is.na(df$Embarked) | df$Embarked == ""] <- mode_emb
df$Embarked <- factor(df$Embarked, levels = c("C", "Q", "S"))

# --- Age: median imputation by Pclass and Sex, then global median ---
for (pc in sort(unique(df$Pclass))) {
  for (sx in c("female", "male")) {
    idx <- df$Pclass == pc & df$Sex == sx & is.na(df$Age)
    sub <- df$Age[df$Pclass == pc & df$Sex == sx & !is.na(df$Age)]
    if (length(sub)) df$Age[idx] <- median(sub, na.rm = TRUE)
  }
}
if (any(is.na(df$Age))) {
  df$Age[is.na(df$Age)] <- median(df$Age, na.rm = TRUE)
}

# --- Fare: impute by Pclass median, then global ---
for (pc in sort(unique(df$Pclass))) {
  idx <- df$Pclass == pc & is.na(df$Fare)
  med <- median(df$Fare[df$Pclass == pc & !is.na(df$Fare)], na.rm = TRUE)
  if (!is.na(med)) df$Fare[idx] <- med
}
if (any(is.na(df$Fare))) df$Fare[is.na(df$Fare)] <- median(df$Fare, na.rm = TRUE)

# --- Title from Name (text before first dot after comma) ---
df$Title <- sub("^[^,]+, ([^.]+).*", "\\1", df$Name)
df$Title <- trimws(df$Title)

# --- Family size & solo traveller ---
df$FamilySize <- df$SibSp + df$Parch + 1L
df$IsSolo <- as.integer(df$FamilySize == 1L)

# --- Ticket party size & fare per person (same Ticket = same purchase group) ---
tix_n <- as.data.frame.table(table(df$Ticket), stringsAsFactors = FALSE)
names(tix_n) <- c("Ticket", "Ticket_party_size")
tix_n$Ticket_party_size <- as.integer(tix_n$Ticket_party_size)
df <- merge(df, tix_n, by = "Ticket", all.x = TRUE)
df$Fare_per_person <- df$Fare / df$Ticket_party_size

# --- SES_band: ordinal socioeconomic proxy (NOT annual income in currency) ---
# Within each ticket class (1/2/3), passengers are sorted by Fare_per_person then
# PassengerId; the lowest third of rows get Low, middle third Medium, top third High.
# Interpretation: within-class relative fare share; ties broken deterministically by ID.
df$SES_band <- NA_character_
for (pc in c(1L, 2L, 3L)) {
  idx <- which(df$Pclass == pc)
  n <- length(idx)
  if (n == 0L) next
  ord <- order(df$Fare_per_person[idx], df$PassengerId[idx], na.last = TRUE)
  lab <- rep(NA_character_, n)
  a <- floor(n / 3L)
  b <- floor(2L * n / 3L)
  if (a < 1L) {
    lab[] <- "Medium"
  } else {
    lab[ord[seq_len(a)]] <- "Low"
    if (b > a) lab[ord[(a + 1L):b]] <- "Medium"
    if (b < n) lab[ord[(b + 1L):n]] <- "High"
  }
  df$SES_band[idx] <- lab
}
df$SES_band <- factor(df$SES_band, levels = c("Low", "Medium", "High"), ordered = TRUE)

# --- Cabin deck (first letter) or Unknown ---
deck <- substr(df$Cabin, 1L, 1L)
deck[is.na(df$Cabin) | df$Cabin == ""] <- "U"
df$Deck <- factor(deck)

# --- Useful types for analysis ---
df$Survived <- as.integer(df$Survived)
df$Sex <- factor(df$Sex, levels = c("male", "female"))
df$Pclass <- factor(df$Pclass, levels = c(1, 2, 3), ordered = TRUE)

df <- df[order(df$PassengerId), , drop = FALSE]
rownames(df) <- NULL

out_path <- file.path("data", "titanic_cleaned.csv")
utils::write.csv(df, out_path, row.names = FALSE)

message("Wrote ", nrow(df), " rows to ", normalizePath(out_path, winslash = "/"))
