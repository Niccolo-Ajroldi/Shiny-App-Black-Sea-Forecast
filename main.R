
# Come far selzionare un rettangolo:
# https://shiny.rstudio.com/articles/plot-interaction.html


# set directory
#name_dir = paste0("D:/Poli/TESI/Code/Time-Series-CP/FAR_2D/Band_visualization/Shiny")
#setwd(name_dir)

library(shiny)
setwd("D:/Poli/TESI/Code/Shiny_App_Black_Sea/my_app")
load("my_app/data/width.RData")
load("my_app/data/y_bands.RData")

app_dir="D:/Poli/TESI/Code/Shiny_App_Black_Sea/my_app"
runApp(app_dir)

