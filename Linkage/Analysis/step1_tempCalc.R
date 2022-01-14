library(magrittr)
library(raster)
library(sf)

setwd('')

for (f in list.files('temperature', full.names = T, recursive = T)){
  patch <- ''
  # stack two raster
  # f: temperature; patch: patch ID
  rs <- stack(c(f, patch)) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
  colnames(rs)[3:4] <- c('temp', 'pid')
  row.names(rs) <- seq(1,nrow(rs))
  
  # calculate mean temperature and standard deviation among patches
  dt_temp <- c()
  for (p in unique(rs$pid)){
    patch_temp <- subset(rs, pid == p)
    temp_mean <- mean(patch_temp$temp)
    temp_sd <- sd(patch_temp$temp)
    dt_temp <- rbind(dt_temp, cbind(pid = p, 
                                    mean = temp_mean, 
                                    sd = temp_sd)) %>% as.data.frame()
  }
  
  # export data
  to_path <- ''
  write.csv(dt_temp, to_path)
  # print(to_path)
}

