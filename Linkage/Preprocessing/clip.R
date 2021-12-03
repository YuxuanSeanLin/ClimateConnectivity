library(raster)
library(magrittr)


setwd('D:/Users/Yuxuan Lin/Documents/LocalFiles/XMU/Connectivity/Linkage')

# temperature  # resistance
for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (f in list.files(paste0('resistance/resist_scales/scale_100/',h), full.names = T, recursive = T)){
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

