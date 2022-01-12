library(sf)
library(raster)
library(magrittr)

setwd('')

#####
# reclassification of HI/CI/temperature
# set HI as an example

files <- list.files('hi', recursive = T, full.names = T)
for (f in files){
  
  dt <- raster(f) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
  colnames(dt)[3] <- 'val'
  # reclassify by quantiles
  ## for value == 0
  ## extract class 1, termed as 0
  dt1 <- dt[which(dt$val == 0),]
  dt1$rank <- 0 
  
  ## for value != 0
  ## divide by quantile, termed as 1-4
  dt2 <- dt[which(dt$val != 0),]  
  ## order by value
  dt2 <- dt2[order(dt2$val),]
  dt2$rank <- 1   ## class 2
  dt2[((nrow(dt2)/4)+1):(nrow(dt2)/2),4] <- 2   ## class 3
  dt2[((nrow(dt2)/2)+1):(nrow(dt2)*3/4),4] <- 3   ## class 4
  dt2[((nrow(dt2)*3/4)+1):(nrow(dt2)),4] <- 4   ## class 5
  
  # combine together
  dt_all <- rbind(dt1, dt2)
  
  # rasterize
  rs.sf <- st_as_sf(dt_all, coords = c('x','y'), crs=4326)
  rs.sp <- as(rs.sf, "Spatial")
  rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1),
               ext = extent(c(-180, 180, -90, 90))) %>%
    rasterize(rs.sp, ., field='rank', fun='first')
  writeRaster(rs, '', overwrite=T)

}



#####
# divide patches by overlapping all three reclassified rasters

for (depth in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  for (scen in c('present','ssp126','ssp245','ssp370','ssp585')){
    if (scen == 'present'){
      # for present data
      ## import reclassified data
      T_r <- raster(paste0('temp_reclass/',depth,'/temp_',depth,'_present_reclass.tif'))
      HI_r <- raster(paste0('hi_reclass/',depth,'/hi_',depth,'_present_reclass.tif'))
      CI_r <- raster(paste0('ci_reclass/',depth,'/ci_',depth,'_present_reclass.tif'))
      ## overlap the three (at three different digits)
      patch_r <- T_r * 100 + CI_r * 10 + HI_r
      ## output raster
      writeRaster(patch_r, '')
    }else{
      # for future data
      for (yr in c(2030,2040,2050)){
        ## import reclassified data
        T_r <- raster(paste0('temp_reclass/',depth,'/',scen,'/temp_',depth,'_',scen,'_',yr,'.tif'))
        HI_r <- raster(paste0('hi_reclass/',depth,'/',scen,'/hi_',depth,'_',scen,'_',yr,'.tif'))
        CI_r <- raster(paste0('ci_reclass/',depth,'/',scen,'/ci_',depth,'_',scen,'_',yr,'.tif'))
        ## overlap the three (at three different digits)
        patch_r <- T_r * 100 + CI_r * 10 + HI_r
        ## output raster
        writeRaster(patch_r, '')
      }
    }
  }
}


