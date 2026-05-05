# TMDB Movie Explorer

A Shiny dashboard exploring ~5,000 films from The Movie Database (TMDB).
Built for the Unit 3 group project.

## Project structure

- `app.R`, `global.R`, `ui.R`, `server.R` — the Shiny dashboard
- `eda.qmd` — exploratory data analysis notebook (renders to HTML)
- `llm-log.md` — declared LLM usage per syllabus policy
- `data/` — local data files (not committed; see "Setup" below)

## Setup

1. Clone this repo:
2. Open the project in Positron or RStudio.
3. Install required R packages:
```r
   install.packages(c("tidyverse", "shiny", "bslib", "plotly",
                      "DT", "jsonlite", "scales"))
```
4. Download the TMDB 5000 dataset from Kaggle:
   https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata
5. Place `tmdb_5000_movies.csv` and `tmdb_5000_credits.csv` in a
   `data/` folder at the project root.
6. Open `app.R` and click "Run App", or run in the console:
```r
   source("global.R"); source("ui.R"); source("server.R")
   shinyApp(ui, server)
```

## Data source

TMDB 5000 Movie Dataset (Kaggle). Data is community-maintained and not
redistributed in this repo per Kaggle's terms.

## Deployed dashboard

[link to shinyapps.io URL — to add after deployment]