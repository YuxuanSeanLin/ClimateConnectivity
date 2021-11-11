# calculate well-protected proportion
# given threshold=0.1 (sensitivity test)

library(sf)
library(raster)
library(magrittr)
library(dplyr)

setwd('')
from_dir <- ''
to_dir <- ''
spelist <- read.csv('cov_leftjoin.csv')

for (d in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  # load total richness
  total_richness <- raster(paste0('Total_richness/richness_',d,'.tif'))
  
  # create attribute
  cover <- cbind(spelist, identify='Gap')

  # identify well-protected species
  for (i in 1:nrow(cover)){
    protect <- cover[i,3:6] %>% as.numeric() %>% mean(., na.rm = T)
    # given threshold=0.1
    if (protect > 0.1){cover[i,7] <- 'Well_protected'} 
  }

  # filter target species raster
  target <- subset(cover, identify=='Well_protected')
  row.names(target) <- seq.int(1,nrow(target))
  colnames(target)[1] <- 'phylum'

  # create Null raster
  a <- raster(crs = 4326, vals = 0, resolution = c(1, 1), 
              ext = extent(c(-180, 180, -90, 90)))

  # calculate total number of well-protected species
  for (j in which(is.na(target[,d])==F)){
    phy <- target[j,'phylum']
    spe <- target[j,'species']
    rs <- raster(paste0(from_dir,'/',d,'/',phy,'/',spe,'.tif'))
    a <- sum(a, rs, na.rm = T)
  }

  # calculate well-protected ratio
  dt <- stack(a, total_richness) %>% as.data.frame(., xy=T)
  colnames(dt)[3:4] <- c('Well_protected', 'overall')
  dt <- cbind(dt, wpratio=dt$Well_protected/dt$overall)

  # rasterize
  rs.sf <- st_as_sf(dt, coords = c('x','y'), crs=4326)
  rs.sp <- as(rs.sf, "Spatial") 
  rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), 
               ext = extent(c(-180, 180, -90, 90))) %>%
    rasterize(rs.sp, ., field='wpratio', fun='first')  

  # output
  writeRaster(rs, paste0(to_dir,'/wpp_',d,'.tif')))
}

