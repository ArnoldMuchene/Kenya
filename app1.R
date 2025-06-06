library(shiny)
library(DT)

# Define UI
ui <- fluidPage(
  # Custom CSS for styling
  tags$head(
    tags$style(HTML("
      body {
        font-family: Arial, sans-serif;
      }
      .sidebar {
        background-color: #f0f4f7;
        padding: 15px;
        height: 100vh;
        border-right: 1px solid #d3d3d3;
      }
      .sidebar a {
        display: block;
        padding: 10px;
        color: #007bff;
        text-decoration: none;
      }
      .sidebar a:hover {
        background-color: #e0e4e7;
      }
      .main-panel {
        padding: 20px;
      }
      .header {
        background-color: #333;
        color: white;
        padding: 10px;
        font-size: 20px;
        font-weight: bold;
      }
      .location {
        float: right;
        font-size: 14px;
        color: #ccc;
      }
      .action-buttons {
        margin: 10px 0;
      }
      .btn-create {
        background-color: #007bff;
        color: white;
        border: none;
        padding: 5px 10px;
        margin-right: 5px;
      }
      .btn-edit {
        background-color: #28a745;
        color: white;
        border: none;
        padding: 5px 10px;
        margin-right: 5px;
      }
      .btn-delete {
        background-color: #dc3545;
        color: white;
        border: none;
        padding: 5px 10px;
      }
    "))
  ),
  
  # Header
  div(class = "header",
      "CLEAR ROADS: Winter Maintenance Impact",
      span(class = "location", "South Dakota")
  ),
  
  # Layout with sidebar and main panel
  fluidRow(
    # Sidebar
    column(2, class = "sidebar",
           a(href = "#", "About"),
           a(href = "#", "Assumptions"),
           a(href = "#", "Capital Plans", style = "font-weight: bold;"),
           a(href = "#", "Capital Plan Details"),
           a(href = "#", "Compare Capital Plans")
    ),
    
    # Main panel
    column(10, class = "main-panel",
           h4("YOUR CAPITAL PLANS:"),
           selectInput("capital_plan", label = NULL, 
                       choices = c("Nothing selected"), 
                       selected = "Nothing selected"),
           textInput("search", label = "Search capital plans table:", placeholder = ""),
           div(class = "action-buttons",
               actionButton("create", "Create New Capital Plans", class = "btn-create"),
               actionButton("edit", "Edit Capital Plans", class = "btn-edit"),
               actionButton("delete", "Delete Capital Plans", class = "btn-delete")
           ),
           DTOutput("table")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Data for the table
  data <- data.frame(
    `Project Type` = c(
      "New Plow Trucks",
      "New Sidewalk Plows",
      "New Tow Trucks",
      "Traditional Intersection to Roundabout",
      "Expand from 1 to 2 Lanes in Each Direction",
      "Addition of Dedicated Left Turn Lane at Intersection",
      "Construction of New Urban Roadway",
      "Construction of New Suburban Roadway",
      "Addition of Adjoining Shared-Use Path, Sidewalk, or On-Road Bike Facility",
      "New roadway, 2-lanes either direction",
      "Shoulder widening in both directions",
      "New right-turn lanes",
      "Road diet conversion, 2-lanes either direction to 1 with a center left-turn lane",
      "Highway lane addition, from 2 to 3 in one direction",
      "Full resurfacing, 1-lane either direction",
      "Pedestrian improvements like addition or widening of sidewalks",
      "Addition of physical traffic calming measures like vertical and horizontal deflectors"
    ),
    Units = c(
      "plow trucks",
      "sidewalk plows",
      "tow trucks",
      "each intx",
      "miles",
      "# of approaches",
      "miles",
      "miles",
      "miles",
      "miles",
      "miles",
      "miles",
      "miles",
      "miles",
      "miles",
      "miles",
      "miles"
    ),
    stringsAsFactors = FALSE
  )
  
  # Render the table
  output$table <- renderDT({
    datatable(data, 
              options = list(
                pageLength = 20,
                searching = TRUE,
                ordering = TRUE,
                dom = 't'
              ),
              rownames = FALSE)
  })
  
  # Button actions (placeholder logic)
  observeEvent(input$create, {
    showNotification("Create New Capital Plans clicked!", type = "message")
  })
  
  observeEvent(input$edit, {
    showNotification("Edit Capital Plans clicked!", type = "message")
  })
  
  observeEvent(input$delete, {
    showNotification("Delete Capital Plans clicked!", type = "message")
  })
}

# Run the app
shinyApp(ui = ui, server = server)