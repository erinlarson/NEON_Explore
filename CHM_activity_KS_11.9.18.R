###ACTIVITY: NEON explore DAY 2
####measured height vs chm projected height:
library(raster)
library(ggplot2)

##
# ##getting our objects back cause r crashed
# vegmap <- read.delim("~/Desktop/NEONworkshopfiles-master/filesToStack10098/stackedFiles/vst_mappingandtagging.csv", stringsAsFactors=FALSE, sep=",")
# vegmap= geoNEON::def.calc.geo.os(vegmap, "vst_mappingandtagging") 
# 
# vegind <- read.delim("~/Desktop/NEONworkshopfiles-master/filesToStack10098/stackedFiles/vst_apparentindividual.csv", stringsAsFactors=FALSE, sep=",")
# veg=merge(vegind, vegmap, by=c("individualID","namedLocation","domainID","siteID","plotID"))


##do the thing

#isolate just ID, height, site, and coords for convenience
height=na.exclude(data.frame("ind"=veg$individualID,site=veg$plotID,"height"=veg$height,"east"=veg$adjEasting,"north"=veg$adjNorthing))

#extract matching raster values for coords
chm.h=extract(chm,height[,4:5])

#isolate just the single site that we looked at yesterday becuase we're not sure what the extent of the raster is
chm.h085=chm.h[height$site %in% "WREF_085"]

out=data.frame("measheight"=height$height[height$site %in% "WREF_085"],"projheight"=chm.h085)

##plot just the 26 in 085
out=data.frame("measheight"=height$height[height$site %in% "WREF_085"],"projheight"=chm.h085)
ggplot(out, aes(x=measheight, y=projheight)) + geom_point() + 
  geom_smooth(method='lm',formula=y~x)

##and plot all
out.full=data.frame("measured.height"=height$height,"projected.height"=chm.h)
ggplot(out.full, aes(x=measured.height, y=projected.height)) + geom_point() + 
  geom_smooth(method='lm',formula=y~x)

