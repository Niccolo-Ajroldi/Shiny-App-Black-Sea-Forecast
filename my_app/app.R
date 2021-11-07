
#' 
#' Interactive parameters:
#' 
#' Point predictor: EK vs Concurrent
#' 

library("shiny")
library("shinythemes")
library('plotly')
library("dplyr")

# Data -------------------------------------------------------------------------

setwd("D:/Poli/TESI/Code/Time-Series-CP/FAR_2D/Band_visualization/Shiny/Interactive/my_app")
load("data/y_bands.RData")

# Parameters -------------------------------------------------------------------

# num of points in the grid
n_points = sum(indexes_not_NA)
n_points # 

# grid
length_grid = n_points
my_grid = 1:n_points

# sample size
sample_size = 99
new_sample_size = 1

# number of rolling windows
n_windows = 50

# total number of time steps
n_tot = sample_size+n_windows
n_tot

# validation set
n_validation = 99+500

# List with dates
dates.asDate = as.character(dates.asDate)
dates.list = as.list(dates.asDate)
names(dates.list) = dates.asDate

col.brewer = ""

# Shiny ------------------------------------------------------------------------

library(shiny)
library(shinydashboard)
library(tidyr)

# UI ---------------------------------------------------------------------------

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Black Sea Forecasting"),
  
  # Panel for inputs ----
  selectInput("date", h3("Select date"), 
              choices = dates.list, selected = dates.list[1]),
  
  # Horizontal rule
  hr(),
  
  # Sidebar layout with input and output definitions ----
  fluidRow(
    column(6,
           plotlyOutput(outputId = "plot_true")
    ),
    column(6,
          plotlyOutput(outputId = "plot_pred")
    )
  ),
  fluidRow(
    column(6,
           plotlyOutput(outputId = "plot_lower")
    ),
    column(6,
           plotlyOutput(outputId = "plot_upper")
    )
  ),
  fluidRow(
    column(6, offset=3,
           plotOutput(outputId = "plot_error")
    ),
    column(3
    )
  )
  
)

# SERVER -----------------------------------------------------------------------

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # OBSERVED SURFACE
  output$plot_true <- renderPlotly({
    library(raster)
    date.index = which(dates.asDate==input$date)
    title.string = paste0("Observed surface on ", dates.asDate[date.index])
    
    r = raster(t(y.true.array[,,date.index]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
               crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    r = flip(r,2)
    rasdf <- as.data.frame(r, xy=TRUE)%>%drop_na()
    names(rasdf) = c("lon", "lat", "value")
    p <- ggplot() + 
      geom_raster(data = rasdf, aes(x = lon, y = lat, fill=value)) +
      labs(xlab="Longitude", ylab="Latitude", title = title.string) +
      scale_fill_gradientn(colours = RColorBrewer::brewer.pal(n = 9, name = "Blues"), 
                           limits=c(minn.no.bands, maxx.no.bands))
    plotly::ggplotly(p)
  })
  
  # PREDICTED SURFACE
  output$plot_pred <- renderPlotly({
    library(raster)
    date.index = which(dates.asDate==input$date)
    title.string = paste0("Predicted surface on ", dates.asDate[date.index])
    
    r = raster(t(y.predicted.array[,,date.index]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
               crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    r = flip(r,2)
    rasdf <- as.data.frame(r, xy=TRUE)%>%drop_na()
    names(rasdf) = c("lon", "lat", "value")
    p <- ggplot() + 
      geom_raster(data = rasdf, aes(x = lon, y = lat, fill=value)) +
      labs(xlab="Longitude", ylab="Latitude", title = title.string) +
      scale_fill_gradientn(colours = RColorBrewer::brewer.pal(n = 9, name = "Blues"), 
                           limits=c(minn.no.bands, maxx.no.bands))
    plotly::ggplotly(p)
  })
  
  # BAND LOWER BOUND
  output$plot_lower <- renderPlotly({
    library(raster)
    date.index = which(dates.asDate==input$date)
    title.string = paste0("Band lower bound on ", dates.asDate[date.index])
    
    r = raster(t(band.lower.array[,,date.index]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
               crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    r = flip(r,2)
    rasdf <- as.data.frame(r, xy=TRUE)%>%drop_na()
    names(rasdf) = c("lon", "lat", "value")
    p <- ggplot() + 
      geom_raster(data = rasdf, aes(x = lon, y = lat, fill=value)) +
      labs(xlab="Longitude", ylab="Latitude", title = title.string) +
      scale_fill_gradientn(colours = RColorBrewer::brewer.pal(n = 9, name = "Blues"), 
                           limits=c(minn, maxx))
    plotly::ggplotly(p)
  })
  
  # BAND UPPER BOUND
  output$plot_upper <- renderPlotly({
    library(raster)
    date.index = which(dates.asDate==input$date)
    title.string = paste0("Band upper bound on ", dates.asDate[date.index])
    
    r = raster(t(band.upper.array[,,date.index]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
               crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    r = flip(r,2)
    rasdf <- as.data.frame(r, xy=TRUE)%>%drop_na()
    names(rasdf) = c("lon", "lat", "value")
    p <- ggplot() + 
      geom_raster(data = rasdf, aes(x = lon, y = lat, fill=value)) +
      labs(xlab="Longitude", ylab="Latitude", title = title.string) +
      scale_fill_gradientn(colours = RColorBrewer::brewer.pal(n = 9, name = "Blues"), 
                           limits=c(minn, maxx))
    plotly::ggplotly(p)
  })
  
  
  output$plot_error <- renderPlot({
    library(raster)
    date.index = which(dates.asDate==input$date)
    title.string = paste0("Observed surface on ", dates.asDate[date.index])
    
    # raster
    r = raster(t(errors[,,date.index]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
               crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    r = flip(r,2)
    
    # dataframe
    val <- getValues(r)
    xy <- as.data.frame(xyFromCell(r,1:ncell(r)))
    xy <- cbind(xy,val)
    head(xy)
    
    ggplot(na.omit(xy), aes(x=x, y=y, fill=val)) + 
      geom_raster() + 
      coord_equal() +
      scale_fill_manual(name="Status", 
                        values = c("TRUE"="dodgerblue3","FALSE"="firebrick1"), 
                        labels=c("Points inside","Points outside")) +
      labs(xlab="Longitude", ylab="Latitude", title = "Points inside/outside prediction bands")
  })
  
}

# SHINY APP CALL ---------------------------------------------------------------

shinyApp(ui = ui, server = server)


