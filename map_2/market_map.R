#Install necessary libraries if required
if(!require(readxl)){install.packages("readxl")}
library(readxl)
library(sf)
library(tidyverse)
library(spData)
library(readxl)

# Read the XLSX file
cwd <- '/Users/newmac/Documents/DSDM/Term_2/03_GIS/Assig_2' #Change the path
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

ggplot() +
  geom_sf(data = africa, fill = "khaki") +
  geom_point(data = coordinates_sf, x=longitude, y=latitude, size = 0.8)
