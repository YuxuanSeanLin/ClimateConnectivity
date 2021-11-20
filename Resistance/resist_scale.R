library(raster)


setwd('D:/Users/Yuxuan Lin/Documents/LocalFiles/XMU/Connectivity/Linkage/resistance')

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  files <- list.files(paste0('hi_regression/',h), full.names = T, pattern = '*.tif$', recursive = T)
  for (f in files){
    rs <- raster(f)
    for (s in c(10,25,50,100,200)){
      fname <- paste0('resist_',h,'_',strsplit(names(rs),'_')[[1]][2],'_scale_',s,'.tif')
      toPath <- paste0('resist_scales/scale_',s,'/',h,'/',fname)
      newrs <- rs / maxValue(rs) * (s - 1) + 1 
      writeRaster(newrs, toPath, overwrite=T)
    }
    print(paste0('complete: ',f))
  }
}


