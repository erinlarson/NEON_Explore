
# USE NEONUTILITIES TO ACCESS & EXPLORE DATA - NOV 9, 2018 -----------------------------------------

setwd("C:/Users/cmcurrie/Documents/NEON")

library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)

options(stringsAsFactors=F)

# we picked a PAR file from ABBY and WREF sites
# PAR is a measure of what light is available for photosynthesis
# stack data from portal 
# stack by table stacks all 30 min files in one big file, etc. 
# groups by time resolution in this case

# for some reason couldn't read file path from DropBox, so made new NEON folder in Documents
stackByTable("~/NEON/NEON_par.zip")

# if unzipped: 
# stackByTable("~/NEON/NEON_par.zip", folder=T)

# download dat awith zipsByProduct()
# a wrapper from the NEON API
# for site=, I can put in site code or use "all" to get all sites
# include savepath= if saving to something other than current folder or director
zipsByProduct(dpID="DP1.10098.001", site="WREF", 
              package="expanded", check.size=T)

# use stack by table again to stack data that was just downloaded

stackByTable("~/NEON/filesToStack10098/", folder=T)

# download AOP data - remote sensing data, "Airborne Observation Platform"
# AOP data tile is a 1km x 1km data product,
# individual pixels are a 1m x 1m of canopy data (for hyperspectral and canopy height model)
# easting and northing are ETM coordinates: 
# in meters... distance from 0 lat and 0 long, for each zone
byTileAOP(dpID="DP3.30015.001", site="WREF", year="2017", 
          easting=580000, northing=5075000)

# load PAR data, 30 min file
# Claire uses read.delim instead of read.csv, seems to reduce errors 
par30 = read.delim("~/NEON/NEON_par/stackedFiles/PARPAR_30min.csv", sep=",")

# first 4 columns in par30 got added by stackByTable 
# all of the other columns are described by the variables file
parvar = read.delim("~/NEON/NEON_par/stackedFiles/variables.csv", sep=",")

# next, plot some of our data.. start with time series
# will need to format time into format that R likes
# all NEON data come with timestamps that are in UTC, so timezone is GMT...
# but can convert to local time after applying POSIX using 
# use strpTime for my data, don't need to for NEON

par30$startDateTime = as.POSIXct(par30$startDateTime, 
                                 format="%Y-%m-%d T %H:%M:%S Z", 
                                 tz="GMT")
head(par30)

# plot mean par at highest tower level
# subset by data at the very top of the tower
# type = "l" means line plot
plot(PARMean~startDateTime,
     data=par30[which(par30$verticalPosition==80),],
     type="l")
# gaps are just because there hasn't been continuous data at this tower

# read in mapping and tagging table
# veg structure data
vegmap=read.delim("~/NEON/filesToStack10098/stackedFiles/vst_mappingandtagging.csv",
                  sep=",")
# dataQF gives us quality flags
# a lot of the observational data are dates without times - times are usually set to noon local time
# use variables file to get more information about each column

# want identification and location of individual trees, load in individual table
vegind=read.delim("~/NEON/filesToStack10098/stackedFiles/vst_apparentindividual.csv",
                  sep=",")
# some columns in common between vegin and vegmap. 
# dataQF: if there is a mark "legacyData", means that data were collected before mobile apps
# data were therefore collected on paper sheets. 

# NOTE: bug in stackByFile that needs to be fixed - the readME files get lost... 

# now let's get into location data
# we will use geoNEON for this - have to install from Github because not available on CRAN yet
# geoNEON provides functionality for spatial data around NEON data

# take veg mapping and tagging data - 
# looks up each point in each plot (takes NAME location and appends point ID), 
# geolocates each stem in the data in relation to each point ID, 
# and gives easting and northing exact location
vegmap=geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging")
# adds adjEasting and adjNorthing

# goal is to plot a stem map
# but stem diameters are in individuals table, not veg and mapping
# only column that is required for merging in this case is individualID
# but we include other column names to avoid duplicates and clean up the data
veg=merge(vegind, vegmap, by=c("individualID","namedLocation",
                               "domainID","siteID","plotID"))

symbols(veg$adjEasting[which(veg$plotID=="WREF_085")],
        veg$adjNorthing[which(veg$plotID=="WREF_085")],
        circles=veg$stemDiameter[which(veg$plotID=="WREF_085")]/100, 
        #divide by 100 to get units the same, get this info from variables file
        xlab="Easting", ylab="Northing", inches=F)

# last thing is to look at AOP tile that we downloaded using raster package
# use tab complete to get through all these nested files to that .tif file... 
chm=raster("~/NEON/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
plot(chm, col=topo.colors(6))
# topo.colors gives nice colors
# values are canopy height estimated from LIDAR

# tomorrow, take canopy height from this model and vegetation structure and see how they compare. 
# see Data Product User Guide on NEON's website from the NEON data portal: NEON.DP1.10098
# our example today was for trees, the user guide does have instructions on shrubs
# individual IDs are connected across data - ie., stem diameter and phenology for the same point have the same ID