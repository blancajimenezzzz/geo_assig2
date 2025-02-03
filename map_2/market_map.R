#Install necessary libraries if required
if(!require(readxl)){install.packages("readxl")}
library(readxl)
library(sf)         
library(tidyverse)
library(spData)     
library(readxl)   

# Read the XLSX file
cwd <- '/Users/newmac/Documents/DSDM/Term_2/03_GIS/Assig_2'
file_name <- 'data/MktCoords.xlsx'
file_path <- file.path(cwd, file_name)
print(file_path)
print(cwd)

# Load the data
data <- read_excel(file_path)

# Load the coordinates for market locations
latitude <- data$latitude
longitude <- data$longitude

# Create a simple feature (sf) object with WGS 84 projection:
coordinates_sf <- st_as_sf(data, coords = c("longitude", "latitude"), crs = 4326)

#Load the world map
sf.world <- world

#We filter to keep only African countries. We also noticed that the paper only looks at Sub-Saharan Africa,
# so we excluded Northern African countries. We excluded Madagascar, just like the authors. Also,
# the Republic of Sudan is attributed to Northern Africa in the world dataset, however,
# in the paper it's considered a part of sub-Saharan Africa. So we decided
# to include it to be able to replicate the paper's findings more closely.

africa <- subset(world, (continent == "Africa" & subregion != "Northern Africa" & name_long != "Madagascar") | name_long == "Sudan")

#Load the roads data from ArcGis (https://www.arcgis.com/home/item.html?id=ba1cf90a739f41f4b91b26441929918a&view=list&sortOrder=desc&sortField=defaultFSOrder#overview)
roads <- st_read('/Users/newmac/Documents/DSDM/Term_2/03_GIS/Assig_2/data/AFR_Infra_Transport_Road.shp/AFR_Infra_Transport_Road.shp')

#Filter road types to keep only primary and motorway, otherwise it looks too messy
roads_type <- c("Road (Primary)")
main_roads <- roads %>%
  filter(FeatureTyp %in% roads_type)

# Exclude countries from Nothern Africa
ssa_exceptions <- c("Algeria", "Egypt", "Morocco and Western Sahara", "Madagascar", "Tunisia", "Libya")
roads_ssa <- main_roads %>%
  filter(!Country %in% ssa_exceptions)

#Load airports data (https://ourairports.com/data/)
airports_csv <- read_csv('/Users/newmac/Documents/DSDM/Term_2/03_GIS/Assig_2/data/airports.csv')

#Transform to geometry
airports <- st_as_sf(airports_csv, coords = c("longitude_deg", "latitude_deg"), crs = 4326)

# Filter airports that fall within the polygons of africa dataset
points_within <- st_within(airports, africa)

# Convert the sparse matrix to a list of vectors
points_within_list <- lapply(points_within, function(x) if (length(x) == 0) NA_integer_ else x)

#Select points that are within the polygon
airports_africa <- airports[which(!is.na(points_within_list)), ]

# Filter out small and closed airports
big_airports <- c("medium_airport", "large_airport")
big_airports_africa <- airports_africa %>%
  filter(type %in% big_airports)

#Plot the data
ggplot() +
  # Layer 1: counrtries with boundaries
  geom_sf(data = africa, fill = "khaki") +
  # Layer 2: Roads
  geom_sf(data = roads_ssa, size = 0.1, color = 'orange', alpha = 0.4) +
  # Layer 3: Market locations
  geom_point(data = coordinates_sf, x=longitude, y=latitude, size = 0.8) +
  # Layer 2: Airports
  geom_sf(data = big_airports_africa, color = 'red', size = 0.8, shape = 3)
