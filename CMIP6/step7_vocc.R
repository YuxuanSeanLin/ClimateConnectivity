# install VoCC (Garcia Molinos et al. 2019)
# devtools::install_github("JorGarMol/VoCC", dependencies = TRUE, force = TRUE)
library(VoCC)
library(raster)

setwd('')

for (h in c('surface', 'mesopelagic', 'bathypelagic', 'abyssopelagic')){
  for (s in c('ssp126', 'ssp245', 'ssp370', 'ssp585')){
    # select by period
    list <- c()
    for (ls in list.files(paste0('future/',h,'/',s), full.names = T)){
      for (yr in seq(2020,2100)){
        if (grepl(yr, ls) == TRUE){
          list <- append(list, ls)
        }
      }
    }
    
    # import raster stack
    rs <- stack(list)
    
    # calculate climate velocity
    vt <- tempTrend(rs, th = 20)
    vg <- spatGrad(rs, th = 0.0001, projected = FALSE)
    gv <- gVoCC(vt, vg)
    
    # output
    writeRaster(gv, paste0('vocc/',h,'/vocc_',h,'_',s,'.tif'))
    print(paste0(h,'-',s,'-complete'))
  }
}


