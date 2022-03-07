library(magrittr)
library(dplyr)
library(raster)
library(sf)

setwd('root')

# load thermal tolerance edge of each species
edge <- read.csv('ClimCon_species/thetao.csv')

#####
# Step1: calculate climate connectivity and climate impacts of each species

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  spelist <- list.files(paste0('ClimCon_species/SpeciesDistribution/',h), 
                        full.names = T, recursive = T, pattern = '.tif$')
  
  for (s in c('ssp126','ssp245','ssp370','ssp585')){
    ### load LCP data
    LCP_list <- read.csv(paste0('linkage_global/',h,'/',s,'/link_',h,'_',s,'_2020.csv'))
    
    for (spe in spelist){
      spe_cc <- c() %>% as.data.frame()
      
      ## species data
      spe_location <- raster(spe)
      spename <- strsplit(strsplit(spe,'/')[[1]][5],'.tif$')[[1]][1]
      
      ## tolerance limits
      low_end <- edge$lower_sd[which(edge$species==spename)]
      high_end <- edge$upper_sd[which(edge$species==spename)]
      
      ## load patches (only historical distribution)
      patch <- raster(paste0('patch_id/',h,'/patch_',h,'_present.tif'))
      
      ## extract patches by mask
      spe_bypatch <- mask(patch, spe_location) %>% 
        as.data.frame(., xy=T) %>% .[complete.cases(.),]
      colnames(spe_bypatch)[3] <- 'pid'
      
      if (nrow(spe_bypatch)>0){
        ### start with different destinations
        for (pch in unique(spe_bypatch$pid)){
          ### extract species within each patch
          spe_bp <- subset(spe_bypatch, pid==pch)
          
          ### load linkage data
          links <- read.csv(paste0('ClimCon/',h,'/',s,'/cclink_2020/cclink_',pch,'.csv'))
          
          ### extract designated patches that within tolerance edges
          Dest_temp <- links[,(ncol(links)/2+2):ncol(links)] %>% 
            as.matrix() %>% as.numeric() %>% na.omit() %>% unique()
          
          ### calculate climate connectivity and climate impacts (against climate of designated patches)
          if (length(which(Dest_temp>=low_end & Dest_temp<=high_end))>0){ #### has suitable destinations
            #### climate connectivity traverse
            Dest_temp <- Dest_temp[which(Dest_temp>=low_end & Dest_temp<=high_end)] #### highest extremes (capability)
            Dest_temp <- min(Dest_temp)
            spe_bp$ClimCon <- unique(links$From_pre) - Dest_temp
            spe_bp$ClimImp <- 0
          }else{ #### has no suitable destinations
            #### targeted patches with lowest extremes (minimized stress)
            dest_id <- which(abs(unique(links$From_pre)-Dest_temp)==min(abs(unique(links$From_pre)-Dest_temp)))
            #### calculation
            Dest_temp <- Dest_temp[dest_id]
            spe_bp$ClimCon <- abs(unique(links$From_pre)-Dest_temp)*(-1)
            if (Dest_temp>high_end){
              spe_bp$ClimImp <- (Dest_temp-high_end)/(high_end-low_end)
            }else{
              spe_bp$ClimImp <- (low_end-Dest_temp)/(high_end-low_end)
            }
          }
          
          ### calculate connectivity coefficient with LCP pathways
          dest_fut <- links[,(ncol(links)/2+2):ncol(links)] %>% as.data.frame()
          conn_coef <- c()
          for (r in 1:nrow(dest_fut)){
            cum_CWD <- 0
            cum_LCP <- 0
            pathway_temp <- dest_fut[r,] %>% as.numeric()
            if (length(which(pathway_temp==Dest_temp))!=0){
              pathway_id <- links[r,1:(which(pathway_temp==Dest_temp)+1)] %>% as.numeric()
              
              #### calculate cumulative LCP and CWD
              for (k in 1:(length(pathway_id)-1)){
                from_p <- pathway_id[k]
                to_p <- pathway_id[k+1]
                cum_CWD <- cum_CWD + LCP_list$CW_Dist[which(LCP_list$Origin==from_p & LCP_list$Dest==to_p)]
                cum_LCP <- cum_LCP + LCP_list$LCP_Length[which(LCP_list$Origin==from_p & LCP_list$Dest==to_p)]
              }
              #### calculate coefficiency
              if (cum_CWD==0){
                conn_coef <- append(conn_coef, 1)
              }else{conn_coef <- append(conn_coef, cum_LCP/cum_CWD)}
            }
          }
          spe_bp$ConnCoef <- max(conn_coef)
          
          ### combine table
          spe_cc <- rbind(spe_cc, spe_bp)
        }
        
        ### export as raster files
        rs.sp <- st_as_sf(spe_cc, coords = c('x','y'), crs=4326) %>% 
          as(., "Spatial")
        #### connectivity coefficient
        raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), ext = extent(c(-180, 180, -90, 90))) %>%
          rasterize(rs.sp, ., field='ConnCoef', fun='first') %>% 
          writeRaster(., paste0('ClimCon_species/Species_ConnCoef/',s,
                                strsplit(spe,'SpeciesDistribution')[[1]][2]), overwrite=T)
        
        print(paste0('----Complete: ',s,'-',strsplit(spe,'/')[[1]][4],
                     '-',strsplit(spe,'/')[[1]][5],'----'))
      }
    }
  }
}



#####
# Step2: calculate total climate connectivity and climate impacts

setwd('root/ClimCon_species')

for (s in c('ssp126','ssp245','ssp370','ssp585')){
  for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
    ## load seascape boundary
    mask_r <- raster(paste0('Seascape_boundaries/',h,'.tif'))
    
    ## import canvas (180*360 raster, value=0)
    canvas_cc <- raster('canvas.tif')
    canvas_ci <- canvas_cc
    canvas_lcp <- canvas_cc
    
    ## list of all species (read recursively)
    spelist <- list.files(paste0('Species_ClimCon/',s,'/',h), 
                          full.names = T, recursive = T, pattern = '.tif$')
    
    for (spe in spelist){
      ## load connectivity, CI and LCP coefficient
      ClimCon <- raster(spe)
      ClimImp <- raster(paste0('Species_ClimImp',
                               strsplit(spe,'Species_ClimCon')[[1]][2]))
      ConnCoef <- raster(paste0('Species_ConnCoef',
                                strsplit(spe,'Species_ClimCon')[[1]][2]))
      
      ## sum all
      canvas_cc <- sum(canvas_cc, ClimCon, na.rm = T)
      canvas_ci <- sum(canvas_ci, ClimImp, na.rm = T)
      canvas_lcp <- sum(canvas_lcp, ConnCoef, na.rm = T)
      
      print(paste0('----Complete: ',s,'-',strsplit(spe,'/')[[1]][4],
                   '-',strsplit(spe,'/')[[1]][5],'----'))
    }
    
    ## extract canvas by mask (boundary)
    canvas_cc_r <- mask(canvas_cc, mask_r)
    canvas_ci_r <- mask(canvas_ci, mask_r)
    canvas_lcp_r <- mask(canvas_lcp, mask_r)
    
    ## export data
    writeRaster(canvas_cc_r, paste0('Species_ClimCon_total/',h,
                                    '/Tot_ClimCon_',h,'_',s,'.tif'),overwrite = TRUE)
    writeRaster(canvas_ci_r, paste0('Species_ClimImp_total/',h,
                                    '/Tot_ClimImp_',h,'_',s,'.tif'),overwrite = TRUE)
    writeRaster(canvas_lcp_r, paste0('Species_ConnCoef_total/',h,
                                     '/Tot_ConnCoef_',h,'_',s,'.tif'),overwrite = TRUE)
    
    print(paste0('----Complete: ',h,'----'))
  }
}



#####
# Step3: calculate total richness

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  ## load seascape boundary
  mask_r <- raster(paste0('Seascape_boundaries/',h,'.tif'))
  
  ## import canvas (180*360 raster, value=0)
  canvas_richness <- raster('canvas.tif')
  
  ## list of all species (read recursively)
  spelist <- list.files(paste0('SpeciesDistribution/',h), 
                        full.names = T, recursive = T, pattern = '.tif$')
  
  for (spe in spelist){
    ## load connectivity and CI
    species <- raster(spe)
    
    ## sum all
    canvas_richness <- sum(canvas_richness, species, na.rm = T)
    
    print(paste0('----Complete: ',h,'-',strsplit(spe,'/')[[1]][3],
                 '-',strsplit(spe,'/')[[1]][4],'----'))
  }
  
  ## extract canvas by mask (boundary)
  canvas_richness_r <- mask(canvas_richness, mask_r)
  
  ## export data
  writeRaster(canvas_richness_r, paste0('Richness/Richness_',h,'.tif'), overwrite = TRUE)
  print(paste0('----Complete: ',h,'----'))
  
}



#####
# Step4: calculate mean connectivity and LCP coefficient (total / richness) (set mean connectivity as an example)

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  # load species richness
  richness <- raster(paste0('Richness/Richness_',h,'.tif'))
  
  for (s in c('ssp126','ssp245','ssp370','ssp585')){
    ## load total climate connectivity (of all species)
    ClimCon <- raster(paste0('Species_ClimCon_total/',h,
                             '/Tot_ClimCon_',h,'_',s,'.tif'))
    
    ## create raster stack
    MeanClimCon <- stack(ClimCon, richness) %>% 
      as.data.frame(., xy=T) %>% .[complete.cases(.),]
    colnames(MeanClimCon)[3:4] <- c('ClimCon', 'richness')
    
    ## calculate mean connectivity
    dt1 <- subset(MeanClimCon, richness==0)
    dt1$Mean_cc <- 0
    dt2 <- subset(MeanClimCon, richness!=0)
    dt2$Mean_cc <- dt2$ClimCon / dt2$richness
    dt <- rbind(dt1, dt2)
    
    ## rasterize and export
    rs.sp <- st_as_sf(dt, coords = c('x','y'), crs=4326) %>% 
      as(., "Spatial") 
    raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), ext = extent(c(-180, 180, -90, 90))) %>%
      rasterize(rs.sp, ., field='Mean_cc', fun='first') %>% 
      writeRaster(., paste0('Species_ClimCon_mean/',h,
                            '/Mean_ClimCon_',h,'_',s,'.tif'), overwrite=T)
    
    print(paste0('----Complete: ',h,'-',s,'----'))
  }
}


