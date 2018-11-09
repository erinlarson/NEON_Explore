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

=======
##
#### reading in merged veg data
<<<<<<< HEAD
merged.veg <- read.delim("_Exercise⁩vegmerge.csv", sep=",")
=======
merged.veg <- read.delim("vegmerge.csv", sep=",")

>>>>>>> 9ad6f6a9700a4ab8b11eda2aa4466580ddf5de70
