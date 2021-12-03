library(raster)
library(magrittr)

setwd('')

# clip by hemisphere in preparation for equidistant projection
# set resistance as example
for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (f in list.files(paste0('resistance/',h), full.names = T, recursive = T)){
    rs <- raster(f)
    fname <- names(rs)
    # northern
    crop(rs, extent(-180, 180, -10, 90)) %>% 
      writeRaster(., paste0('Batch/N_hemi/Resistance/',h,'/',fname,'.tif'))
    # southern
    crop(rs, extent(-180, 180, -90, 10)) %>% 
      writeRaster(., paste0('Batch/S_hemi/Resistance/',h,'/',fname,'.tif'))
  }
}

