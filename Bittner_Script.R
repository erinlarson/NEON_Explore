#------------------------------------------#
#             NEON Workshop Day 1          #
#------------------------------------------#

# Load packages -----------------------------------------------------------
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)
# set option
options(stringsAsFactors = FALSE)

# PART 1 - DOWNLOADING DATA ----------------------------------------------

# METHOD 1 
# stack data from portal
stackByTable("/Users/admin/Desktop/NEON_DATA/NEON_par.zip")
stackByTable("/Users/admin/Desktop/NEON_DATA/NEON_par", folder = TRUE) #if unzipped

# METHOD 2 ---------------
# download data with zipsByProduct()
zipsByProduct(dpID = "DP1.10098.001", site = "WREF", 
              package = "expanded", check.size = TRUE,
              savepath="/Users/admin/Desktop/NEON_DATA")

# stack data from zipsByProduct
stackByTable("/Users/admin/Desktop/NEON_DATA/filesToStack10098", folder = TRUE)

# download AOP data
byTileAOP(dpID = "DP3.30015.001", site = "WREF", year = "2017", easting = 580000, northing = 5075000,
          savepath = "/Users/admin/Desktop/NEON_DATA/")

# PART 2 - WORKING WITH DATA ----------------------------------------------
#load par data
par30 <- read.delim("/Users/admin/Desktop/NEON_DATA/NEON_par/stackedFiles/PARPAR_30min.csv", sep = ",")
View(par30)

parvar <- read.delim("/Users/admin/Desktop/NEON_DATA/NEON_par/stackedFiles/variables.csv", sep = ",")
View(parvar)

par30$startDateTime <- as.POSIXct(par30$startDateTime, 
                                  format = "%Y-%m-%d T %H:%M:%S Z",
                                  tz = "GMT") # fix the date/time

head(par30)

plot(PARMean~startDateTime,
     data=par30[which(par30$verticalPosition==80),],
     type="l")

# veg structure data
vegmap <- read.delim("/Users/admin/Desktop/NEON_DATA/filesToStack10098/stackedFiles/vst_mappingandtagging.csv", sep = ",")
vegind <- read.delim("/Users/admin/Desktop/NEON_DATA/filesToStack10098/stackedFiles/vst_apparentindividual.csv", sep = ",")

# next 

vegmap <- geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging")

veg <- merge(vegind,vegmap, by = c("individualID", "namedLocation",
                                   "domainID", "siteID", "plotID"))

symbols(veg$adjEasting[which(veg$plotID=="WREF_085")],
        veg$adjNorthing[which(veg$plotID=="WREF_085")],
        circles=veg$stemDiameter[which(veg$plotID=="WREF_085")]/100,
        xlab="Easting", ylab="Northing", inches=FALSE)

# AOP Data
chm <- raster("/Users/admin/Desktop/NEON_DATA/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
plot(chm, col=topo.colors(6))



