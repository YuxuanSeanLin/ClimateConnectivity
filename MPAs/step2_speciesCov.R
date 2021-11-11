library(raster)
library(magrittr)

setwd('')
from_dir <- ''
to_dir <- ''

pcm <- raster('mpa_cover.tif')
cov_arr <- c()

for (d in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (phy in list.files(paste0(from_dir,'/',d))){
    for (f in list.files(paste0(from_dir,'/',d,'/',phy), full.names = T)){
      r <- raster(f)
      fname <- strsplit(strsplit(f, '.tif$')[[1]], '/')[[1]][4]
      
      # calculate species coverage within MPA
      p_cover <- mask(pcm, r)
      sum_cov <- sum(values(p_cover), na.rm=T)
      sum_cell <- sum(values(r), na.rm=T)
      cov <- sum_cov / sum_cell
      
      # save results
      cov_arr <- rbind(cov_arr, cbind(depth=d, phylum=phy, 
                                      species=fname, coverage=cov))
      
    }
    print(paste0(phy, ' - complete'))
  }
  # export
  as.data.frame(cov_arr) %>% 
    write.csv(., paste0(to_dir,'/cov_',d,'.csv'))
}


