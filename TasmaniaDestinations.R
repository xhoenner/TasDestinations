rm(list=ls())

library(leaflet); library(mapview); library(readxl); #library(crosstalk)

resources <- read_excel('~/Downloads/WIP/TasDestinations/TasmaniaDestinations.xlsx')
# resources_sd <- SharedData$new(resources)
cof <- colorFactor(c("#ffa500", "#13ED3F"), domain=c("Bushwalk", "Restaurants/Cafes"))

map <- resources %>% 
	leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
    addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap", options = providerTileOptions(updateWhenZooming = FALSE, updateWhenIdle = FALSE)) %>% 
    addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>% 
    addLayersControl(baseGroups = c("OpenStreetMap", "Esri.WorldImagery")) %>%
    setView(lng = 146.75, lat = -42.1, zoom = 8) %>%
  	addMiniMap() %>% addMeasure(primaryLengthUnit = 'kilometers') %>%
  	addCircleMarkers(~LON, ~LAT, color = ~cof(Type), fill = ~cof(Type), label = resources$Name, clusterOptions = markerClusterOptions(), popup = paste0(resources$Name, ': ', resources$Description)) %>%
  	addLegend("bottomright", colors= c("#ffa500", "#13ED3F"), labels=c("Bushwalk", "Restaurants/Cafes"), title="Things to do") 
  	
# bscols(filter_select("Location", "Location", resources_sd, ~Location))

mapshot(map, url = '~/Downloads/WIP/TasDestinations/index.html')