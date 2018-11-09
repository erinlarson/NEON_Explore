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

##
#### DOWNLOAD & STACK DATA (veg structure and canopy height)
##

# download observational data with zipsByProduct()
#Only have to do this step once (the first time you work the data)
zipsByProduct(dpID = "DP1.10098.001", 
              site = 'WREF', #site = all for all sites
              package = 'expanded', 
              check.size = T, # turn to false when using a continious workflow
              savepath = "C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON")  
# now stack downloaded data
stackByTable("C:/Users/Al/Files/PHD/25_AUG_2016/ProjectManagement/NEON/filesToStack10098/", folder = T)


