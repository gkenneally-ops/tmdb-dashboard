# server.R --------------------------------------------------------------------
# Handles reactivity. Filters get applied here, plots get rendered here.

server <- function(input, output, session) {

  # Reactive: filtered movie set --------------------------------------------
  filtered_movies <- reactive({
    out <- movies |>
      filter(
        release_year >= input$year_range[1],
        release_year <= input$year_range[2],
        vote_count   >= input$min_votes
      )
    if (input$genre != "all") {
      out <- out |> filter(map_lgl(genre_names, ~ input$genre %in% .x))
    }
    out
  })

  # Plot: budget vs. revenue --------------------------------------------------
  output$budget_revenue_plot <- renderPlotly({
    df <- filtered_movies() |>
      filter(!is.na(budget_clean), !is.na(revenue_clean))

    # Compute share of profitable films for the subtitle
    pct_profitable <- df |>
      summarize(pct = mean(revenue_clean > budget_clean, na.rm = TRUE) * 100) |>
      pull(pct) |>
      round(0)

    p <- ggplot(df, aes(
            x = budget_clean,
            y = revenue_clean,
            text = paste0(
              "<b>", title, "</b><br>",
              "Year: ", release_year, "<br>",
              "Budget: ",  label_dollar(scale_cut = cut_short_scale())(budget_clean),  "<br>",
              "Revenue: ", label_dollar(scale_cut = cut_short_scale())(revenue_clean), "<br>",
              "ROI: ", round(roi, 2), "x"
            )
          )) +
      geom_abline(slope = 1, intercept = 0,
                  linetype = "dashed", color = palette_neutral, linewidth = 0.4) +
      geom_point(alpha = 0.55, color = palette_primary, size = 1.6) +
      annotate("text",
               x = 1e8, y = 5e5,
               label = "Below the line:\nlost money",
               size = 3, color = palette_neutral, hjust = 0) +
      annotate("text",
               x = 1e5, y = 5e8,
               label = "Above the line:\nprofitable",
               size = 3, color = palette_neutral, hjust = 0) +
      scale_x_log10(labels = label_dollar(scale_cut = cut_short_scale()),
                    breaks = c(1e4, 1e6, 1e8)) +
      scale_y_log10(labels = label_dollar(scale_cut = cut_short_scale()),
                    breaks = c(1e4, 1e6, 1e8, 1e10)) +
      labs(
        title    = paste0(pct_profitable, "% of films in this view earned more than they cost"),
        subtitle = "Each point is one film. Dashed line marks break-even (revenue = budget).",
        x        = "Budget",
        y        = "Revenue",
        caption  = "Source: TMDB 5000. Both axes on log scale."
      )

    ggplotly(p, tooltip = "text") |>
      config(displayModeBar = FALSE)
  })

  # Plot: genre comparison ---------------------------------------------------
  output$genre_plot <- renderPlotly({
    df <- filtered_movies() |>
      filter(!is.na(roi)) |>
      unnest(genre_names) |>
      group_by(genre_names) |>
      summarize(
        n_films    = n(),
        median_roi = median(roi, na.rm = TRUE),
        .groups    = "drop"
      ) |>
      filter(n_films >= 10) |>
      arrange(median_roi)

    if (nrow(df) == 0) {
      # Graceful empty state
      return(plotly_empty() |>
        layout(title = list(text = "Not enough data for the current filters",
                            font = list(family = "Helvetica", size = 16))))
    }

    # Highlight the top-ROI genre in red, mute the rest
    top_genre <- df |> slice_max(median_roi, n = 1) |> pull(genre_names)

    df <- df |> mutate(highlight = if_else(genre_names == top_genre,
                                           "top", "other"))

    p <- ggplot(df, aes(
            x = median_roi,
            y = fct_reorder(genre_names, median_roi),
            fill = highlight,
            text = paste0(
              "<b>", genre_names, "</b><br>",
              "Median ROI: ", round(median_roi, 2), "x<br>",
              "Films: ", label_comma()(n_films)
            )
          )) +
      geom_col(width = 0.75) +
      scale_fill_manual(values = c(top   = palette_primary,
                                   other = "#CCCCCC"),
                        guide = "none") +
      scale_x_continuous(labels = label_number(suffix = "x"),
                         expand = expansion(mult = c(0, 0.1))) +
      labs(
        title    = paste0(top_genre, " has the highest median ROI in this view"),
        subtitle = "Median revenue-to-budget ratio. Genres with fewer than 10 films excluded.",
        x        = NULL,
        y        = NULL,
        caption  = "Source: TMDB 5000."
      ) +
      theme(panel.grid.major.y = element_blank())

    ggplotly(p, tooltip = "text") |>
      config(displayModeBar = FALSE)
  })

  # Table: top films --------------------------------------------------------
  output$top_films_table <- renderDT({
    filtered_movies() |>
      arrange(desc(revenue_clean)) |>
      select(Title    = title,
             Year     = release_year,
             Genre    = primary_genre,
             Budget   = budget_clean,
             Revenue  = revenue_clean,
             ROI      = roi,
             Rating   = vote_average) |>
      head(50) |>
      datatable(
        rownames = FALSE,
        options  = list(
          pageLength = 10,
          scrollX    = TRUE,
          dom        = "tip",   # tools, table, info, pagination — no search box clutter
          columnDefs = list(
            list(className = "dt-right", targets = c(1, 3, 4, 5, 6))
          )
        )
      ) |>
      formatCurrency(c("Budget", "Revenue"),
                     digits = 0,
                     interval = 3,
                     mark = ",") |>
      formatRound("ROI",    digits = 2) |>
      formatRound("Rating", digits = 1) |>
      formatStyle("ROI",
                  background = styleColorBar(c(0, 20), "#FFE5E7"),
                  backgroundSize = "98% 80%",
                  backgroundRepeat = "no-repeat",
                  backgroundPosition = "center")
  })
}