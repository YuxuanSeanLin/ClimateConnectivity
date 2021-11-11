library(raster)
library(magrittr)

# # all parameters
# c('bacc', 'detoc', 'dfe', 'dissic', 'dissoc',
#   'nh4', 'no3', 'o2', 'ph', 'phyc', 'po4', 'pp',
#   'si', 'so', 'talk', 'thetao', 'zooc')


# set work dictionary
setwd('D:/Users/Yuxuan Lin/Documents/LocalFiles/XMU/Connectivity/AquaMaps')

# define function
func <- function(d, env_surf, env_meso, env_bathy, env_abysso){
  if (d == 'surface'){env <- mask(env_surf, r) %>% 
      as.data.frame() %>% .[complete.cases(.),]}
  else if (d == 'mesopelagic'){env <- mask(env_meso, r) %>% 
      as.data.frame() %>% .[complete.cases(.),]}
  else if (d == 'bathypelagic'){env <- mask(env_bathy, r) %>% 
    as.data.frame() %>% .[complete.cases(.),]}
  else if (d == 'abyssopelagic'){env <- mask(env_abysso, r) %>% 
    as.data.frame() %>% .[complete.cases(.),]}
  return(env)
}


# initialize
para <- 'bacc'
mem <- 'Acanthocephala'
tolerance <- c()
interval <- c()

# load species dataset
spelist <- read.csv('distribution/historical/Species_list.csv')
row.names(spelist) <- spelist$name

# load env dataset
env_surf <- list.files(paste0('cmip6_historical/surface/',para), 
                       pattern = '*tif$', full.names = T) %>% stack()
env_meso <- list.files(paste0('cmip6_historical/mesopelagic/',para), 
                       pattern = '*tif$', full.names = T) %>% stack()
env_bathy <- list.files(paste0('cmip6_historical/bathypelagic/',para), 
                        pattern = '*tif$', full.names = T) %>% stack()
env_abysso <- list.files(paste0('cmip6_historical/abyssopelagic/',para), 
                         pattern = '*tif$', full.names = T) %>% stack()

# main part
for (spe in spelist$name){
  
  # start time
  t1=proc.time()
  
  all_layer <- c()
  exist <- spelist[spe,] %>% as.character()
  phy <- exist[2]
  
  # identify progress
  if (mem != phy){print(paste0(mem, ' - complete'))}
  
  # extract not NA
  distri <- colnames(spelist)[which(exist != 'NA')][-c(1,2)]
  
  # integrate envs of different distribution layers
  for (d in distri){
    # input species raster
    r <- raster(paste0('SpeciesDistribution/',d,'/',phy,'/',spe,'.tif'))
    # mask rasterstack
    env <- func(d, env_surf, env_meso, env_bathy, env_abysso)
    colnames(env) <- seq.int(1984, 2014)
    
    # integrate
    all_layer <- rbind(all_layer, env)
  }
  
  # create empty array
  max_list <- c()
  min_list <- c()
  
  # integrate extreme value among period (1984-2014)
  for (id in 1:31){
    max_list <- append(max_list, max(all_layer[,id], na.rm=T))
    min_list <- append(min_list, min(all_layer[,id], na.rm=T))
  }
  
  # calculate tolerance
  interval <- rbind(interval, 
                    cbind(species=spe, phylum=phy, parameter=para, 
                          lower_2sd=mean(min_list)-2*sd(min_list), 
                          lower_sd=mean(min_list)-sd(min_list),
                          lower=mean(min_list), upper=mean(max_list), 
                          upper_sd=mean(max_list)+sd(max_list),
                          upper_2sd=mean(max_list)+2*sd(max_list)))
  if (nrow(interval) > 1000){
    tolerance <- rbind(tolerance, interval)
    interval <- c()
  }
  
  # identify
  mem <- phy
  
  # stop time
  t2=proc.time()
  t=t2-t1
  print(paste0(phy,'-',spe,' - time elapsed:',round(t[3][[1]], 4),'second'))

}

# export csv
as.data.frame(tolerance) %>% 
  write.csv(., paste0('tolerance/',para,'.csv'))

