# ui.R ------------------------------------------------------------------------
# Defines the layout. No data manipulation here — only structure and inputs.

ui <- page_sidebar(
  title = "TMDB Movie Explorer",
  theme = bs_theme(
    version       = 5,
    bootswatch    = "flatly",
    primary       = palette_primary,
    base_font     = font_google("Inter"),
    heading_font  = font_google("Inter")
  ),

  sidebar = sidebar(
    title = "Filters",
    sliderInput(
      "year_range",
      "Release year",
      min   = year_range[1],
      max   = year_range[2],
      value = c(1990, year_range[2]),
      sep   = ""
    ),
    selectInput(
      "genre",
      "Genre",
      choices  = c("All genres" = "all", all_genres),
      selected = "all"
    ),
    sliderInput(
      "min_votes",
      "Minimum vote count",
      min   = 0,
      max   = 5000,
      value = 50,
      step  = 50
    ),
    helpText("Filter out obscure films with very few ratings.")
  ),

 navset_card_tab(
    nav_panel(
      "Budget vs. Revenue",
      plotlyOutput("budget_revenue_plot", height = "500px")
    ),
    nav_panel(
      "Genre Comparison",
      plotlyOutput("genre_plot", height = "500px")
    ),
    nav_panel(
      "Top Films",
      DTOutput("top_films_table")
    ),
    nav_panel(
      "Critics vs. Audience",
      plotlyOutput("critic_audience_plot", height = "550px")
    ),
    nav_panel(
      "About",
      uiOutput("about_panel")
    )
  )
)