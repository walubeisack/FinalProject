library(shiny);library(leaflet);library(sf);library(dplyr)
install.packages()


#check directory
getwd()

#read the data
point_data  <- st_read('cbsa_points.shp')

#transform to wgs
tf_data <- st_transform(point_data, crs = '+proj=longlat +datum=WGS84')


# structure for a simple user interface
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
                  multiple = TRUE)),
    mainPanel(
      leafletOutput(outputId = 'map',width = '100%',
                    height = '500px')))) 


server = function(input, output){
  filtered_data = reactive({
    tf_data %>% filter(
      Mortgage >= input$morgagerange[1],
      Mortgage >= input$morgagerange[2],
      State %in% input$stateFilter)
  })
  
  output$map = renderLeaflet({
    leaflet() %>% 
      addTiles() %>%
      setView(lng = mean (st_coordinates(tf_data)[,1]),
              lat = mean (st_coordinates(tf_data)[,2]),
              zoom = 6)
  })
  
  observe({
    leafletProxy("map", data = filtered_data()) %>%
      clearMarkers() %>%
      addCircleMarkers(
        radius = 5,  # Adjust size based on Mortgage value (adjust the divisor as needed)
        color = "blue",
        label = ~paste("Mortgage:", Mortgage, "<br>", "State:", State)
      )
  })
  }
shinyApp(ui, server)














