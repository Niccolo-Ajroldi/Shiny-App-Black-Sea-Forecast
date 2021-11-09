
#' 
#' Interactive parameters:
#' 
#' Point predictor: EK vs Concurrent
#' 

# WARNING: all packages are built under R version 4.05
# Current R Version: 4.0.3
# Update R version if there are some problems

#install.packages("raster")
#install.packages("plotly")
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("RColorBrewer")
#install.packages("rstudioapi")
#install.packages("packrat")
#install.packages("rsconnect")
#install.packages("shiny")
#install.packages("shinydashboard")
#install.packages("shinythemes")

library(raster)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(dplyr)
library(tidyr)
library(RColorBrewer)
library(rstudioapi)
library(packrat)
library(rsconnect)

# Data -------------------------------------------------------------------------

#setwd("D:/Poli/TESI/Code/Shiny_App_Black_Sea/my_app")
load("data/y_bands.RData")
load("data/width.RData")

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

#display.brewer.all(type = 'seq')
#col.brewer = "GnBu"
col.brewer = "YlGnBu"

# Auxiliary Functions ----------------------------------------------------------

my_plot_raster = function(data, title.string, limits){
  
  r = raster(data, xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
             crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
  r = flip(r,2)
  rasdf <- as.data.frame(r, xy=TRUE)%>%drop_na()
  names(rasdf) = c("lon", "lat", "value")
  p <- ggplot() + 
    geom_raster(data = rasdf, aes(x = lon, y = lat, fill=value)) +
    ggtitle(title.string) + 
    xlab("Longitude") + 
    ylab("Latitude") +
    scale_fill_gradientn(name="Value",
                         colours = RColorBrewer::brewer.pal(n=9, name=col.brewer), 
                         limits=limits)
  plotly::ggplotly(p)
  
}

my_plot_contour = function(data, title.string, limits){
  
  Value = data
  p = plot_ly(z = ~Value, x = ~lon, y = ~lat,
              type = "contour", zmin=limits[1], zmax=limits[2]) %>%
    layout(title = title.string,
           xaxis = list(title = 'Longitude'), 
           yaxis = list(title = 'Latitude'))
  p
  
}

# Shiny ------------------------------------------------------------------------

# UI ---------------------------------------------------------------------------

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Black Sea Forecasting"),
  
  
  fluidRow(
    column(3,
           h3("Select date"),
           #helpText("Select a date from the list."),
           selectInput(inputId = "date", 
                       label=NULL,
                       choices = dates.list, selected = dates.list[1])
    ),
    column(3,
           h3("Color scale"),
           radioButtons(inputId = "legend_scale", 
                        label=NULL,
                        choices = list("All plots on the same scale"  = "same",
                                       #"Observed & Predicted on same scale" = "same_12",
                                       "Plots on different scales" = "diff"),
                        selected = "same"),
           br()
    ),
    column(3,
           h3("Plot type"),
           radioButtons(inputId = "plot_type", 
                        label=NULL,
                        choices = list("Contour plot"  = "contour",
                                       "Rasters plot"  = "raster"),
                        selected = "contour"),
           br()
    ),
    column(3,
           h3("Band Width"),
           textOutput(outputId = "width")
    )
  ),
  
  
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
  
  # WIDTH
  output$width = renderText({
    
    date.index = which(dates.asDate==input$date)
    round(width[date.index,],6)
    
  })
  
  # OBSERVED SURFACE
  output$plot_true <- renderPlotly({
    
    limits = switch(input$legend_scale, 
                    "same"=c(minn,maxx), #"same_12"=c(minn.no.bands, maxx.no.bands),
                    "diff"=NULL)
    
    # retrieve plot index
    date.index = which(dates.asDate==input$date)
    
    # data to plot
    data = t(y.true.array[,,date.index])
    
    # title
    title.string = paste0("Observed surface on ", dates.asDate[date.index])
    
    # plot
    switch(input$plot_type, 
           "raster"  = my_plot_raster (data, title.string, limits),
           "contour" = my_plot_contour(data, title.string, limits))
  })
  
  # PREDICTED SURFACE
  output$plot_pred <- renderPlotly({
    
    limits = switch(input$legend_scale, 
                    "same"=c(minn,maxx), #"same_12"=c(minn.no.bands, maxx.no.bands),
                    "diff"=NULL)
    
    # retrieve plot index
    date.index = which(dates.asDate==input$date)
    
    # data to plot
    data = t(y.predicted.array[,,date.index])
    
    # title
    title.string = paste0("Predicted surface on ", dates.asDate[date.index])
    
    # plot
    switch(input$plot_type, 
           "raster"  = my_plot_raster (data, title.string, limits),
           "contour" = my_plot_contour(data, title.string, limits))
  })
  
  # BAND LOWER BOUND
  output$plot_lower <- renderPlotly({
    
    limits = switch(input$legend_scale, 
                    "same"=c(minn,maxx), #"same_12"=c(minn.no.bands, maxx.no.bands),
                    "diff"=NULL)
    
    # retrieve plot index
    date.index = which(dates.asDate==input$date)
    
    # data to plot
    data = t(band.lower.array[,,date.index])
    
    # title
    title.string = paste0("Prediction band lower bound on ", dates.asDate[date.index])
    
    # plot
    switch(input$plot_type, 
           "raster"  = my_plot_raster (data, title.string, limits),
           "contour" = my_plot_contour(data, title.string, limits))
  })
  
  # BAND UPPER BOUND
  output$plot_upper <- renderPlotly({
    
    limits = switch(input$legend_scale, 
                    "same"=c(minn,maxx), #"same_12"=c(minn.no.bands, maxx.no.bands),
                    "diff"=NULL)
    
    # retrieve plot index
    date.index = which(dates.asDate==input$date)
    
    # data to plot
    data = t(band.upper.array[,,date.index])
    
    # title
    title.string = paste0("Prediction band upper bound on ", dates.asDate[date.index])
    
    # plot
    switch(input$plot_type, 
           "raster"  = my_plot_raster (data, title.string, limits),
           "contour" = my_plot_contour(data, title.string, limits))
  })
  
  # POINTS INSIDE/OUTSIDE BAND
  output$plot_error <- renderPlot({
    
    # retrieve plot index
    date.index = which(dates.asDate==input$date)
    
    # title
    title.string = paste0("Points inside/outside prediction bands on ", dates.asDate[date.index])
    
    # raster
    r = raster(t(errors[,,date.index]), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), 
               crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))
    r = flip(r,2)
    
    # dataframe
    val = getValues(r)
    val = as.factor(val)
    xy = as.data.frame(xyFromCell(r,1:ncell(r)))
    xy = cbind(xy,val)
    head(xy)
    
    p = ggplot(na.omit(xy), aes(x=x, y=y, fill=val)) + 
          geom_raster() + 
          scale_fill_manual(name="Status", 
                            values = c("TRUE"="dodgerblue3","FALSE"="firebrick1"), 
                            labels=c("Points inside","Points outside")) +
      theme(text=element_text(size=16,  family="sans"),
            plot.title = element_text(size = 18),
            legend.title = element_text(size = 14),
            legend.text = element_text(size = 12)) +
      ggtitle(title.string) + 
      xlab("Longitude") + 
      ylab("Latitude")
    p
  })
  
}

# SHINY APP CALL ---------------------------------------------------------------

shinyApp(ui = ui, server = server)


