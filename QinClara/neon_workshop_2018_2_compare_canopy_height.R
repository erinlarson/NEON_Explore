# Explore NEON Workshop
# Part 3: Afternoon of November 9, 2018

# Task: Compare stem height in example vegetation structure data from yesterday

library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)
library(ggplot2)

options(stringsAsFactors = FALSE)

setwd("~/Documents/Workshops/Explore NEON Workshop 2018")

# Load vegetation structure data
vegmap <- read.delim("data/filesToStack10098/stackedFiles/vst_mappingandtagging.csv",
                     sep=",")
View(vegmap)

vegind <- read.delim("data/filesToStack10098/stackedFiles/vst_apparentindividual.csv",
                     sep=",")
View(vegind)

parvar_veg <- read.delim("data/filesToStack10098/stackedFiles/variables.csv",
                         sep=",")
View(parvar_veg)

# Use the geoNEON package to calculate stem locations
# Gets (easting, northing) from (stemAzimuth, stemDistance)
names(vegmap)
vegmap_calc <- geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging")
names(vegmap_calc)[!(names(vegmap_calc) %in% names(vegmap))]

# And now merge the mapping data with the individual measurements. 
# individualID is the linking variable, the others are included to 
# avoid having duplicate columns.
veg <- merge(
  vegind, 
  vegmap_calc, 
  by = c("individualID","namedLocation",
         "domainID","siteID","plotID")
)

# Map the stems in plot 85
symbols(
  x = veg$adjEasting[which(veg$plotID=="WREF_085")], 
  y = veg$adjNorthing[which(veg$plotID=="WREF_085")], 
  circles = veg$stemDiameter[which(veg$plotID=="WREF_085")]/100, # radius, /100 to convert cm to m
  xlab = "Easting", 
  ylab = "Northing", 
  inches = FALSE
)

# Rasterize and plot Lidar data (chm = canopy height model)
chm <- raster("data/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
plot(chm, col=topo.colors(6))


# Extract raster values at specified coordinates (vegmap_calc$adjNorthing, vegmap_calc$adjEasting)
veg %>%
  select(adjNorthing, adjEasting) %>%
  filter(!is.na(adjNorthing), !is.na(adjEasting)) ->
  temp
class(temp) # this goes from data.frame object...
coordinates(temp) <- ~adjEasting + adjNorthing
class(temp) # ... to SpatialPoints object

# Assign coordinate reference to SpatialPoints based on canopy height model
SpatialPoints(coords = temp, proj4string = crs(chm)) ->
  sp

# Extract heights from canopy model at specified SpatialPoints
raster_heights <- raster::extract(chm, sp)
head(raster_heights)

veg %>%
  filter(!is.na(adjNorthing), !is.na(adjEasting)) %>%
  cbind(raster_heights) ->
  veg_compare

ggplot(
  veg_compare,
  aes(x=height, y=raster_heights)
  ) +
  geom_point() +
  theme_bw() +
  geom_abline(a=0,b=1,linetype=3)


# 3D plot comparing modeled and measured canopy heights
library(plotly)
library(tidyr)
veg_compare %>%
  select(adjNorthing, adjEasting, height, raster_heights) %>%
  rename(model_height = raster_heights,
         measured_height = height) %>%
  gather(key = "key", value = "value", model_height:measured_height) -> veg_compare_long

p <- plot_ly(
  veg_compare_long, 
  x = ~adjEasting, 
  y = ~adjNorthing, 
  z = ~value, 
  color = ~key, 
  colors = c('#BF382A', '#0C4B8E'),
  size=1,
  alpha=0.5
) %>%
  add_markers() %>%
  layout(scene = list(xaxis = list(title = 'Easting'),
                      yaxis = list(title = 'Northing'),
                      zaxis = list(title = 'Height (m)')))
