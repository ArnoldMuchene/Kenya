library(shiny)
library(tmap)
library(sf)
library(rKenyaCensus)

data("KenyaCounties_SHP")
kenya_map <- st_as_sf(KenyaCounties_SHP)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { margin: 0; font-family: 'Segoe UI', sans-serif; }
      .main-container { display: flex; height: 100vh; }
      .sidebar {
        background-color: #e9eef3;
        width: 250px;
        padding: 20px;
        border-right: 1px solid #ccc;
      }
      .sidebar h3 {
        font-size: 1.2rem;
        margin-bottom: 1rem;
        color: #004085;
      }
      .sidebar a {
        display: block;
        margin-bottom: 1rem;
        color: #004085;
        text-decoration: none;
        font-weight: 500;
      }
      .sidebar a:hover {
        text-decoration: underline;
      }
      .main-panel {
        flex-grow: 1;
        display: flex;
        flex-direction: column;
      }
      .header {
        background-color: #004085;
        color: white;
        padding: 15px 30px;
        font-size: 1.3rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .header p {
        font-size: 1rem;
        margin: 5px 0 0;
        color: #dbe9f9;
      }
      .logout-btn {
        background-color: #dc3545;
        border: none;
        color: white;
        padding: 8px 14px;
        border-radius: 4px;
        font-weight: bold;
        cursor: pointer;
      }
      .logout-btn:hover {
        background-color: #bd2130;
      }
      .map-area {
        flex-grow: 1;
        padding: 0;
      }
    "))
  ),
  
  # Login Panel
  conditionalPanel(
    condition = "!output.authenticated",
    wellPanel(
      h3("Login"),
      textInput("county", "Enter County (e.g., Kajiado)", value = ""),
      passwordInput("password", "Enter Password"),
      actionButton("login", "Login"),
      verbatimTextOutput("login_status")
    )
  ),
  
  # Main App Panel
  conditionalPanel(
    condition = "output.authenticated",
    div(
      class = "main-container",
      div(
        class = "sidebar",
        h3("Menu"),
        tags$a(href = "#", "Assumptions"),
        tags$a(href = "#", "Capital Plans"),
        tags$a(href = "#", "Capital Plan Details"),
        tags$a(href = "#", "Compare Capital Plans")
      ),
      div(
        class = "main-panel",
        div(
          class = "header",
          div(
            HTML("Welcome to the Kenya County Viewer<br><p>Use this tool to highlight a specific county and display it on the map.</p>")
          ),
          actionButton("logout", "Logout", class = "logout-btn")
        ),
        div(
          class = "map-area",
          tmapOutput("kenya_map", height = "100%")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  credentials <- reactiveValues(authenticated = FALSE, county = NULL)
  
  observeEvent(input$login, {
    req(input$county)
    if (tolower(input$password) == "password") {
      if (toupper(input$county) %in% toupper(kenya_map$County)) {
        credentials$authenticated <- TRUE
        credentials$county <- tools::toTitleCase(tolower(input$county))
      } else {
        credentials$authenticated <- FALSE
      }
    } else {
      credentials$authenticated <- FALSE
    }
  })
  
  observeEvent(input$logout, {
    credentials$authenticated <- FALSE
    credentials$county <- NULL
    updateTextInput(session, "county", value = "")
    updateTextInput(session, "password", value = "")
  })
  
  output$authenticated <- reactive({
    credentials$authenticated
  })
  outputOptions(output, "authenticated", suspendWhenHidden = FALSE)
  
  output$login_status <- renderText({
    if (input$login > 0 && !credentials$authenticated) {
      "Invalid login or county. Try again."
    }
  })
  
  output$kenya_map <- renderTmap({
    req(credentials$authenticated)
    kenya_map$highlight <- toupper(kenya_map$County) == toupper(credentials$county)
    
    tm_shape(kenya_map) +
      tm_polygons("highlight", palette = c("gray80", "#2c7fb8"),
                  title = "", border.col = "white", lwd = 0.5) +
      tm_layout(main.title = paste("Highlighted County:", credentials$county),
                main.title.size = 1.3, frame = FALSE)
  })
}

shinyApp(ui, server)
