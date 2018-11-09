# Explore NEON Workshop
# Part II: Afternoon of November 8, 2018
# API Tutorial

library(httr)
library(jsonlite)
library(downloader)
library(dplyr)

# Task 1: Use /product endpoint to specify a data product to get all
# the URLs where that product is available
req <- GET("http://data.neonscience.org/api/v0/products/DP1.10003.001")
req
req_content <- content(req, as="parsed") # From httr package
req_content

content(req, as="text") %>%
  fromJSON(simplifyDataFrame = TRUE, flatten = TRUE) ->
  available

available$data$siteCodes
bird_urls <- unlist(available$data$siteCodes$availableDataUrls)
bird_urls

# Task 2: Use /data endpoint to see files from one site+date
bird <- GET(bird_urls[grep("WOOD/2015-07", bird_urls)])

content(bird, as="text") %>%
  fromJSON() ->
  bird_list
bird_list$data$files$name

# Task 3: Use /data endpoint to retrieve bird count data for "basic" level
bird_count <- read.delim(
  bird_list$data$files$url[
    intersect(
      grep("countdata", bird_list$data$files$name),
      grep("basic", bird_list$data$files$name) # to excluded "countdata...expanded"
    )
  ],
  sep=","
)

# Task 4: Use /taxonomy endpoint to get URLS where that taxon is available
GET("http://data.neonscience.org/api/v0/taxonomy/?family=Gaviidae") %>%
  content(as = "text") %>%
  fromJSON() ->
  loon_list

loon_list$data
