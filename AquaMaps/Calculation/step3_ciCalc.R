library(sf)
library(raster)
library(magrittr)

years <- ''
exp <- "exp8_2"
depths <- 
weight_main <- 8/5
weight_sub <- 2/12
for (year in years){
  for (dp in c("surface","mesopelagic","abyssopelagic","bathypelagic")){
    phys <- list.files(paste("F:/Lconnectivity/P3_S1_processing/CI_calculate/weight/",year,"/",dp,sep = ""))
    
    for (phy in phys){
      spes <- list.files(paste("F:/Lconnectivity/P3_S1_processing/CI_calculate/weight/",year,"/",dp,"/",phy,"/",sep = ""))
      if (length(spes)>0){
        for (spe in spes){
          spe_ci <- read.csv(paste("F:/Lconnectivity/P3_S1_processing/CI_calculate/weight/",year,"/",dp,"/",phy,"/",spe,sep = ""))
          spe_ci$CI_total <- (spe_ci[,10]*weight_main+
                                spe_ci[,11]*weight_main+
                                spe_ci[,12]*weight_main+
                                spe_ci[,16]*weight_main+
                                spe_ci[,18]*weight_main+
                                
                                spe_ci[,3]*weight_sub+
                                spe_ci[,4]*weight_sub+
                                spe_ci[,5]*weight_sub+
                                spe_ci[,6]*weight_sub+
                                spe_ci[,7]*weight_sub+
                                spe_ci[,8]*weight_sub+
                                spe_ci[,9]*weight_sub+
                                spe_ci[,13]*weight_sub+
                                spe_ci[,14]*weight_sub+
                                spe_ci[,15]*weight_sub+
                                spe_ci[,17]*weight_sub+
                                spe_ci[,19]*weight_sub)
          
          
        }
        # convert to sf
        rs.sf <- st_as_sf(dt, coords = c('x','y'), crs=4326)
        # create st from sf
        rs.sp <- as(rs.sf, "Spatial") 
        # create constant raster and rasterize from sp; export
        raster(crs = crs(rs.sp), vals = 1, resolution = c(1, 1), ext = extent(c(-180, 180, -90, 90))) %>%
          rasterize(rs.sp, ., field='CI_total', fun='first', mask = T) %>% 
          writeRaster(., '')
        
      }
      print(paste(dp,"done",sep = "_"))
    }
  }
}
