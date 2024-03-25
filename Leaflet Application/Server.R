library(shiny)
library(ggplot2)
library(tidyverse)
library(tsibble)
library(maps)
library(colourpicker)
library(leaflet)
library(sf)
library(rnaturalearthdata)
library(rnaturalearth)

# temperature_data <- data.frame(read_csv("~/GitHub/stat436-project/raw_data/Test_Temp.csv"))
temperature_data <- data.frame(read_csv("Test_Temp.csv"))
temperature_data$present = temperature_data$present - temperature_data$historical
temperature_data$mid = temperature_data$mid - temperature_data$historical
temperature_data$end = temperature_data$end - temperature_data$historical


# Load spatial data with country boundaries
world <- ne_countries(scale = "medium", returnclass = "sf")

# Merge temperature data with country data
world_temp <- left_join(world, temperature_data[c("country_code", "mid")], by = c("iso_a3" = "country_code"))

# Choose colors
rev_palette <- colorRampPalette(c("blue", "red"))(100)

server <- function(input, output) {
  
  output$Map <- renderLeaflet({
    selected = 
      leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(data = world_temp, 
                  fillColor = ~colorNumeric(palette = rev_palette, domain = temperature_data$mid)(mid),
                  fillOpacity = 0.7,
                  weight = 1,
                  color = "white",
                  popup = ~paste(name, "<br>", "Temperature Change: ", mid, "F")) %>%
      addLegend("bottomright", 
                pal = colorNumeric(palette = rev_palette, domain = temperature_data$mid),
                values = temperature_data$mid,
                title = "Temperature Change (F)",
                opacity = 0.7)
  })
}