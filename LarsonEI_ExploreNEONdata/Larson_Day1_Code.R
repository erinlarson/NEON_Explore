## NEON workshop DAY 1 ##
#########################
## Nov 8, 2018
# Accessing NEON data and Using neonUtilities
# this routine is also available as a tutorial on NEON science 
# (neonscience.org/download-explore-neon-data)


## Downloading and attaching packages needed for NEON workshop
# uncomment to install
#install.packages("raster")
#install.packages("neonUtilities")
#install.packages("devtools")
#source("http://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
#library(devtools)
#install_github("NEONScience/NEON-geolocation/geoNEON")

##NEON WORKSHOP DAY 1
## Getting set up
require(raster)
require(neonUtilities)
require(devtools)
require(rhdf5)
require(geoNEON)

options(stringsAsFactors=F)

# stack data from portal - helps merge month files
# here we're using PAR data we downloaded manually from the Data Portal from two sites and two months
stackByTable("NEON_par.zip") # replace with your own filepath as needed

# download data with zipsByProduct()
# this lets you download data through scripts, rather than manually online
# downside is you get less info about data products this way
zipsByProduct(dpID="DP1.10098.001", site="WREF", package="expanded", check.size=T,
              savepath="~/Downloads") 
# check size means you have to answer y/n about downloading file 
# if you're running other code afterwards, you might want to change check.size to F

# stack data we just downloaded
stackByTable("~/Downloads/filesToStack10098/", folder=T)

# download AOP data
# downloading data by spatial tiles - you can also put in vectors for easting & northing
byTileAOP(dpID="DP3.30015.001", site="WREF", year="2017",
          easting=580000, northing=5075000, savepath="~/Downloads")

# load par data - read.delim seems more stable than read.csv (?) 
# doesn't truncate if rows have different number of columns 
# NAs entered as blanks (sometimes - they don't have a consistent NA)
par30<-read.delim("~/Downloads/NEON_par/stackedFiles/PARPAR_1min.csv", sep=",")
View(par30)

# looking at variables available in data product
# one variables file per data product 
# (so you might see variables here that aren't in the basic dataset, but are in extended)
parvar<-read.delim("~/Downloads/NEON_par/stackedFiles/variables.csv", sep=",")
View(parvar)

# converting time to plot time series
# all NEON products come in UTC to standardize, not local time
par30$startDateTime <- as.POSIXct(par30$startDateTime, format="%Y-%m-%d T %H:%M:%S Z", 
                                  tz="GMT")
head(par30)

plot(PARMean~startDateTime, data=par30[which(par30$verticalPosition==80),], 
     type="l")

# veg structure data - reading in data
vegmap <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_mappingandtagging.csv",
                     sep=",")
View(vegmap)

# individual vegetation data - reading in data
vegind <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_apparentindividual.csv", 
                     sep=",")
View(vegind)

## geoNEON helps you spatially reference data
# observation data don't come automatically with spatial location data
vegmap<-geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging")

# making a stem map - first we need to merge datasets
veg <- merge(vegind, vegmap, by=c("individualID", "namedLocation",
                                  "domainID", "siteID", "plotID"))
symbols(veg$adjEasting[which(veg$plotID=="WREF_085")],
        veg$adjNorthing[which(veg$plotID=="WREF_085")],
        circles=veg$stemDiameter[which(veg$plotID=="WREF_085")]/100,
        xlab="Easting", ylab="Northing", inches=F)

# AOP data - mapping canopy height
# this data is already highly processed LIDAR data
chm <- raster("~/Downloads/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
plot(chm, col=topo.colors(6))
