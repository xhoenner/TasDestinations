rm(list=ls())

## Load libraries and set up environment
library(leaflet); library(mapview); library(readxl); library(leaflet.extras); library(leaflet.extras2); library(dplyr); library(RColorBrewer)
Sys.setenv("OPENWEATHERMAP" = 'e8f90cc547708add27f4cfcf9fc851f6')
setwd('~/Documents/PersonalStuff/')

## Read config file
resources <- read_excel('TasDestinations/TasmaniaDestinations.xlsx') ## To insert GoogleDrive images, just add the photo id at the end of https://lh3.googleusercontent.com/d/
resources.type <- sort(unique(resources$Type)); resources$AdditionalInfo[which(is.na(resources$AdditionalInfo))] <- ''
cols <- brewer.pal(n = length(resources.type), name = "Paired"); cols[1] <- '#15dcfe'; cof <- colorFactor(cols, domain= resources.type);

## Validate all URLs in Excel spreadsheet - takes about 2 minutes for each run
valid_url <- function(url_in,t=2){
  con <- url(url_in)
  check <- suppressWarnings(try(open.connection(con,open="rt",timeout=t),silent=T)[1])
  suppressWarnings(try(close.connection(con),silent=T))
  ifelse(is.null(check),TRUE,FALSE)
}
sapply(resources$Photo,valid_url); ## Photos
sapply(resources$Resources,valid_url); ## Additional info

## Generate map
map <- resources %>% 
	leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
    addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap", options = providerTileOptions(updateWhenZooming = FALSE, updateWhenIdle = FALSE)) %>% 
    addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>% 
    addProviderTiles(providers$OpenWeatherMap.Wind, group = 'Wind speed', options = providerTileOptions(apiKey="e8f90cc547708add27f4cfcf9fc851f6")) %>% ## Wind
    addProviderTiles(providers$OpenWeatherMap.RainClassic, group = 'Rain', options = providerTileOptions(apiKey="e8f90cc547708add27f4cfcf9fc851f6")) %>% ## Rain
    addProviderTiles(providers$OpenWeatherMap.Temperature, group = 'Temperature', options = providerTileOptions(apiKey="e8f90cc547708add27f4cfcf9fc851f6")) %>% ## Temperature
    # addOpenweatherTiles(layers = "wind") %>%
    addLayersControl(baseGroups = c("OpenStreetMap", "Esri.WorldImagery"), overlayGroups = c('Wind speed', 'Rain', 'Temperature')) %>%
    hideGroup(c('Wind speed', 'Rain', 'Temperature')) %>%
    setView(lng = 146.75, lat = -42.1, zoom = 8) %>%
    addResetMapButton() %>%
  	addMiniMap() %>% 
  	addMeasure(primaryLengthUnit = 'kilometers') %>%
  	addCircleMarkers(~LON, ~LAT, color = ~cof(Type), fill = ~cof(Type), label = paste0(resources$Name, ' - ', resources$Type), stroke = TRUE, radius = 15, fillOpacity = .75, 
  		clusterOptions = markerClusterOptions(), 
  		popup = paste0('<font size="3"> <b>', resources$Name, ': </font></b><br>', 
  						'<font size="2">', resources$Description, "<br>", 
  						'<font size="2"> <b>', resources$AdditionalInfo, "</b> <br>", 
  						paste0("<img src = ", resources$Photo, " width='300' height='200'>"), "<br>", 
  						"<a href='", resources$Resources, "' target='_blank'>", "More info</a></font>"),
    labelOptions = labelOptions(textsize = "15px", direction = "auto"), group = 'Resources') %>%
  	addLegend("bottomright", colors= cols, labels= resources.type, title= "Things to do"); ## Export Map from Viewer tab as index.html in RStudio
  	
# mapshot(map, url = '~/Documents/PersonalStuff/TasDestinations/index.html', title="TasDestinations"); ## Somehow not functional anymore...