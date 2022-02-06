library(magrittr)
library(dplyr)
library(raster)
library(sf)
library(arcgisbinding)

setwd('')

# activate ArcGIS lisence
arc.check_product()

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  for (s in c('present',
              'ssp126_2030','ssp126_2040','ssp126_2050',
              'ssp245_2030','ssp245_2040','ssp245_2050',
              'ssp370_2030','ssp370_2040','ssp370_2050',
              'ssp585_2030','ssp585_2040','ssp585_2050')){
    
    ##########
    # Step1: load corridors results
    if (s == 'present'){  ## present
      
      ## northern hemisphere
      arcf <- arc.open(paste0('N_hemisphere/',h,'/',s,'/link_maps.gdb/present_LCPs'))
      N_link <- arc.select(arcf, fields=c('From_Core','To_Core','CW_Dist','LCP_Length')) %>% 
        as.data.frame(.)
      colnames(N_link)[1:2] <- c('coreId1','coreId2')
      
      ## southern hemisphere
      arcf <- arc.open(paste0('S_hemisphere/',h,'/',s,'/link_maps.gdb/present_LCPs'))
      S_link <- arc.select(arcf, fields=c('From_Core','To_Core','CW_Dist','LCP_Length')) %>% 
        as.data.frame(.)
      colnames(S_link)[1:2] <- c('coreId1','coreId2')
      
    }else{  ## future
      sc <- strsplit(s,'_')[[1]][1]
      
      ## northern hemisphere
      arcf <- arc.open(paste0('N_hemisphere/',h,'/',sc,'/',s,
                              '/link_maps.gdb/',s,'_LCPs'))
      N_link <- arc.select(arcf, fields=c('From_Core','To_Core','CW_Dist','LCP_Length')) %>% 
        as.data.frame(.)
      colnames(N_link)[1:2] <- c('coreId1','coreId2')
      
      ## southern hemisphere
      arcf <- arc.open(paste0('S_hemisphere/',h,'/',sc,'/',s,
                              '/link_maps.gdb/',s,'_LCPs'))
      S_link <- arc.select(arcf, fields=c('From_Core','To_Core','CW_Dist','LCP_Length')) %>% 
        as.data.frame(.)
      colnames(S_link)[1:2] <- c('coreId1','coreId2')
      
    }
    
    
    
    ##########
    # Step2: generate unique linkage of two hemisphere
    ## combine hemispheres and create new linkage table
    linkage <- rbind(N_link, S_link)
    link_new <- c()
    
    for (p in unique(linkage$coreId1)){
      link_ext <- subset(linkage, coreId1==p)
      
      ## extract repeated linkage
      ## the patch ID is automatically ordered ascendingly by Linkage Mapper
      if (length(unique(link_ext$coreId2)) < length(link_ext$coreId2)){
        for (rep in unique(link_ext$coreId2)){
          ## judge repeated pairs
          link_rep <- subset(link_ext, coreId2==rep)
          if (nrow(link_rep) > 1){
            ### calculate mean cost-weighted distance and LCP length
            CWD_m <- mean(link_rep$CW_Dist)
            LCP_m <- mean(link_rep$LCP_Length)
            ### combine to new table
            link_new <- rbind(link_new, cbind(coreId1=p,
                                              coreId2=rep,
                                              CW_Dist=CWD_m,
                                              LCP_Length=LCP_m))
          }else{link_new <- rbind(link_new, link_rep)} ## combine to new table without changes
        }
      }else{link_new <- rbind(link_new, link_ext)} ## combine to new table without changes
    }
    rm(arcf, N_link, S_link, link_ext, link_rep, CWD_m, LCP_m, p, rep, linkage)
    
    
    
    ##########
    # Step3: add all patches to linkage table (connected or isolated)
    ## list of all connected patches
    con_pch <- unique(append(link_new$coreId1, link_new$coreId2))
    
    ## list of all patches
    if (s == 'present'){  ## present
      all_pch <- st_read(paste0('patch/',h,'/patch_',h,'_present.shp')) %>% .$pid
    }else{  ## future
      sc <- strsplit(s,'_')[[1]][1]
      all_pch <- st_read(paste0('patch/',h,'/',sc,'/patch_',h,'_',s,'.shp')) %>% .$pid
    }
    
    ## add all patches connected to themselves, with zero distance
    link_new <- rbind(link_new, cbind(coreId1=all_pch,
                                      coreId2=all_pch,
                                      CW_Dist=0,
                                      LCP_Length=0))
    
    ## order by patch ID
    link_new <- link_new[order(link_new$coreId1,link_new$coreId2),]
    row.names(link_new) <- seq(1,nrow(link_new))
    

    
    ##########
    # Step4: mesh linkage by climate trajectory and thermal gradient
    ## load climate trajectory data
    if (s == 'present'){  ## present
      ## load temperature data
      temp <- read.csv(paste0('patch_temp/',h,'/ptemp_',h,'_present.csv'))
      
      for (sc in c('ssp126','ssp245','ssp370','ssp585')){
        ## load velocity trajectory data (see details in 'VoCC' section)
        traj <- read.csv(paste0('vocc/traj_patches/',h,'/',sc,'/traj_',h,'_',sc,'_2020.csv'))
        
        ## mesh linkage by velocity trajectory
        link_traj <- data.frame()
        link <- link_new
        for (r in 1:nrow(link)){
          core1 <- link[r,1]
          core2 <- link[r,2]
          
          ### only connections reachable by velocity trajectory are kept
          if (length(which(traj$from_patch==core1 & traj$to_patch==core2))>0){
            link_traj <- rbind(link_traj, cbind(Origin=core1, 
                                                Dest=core2,
                                                CW_Dist=link[r,3],
                                                LCP_Length=link[r,4]))
          }else if (length(which(traj$from_patch==core2 & traj$to_patch==core1))>0){
            link_traj <- rbind(link_traj, cbind(Origin=core2, 
                                                Dest=core1,
                                                CW_Dist=link[r,3],
                                                LCP_Length=link[r,4]))
          }
        }
        
        ## join present origin temperature to linkage table
        colnames(temp)[1] <- 'Origin'
        link_traj <- left_join(link_traj, temp, by = 'Origin')
        link_traj <- link_traj[,1:5]
        colnames(link_traj)[5] <- 'Origin_pre'
        
        ## join present destination temperature to linkage table
        colnames(temp)[1] <- 'Dest'
        link_traj <- left_join(link_traj, temp, by = 'Dest')
        link_traj <- link_traj[,c(1:6)]
        colnames(link_traj)[6] <- 'Dest_pre'
        
        ## join future destination temperature to linkage table
        link_traj <- left_join(link_traj, temp, by = 'Dest')
        link_traj <- link_traj[,c(1:6, which(colnames(link_traj)==paste0(sc,'_2100')))]
        colnames(link_traj)[7] <- 'Dest_fut'
        
        ## reorder by patch ID
        link_traj <- link_traj[order(link_traj$Origin,link_traj$Dest),]
        row.names(link_traj) <- seq(1,nrow(link_traj))

        ## mesh linkage by thermal gradient
        ### calculate temperature differences between core pairs 
        link_traj$TempDif <- link_traj$Origin_pre - link_traj$Dest_pre
        ### only connections reachable by thermal gradient (not less than 0) are kept
        link_traj_temp <- subset(link_traj, TempDif>=0)
        link_traj_temp <- link_traj_temp[,1:7]
        
        ## export linkage table
        write.csv(link_traj_temp, paste0('Output/linkage_global/',h,'/',sc,
                                         '/link_',h,'_',sc,'_2020.csv'), row.names = F)
      }
    }else{  ## future
      sc <- strsplit(s,'_')[[1]][1]
      
      ## load temperature data
      temp <- read.csv(paste0('patch_temp/',h,'/',sc,'/ptemp_',h,'_',s,'.csv'))

      ## load velocity trajectory data
      traj <- read.csv(paste0('vocc/traj_patches/',h,'/',sc,'/traj_',h,'_',s,'.csv'))
      
      ## mesh linkage by velocity trajectory
      link_traj <- data.frame()
      link <- link_new
      for (r in 1:nrow(link)){
        core1 <- link[r,1]
        core2 <- link[r,2]
        
        ### only connections reachable by velocity trajectory are kept
        if (length(which(traj$from_patch==core1 & traj$to_patch==core2))>0){
          link_traj <- rbind(link_traj, cbind(Origin=core1, 
                                              Dest=core2,
                                              CW_Dist=link[r,3],
                                              LCP_Length=link[r,4]))
        }else if (length(which(traj$from_patch==core2 & traj$to_patch==core1))>0){
          link_traj <- rbind(link_traj, cbind(Origin=core2, 
                                              Dest=core1,
                                              CW_Dist=link[r,3],
                                              LCP_Length=link[r,4]))
        }
      }
      
      ## join present origin temperature to linkage table
      colnames(temp)[1] <- 'Origin'
      link_traj <- left_join(link_traj, temp, by = 'Origin')
      link_traj <- link_traj[,1:5]
      colnames(link_traj)[5] <- 'Origin_pre'
      
      ## join present destination temperature to linkage table
      colnames(temp)[1] <- 'Dest'
      link_traj <- left_join(link_traj, temp, by = 'Dest')
      link_traj <- link_traj[,c(1:6)]
      colnames(link_traj)[6] <- 'Dest_pre'
      
      ## join future destination temperature to linkage table
      link_traj <- left_join(link_traj, temp, by = 'Dest')
      link_traj <- link_traj[,c(1:6,9)]
      colnames(link_traj)[7] <- 'Dest_fut'
      
      ## reorder by patch ID
      link_traj <- link_traj[order(link_traj$Origin,link_traj$Dest),]
      row.names(link_traj) <- seq(1,nrow(link_traj))
      
      ## mesh linkage by thermal gradient
      ### calculate temperature differences between core pairs 
      link_traj$TempDif <- link_traj$Origin_pre - link_traj$Dest_pre
      ### only connections reachable by thermal gradient (not less than 0) are kept
      link_traj_temp <- subset(link_traj, TempDif>=0)
      link_traj_temp <- link_traj_temp[,1:7]
      
      ## export linkage table
      write.csv(link_traj_temp, paste0('Output/linkage_global/',h,'/',sc,
                                       '/link_',h,'_',s,'.csv'), row.names = F)
    }
  }
}

