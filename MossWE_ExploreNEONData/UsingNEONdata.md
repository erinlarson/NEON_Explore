Stacking data downloaded from NEON
==================================

Previously, we downloaded June July PAR from NEON's web interface. All data are in month by site files. Function `stackByTable` will merge files.

``` r
stackByTable("NEON_par.zip")

# if already unzipped
stackByTable("NEON_par", folder = T)
```

Stack will unzip, will merge all the same file types (all 1 mins together, all 30 mins together)

Download observational data using NEON utilities
================================================

Function `zipsByProduct` uses the NEON API.

``` r
zipsByProduct(dpID = "DP1.10098.001", # woody veg structure data
              site = "WREF", # could put in site = "all" to get all sites
               package = "expanded",
               check.size = TRUE, # turn to F if you're using a workflow
               savepath = "/Users/wynnemoss/PhD life/Projects and Data/NEON/ExploreNEON") # use current wd

stackByTable("filesToStack10098", folder = T)
```

Downloading Remote Sensing data
===============================

This is AOP data. The argument `byFile` = downloads everything available for a given data product by site by year (can be way too big). Argument `byTile` is to download just a specific tile based on coordinates.

``` r
byTileAOP(dpID = "DP3.30015.001", #canopy height data
          site = "WREF", year = "2017",
          easting = 580000, northing = 5075000
          ) # UTM coordinates (just need to fall within that tile), could put a vector for multiple
```

This example downloads just a patch from the mosaic. In practice, figure out the coordinates of the plot you care about and put them in this script.

Working with PAR data
=====================

Read in the stacked data:

``` r
par30 <- read.delim("NEON_par/stackedFiles/PARPAR_30min.csv", sep = ",") #tab will help
# View(par30)
str(par30)
```

    ## 'data.frame':    36144 obs. of  22 variables:
    ##  $ domainID          : chr  "D16" "D16" "D16" "D16" ...
    ##  $ siteID            : chr  "ABBY" "ABBY" "ABBY" "ABBY" ...
    ##  $ horizontalPosition: int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ verticalPosition  : int  10 10 10 10 10 10 10 10 10 10 ...
    ##  $ startDateTime     : chr  "2018-06-01T00:00:00Z" "2018-06-01T00:30:00Z" "2018-06-01T01:00:00Z" "2018-06-01T01:30:00Z" ...
    ##  $ endDateTime       : chr  "2018-06-01T00:30:00Z" "2018-06-01T01:00:00Z" "2018-06-01T01:30:00Z" "2018-06-01T02:00:00Z" ...
    ##  $ PARMean           : num  27.66 9.88 9.56 5.9 4.17 ...
    ##  $ PARMinimum        : num  15.65 6.71 7.8 4.62 1.74 ...
    ##  $ PARMaximum        : num  37.65 16.3 11.55 8.4 6.87 ...
    ##  $ PARVariance       : num  27.37 5.8 0.36 0.42 1.44 ...
    ##  $ PARNumPts         : int  1800 1800 1800 1800 1800 1800 1800 1800 1800 1800 ...
    ##  $ PARExpUncert      : num  1.2 0.52 0.37 0.28 0.24 0.11 0.2 0.1 0.09 0.09 ...
    ##  $ PARStdErMean      : num  0.12 0.06 0.01 0.02 0.03 0.01 0.03 0.01 0 0 ...
    ##  $ PARFinalQF        : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ outPARMean        : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARMinimum     : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARMaximum     : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARVariance    : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARNumPts      : int  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARExpUncert   : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARStdErMean   : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARFinalQF     : int  NA NA NA NA NA NA NA NA NA NA ...

The first four columns are added by stack by table. Each file was separated by these four columns (we used to have one for each position)

Read in the variables file to see metadata:

``` r
parvar <- read.delim("NEON_par/stackedFiles/variables.csv", sep = ",")
# View(parvar)
```

All NEON times are in UTC formatting (GMT). We need to tell R that this is a date and what kind of formatting it is.

``` r
par30$startDateTime <- as.POSIXct(par30$startDateTime, 
                                  format = "%Y-%m-%d T %H:%M:%S Z",
                                  tz = "GMT")
str(par30)
```

    ## 'data.frame':    36144 obs. of  22 variables:
    ##  $ domainID          : chr  "D16" "D16" "D16" "D16" ...
    ##  $ siteID            : chr  "ABBY" "ABBY" "ABBY" "ABBY" ...
    ##  $ horizontalPosition: int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ verticalPosition  : int  10 10 10 10 10 10 10 10 10 10 ...
    ##  $ startDateTime     : POSIXct, format: "2018-06-01 00:00:00" "2018-06-01 00:30:00" ...
    ##  $ endDateTime       : chr  "2018-06-01T00:30:00Z" "2018-06-01T01:00:00Z" "2018-06-01T01:30:00Z" "2018-06-01T02:00:00Z" ...
    ##  $ PARMean           : num  27.66 9.88 9.56 5.9 4.17 ...
    ##  $ PARMinimum        : num  15.65 6.71 7.8 4.62 1.74 ...
    ##  $ PARMaximum        : num  37.65 16.3 11.55 8.4 6.87 ...
    ##  $ PARVariance       : num  27.37 5.8 0.36 0.42 1.44 ...
    ##  $ PARNumPts         : int  1800 1800 1800 1800 1800 1800 1800 1800 1800 1800 ...
    ##  $ PARExpUncert      : num  1.2 0.52 0.37 0.28 0.24 0.11 0.2 0.1 0.09 0.09 ...
    ##  $ PARStdErMean      : num  0.12 0.06 0.01 0.02 0.03 0.01 0.03 0.01 0 0 ...
    ##  $ PARFinalQF        : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ outPARMean        : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARMinimum     : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARMaximum     : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARVariance    : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARNumPts      : int  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARExpUncert   : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARStdErMean   : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ outPARFinalQF     : int  NA NA NA NA NA NA NA NA NA NA ...

Time zone indicator is at the end. For more information, see help files for `striptime`. Once you do this, now you can convert to local time

Visualize the data:

``` r
plot(PARMean~startDateTime, 
     data = par30[which(par30$verticalPosition==80),],# this will only grab WR data because it's the highest tower position in the dataset
     type = "l", lwd = 1.5, col = "magenta") 
```

![](UsingNEONdata_files/figure-markdown_github/unnamed-chunk-7-1.png)

Working with vegetation structure data
======================================

This is observational data giving vegetative structure. Validation file gets at how the data were QCd

Next read in a file gives the ID and location of individual trees

Note: data QF legacy data are old observational data from paper datasheets

Getting locational data
=======================

Mapping and tagging data has plots but no actual locational data. `calc.geo` function calculates precise loations for specific observations.

``` r
vegmap <- geoNEON::def.calc.geo.os(vegmap, 
                                   "vst_mappingandtagging") # tell it what data it is
```

Data product user guides will help you figure out what data source to use. This function looks up the plot and the point within the plot and looks for the location. Takes NAmed Location + Point ID, and looks up that value. Then it gets a location for point id, then takes the stemlocation relative to point ID (because we have stem length and angle)

Now, let's join the two tables

``` r
veg <- merge(vegind, vegmap, by = c("individualID", "namedLocation", 
                                    "domainID", "siteID", "plotID"))
```

Plot the data:

``` r
symbols(veg$adjEasting[which(veg$plotID == "WREF_085")],
        veg$adjNorthing[which(veg$plotID == "WREF_085")],
        circles = veg$stemDiameter[which(veg$plotID == "WREF_085")]/100,
        xlab = "Easting", ylab = "Northing", inches = F, bg = "brown")
```

![](UsingNEONdata_files/figure-markdown_github/unnamed-chunk-12-1.png)

Using AOP files
===============

``` r
chm <- raster("DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
str(chm)
```

    ## Formal class 'RasterLayer' [package "raster"] with 12 slots
    ##   ..@ file    :Formal class '.RasterFile' [package "raster"] with 13 slots
    ##   .. .. ..@ name        : chr "/Users/wynnemoss/PhD life/Projects and Data/NEON/ExploreNEON/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/Dis"| __truncated__
    ##   .. .. ..@ datanotation: chr "FLT4S"
    ##   .. .. ..@ byteorder   : chr "little"
    ##   .. .. ..@ nodatavalue : num -Inf
    ##   .. .. ..@ NAchanged   : logi FALSE
    ##   .. .. ..@ nbands      : int 1
    ##   .. .. ..@ bandorder   : chr "BIL"
    ##   .. .. ..@ offset      : int 0
    ##   .. .. ..@ toptobottom : logi TRUE
    ##   .. .. ..@ blockrows   : int 1
    ##   .. .. ..@ blockcols   : int 1000
    ##   .. .. ..@ driver      : chr "gdal"
    ##   .. .. ..@ open        : logi FALSE
    ##   ..@ data    :Formal class '.SingleLayerData' [package "raster"] with 13 slots
    ##   .. .. ..@ values    : logi(0) 
    ##   .. .. ..@ offset    : num 0
    ##   .. .. ..@ gain      : num 1
    ##   .. .. ..@ inmemory  : logi FALSE
    ##   .. .. ..@ fromdisk  : logi TRUE
    ##   .. .. ..@ isfactor  : logi FALSE
    ##   .. .. ..@ attributes: list()
    ##   .. .. ..@ haveminmax: logi TRUE
    ##   .. .. ..@ min       : num 0
    ##   .. .. ..@ max       : num 65.7
    ##   .. .. ..@ band      : int 1
    ##   .. .. ..@ unit      : chr ""
    ##   .. .. ..@ names     : chr "NEON_D16_WREF_DP3_580000_5075000_CHM"
    ##   ..@ legend  :Formal class '.RasterLegend' [package "raster"] with 5 slots
    ##   .. .. ..@ type      : chr(0) 
    ##   .. .. ..@ values    : logi(0) 
    ##   .. .. ..@ color     : logi(0) 
    ##   .. .. ..@ names     : logi(0) 
    ##   .. .. ..@ colortable: logi(0) 
    ##   ..@ title   : chr(0) 
    ##   ..@ extent  :Formal class 'Extent' [package "raster"] with 4 slots
    ##   .. .. ..@ xmin: num 580000
    ##   .. .. ..@ xmax: num 581000
    ##   .. .. ..@ ymin: num 5075000
    ##   .. .. ..@ ymax: num 5076000
    ##   ..@ rotated : logi FALSE
    ##   ..@ rotation:Formal class '.Rotation' [package "raster"] with 2 slots
    ##   .. .. ..@ geotrans: num(0) 
    ##   .. .. ..@ transfun:function ()  
    ##   ..@ ncols   : int 1000
    ##   ..@ nrows   : int 1000
    ##   ..@ crs     :Formal class 'CRS' [package "sp"] with 1 slot
    ##   .. .. ..@ projargs: chr "+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
    ##   ..@ history : list()
    ##   ..@ z       : list()

``` r
plot(chm, col = topo.colors(6))
```

![](UsingNEONdata_files/figure-markdown_github/unnamed-chunk-13-1.png)
