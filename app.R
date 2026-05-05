# app.R -----------------------------------------------------------------------
# Entry point. Sources the other files and starts the app.

source("global.R")
source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)