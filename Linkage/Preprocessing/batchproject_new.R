library(sf)
library(raster)
library(magrittr)


setwd('D:/Users/Yuxuan Lin/Documents/LocalFiles/XMU/Connectivity/Linkage/Batch')

for (hemi in c('N_hemi', 'S_hemi')){
  files <- list.files(hemi, recursive = T, full.names = T)
  for (f in files){
    para <- strsplit(f,'/')[[1]][2]
    depth <- strsplit(f,'/')[[1]][3]
    fname <- strsplit(f,'/')[[1]][length(strsplit(f,'/')[[1]])]
    
    # set output path
    if (length(strsplit(fname,'_')[[1]])==4){
      ## future
      scen <- strsplit(fname,'_')[[1]][3]
      to_path <- paste0(hemi,'sphere/',para,'/',depth,'/',scen,'/',
                        strsplit(hemi, '_')[[1]][1],'_',fname)
    }else{
      ## present
      to_path <- paste0(hemi,'sphere/',para,'/',depth,'/',
                        strsplit(hemi, '_')[[1]][1],'_',fname)
    }
    
    # output projected raster
    if (strsplit(hemi, '_')[[1]][1] == 'N'){
      ## Northern hemisphere
      projectRaster(raster(f), 
                    crs = "+proj=aeqd +lat_0=90 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
                    method = "ngb", over = FALSE, filename =  to_path, overwrite = T)
    }else{
      ## Southern hemisphere
      projectRaster(raster(f), 
                    crs = "+proj=aeqd +lat_0=-90 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
                    method = "ngb", over = FALSE, filename =  to_path, overwrite = T)
    }
  }
}


