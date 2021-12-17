rm(list=ls())

library(leaflet); library(mapview); library(readxl); library(leaflet.extras); library(leaflet.extras2);
Sys.setenv("OPENWEATHERMAP" = 'e8f90cc547708add27f4cfcf9fc851f6')

resources <- read_excel('~/Downloads/WIP/TasDestinations/TasmaniaDestinations.xlsx')
cof <- colorFactor(c("#ffa500", "#13ED3F"), domain=c("Bushwalk", "Campground"))

map <- resources %>% 
	leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
    addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap", options = providerTileOptions(updateWhenZooming = FALSE, updateWhenIdle = FALSE)) %>% 
    addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>% 
    addProviderTiles(providers$OpenWeatherMap.Wind, group = 'Wind speed', options = providerTileOptions(apiKey="e8f90cc547708add27f4cfcf9fc851f6")) %>% ## Wind
    addProviderTiles(providers$OpenWeatherMap.RainClassic, group = 'Rain', options = providerTileOptions(apiKey="e8f90cc547708add27f4cfcf9fc851f6")) %>% ## Rain
    addProviderTiles(providers$OpenWeatherMap.Temperature, group = 'Temperature', options = providerTileOptions(apiKey="e8f90cc547708add27f4cfcf9fc851f6")) %>% ## Temperature
    # addOpenweatherTiles(layers = "wind") %>%
    addLayersControl(baseGroups = c("OpenStreetMap", "Esri.WorldImagery"), overlayGroups = c('Wind speed', 'Rain', 'Temperature', 'Bushwalks')) %>%
    hideGroup(c('Wind speed', 'Rain', 'Temperature')) %>%
    setView(lng = 146.75, lat = -42.1, zoom = 8) %>%
    addResetMapButton() %>%
  	addMiniMap() %>% 
  	addMeasure(primaryLengthUnit = 'kilometers') %>%
  	addCircleMarkers(~LON, ~LAT, color = ~cof(Type), fill = ~cof(Type), label = ~Name, stroke = FALSE, fillOpacity = 0.5, clusterOptions = markerClusterOptions(), 
  		popup = paste0('<font size="3"> <b>', resources$Name, ': </font></b>', "<br>", 
  						'<font size="2">', resources$Description, "<br>", 
  						paste0("<img src = ", resources$Photo, " width='300' height='200'>"), "<br>", 
  						"<a href='", resources$Resources, "' target='_blank'>", "More info</a></font>"),
    labelOptions = labelOptions(textsize = "15px", direction = "auto"), group = 'Bushwalks') %>%
  	addLegend("bottomright", colors= c("#ffa500", "#13ED3F"), labels=c("Bushwalk", "Campground"), title="Things to do") 
  	

mapshot(map, url = '~/Downloads/WIP/TasDestinations/index.html', title="Favourite Tasmanian Destinations")