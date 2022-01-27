library(sf)
library(raster)
library(magrittr)
library(VoCC)

setwd('')

#####
# calculate gradient-based velocity

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    # select by period
    list <- c()
    for (ls in list.files(paste0('temperature/',h,'/',s), full.names = T)){
      for (yr in seq(2020,2099)){
        if (grepl(yr, ls) == TRUE){
          list <- append(list, ls)
        }
      }
    }
    
    # start from different years
    for (yr in seq(2020, 2050, 10)){
      # select by period (20x0~2099, decadal intervals)
      for (y in seq(yr-30,yr-1)){list <- list[which(grepl(y, list) == FALSE)]}
      
      # import raster stack
      rs <- stack(list)
      
      # extend data
      rs1 <- crop(rs, extent(-180, -179, -90, 90))
      rs2 <- crop(rs, extent(179, 180, -90, 90))
      extent(rs1) <- c(180, 181, -90, 90)
      extent(rs2) <- c(-181, -180, -90, 90)
      newrs <- merge(rs2, rs, rs1)
      
      # calculate climate velocity
      vt <- tempTrend(newrs, th = 20)
      vg <- spatGrad(newrs, th = 0.0001, projected = FALSE)
      gv <- gVoCC(vt, vg)
      gv <- crop(gv, extent(-180, 180, -90, 90))
      
      # output
      writeRaster(gv, paste0('velocity/',h,'/',s,'/','vocc_',h,'_',s,'_',yr,'.tif'), overwrite=T)
      print(paste0(h,'-',s,'-',yr,'-complete'))
      
    }
  }
}

