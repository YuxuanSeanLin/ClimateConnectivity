library(magrittr)
library(raster)
library(sf)


# ==============================
# average all among depth layers


levmean <- function(x){mean(x,na.rm = T)}

setwd('')
for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  
  from_dir <- paste0("thetao_depth/", h)
  to_dir <- paste0("thetao_dmean/", h)
  
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    for (yr in 2015:2100){
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



# ==============================
# average all among GCMs


modelmean <- function(dt, output_path){
  newdt <- c()
  interval <- c()
  
  for (i in 1:nrow(dt)){
    cell <- dt[i,3:ncol(dt)] %>% as.numeric(.)
    
    if (length(which(is.na(cell) == F)) == 0){next}
    else if (length(which(is.na(cell) == F)) >= 5){
      cell <- cell[which(is.na(cell) == F)]
      newmean <- cell[which(cell>=mean(cell)-2*sd(cell) & cell<=mean(cell)+2*sd(cell))] %>%
        mean(.)
      interval <- rbind(interval, cbind(dt[i,1:2], value=newmean))
      
    }
    else{
      cell <- cell[which(is.na(cell) == F)]
      newmean <- mean(cell)
      interval <- rbind(interval, cbind(dt[i,1:2], value=newmean))}
    
    if (i%%5000 == 0){
      newdt <- rbind(newdt, interval)
      interval <- c()
    }
  }
  newdt <- rbind(newdt, interval)
  # snap
  newdt$x <- newdt$x + 0.5
  newdt$y <- newdt$y - 1
  
  # rasterize
  rs.sf <- st_as_sf(newdt, coords = c('x','y'), crs=4326)
  rs.sp <- as(rs.sf, "Spatial") 
  rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), 
               ext = extent(c(-180, 180, -90, 90))) %>%
    rasterize(rs.sp, ., field='value', fun='first')  
  writeRaster(rs, output_path) 
  
}

setwd('')
for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  from_dir <- paste0("thetao_dmean/", h)
  to_dir <- paste0("thetao_mdmean/", h)
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    for (yr in 2015:2100){
      to_path <- paste0(to_dir,'/',s)
      name <- paste0('thetao_',h,'_',s,'_',yr,'.tif')
      
      dt <- list.files(paste0(from_dir,'/',s,'/',yr), full.names = T) %>% 
        stack() %>%
        as.data.frame(., xy=T)
      modelmean(dt, paste0(to_path,'/',name))
      
    }
    print(paste0(s, ': ', yr, ' complete'))
  }
  print(paste0(h, ': complete ----'))
}



# ==============================
# expand extent by 1 degree
# preprocessing for Moving Window 


rs_exp <- function(rs, output_path){
  dt <- as.data.frame(rs, xy=T) %>%
    .[complete.cases(.),]
  colnames(dt)[3] <- "value"
  
  # expand data
  right <- subset(dt, x >= 179.5)
  left <- subset(dt, x <= -179.5)
  right$x <- right$x - 360
  left$x <- left$x + 360
  newdt <- rbind(dt, left, right)
  
  # rasterize
  rs.sf <- st_as_sf(newdt, coords = c('x','y'), crs=4326)
  rs.sp <- as(rs.sf, "Spatial") 
  rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), 
               ext = extent(c(-181, 181, -90, 90))) %>%
    rasterize(rs.sp, ., field='value', fun='first')  
  writeRaster(rs, output_path) 
}

setwd('')
for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  from_dir <- paste0("thetao_mdmean/", h)
  to_dir <- paste0("thetao_expand/", h)
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    files <- list.files(paste0(from_dir,'/',s))
    for (f in files){
      output_path <- paste0(to_dir,'/',s,'/',f)
      input_path <- paste0(from_dir,'/',s,'/',f)
      raster(input_path) %>%
        rs_exp(., output_path)
      print(paste0(s, ': ', f, ' - complete'))
    }
  }
  print(paste0(h, ': complete ----'))
}


