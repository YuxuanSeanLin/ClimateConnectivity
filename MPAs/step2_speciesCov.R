library(raster)
library(magrittr)


##===================
# calculate by depth

setwd('')
from_dir <- ''
to_dir <- ''

pcm <- raster('mpa_cover.tif')
cov_arr <- c()

for (d in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (phy in list.files(paste0(from_dir,'/',d))){
    for (f in list.files(paste0(from_dir,'/',d,'/',phy), full.names = T)){
      r <- raster(f)
      fname <- strsplit(strsplit(f, '.tif$')[[1]], '/')[[1]][4]
      
      # calculate species coverage within MPAs
      p_cover <- mask(pcm, r)
      sum_cov <- sum(values(p_cover), na.rm=T)
      sum_cell <- sum(values(r), na.rm=T)
      cov <- sum_cov / sum_cell
      
      # save results
      cov_arr <- rbind(cov_arr, cbind(depth=d, phylum=phy, 
                                      species=fname, coverage=cov))
      
    }
    print(paste0(phy, ' - complete'))
  }
  # export
  as.data.frame(cov_arr) %>% 
    write.csv(., paste0(to_dir,'/cov_',d,'.csv'))
}


##===================
# join all depths together

surface <- read.csv(paste0(to_dir,'/cov_surface.csv'))
mesopelagic <- read.csv(paste0(to_dir,'/cov_mesopelagic.csv'))
bathypelagic <- read.csv(paste0(to_dir,'/cov_bathypelagic.csv'))
abyssopelagic <- read.csv(paste0(to_dir,'/cov_abyssopelagic.csv'))

# create species dataframe
spelist <- rbind(surface[,3:4], mesopelagic[,3:4], 
                 bathypelagic[,3:4], abyssopelagic[,3:4]) %>% unique()
spelist <- spelist[order(spelist$phylum, spelist$species),]
row.names(spelist) <- seq.int(1:nrow(spelist))

# join different layers by name
spelist <- left_join(spelist, surface, by= "species")
spelist <- left_join(spelist, mesopelagic, by= "species") 
spelist <- left_join(spelist, bathypelagic, by= "species") 
spelist <- left_join(spelist, abyssopelagic, by= "species") 

# eliminate repeating data
spelist <- spelist[,-c(3,4,5,7,8,9,11,12,13,15,16,17)]
colnames(spelist)[3:6] <- c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')

# # calculate mean coverage and standard deviation
# spelist <- cbind(spelist, Mean=0, Sd=0)
# for (i in 1:nrow(spelist)){
#   compare[i,7] <- compare[i,3:6] %>% as.numeric() %>% mean(., na.rm = T)
#   compare[i,8] <- compare[i,3:6] %>% as.numeric() %>% sd(., na.rm = T)
# }

# export results
write.csv(spelist, 'mpa_cover/species_cov/cov_leftjoin.csv', row.names = F)
