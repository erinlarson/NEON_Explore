######## Set Up ###########

# load packages
library(neonUtilities)
library(geoNEON)
library(raster)
library(rhdf5)

# strings as factors
options(stringsAsFactors = F)

#### Accessing Data ######

# stack data from downloaded from portal 
stackByTable("~/Downloads/NEON_par.zip")

## Access OS/IS data

# download data directly
zipsByProduct(dpID="DP1.10098.001", 
							site="WREF", 
							package="expanded", 
							check.size=T, 
							savepath="~/Downloads")

# stack data from zipsByProduct
stackByTable("~/Downloads/filesToStack10098/", folder=T)


### Access AOP data
byTileAOP(dpID="DP3.30015.001", site="WREF", year="2017",
					easting=580000, northing=5075000, # any E/N in the tile
					savepath="~/Downloads/")

##### Exploring Data ######

### Explore IS Data (Exmaple: Photosynthetically Active Radiation) 

# load PAR
par30 <- read.delim("~/Downloads/NEON_par/stackedFiles/PARPAR_30min.csv", 
										sep=",")
View(par30)

# Explore PAR variables
parVar <- read.delim("~/Downloads/NEON_par/stackedFiles/variables.csv", sep=",")
View(parVar)

# Convert Time into a TimeDate format
par30$startDateTime <- as.POSIXct(par30$startDateTime, 
																	format="%Y-%m-%d T %H:%M:%S Z",
																	tz="GMT")

# Plot PAR 
plot(PARMean~startDateTime, 
		 data=par30[which(par30$verticalPosition==80),],
		 type="l")

## Explore OS Data (Example: Veg Structure)

# Validation File 
# Not explored in R. See the "rules" used to ensure reliability of the entered
# data. Min and Max of the sizes and other constraints. 

# Read mappingandtagging table
vegmap <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_mappingandtagging.csv", sep = ",")

View(vegmap)

# Read apparentindividuals table
vegind <- read.delim("~/Downloads/filesToStack10098/stackedFiles/vst_apparentindividual.csv", sep = ",")

###### Location Data ############

# get individual location of each tree
# exactly what happens for this depends on each protocol
# find out more in the user guide for each data product
vegmap <- geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging")
# warnings are not shown and are usually the result of blanks in the data. 

str(vegmap)
# note the added columns at the end (after `dataQF`). 

# merge the two tables of interest
veg <- merge(vegind, vegmap, 
						 by=c("individualID", "namedLocation", "domainID", "siteID", "plotID"))

# map the trees for a single plot
symbols(veg$adjEasting[which(veg$plotID=="WREF_085")], # plot only the WREF_085 plot
				veg$adjNorthing[which(veg$plotID=="WREF_085")],
				circles = veg$stemDiameter[which(veg$plotID=="WREF_085")]/100,
				xlab="Easting", ylab="Northing", inches=F)

#### View AOP CHM #####

# read in CHM file 
# lots of subfolders so using tab complete in RStudio is nice
chm <- raster("~/Downloads/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")

# plot CHM
plot(chm, col=topo.colors(6))