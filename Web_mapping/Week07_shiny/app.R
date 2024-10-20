library(shiny);library(leaflet);library(sf);library(dplyr)


#read the data
point_data  <- st_read('cbsa_points.shp')

#transform to wgs
tf_data <- st_transform(point_data, crs = '+proj=longlat +datum=WGS84')


ui <- fluidPage(
  titlePanel('Housing Mortgage Map'),
  sidebarLayout(
    sidebarPanel(
      sliderInput(inputId = 'mortgagerange',
                  label = 'Mortgage Range',
                  min = 0,
                  max = max(tf_data$Mortgage, na.rm = TRUE),
                  value = c(0, max(tf_data$Mortgage, na.rm = TRUE))),
      selectInput(inputId = 'stateFilter',
                  label = 'Select State',
                  choices = unique(tf_data$State),
                  selected = unique(tf_data$State[1]),
                  multiple = TRUE),
      radioButtons(inputId = 'filterChoice',
                   label = 'Selection:',
                   choices = c("All", "Filter"),
                   selected = "Filter")),
    mainPanel(
      leafletOutput(outputId = 'map', width = '100%', height = '500px'))
  )
)

server <- function(input, output){
  
  # Reactive filtering based on user input
  filtered_data <- reactive({
    if(input$filterChoice == "All"){
      tf_data %>% filter(
        Mortgage >= input$mortgagerange[1],
        Mortgage <= input$mortgagerange[2]
      )
    } else {
      tf_data %>% filter(
        Mortgage >= input$mortgagerange[1],
        Mortgage <= input$mortgagerange[2],
        State %in% input$stateFilter
      )
    }
  })
  
  # Render leaflet map
  output$map <- renderLeaflet({
    data <- filtered_data()  # Filter
    
    leaflet(data) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~st_coordinates(data)[,1], lat = ~st_coordinates(data)[,2], 
                       popup = ~paste("Mortgage:", Mortgage, "<br>", "State:", State),
                       radius = 5,
                       color = "blue",
                       fill = TRUE,
                       fillOpacity = 0.7)
  })
}

shinyApp(ui = ui, server = server)












