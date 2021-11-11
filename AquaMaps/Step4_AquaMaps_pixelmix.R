library(raster)
library(magrittr)
library(sf)


# os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel")
# for t in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample"):
#   os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s" % t)
# for h in ['surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic']:
#   os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s\%s" % (t, h))
# for percent in ['25', '50', '75', '100']:
#   os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s\%s\%s" % (t, h, percent))
# for p in os.listdir(r"G:\LinYuxuan\AquaMaps\Threshold_resample\%s\%s" % (t, h)):
#   os.mkdir(r"G:\LinYuxuan\AquaMaps\Threshold_pixel\%s\%s\%s\%s" % (t, h, percent, p))

pixelmix <- function(rs, perc, output_path){
  dt <- as.data.frame(rs, xy = T) %>% 
    .[complete.cases(.),]
  colnames(dt)[3] <- "value"
  crit <- as.integer(perc) / 100 * 4
  
  # rasterize
  newdt <- subset(dt, value >= crit)
  if (nrow(newdt) != 0){
    newdt <- cbind(newdt, val=1)
    rs.sf <- st_as_sf(newdt, coords = c('x','y'), crs=4326)
    rs.sp <- as(rs.sf, "Spatial") 
    rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1), 
                 ext = extent(c(-180, 180, -90, 90))) %>%
      rasterize(rs.sp, ., field='val', fun='first')  
    writeRaster(rs, output_path, overwrite=T) 
  }else{}
}


from_dir <- "G:/LinYuxuan/AquaMaps/Threshold_resample"
to_dir <- "G:/LinYuxuan/AquaMaps/Threshold_pixel"

# c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')
# c('25', '50', '75', '100')
for (t in list.files(from_dir)){
  for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
    for (perc in c('25', '50', '75', '100')){
      for (p in list.files(paste0(from_dir,'/',t,'/',h))){
        setwd(paste0(from_dir,'/',t,'/',h,'/',p))
        files <- list.files(full.names = F, pattern='*.tif$')
        for (f in files){
          to_path <- paste0(to_dir,'/',t,'/',h,'/',perc,'/',p,'/',f)
          raster(f) %>% pixelmix(., perc, to_path)
        }
        print(paste0(h, ': ', perc,', ', p,', complete'))
      }
    }
  }
  print(paste0(t, ' threshold, complete ==='))
}


