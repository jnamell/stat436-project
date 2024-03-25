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

# Merge data
world_temp <- left_join(world, temperature_data[c("country_code", "mid")], by = c("iso_a3" = "country_code"))

# Choose colors
rev_palette <- colorRampPalette(c("blue", "red"))(100)

ui <- fluidPage(
  titlePanel("Experimental mapping with historical temperature data"),
  # Inputs
  selectInput("Time", "Select Time", c("Present", "Mid-Century", "End-Century"), selected = "Present"),
  # Outputs
  leafletOutput("Map")
)