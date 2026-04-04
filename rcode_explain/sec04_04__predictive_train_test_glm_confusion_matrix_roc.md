# Explainer: `R/sec04_04__predictive_train_test_glm_confusion_matrix_roc.R`

- **§4.4** — **predictive** check (held-out data), not same-sample accuracy.
- **Method:** `set.seed(3511)`; **80% train / 20% test**; `glm` on train; predict test; threshold **0.5**.
- **Prints:** confusion matrix; accuracy.
- **Figure:** heatmap-style confusion matrix (ggplot).
- **Note:** ROC/AUC omitted to avoid extra packages; add `pROC` later if required.
