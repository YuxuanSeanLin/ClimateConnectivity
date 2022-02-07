library(magrittr)
library(dplyr)
library(raster)
library(sf)

setwd('D:/LinkageMapper/Statistics')

# load thermal tolerance edge of each species
edge <- read.csv('ClimCon_species/thetao.csv')

# create files
for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  dir.create(paste0('ClimCon_species/Species_ClimCon/',h))
  dir.create(paste0('ClimCon_species/Species_ClimImp/',h))
  for (phy in unique(edge$phylum)){
    dir.create(paste0('ClimCon_species/Species_ClimCon/',h,'/',phy))
    dir.create(paste0('ClimCon_species/Species_ClimImp/',h,'/',phy))
  }
}

#####
# Step1: calculate climate connectivity and climate impacts of each species
for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  spelist <- list.files(paste0('ClimCon_species/SpeciesDistribution/',h), 
                        full.names = T, recursive = T, pattern = '.tif$')
  
  for (spe in spelist){
    ## species data
    spe_location <- raster(spe)
    
    ## tolerance limits
    low_end <- edge$lower_sd[which(edge$species==names(spe_location))]
    high_end <- edge$upper_sd[which(edge$species==names(spe_location))]
    
    ## load patches (only historical distribution)
    patch <- raster(paste0('patch_id/',h,'/patch_',h,'_present.tif'))
    
    ## extract patches by mask
    spe_bypatch <- mask(patch, spe_location) %>% 
      as.data.frame(., xy=T) %>% .[complete.cases(.),]
    colnames(spe_bypatch)[3] <- 'pid'
    
    ## calculate patch-wise species climate connectivity of 4 scenarios
    for (s in c('ssp126','ssp245','ssp370','ssp585')){
      spe_cc <- c() %>% as.data.frame()
      
      ### start with different destinations
      for (pch in unique(spe_bypatch$pid)){
        ### extract species within each patch
        spe_bp <- subset(spe_bypatch, pid==pch)
        
        ### load linkage data
        links <- read.csv(paste0('ClimCon/',h,'/',s,'/cclink_2020/cclinks_',pch,'.csv'))
        
        ### extract designated patches that within tolerance edges
        Dest_temp <- links[,(ncol(links)/2+2):ncol(links)] %>% 
          as.matrix() %>% as.numeric() %>% na.omit() %>% unique()
        
        ### calculate climate connectivity and climate impacts (against climate of designated patches)
        if (length(which(Dest_temp>=low_end & Dest_temp<=high_end))>0){ #### has suitable destinations
          Dest_temp <- Dest_temp[which(Dest_temp>=low_end & Dest_temp<=high_end)] #### highest extremes (capability)
          spe_bp$ClimCon <- unique(links$From_pre) - min(Dest_temp)
          spe_bp$ClimImp <- 0
        }else{ #### has no suitable destinations
          #### targeted patches with lowest extremes (minimized stress)
          dest_id <- which(abs(unique(links$From_pre)-Dest_temp)==min(abs(unique(links$From_pre)-Dest_temp)))
          #### calculation
          spe_bp$ClimCon <- abs(unique(links$From_pre)-Dest_temp[dest_id])*(-1)
          if (Dest_temp[dest_id]>high_end){
            spe_bp$ClimImp <- (Dest_temp[dest_id]-high_end)/(high_end-low_end)
          }else{
            spe_bp$ClimImp <- (low_end-Dest_temp[dest_id])/(high_end-low_end)
          }
        }
        ### combine table
        spe_cc <- rbind(spe_cc, spe_bp)
      }
      
      ### export as raster files
      rs.sp <- st_as_sf(spe_cc, coords = c('x','y'), crs=4326) %>% 
        as(., "Spatial") 
      #### climate connectivity
      raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), ext = extent(c(-180, 180, -90, 90))) %>%
        rasterize(rs.sp, ., field='ClimCon', fun='first') %>% 
        writeRaster(., paste0('ClimCon_species/Species_ClimCon/',s,
                              strsplit(spe,'SpeciesDistribution')[[1]][2]))
      #### climate impacts
      raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), ext = extent(c(-180, 180, -90, 90))) %>%
        rasterize(rs.sp, ., field='ClimImp', fun='first') %>% 
        writeRaster(., paste0('ClimCon_species/Species_ClimImp/',s,
                              strsplit(spe,'SpeciesDistribution')[[1]][2]))
      
      print(paste0('----Complete: ',s,'-',strsplit(spe,'/')[[1]][4],
                   '-',strsplit(spe,'/')[[1]][5],'----'))
    }
    
    
    
  }
}



#####
# Step2: calculate total climate connectivity and climate impacts
setwd('D:/LinkageMapper/Statistics/ClimCon_species')

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  ## load seascape boundary
  mask_r <- raster(paste0('Seascape_boundaries/',h,'.tif'))
  
  ## import canvas (180*360 raster, value=0)
  canvas_cc <- raster('canvas.tif')
  canvas_ci <- canvas_cc
  
  ## list of all species (read recursively)
  spelist <- list.files(paste0('Species_ClimCon/',h), 
                        full.names = T, recursive = T, pattern = '.tif$')
  
  for (spe in spelist){
    ## load connectivity and CI
    ClimCon <- raster(spe)
    ClimImp <- raster(paste0('Species_ClimImp',
                             strsplit(spe,'Species_ClimCon')[[1]][1]))
    
    ## sum all
    canvas_cc <- sum(canvas_cc, ClimCon, na.rm = T)
    canvas_ci <- sum(canvas_ci, ClimImp, na.rm = T)
    
  }

  ## extract canvas by mask (boundary)
  canvas_cc_r <- mask(canvas_cc, mask_r)
  canvas_ci_r <- mask(canvas_ci, mask_r)
  
  ## export data
  writeRaster(canvas_cc_r, paste0('Species_ClimCon_total/',h,
                                  '/Tot_ClimCon_',h,'.tif'),overwrite = TRUE)
  writeRaster(canvas_ci_r, paste0('Species_ClimImp_total/',h,
                                  '/Tot_ClimImp_',h,'.tif'),overwrite = TRUE)
  
  print(paste(exp,"-",year,"-",dp,"Done!",sep = ""))
}

