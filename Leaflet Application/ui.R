library(shiny)
library(ggplot2)
library(tidyverse)
library(tsibble)
library(maps)
library(colourpicker)

library(ncdf4)
data <- nc_open("TSavg.djf2015-2100.ensavg.nc")
lats <- ncvar_get(data, "lat")
lons <- ncvar_get(data, "lon")
temp <- ncvar_get(data, "TS")

# Alternative data reading methods that did not work too well...
# temp <- read_csv("https://uwmadison.box.com/shared/static/aqsak1cbbf81bgiqfhxrxsvlxzlhnxsk.csv")
# lons <- read_csv("https://uwmadison.box.com/shared/static/ldra9ygas6st3le0l2914h3oipzkxxys.csv")
# lats <- read_csv("https://uwmadison.box.com/shared/static/n6n4e1wmji4jntzcvcl88y96ypx10pqq.csv")
# temp <- read_csv("Temperature.csv")
# lons <- read_csv("Lons.csv")
# lats <- read_csv("Lats.csv")

# Variable to store our selected latitude and longitude points
selected <- reactiveValues(points = data.frame(Lat = numeric(0), 
                                               Lon = numeric(0)))

# User interface
ui <- fluidPage(
  titlePanel("Northern Winter Temperature Anomolies in the 21st Century"),
  helpText("Below is a map plotting predicted temperature anomalies in Northern winter.",
           "Use the time slider to view the expected change in temperature from 2015."),

  # Slider controls
  fluidRow(
    sliderInput("year", "Select Year", min=2015, max=2100, value=2100,
                width="95%", sep="")
  ),
  helpText("Use the longitude and latitude sliders to view a time series of temperature at that point"),
  fluidRow(
    sliderInput("Lon", "Longitude", min = 0, 360, value = 180, width="95%")
  ),
  fluidRow(
    sliderInput("Lat", "Latitude", min = -90, max = 90, value = 0, width="95%")
  ),
  
  # Button controls
  helpText("Click 'Add Point' to save selected lon/lat point to compare with others.",
           "Click 'Clear Points' to reset selected"),
  fluidRow(
    actionButton("addPoint", "Add Point"),
    actionButton("reset", "Clear Points")
  ),

  # Outputs
  fluidRow(
    column(7,
           plotOutput("heatMap")
    ),
    column(5,
           plotOutput("tSeries")
    )
  )
)
