# Section 4.2.6 — Same-ticket travel party concordance
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

d$n_on_ticket <- ave(seq_len(nrow(d)), d$Ticket, FUN = length)
multi <- d[d$n_on_ticket > 1L, , drop = FALSE]

other_surv <- vapply(seq_len(nrow(multi)), function(i) {
  pid <- multi$PassengerId[i]
  tix <- as.character(multi$Ticket[i])
  party <- d[d$Ticket == tix & d$PassengerId != pid, , drop = FALSE]
  as.integer(any(party$Survived == 1L))
}, integer(1))
multi$other_survived <- other_surv

tab <- table(Self = multi$Survived, Other = multi$other_survived)
print(tab)
if (all(dim(tab) == c(2L, 2L)) && sum(tab) > 0L) {
  print(stats::fisher.test(tab))
} else {
  message("Skipping Fisher test: 2x2 table is degenerate (check multi-ticket subset).")
}

party_pattern <- tapply(multi$Survived, multi$Ticket, function(x) {
  if (all(x == 1L)) "all_survived"
  else if (all(x == 0L)) "all_died"
  else "mixed"
})
print(table(party_pattern))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  ppdf <- as.data.frame(table(party_pattern))
  names(ppdf) <- c("Pattern", "Freq")
  p <- ggplot2::ggplot(ppdf, ggplot2::aes(x = Pattern, y = Freq)) +
    ggplot2::geom_col(fill = "coral") +
    ggplot2::labs(title = "Multi-ticket parties: outcome mix", x = "Party pattern", y = "Count")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_02_06__ticket_party_mix.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
