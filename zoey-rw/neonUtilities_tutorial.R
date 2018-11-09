rm(list=ls())
library(neonUtilities)
library(rhdf5)
library(raster)
library(geoNEON)

options(stringsAsFactors = F)

# stack PAR data that was downlaoded from portal
stackByTable("~/Downloads/NEON_par.zip")

# now using a different method: download data with zipsByProduct()
zipsByProduct(dpID = "DP1.10098.001", site="WREF", package = "expanded", 
              check.size = F, savepath="~/Downloads") # check.size is for interactive use

# stack this WREF data
stackByTable("~/Downloads/filesToStack10098", folder = T)

# Atmospheric Observation Platform (AOP) data is massive, more comprehensive data can be downloaded with a diff function
# download one tile of AOP data, could put a vector here instead of just one set of coordinates
# downloads the km x km tile that the coordinates fall into
# eastings/northings is similar to lat/lon but measured in meters (can convert from lat/lon)
byTileAOP(dpID = "DP3.30015.001", site = "WREF", year = "2017",
          easting=580000, northing=5075000, savepath = "~/Downloads")

# load PAR data
par30 <- read.delim("~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv", sep = ",")

# load PAR variables
parvar <- read.delim("~/Downloads/NEON_par/stackedFiles/variables.csv", sep=",")

# plot time series
par30$startDateTime <- as.POSIXct(par30$startDateTime, format="%Y-%m-%d T %H:%M:%S Z", tz="GMT")

# veiw time series of PAR over the two months of the download
plot(PARMean~startDateTime,
     data=par30[which(par30$verticalPosition==80),],
     type="l")

# viewing the veg structure download
# this observational data has a validation file
vegmap <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_mappingandtagging.csv",sep = ",")
View(vegmap)

# plot individual vegetation structures
vegind <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_apparentindividual.csv",sep = ",")
View(vegind)

# get spatial data
vegmap <- geoNEON::def.calc.geo.os(vegmap,"vst_mappingandtagging")

veg <- merge(vegind, vegmap, by = c("individualID", "namedLocation", 
                                    "domainID", "siteID", "plotID"))

# stem diameter is divided by 100 bc of unit issues - can learn this sort of thing from the variables file
symbols(veg$adjEasting[which(veg$plotID=="WREF_085")],
        veg$adjNorthing[which(veg$plotID=="WREF_085")],
        circles=veg$stemDiameter[which(veg$plotID=="WREF_085")]/100,
        xlab="Easting", ylab="Northing", inches=F)

dev.off()
# AOP data
chm <- raster("~/Downloads/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")

plot(chm, col=topo.colors(6))



