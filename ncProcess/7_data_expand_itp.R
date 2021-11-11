library(magrittr)
library(raster)
library(sf)


# ==============================
# average all among depth layers


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
  
  # rasterize
  rs.sf <- st_as_sf(newdt, coords = c('x','y'), crs=4326)
  rs.sp <- as(rs.sf, "Spatial") 
  rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), 
               ext = extent(c(-185, 185, -90, 90))) %>%
    rasterize(rs.sp, ., field='value', fun='first')  
  writeRaster(rs, output_path, overwrite=T) 
}


# c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')
for (h in c('mesopelagic')){
  from_dir <- paste0("D:/Users/Yuxuan Lin/Documents/LocalFiles/6_data_smooth/", h)
  to_dir <- paste0("D:/Users/Yuxuan Lin/Documents/LocalFiles/7_data_expand_itp/", h)
  
  for (s in c('historical', 'ssp126', 'ssp245', 'ssp370', 'ssp585')){
    for (p in list.files(paste0(from_dir,'/', s))){
      files <- list.files(paste0(from_dir,'/',s,'/',p), pattern = '*.tif$')
      for (f in files){
        output_path <- paste0(to_dir,'/',s,'/',p,'/',f)
        input_path <- paste0(from_dir,'/',s,'/',p,'/',f)
        raster(input_path) %>%
          rs_exp(., output_path)
        
      }
      print(paste0(s, ': ', p, ' complete'))
    }
    
  }
  print(paste0(h, ': complete ----'))
}


