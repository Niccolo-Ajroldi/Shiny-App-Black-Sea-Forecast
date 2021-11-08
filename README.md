# Shiny-App-Black-Sea-Forecast

Codes for the web application listening on: https://niccolo-ajroldi.shinyapps.io/Black-Sea-Forecasting/

The web panel is part of a larger project aiming to forecast surface data and quantify uncertainty in prediction. 

In this application we aim to forecast Black Sea level anomalies.
Data are provided by [Copernicus Climate Change Service](https://climate.copernicus.eu/), a project operated by the [European Center for Medium-Range Weather Forecasts](https://www.ecmwf.int/), collecting daily sea level anomalies of the Black Sea in the last twenty years. Data are publicly available at [Climate Data Store](https://cds.climate.copernicus.eu/cdsapp#!/dataset/satellite-sea-level-black-sea?tab=overview).

<p align="center">
  <img src="https://github.com/Niccolo-Ajroldi/Shiny-App-Black-Sea-Forecast/blob/master/Pics/Screenshot_APP_1.png" width="941.5" height="367.5" />
</p>

<p align="center">
  <img src="https://github.com/Niccolo-Ajroldi/Shiny-App-Black-Sea-Forecast/blob/master/Pics/Screenshot_APP_2.png" width="941.5" height="367.5" />
</p>

The panel displays the following surfaces:
- observed surface
- predicted surface
- surface defyining prediction band's lower bound
- surface defyining prediction band's upper bound
- points outside the prediction band (if any)


<p align="center">
  <img src="https://github.com/Niccolo-Ajroldi/Shiny-App-Black-Sea-Forecast/blob/master/Pics/Screenshot_APP_3.png" width="941.5" height="367.5" />
</p>

<p align="center">
  <img src="https://github.com/Niccolo-Ajroldi/Shiny-App-Black-Sea-Forecast/blob/master/Pics/Screenshot_APP_4.png" width="941.5" height="367.5" />
</p>

The forecasting algorithm choosen for his application is a **Functional Autoregressive process** of order one.
Prediction bands are obtained with **Conformal Prediction**, a versatile **nonparametric** technique used to quantify uncertainty in prediction problems. Such method has been extended to allow for time series of functions defined ona bivariate domain. Nominal coverage of prediction bands is fixed to 90%.
The procedure is applied to the time series of second differences of sea level anomalies.

The webapp is developed using [Shiny App](https://shiny.rstudio.com/).
