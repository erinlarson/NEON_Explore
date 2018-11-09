# Explore NEON Workshop
# Part 1: Morning of November 8, 2018

# Follows this webpage https://www.neonscience.org/download-explore-neon-data

library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)

options(stringsAsFacors = FALSE)

setwd("~/Documents/NEON Workshop 2018/NEON Data")

# Photosynthetically active radiation (PAR) data for Abby Road and 
# Wind River Experimental Forest (WREF)

# Stack data from portal (only needs to happen once for a dataset, not for each run)
stackByTable("NEON_par.zip")
# Without this step, NEON data is difficult to use

# Download new data with zipsByProduct() (wrapper to the API)
# Download woody vegetation data from WREF
zipsByProduct(
  dpID = "DP1.10098.001", # dpID = data product ID
  site = "WREF",
  package = "expanded",
  check.size = TRUE, # interrupts workflow, so set FALSE for batch processes
  # savepath = "~/Downloads"
  )

# Now stack this data
stackByTable("filesToStack10098", folder = TRUE)

# Retrieve AOP (aerial observational platform) data
# Spatial resolution: 1m x 1m (or 10cm x 10cm for Lidar)
# Can download "by file" (usu. bigger) or "by tile" (usu. smaller)
byTileAOP(
  dpID = "DP3.30015.001",
  site = "WREF",
  year = "2017",
  easting = 580000, # can take vector as well
  northing = 5075000, # can take vector as well
  # savepath = "~/Downloads"
)




# Load PAR data
par30 <- read.delim("NEON_par/stackedFiles/PARPAR_30min.csv", sep=",")
View(par30)

# Load variables (metadata) table
parvar <- read.delim("NEON_par/stackedFiles/variables.csv", sep=",")
View(parvar)

# Convert time series data to R-readable
par30$startDateTime <- as.POSIXct(par30$startDateTime,
                                  format = "%Y-%m-%d T %H:%M:%S Z",
                                  tz = "GMT")
head(par30)

# Plot data
plot(
  PARMean ~ startDateTime,
  data = par30[which(par30$verticalPosition == 80),],
  type = 'l'
)

# Load vegetation structure data
vegmap <- read.delim("filesToStack10098/stackedFiles/vst_mappingandtagging.csv",
                     sep=",")
View(vegmap)

vegind <- read.delim("filesToStack10098/stackedFiles/vst_apparentindividual.csv",
                     sep=",")
View(vegind)

parvar_veg <- read.delim("filesToStack10098/stackedFiles/variables.csv",
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



# Rasterize and plot Lidar data
chm <- raster("DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
plot(chm, col=topo.colors(6))
plot(chm)
