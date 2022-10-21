library(magrittr)
library(raster)
library(sf)

setwd('')

# create folders
dir.create('thetao_depth')
dir.create('thetao_dmean')
dir.create('thetao_mdmean')
dir.create('thetao_expand')
dir.create('thetao_smooth')
dir.create('thetao_exp2p')
dir.create('thetao_idw')
dir.create('thetao_final')
for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  dir.create(paste0('thetao_depth/',h))
  dir.create(paste0('thetao_dmean/',h))
  dir.create(paste0('thetao_mdmean/',h))
  dir.create(paste0('thetao_expand/',h))
  dir.create(paste0('thetao_smooth/',h))
  dir.create(paste0('thetao_exp2p/',h))
  dir.create(paste0('thetao_idw/',h))
  dir.create(paste0('thetao_final/',h))
  for (s in c('ssp126', 'ssp245', 'ssp585')){
    dir.create(paste0('thetao_dmean/',h,'/',s))
    dir.create(paste0('thetao_mdmean/',h,'/',s))
    dir.create(paste0('thetao_expand/',h,'/',s))
    dir.create(paste0('thetao_smooth/',h,'/',s))
    dir.create(paste0('thetao_exp2p/',h,'/',s))
    dir.create(paste0('thetao_idw/',h,'/',s))
    dir.create(paste0('thetao_final/',h,'/',s))
    for (yr in c(2020:2050,2100)){
      dir.create(paste0('thetao_dmean/',h,'/',s,'/',yr))
    }
  }
}



# ###################################### #
# Step1: average all depths among layers #
# ###################################### #

levmean <- function(x){mean(x,na.rm = T)}

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  
  from_dir <- paste0("thetao_depth/", h)
  to_dir <- paste0("thetao_dmean/", h)
  
  for (s in c('ssp126', 'ssp245', 'ssp585')){
    for (yr in c(2020:2100)){
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





# ###################################### #
# Step2: average all among models (GCMs) #
# ###################################### #

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
    
    # batch calculation
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

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  from_dir <- paste0("thetao_dmean/", h)
  to_dir <- paste0("thetao_mdmean/", h)
  for (s in c('ssp126', 'ssp245', 'ssp585')){
    for (yr in c(2020:2100)){
      to_path <- paste0(to_dir,'/',s)
      name <- paste0('thetao_',h,'_',s,'_',yr,'.tif')
      
      dt <- list.files(paste0(from_dir,'/',s,'/',yr), pattern = '.tif$', full.names = T) %>% 
        stack() %>%
        as.data.frame(., xy=T)
      modelmean(dt, paste0(to_path,'/',name))
      
    }
    print(paste0(s, ': ', yr, ' complete'))
  }
  print(paste0(h, ': complete ----'))
}




# ############################################################################ #
# Step3: expand extent by 1 degree (preprocessing for Moving Window averaging) #
# ############################################################################ #

rs_exp <- function(rs, output_path){
  
  # expand raster
  rs1 <- crop(rs, extent(-180, -179, -90, 90))
  rs2 <- crop(rs, extent(179, 180, -90, 90))
  extent(rs1) <- c(180, 181, -90, 90)
  extent(rs2) <- c(-181, -180, -90, 90)
  newrs <- merge(rs2, rs, rs1)
  
  writeRaster(newrs, output_path) 
}

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  from_dir <- paste0("thetao_mdmean/", h)
  to_dir <- paste0("thetao_expand/", h)
  for (s in c('ssp126', 'ssp245', 'ssp585')){
    files <- list.files(paste0(from_dir,'/',s), pattern = '.tif$')
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





# #################################################### #
# Step4: Moving Window averaging (processed in Python) #
# #################################################### #
# Detains see: 
# https://github.com/YuxuanSeanLin/ClimateConnectivity/blob/main/CMIP6/mva_idw.py





# ####################################################################### #
# Step5: expand extent by 1 degree (preprocessing for IDW interpolation ) #
# ####################################################################### #

rs_exp <- function(rs, output_path){
  # crop the expanded margin to c(-180, 180, -90, 90)
  rs <- crop(rs, extent(-180, 180, -90, 90))
  
  # expand raster
  rs1 <- crop(rs, extent(-180, -175, -90, 90))
  rs2 <- crop(rs, extent(175, 180, -90, 90))
  extent(rs1) <- c(180, 185, -90, 90)
  extent(rs2) <- c(-185, -180, -90, 90)
  newrs <- merge(rs2, rs, rs1)
  newdt <- as.data.frame(newrs, xy=T) %>%
    .[complete.cases(.),]
  colnames(newdt)[3] <- "value"
  
  # convert to point
  rs.sf <- st_as_sf(newdt, coords = c('x','y'), crs=4326)
  st_write(rs.sf, output_path)
}

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  from_dir <- paste0("thetao_smooth/", h)
  to_dir <- paste0("thetao_exp2p/", h)
  for (s in c('ssp126', 'ssp245', 'ssp585')){
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





# ############################################## #
# Step6: IDW interpolation (processed in Python) #
# ############################################## #
# Detains see: 
# https://github.com/YuxuanSeanLin/ClimateConnectivity/blob/main/CMIP6/mva_idw.py





# ########################### #
# Step7: masked by topography #
# ########################### #

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  topo <- raster(paste0('bathymetry/',h,'.tif'))
  from_dir <- paste0("thetao_idw/", h)
  to_dir <- paste0("thetao_final/", h)
  for (s in c('ssp126', 'ssp245', 'ssp585')){
    files <- list.files(paste0(from_dir,'/',s), pattern = '*.tif$')
    for (f in files){
      fname <- strsplit(f,'.tif')[[1]]
      output_path <- paste0(to_dir,'/',s,'/',fname,'.tif')
      input_path <- paste0(from_dir,'/',s,'/',f)
      mask(raster(input_path), topo) %>%
        writeRaster(., output_path)
      print(paste0(s, ': ', f, ' complete'))
    }

  }
  print(paste0(h, ': complete ----'))
}




