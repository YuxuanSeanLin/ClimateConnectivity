library(magrittr)
library(dplyr)
library(raster)
library(sf)

setwd('')

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  ## load seascape boundary
  mask_r <- raster(paste0('Seascape_boundaries/',h,'.tif'))
  
  ## import canvas (180*360 raster, value=0)
  canvas_richness <- raster('canvas.tif')
  
  ## list of all species (read recursively)
  spelist <- list.files(paste0('SpeciesDistribution/',h), 
                        full.names = T, recursive = T, pattern = '.tif$')
  
  for (spe in spelist){
    ## load connectivity and CI
    species <- raster(spe)
    
    ## sum all
    canvas_richness <- sum(canvas_richness, species, na.rm = T)
    
    print(paste0('----Complete: ',h,'-',strsplit(spe,'/')[[1]][3],
                 '-',strsplit(spe,'/')[[1]][4],'----'))
  }
  
  ## extract canvas by mask (boundary)
  canvas_richness_r <- mask(canvas_richness, mask_r)
  
  ## export data
  writeRaster(canvas_richness_r, paste0('Richness/Richness_',h,'.tif'), overwrite = TRUE)
  print(paste0('----Complete: ',h,'----'))
  
}

