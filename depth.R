library(raster)
library(magrittr)

levmean <- function(x){mean(x,na.rm = T)}

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  
  from_dir <- paste0("J:/cmip6/data/thetao_depth/", h)
  to_dir <- paste0("J:/cmip6/data/thetao_dmean/", h)

  for (s in c('ssp245', 'ssp370', 'ssp585')){
    for (yr in 2051:2099){
      models <- list.files(paste0(from_dir,'/',s,'/',yr))
      for (m in models){
        to_path <- paste0(to_dir,'/',s,'/',yr)
        name <- paste0('thetao_',m,'_',s,'_',h,'_',yr,'.tif')
        
        # stack tif files
        if (length(list.files(paste0(from_dir,'/',s,'/',yr,'/',m))) > 0){
          tifs <- list.files(paste0(from_dir,'/',s,'/',yr,'/',m), 
                             full.names = T, pattern = '*.tif$', recursive = T) %>% 
            stack()
          # define mean calculation
          mean <- calc(tifs, levmean)
          flip(mean, direction = 'y') %>%
            writeRaster(., paste0(to_path,'/',name), overwrite=TRUE)
          
        }
      }
      print(paste0(yr, '-', s,'-',h,'-complete'))
    }
  }
}
