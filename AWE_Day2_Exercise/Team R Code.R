# Names: Alex Wright, Erin Larson, and Wynne Moss
# Date: 9 Nov 2018
# Description: Team exercise to compare the veg structure and canopy height 


#########
## PART - Setting up the example
#########

##
#### INSTALL PACKAGES
##

#Library
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)


vegobs <- read.csv("AWE_Day2_Exercise/vegmerge.csv")
str(vegobs)
vegraster <- raster("data/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")


#### reading in merged veg data
# merged.veg <- read.delim("vegmerge.csv", sep=",")

str(vegobs)
vegobs$canopyPosition

# extract function to get the RASTER values from the tile for specific tree locations
# tree locatons are in vegobs
# we have more tree locatios than we do raster values, so we need to subset tree locations

?extract
myextent <- extent(vegraster)
str(myextent)
vegobs <- subset(vegobs, adjNorthing > 5075000 & adjNorthing < 5076000 & adjEasting >  580000 & adjEasting < 581000)
vegobslocs <- c(vegobs$adjNorthing, vegobs$adjEasting)
nrow(vegobs)

rasterCanValues <- raster::extract(vegraster, y = vegobs)
