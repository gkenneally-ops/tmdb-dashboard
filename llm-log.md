# LLM usage log
5/5/26

## Entry 1 — Shiny app skeleton.
**Tool:** Claude (claude.ai, Opus 4.7)
**Used by:** Gerard Kenneally
**Purpose:** Shiny app skeleton.
**Prompt summary:**
Asked Claude to help me generate a starter Shiny skeleton for TMDB 5000 with global.R, ui.R, server.R, and app.R.
Included data loading with JSON parsing, a custom ggplot theme
(theme_tmdb), a bslib Bootstrap themes.

**What we used:**
- The four-file structure (global.R / ui.R / server.R / app.R)
- The parse_json_names() helper for genre/cast columns
- The theme_tmdb() function and the bslib theme setup
- The filtered_movies() reactive pattern

**What we changed:**
"Replaced the Netflix-red palette with our own colors,"
"Added a fourth tab for director-level analysis,"
"Rewrote the genre comparison plot to use medians instead of means," etc.]

## Entry 2 — GitHub Deployment
**GitHub Deployment:**
installation on macOS,
creating the GitHub repository, configuring `.gitignore` to exclude the
Kaggle data files, authenticating with a Personal Access Token, installing
`rsconnect`, and deploying the app to shinyapps.io.
The step-by-step Git setup, the `.gitignore` contents, the
README structure, the deployment workflow via `rsconnect::deployApp()`, and
the troubleshooting steps when authentication and deploy errors came up.

## Entry 2 — Critics vs. Audience Dashboard
**Critics vs. Audience :** Asked Claude to build a `vote_average` vs. `popularity`
scatter that computes percentile ranks within the current filter and
categorizes films into "Universally loved" (top 10% both), "Critic darlings"
(top 10% rating, bottom 50% popularity), "Crowd pleasers" (top 10% popularity,
bottom 50% rating), and "Other," with distinct colors for the three named
categories.
The full plot logic, the within-filter percentile-rank
approach, the category color encoding, and the rich-text tooltip with film
details.
Confirmed the percentile categorization recomputed
correctly when filters changed.

## Entry 4 — Exploratory data analysis notebook

**Date:** May 5, 2026
**Tool:** Claude (claude.ai, Opus 4.7)
**Used by:** Gerard Kenneally
**Purpose:** Draft the EDA notebook (`eda.qmd`) for CP2, covering shape,
distributions, data quality, and the dashboard's research questions.

**Prompt summary:** Asked Claude to produce a Quarto notebook that loads the
TMDB CSVs, reports the shape, surfaces the budget/revenue=0 missing-data
problem, plots the distributions of release year, budget, genre frequency, and
ratings, and locks in 5 research questions for the dashboard.

**What was used:** The notebook structure (Setup → Shape → JSON columns → Data
quality → Distributions → Questions → Ethical considerations), the missing-data
summary table, and the four illustrative distribution plots.

**What was changed:** Verified numbers (4,803 films, missing-data percentages)
against the rendered output. Edited the questions section to match the final
dashboard tabs.

---

## Entry 3 — Visual polish to dashboard plots

**Date:** May 5, 2026
**Tool:** Claude (claude.ai, Opus 4.7)
**Used by:** Gerard Kenneally
**Purpose:** Apply professional-level polish to the three initial dashboard
outputs — dynamic finding-stating titles, preattentive color highlighting,
formatted tooltips and axis labels.

**Prompt summary:** Asked Claude to rewrite `server.R` with polish moves
including dynamic titles computed from the filtered data, preattentive
highlighting on the genre comparison chart (top genre in red, others in grey),
formatted hover tooltips, and a ROI bar chart embedded in the Top Films table.

**What was used:** All of the polish patterns — dynamic title computation, the
red-highlight-only design for the genre chart, the formatted tooltip blocks,
the bar-in-table visualization via `styleColorBar()`, and the empty-state
handling for restrictive filters.

**What was changed:** Re-verified the dynamic title math by moving filters in
the live app. Confirmed colors matched the shared palette.