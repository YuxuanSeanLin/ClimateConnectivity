library(magrittr)
library(raster)
library(sf)

setwd('D:/LinkageMapper/Statistics')

for (f in list.files('temperature', full.names = T, recursive = T)){
  
  patch <- paste0(strsplit(paste0('patch_elim_tif',strsplit(f,'temperature')[[1]][2]),'thetao')[[1]][1],
                  'patch',
                  strsplit(paste0('patch_elim_tif',strsplit(f,'temperature')[[1]][2]),'thetao')[[1]][2])
  
  rs <- stack(c(f, patch)) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
  colnames(rs)[3:4] <- c('temp', 'pid')
  row.names(rs) <- seq(1,nrow(rs))
  
  dt_temp <- c()
  for (p in unique(rs$pid)){
    patch_temp <- subset(rs, pid == p)
    temp_mean <- mean(patch_temp$temp)
    temp_sd <- sd(patch_temp$temp)
    dt_temp <- rbind(dt_temp, cbind(pid = p, 
                                    mean = temp_mean, 
                                    sd = temp_sd)) %>% as.data.frame()
  }
  
  to_path <- paste0(strsplit(paste0(strsplit(paste0('patch_temp',
                                                    strsplit(f,
                                                             'temperature')[[1]][2]),
                                             'thetao')[[1]][1],
                                    'ptemp',
                                    strsplit(paste0('patch_temp',
                                                    strsplit(f,
                                                             'temperature')[[1]][2]),
                                             'thetao')[[1]][2]),
                             '.tif')[[1]][1],'.csv')
  
  write.csv(dt_temp, to_path)
  print(to_path)
}

