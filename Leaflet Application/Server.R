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
selected <- reactiveValues(points = data.frame(Lat = numeric(0), 
                                               Lon = numeric(0)))


server <- function(input, output) {
  # Add point button is pressed:
  observeEvent(input$addPoint, {
    selected$points <- rbind(selected$points, data.frame(Lat = input$Lat, Lon = input$Lon))
  })
  # Reset points button is pressed:
  observeEvent(input$reset, {
    selected$points <- data.frame(Lat = numeric(0), Lon = numeric(0))
  })

  # Render contour map:
  output$heatMap <- renderPlot( {
    curr_lat <- lats[which.min(abs(lats - input$Lat))]
    curr_lon <- lons[which.min(abs(lons - input$Lon))]
    colors <- rainbow(nrow(selected$points))
    filled.contour(lons, lats, temp[,,input$year - 2014] - temp[,,1],
                   zlim = c(-5, 25),
                   main = paste("Predicted Average Change in December, January, February temperature",
                   "from 2015 to", input$year, "(Degrees Celcius)"),
                   plot.axes = {
                     axis(1)
                     axis(2)
                     maps::map('world',add=TRUE, wrap=c(0,360), interior = FALSE)
                     points(selected$points$Lon, selected$points$Lat, col = colors, pch = "x", cex = 2)
                     points(curr_lon, curr_lat, col = "black", pch = "x", cex = 2)
                   })
  })
  
  # Render time series:
  output$tSeries <- renderPlot( {
    # Creat tsibble for current lat and lon
    curr_lat <- which.min(abs(lats - input$Lat))
    curr_lon <- which.min(abs(lons - input$Lon))
    t_df = data.frame(t = temp[curr_lon,curr_lat,], year=2015:2100)
    t_tsibble = as_tsibble(t_df, index=year)

    # If selected points is not empty:
    if(nrow(selected$points) > 0) {
      t_df_all <- data.frame()
      # Create t_tsibble for all lats and lons selected
      for (i in 1:nrow(selected$points)) {
        lat_idx <- which.min(abs(lats - selected$points$Lat[i]))
        lon_idx <- which.min(abs(lons - selected$points$Lon[i]))
        t_df_all <- rbind(t_df_all, data.frame(t = temp[lon_idx, lat_idx, ],
                                               year = 2015:2100, Point = as.character(i)))
      }
      t_tsibble_all <- as_tsibble(t_df_all, key = "Point", index = "year")
      colors <- rainbow(nrow(selected$points))
      # Plot time series
      ggplot() +
        geom_line(data = t_tsibble, aes(x = year, y = t - 273), color = "black") +
        geom_line(data = t_tsibble_all, aes(x = year, y = t - 273, color = Point, group = Point),
                  linetype = "dashed") +
        scale_color_manual(values = colors) +
        labs(title = "Temperature over the 21st Century",
             y = "T (Degrees Celcius)",
             x = "Year")
    } else {
      # Plot only current time series
      ggplot() +
        geom_line(data = t_tsibble, aes(x = year, y = t - 273), color = "black") +
        labs(title = "Temperature over the 21st Century",
             y = "T (Degrees Celcius)",
             x = "Year")
    }
  })
}