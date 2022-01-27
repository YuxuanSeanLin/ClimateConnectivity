library(sf)
library(raster)
library(magrittr)
# library(ggplot2)
library(VoCC)
library(dplyr)

setwd('D:/LinkageMapper/Statistics/vocc')


for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    # select by period
    list <- c()
    for (ls in list.files(paste0('temperature/',h,'/',s), full.names = T)){
      for (yr in seq(2020,2099)){
        if (grepl(yr, ls) == TRUE){list <- append(list, ls)}
      }
    }
    
    # start from different years
    for (yr in seq(2020, 2050, 10)){
      yr_span <- list
      
      # select by period
      for (y in seq(yr-30,yr-1)){yr_span <- yr_span[which(grepl(y, yr_span) == FALSE)]}
      
      # import raster stack&brick
      rs <- stack(yr_span)
      gv <- brick(paste0('velocity/',h,'/',s,'/vocc_',h,'_',s,'_',yr,'.tif'))
      
      # import patch and patch ID
      if (yr == 2020){
        patch <- raster(paste0('patch_id/',h,'/patch_',h,'_present.tif'))
        patchid <- as.data.frame(patch, xy=T) %>% .[complete.cases(.),]
      }else{
        patch <- raster(paste0('patch_id/',h,'/',s,'/patch_',h,'_',s,'_',yr,'.tif'))
        patchid <- as.data.frame(patch, xy=T) %>% .[complete.cases(.),]
      }
      colnames(patchid)[3] <- 'pid'
      
      # extract velocity and angle
      vel <- gv[[1]]
      ang <- gv[[2]]
      
      # calculate mean temperature
      mn <- mean(rs, na.rm = T)
      
      # extract x-y points
      lonlat <- patchid
      row.names(lonlat) <- seq(1,nrow(lonlat))
      lonlat <- lonlat[,-3]
      lonlat$vel <- raster::extract(vel, lonlat)
      lonlat$ang <- raster::extract(ang, lonlat[,1:2])
      lonlat$mn <- raster::extract(mn, lonlat[,1:2])
      lonlat <- lonlat[complete.cases(lonlat),]
      
      # velocity trajectory
      traj <- voccTraj(lonlat, vel, ang, mn, tyr = 2100-yr, 
                       trajID = as.numeric(rownames(lonlat)), correct=T)
      traj_lns <- trajLine(x = traj) %>% st_as_sf(.)
      
      # extract start points and retrieved patch IDs
      xystart <- traj[1:nrow(traj_lns),]
      xystart$pid <- raster::extract(patch, xystart[,1:2])
      
      # left-join to polyline attribute
      traj_lns <- left_join(traj_lns, xystart, by='trajIDs')
      
      for (p in unique(traj_lns$pid)){
        # trajectory lines of each patch
        Pch_traj <- subset(traj_lns, pid==p)
        
        # export trajectories with patches 
        ## Error in h(simpleError(msg, call)) : 
        ## error in evaluating the argument 'x' in selecting a method for function 'addAttrToGeom': invalid class “SpatialLines” object: bbox should never contain infinite values
        st_write(st_as_sf(Pch_traj), 
                 paste0('traj_lines_bypatch/',h,'/',s,'/',yr,'/traj_',h,'_',s,'_',yr,'_',p,'.shp'))
      }

      # export overall trajectory line
      st_write(st_as_sf(traj_lns), 
               paste0('traj_lines/',h,'/',s,'/traj_',h,'_',s,'_',yr,'.shp'))
      
    }
  }
}

