# Names: Alex Wright, Erin Larson, and Wynne Moss
# Date: 9 Nov 2018
# Description: Team exercise to compare the veg structure and canopy height 

dir <- getwd()
dirPaste <- paste(dir,'/AWE_Day2_Exercise', sep = "")

#########
## PART - Setting up the example
#########

##
#### INSTALL PACKAGES
##
install.packages('raster')
#Library
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)


vegobs <- read.csv("AWE_Day2_Exercise/vegmerge.csv")

vegraster <- raster("data/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")


##
#### reading in merged veg data
merged.veg <- read.delim("vegmerge.csv", sep=",")


