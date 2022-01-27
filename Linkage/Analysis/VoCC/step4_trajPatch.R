library(sf)
library(raster)
library(magrittr)

setwd('')

#####
# generate the trajectory pairs of patches

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    # start from different years
    for (yr in seq(2020, 2050, 10)){
      # import total patch and patch ID
      if (yr == 2020){
        patch <- raster(paste0('patch_id/',h,'/patch_',h,'_present.tif'))
        patchid <- as.data.frame(patch, xy=T) %>% .[complete.cases(.),]
      }else{
        patch <- raster(paste0('patch_id/',h,'/',s,'/patch_',h,'_',s,'_',yr,'.tif'))
        patchid <- as.data.frame(patch, xy=T) %>% .[complete.cases(.),]
      }
      colnames(patchid)[3] <- 'pid'
      pch_all <- unique(patchid$pid)    ## overall patches
      
      # load available patch ID (have velocity trajectory)
      traj_all <- st_read(paste0('traj_lines/',h,'/',s,'/traj_',h,'_',s,'_',yr,'.shp'))
      pch_traj <- traj_all$pid    ## available patches
      
      # initialize
      result <- c()
      
      for (p in pch_all){
        if (p %in% pch_traj){
          # trajectory lines of each patch
          traj_path <- raster(paste0('traj_lines_bypatch/',h,'/',s,'/',yr,'/traj_',h,'_',s,'_',yr,'_',p,'.tif')) %>% 
            as.data.frame(.) %>% .[complete.cases(.),] %>% unique(.)
          result <- rbind(result, cbind(from_patch=p, to_patch=traj_path)) %>% 
            as.data.frame(.)
        }else{
          # for non-available trajectories (discrete patches)
          result <- rbind(result, cbind(from_patch=p, to_patch=p))
        }
      }
      
      # export overall trajectory results
      write.csv(result, paste0('traj_patches/',h,'/',s,'/traj_',h,'_',s,'_',yr,'.csv'),row.names = F)
      print(paste0(h,'-',s,'-',yr))
    }
  }
}

