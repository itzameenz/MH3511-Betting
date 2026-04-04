# Explainer: `R/sec04_02_06__statistical_tests_same_ticket_party_concordance.R`

- **§4.2.6** — travel-party concordance (same **`Ticket`** proxy).
- **Logic:** restrict to **Ticket_party_size > 1**; **`other_survived`** = any other passenger on that ticket survived.
- **Tests:** `fisher.test` on 2×2 self vs other; table of **all survived / all died / mixed** per ticket.
