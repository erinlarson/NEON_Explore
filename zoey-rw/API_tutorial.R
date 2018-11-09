##### API TUTORIAL #####
library(downloader)
library(httr)
library(jsonlite)

# first we go to the product endpoints to figure out which sites have data
req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")
req.content <- content(req, as="parsed")
available <- fromJSON(content(req, as="text"))

bird.urls <- unlist(available$data$siteCodes$availableDataUrls)
bird.urls

# now we can download data with the data endpoints
bird <- GET(bird.urls[grep("WOOD/2015-07", bird.urls)])
bird.files <- fromJSON(content(bird, as="text"))

bird.count <- read.delim(bird.files$data$files$url[intersect(grep("countdata", 
                                                                  bird.files$data$files$name),
                                                             grep("basic",
                                                                  bird.files$data$files$name))],
                         sep=',')

# download by taxon
loon.req <- GET("http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae")
loon.list <- fromJSON(content(loon.req, as="text"))
loon.list
