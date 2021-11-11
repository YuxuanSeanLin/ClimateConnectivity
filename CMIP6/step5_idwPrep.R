library(magrittr)
library(sp)
library(raster)
library(sf)


# ==============================
# expand extent by several degrees
# preprocessing for interpolation 


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

setwd('')
for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  from_dir <- paste0("6_data_smooth/", h)
  to_dir <- paste0("7_data_expand_itp/", h)
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    files <- list.files(paste0(from_dir,'/',s), pattern = '*.tif$')
    for (f in files){
      output_path <- paste0(to_dir,'/',s,'/',f)
      input_path <- paste0(from_dir,'/',s,'/',f)
      raster(input_path) %>%
        rs_exp(., output_path)
    }
    print(paste0(s, ': ', f, ' complete'))
  }
  print(paste0(h, ': complete ----'))
}



# ==============================
# convert raster to point
# preprocessing for interpolation 


setwd('')
for (depth in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (scen in list.files(paste0('7_data_expand_itp/',depth))){
    for (f in list.files(paste0('7_data_expand_itp/',depth,'/',scen))){
      fromdir <- paste0('7_data_expand_itp/',depth,'/',scen,'/',f)
      rs <- raster(fromdir) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
      colnames(rs)[3] <- 'value'
      fname <- strsplit(f,'.tif')[[1]]
      
      # convert to point
      rs.sf <- st_as_sf(rs, coords = c('x','y'), crs=4326)
      st_write(rs.sf, paste0('8_rs2point/',depth,'/',scen,'/',fname,'.shp'))
    }
    print(paste0(depth,'-',scen,': complete'))
  }
}

