library(magrittr)
library(raster)
library(sf)

rasterize_func <- function(dt, fieldv){
  rs.sf <- st_as_sf(dt, coords = c('Longitude','Latitude'), crs=4326)
  
  # create st from sf
  rs.sp <- as(rs.sf, "Spatial") 
  
  # create constant raster and rasterize from sp
  rs <- raster(crs = crs(rs.sp), vals = 1, resolution = c(0.5, 0.5), ext = extent(c(-180, 180, -90, 90))) %>%
    rasterize(rs.sp, ., field=fieldv, fun='first', mask = T)  
  
  return (rs)
}

# built a null raster
# null <- raster(crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0", 
#                vals = 0, resolution = c(0.5, 0.5), ext = extent(c(-180, 180, -90, 90)))


setwd("G:/LinYuxuan/AquaMaps")

# threshold <- list.files("Threshold_csv") 
threshold <- c(30, 40)

for (t in threshold){
  level <- list.files(paste0("Threshold_csv/",t))
  for (h in level){
    phylums <- list.files(paste0("Threshold_csv/",t,'/',h))
    for (p in phylums){
      species <- list.files(paste0("Threshold_csv/",t,'/',h,'/',p))
      for (s in species){
        to_path <- paste0("Threshold_tif/",t,'/',h,'/',p,'/',
                          substring(s,1,nchar(s)-4),'.tif')
        dt <- paste0("Threshold_csv/",t,'/',h,'/',p,'/',s) %>% 
          read.csv(.) %>% subset(., occurrence == 1)
        
        if (nrow(dt) > 0){rasterize_func(dt, "occurrence") %>% writeRaster(., to_path)}
        else{next}
      }
      print(paste0(t,' - ',h,' - ',p," - finish"))
    }
  }
}

