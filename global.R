# global.R --------------------------------------------------------------------
# Loads and prepares TMDB 5000 data for the Shiny app.
# Runs once at app startup. All objects defined here are visible to ui.R and
# server.R.

library(tidyverse)
library(jsonlite)
library(shiny)
library(bslib)
library(plotly)
library(DT)
library(scales)

# Load raw data ---------------------------------------------------------------
movies_raw  <- read_csv("data/tmdb_5000_movies.csv",  show_col_types = FALSE)
credits_raw <- read_csv("data/tmdb_5000_credits.csv", show_col_types = FALSE)

# Helper: parse a JSON-string column and pull out the "name" field ------------
parse_json_names <- function(json_string) {
  if (is.na(json_string) || json_string == "" || json_string == "[]") {
    return(character(0))
  }
  parsed <- tryCatch(fromJSON(json_string), error = function(e) NULL)
  if (is.null(parsed) || length(parsed) == 0) return(character(0))
  parsed$name
}

# Build the analysis dataset --------------------------------------------------
movies <- movies_raw |>
  left_join(credits_raw |> select(movie_id, cast, crew),
            by = c("id" = "movie_id")) |>
  mutate(
    release_date    = as.Date(release_date),
    release_year    = as.integer(format(release_date, "%Y")),
    decade          = (release_year %/% 10) * 10,
    genre_names     = map(genres, parse_json_names),
    primary_genre   = map_chr(genre_names, ~ if (length(.x) > 0) .x[1] else NA_character_),
    budget_clean    = if_else(budget  == 0, NA_real_, budget),
    revenue_clean   = if_else(revenue == 0, NA_real_, revenue),
    profit          = revenue_clean - budget_clean,
    roi             = revenue_clean / budget_clean
  ) |>
  filter(!is.na(release_year), status == "Released")

# Build a directors-by-film table --------------------------------------------
# crew is a JSON list of crew members per film; we want only those with job=Director.
parse_directors <- function(crew_string) {
  if (is.na(crew_string) || crew_string == "" || crew_string == "[]") {
    return(character(0))
  }
  parsed <- tryCatch(fromJSON(crew_string), error = function(e) NULL)
  if (is.null(parsed) || length(parsed) == 0) return(character(0))
  if (!"job" %in% names(parsed)) return(character(0))
  parsed$name[parsed$job == "Director"]
}

# Build a long table: one row per (film, director) pair
directors_long <- movies |>
  mutate(director_names = map(crew, parse_directors)) |>
  select(id, title, release_year, vote_average, vote_count,
         budget_clean, revenue_clean, roi, director_names) |>
  unnest(director_names) |>
  rename(director = director_names) |>
  filter(!is.na(director), director != "")

# Lookup vectors for UI controls ----------------------------------------------
all_genres <- movies |>
  pull(genre_names) |>
  unlist() |>
  unique() |>
  sort()

year_range <- range(movies$release_year, na.rm = TRUE)

# Shared color palette --------------------------------------------------------
# Used across the whole dashboard for visual coherence.
palette_primary   <- "#E50914"   # signal red — for emphasis / single-series
palette_secondary <- "#221F1F"   # near-black — for text and reference lines
palette_neutral   <- "#888888"   # grey — for non-data ink (annotations, captions)
palette_muted     <- "#F5F5F5"   # light grey — for plot backgrounds if needed

# Categorical palette for genre coloring (Brewer Set2-inspired, with a movie twist)
# Used when we need to distinguish multiple genres or categories at once.
palette_categorical <- c(
  "#E50914",  # red
  "#1F77B4",  # blue
  "#2CA02C",  # green
  "#F5C518",  # gold
  "#9467BD",  # purple
  "#8C564B",  # brown
  "#17BECF",  # cyan
  "#FF7F0E"   # orange
)

# Custom ggplot theme ---------------------------------------------------------
theme_tmdb <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      text             = element_text(family = "Helvetica", color = palette_secondary),
      plot.title       = element_text(face = "bold", size = base_size + 4,
                                      margin = margin(b = 4)),
      plot.subtitle    = element_text(color = palette_neutral, size = base_size,
                                      margin = margin(b = 12)),
      plot.caption     = element_text(color = palette_neutral, size = base_size - 2,
                                      hjust = 0, margin = margin(t = 12)),
      axis.title       = element_text(color = palette_neutral, size = base_size - 1),
      axis.text        = element_text(color = palette_secondary),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#EEEEEE"),
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      legend.position  = "bottom",
      legend.title     = element_text(size = base_size - 1, color = palette_neutral),
      strip.text       = element_text(face = "bold", color = palette_secondary)
    )
}

theme_set(theme_tmdb())