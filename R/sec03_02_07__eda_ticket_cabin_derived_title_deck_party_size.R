# Section 3.2.7 — Ticket / cabin / derived: Title, Deck, party size
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
print(head(sort(table(d$Title), decreasing = TRUE), n = 15L))
print(table(d$Deck))
print(summary(d$Ticket_party_size))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  top_titles <- names(sort(table(d$Title), decreasing = TRUE))[1:8]
  d2 <- d
  d2$Title_g <- ifelse(d2$Title %in% top_titles, as.character(d2$Title), "Other")
  p <- ggplot2::ggplot(d2, ggplot2::aes(x = Title_g, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1)) +
    ggplot2::labs(title = "Survival share by title (top 8 + Other)", x = NULL, y = "Proportion", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_07__title_survival.png"),
    p, width = 8, height = 4, dpi = 150
  )
}
