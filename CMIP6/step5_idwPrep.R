# preprocessing for interpolation 

library(magrittr)
library(sp)
library(raster)
library(sf)


rs_exp <- function(rs, output_path){
  dt <- as.data.frame(rs, xy=T) %>%
    .[complete.cases(.),]
  colnames(dt)[3] <- "value"
  
  # expand data
  right <- subset(dt, x >= 175.5)
  left <- subset(dt, x <= -175.5)
  right$x <- right$x - 360
  left$x <- left$x + 360
  newdt <- rbind(dt, left, right)
  
  # convert to point
  rs.sf <- st_as_sf(dt, coords = c('x','y'), crs=4326)
  st_write(rs.sf, output_path)
}

setwd('')
for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  from_dir <- paste0("thetao_smooth/", h)
  to_dir <- paste0("thetao_exp2p/", h)
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    files <- list.files(paste0(from_dir,'/',s), pattern = '*.tif$')
    for (f in files){
      fname <- strsplit(f,'.tif')[[1]]
      output_path <- paste0(to_dir,'/',s,'/',fname,'.shp')
      input_path <- paste0(from_dir,'/',s,'/',f)
      raster(input_path) %>%
        rs_exp(., output_path)
    }
    print(paste0(s, ': ', f, ' complete'))
  }
  print(paste0(h, ': complete ----'))
}

