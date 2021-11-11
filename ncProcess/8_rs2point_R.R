library(sf)
library(sp)
library(raster)
library(magrittr)

setwd('D:\\Users\\Yuxuan Lin\\Documents\\LocalFiles\\XMU\\CMIP6')

# c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')

for (depth in c('surface')){
  for (scen in list.files(paste0('7_data_expand_itp/',depth))){
    for (para in list.files(paste0('7_data_expand_itp/',depth,'/',scen))){
      for (f in list.files(paste0('7_data_expand_itp/',depth,'/',scen,'/',para))){
        fromdir <- paste0('7_data_expand_itp/',depth,'/',scen,'/',para,'/',f)
        rs <- raster(fromdir) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
        colnames(rs)[3] <- 'value'
        fname <- strsplit(f,'.tif')[[1]]
        
        rs.sf <- st_as_sf(rs, coords = c('x','y'), crs=4326)
        st_write(rs.sf, paste0('8_rs2point/',depth,'/',scen,'/',para,
                               '/',fname,'.shp'))
      }
      print(paste0(depth,'-',scen,'-',para,': complete'))
    }
  }
}

