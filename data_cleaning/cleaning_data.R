library(readr)
library(dplyr)

data <- read_csv("data/raw/closing_odds.csv", show_col_types = FALSE)

clean <- data %>%
  filter(league == "England: Premier League") %>%
  filter(
    !is.na(home_score),
    !is.na(away_score),
    !is.na(avg_odds_home_win),
    !is.na(avg_odds_draw),
    !is.na(avg_odds_away_win)
  ) %>%
  filter(
    avg_odds_home_win > 1,
    avg_odds_draw > 1,
    avg_odds_away_win > 1
  ) %>%
  mutate(
    result = case_when(
      home_score > away_score ~ "H",
      home_score == away_score ~ "D",
      TRUE ~ "A"
    ),
    p_home_raw = 1 / avg_odds_home_win,
    p_draw_raw = 1 / avg_odds_draw,
    p_away_raw = 1 / avg_odds_away_win,
    overround = p_home_raw + p_draw_raw + p_away_raw,
    p_home = p_home_raw / overround,
    p_draw = p_draw_raw / overround,
    p_away = p_away_raw / overround
  ) %>%
  select(
    match_date,
    league,
    home_team,
    away_team,
    home_score,
    away_score,
    avg_odds_home_win,
    avg_odds_draw,
    avg_odds_away_win,
    result,
    p_home,
    p_draw,
    p_away
  )

write_csv(clean, "data/cleaned/cleaned_betting_data.csv")