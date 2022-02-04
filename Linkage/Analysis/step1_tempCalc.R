library(magrittr)
library(raster)
library(sf)

setwd('')

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  for (s in c('present','ssp126','ssp245','ssp370','ssp585')){
    if (s == 'present'){  # present: 4 designated years
      ## patch tif
      patch <- paste0('patch_elim_tif/',h,'/patch_',h,'_present.tif')
      
      ## contemporary temperature
      temp <- c(paste0('temperature/',h,'/thetao_',h,'_present.tif'))
      
      ## future temperature
      for (sc in c('ssp126','ssp245','ssp370','ssp585')){
        temp <- append(temp, paste0('temperature/',h,'/',sc,'/thetao_',h,'_',sc,'_2100.tif'))
      }
      
      ## load raster stack
      rs <- stack(append(patch, temp)) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
      colnames(rs)[3:8] <- c('pid','present','ssp126','ssp245','ssp370','ssp585')
      row.names(rs) <- seq(1,nrow(rs))
      
      ## calculate zonal temperature
      dt_temp <- c()
      for (p in unique(rs$pid)){
        patch_temp <- subset(rs, pid == p)
        ### calculate zonal temperature
        dt_temp <- rbind(dt_temp, cbind(pid = p, 
                                        present = mean(patch_temp$present), 
                                        present_sd = sd(patch_temp$present), 
                                        ssp126_2100 = mean(patch_temp$ssp126), 
                                        ssp245_2100 = mean(patch_temp$ssp245), 
                                        ssp370_2100 = mean(patch_temp$ssp370), 
                                        ssp585_2100 = mean(patch_temp$ssp585))) %>% as.data.frame()
      }
      
      ## export data
      to_path <- paste0('patch_temp/',h,'/ptemp_',h,'_present.csv')
      write.csv(dt_temp, to_path, row.names = F)
      print(to_path)
      
    }else{  # future
      for (yr in seq(2030, 2050, 10)){
        ## patch tif
        patch <- paste0('patch_elim_tif/',h,'/',s,'/patch_',h,'_',s,'_',yr,'.tif')
        
        ## temperature
        temp <- append(paste0('temperature/',h,'/',s,'/thetao_',h,'_',s,'_',yr,'.tif'), 
                       paste0('temperature/',h,'/',s,'/thetao_',h,'_',s,'_2100.tif'), )
        
        ## load raster stack
        rs <- stack(append(patch, temp)) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
        colnames(rs)[3:5] <- c('pid',paste0(s,'_',yr),paste0(s,'_2100'))
        row.names(rs) <- seq(1,nrow(rs))
        
        ## calculate zonal temperature
        dt_temp <- c()
        for (p in unique(rs$pid)){
          patch_temp <- subset(rs, pid == p)
          ### calculate zonal temperature
          dt_temp <- rbind(dt_temp, cbind(pid = p, 
                                          present = mean(patch_temp[,4]), 
                                          present_sd = sd(patch_temp[,4]), 
                                          future = mean(patch_temp[,5]))) %>% as.data.frame()
        }
        colnames(dt_temp)[2:4] <- c(paste0(s,'_',yr),paste0(s,'_',yr,'_sd'),paste0(s,'_2100'))
        
        ## export data
        to_path <- paste0('patch_temp/',h,'/',s,'/ptemp_',h,'_',s,'_',yr,'.csv')
        write.csv(dt_temp, to_path, row.names = F)
        print(to_path)
        
      }
    }
  }
}

