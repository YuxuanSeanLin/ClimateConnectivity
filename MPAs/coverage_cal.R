library(raster)
library(magrittr)

setwd('D:/Users/Yuxuan Lin/Documents/LocalFiles/XMU/Connectivity/AquaMaps')

pcm <- raster('mpa_cover.tif')
cov_arr <- c()

# depth <- c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')
depth <- c('surface')
for (d in depth){
  for (phy in list.files(paste0('SpeciesDistribution/',d))){
    for (f in list.files(paste0('SpeciesDistribution/',d,'/',phy), 
                         full.names = T)){
      r <- raster(f)
      fname <- strsplit(strsplit(f, '.tif$')[[1]], '/')[[1]][4]
      
      # calculate species coverage within MPA
      p_cover <- mask(pcm, r)
      sum_cov <- sum(values(p_cover), na.rm=T)
      sum_cell <- sum(values(r), na.rm=T)
      cov <- sum_cov / sum_cell
      
      # create array
      cov_arr <- rbind(cov_arr, cbind(depth=d, phylum=phy, 
                                      species=fname, coverage=cov))
      
    }
    print(paste0(phy, ' - complete'))
  }
  as.data.frame(cov_arr) %>% 
    write.csv(., paste0('mpa_cover/species_cov/cov_',d,'.csv'))
}


