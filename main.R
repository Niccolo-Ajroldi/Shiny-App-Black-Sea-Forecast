
# Come far selzionare un rettangolo:
# https://shiny.rstudio.com/articles/plot-interaction.html


# set directory
#name_dir = paste0("D:/Poli/TESI/Code/Time-Series-CP/FAR_2D/Band_visualization/Shiny")
#setwd(name_dir)

library(shiny)
setwd("D:/Poli/TESI/Code/Time-Series-CP/FAR_2D/Band_visualization/Shiny/Interactive")
load("my_app/data/BS_diff.RData")
load("my_app/data/y_bands.RData")

app_dir="D:/Poli/TESI/Code/Time-Series-CP/FAR_2D/Band_visualization/Shiny/Interactive/my_app"
runApp(app_dir)

