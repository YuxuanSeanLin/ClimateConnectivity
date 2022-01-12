library(sf)
library(raster)
library(magrittr)


######
# project future HI by anthropogenic CO2 emission scenarios 

setwd('')

files <- list.files('co2_em', full.names = T, recursive = T)

for (d in c("surface","mesopelagic","abyssopelagic","bathypelagic")){
  for (yr in c('2030','2040','2050')){
    ## import initial HI data (no scenarios)
    lists <- c()
    for (f in files){if (grepl(yr,f)){lists <- append(lists, f)}}
    lists <- append(lists, paste0('hi/',d,'/hi_',yr,'.tif'))
    
    ## import CO2 emission data
    co2em <- stack(lists) %>% as.data.frame(., xy=T) %>% .[complete.cases(.),]
    row.names(co2em) <- seq(1,nrow(co2em))
    colnames(co2em)[3:7] <- c('co2em_ssp126','co2em_ssp245','co2em_ssp370','co2em_ssp585','hi')
    
    ## calculate mean CO2 emission
    co2em$mean_em <- (co2em$co2em_ssp126 + co2em$co2em_ssp245 + 
                      co2em$co2em_ssp370 + co2em$co2em_ssp585) / 4
    
    ## calculate relative ratio
    co2em$ratio <- 1 / co2em$mean_em
    ## pretreatment to avoid error occurring where mean HI == 0
    for (i in which(is.finite(co2em$ratio) == FALSE)){co2em$ratio[i] <- 0}
    
    ## predict HI scenarios based on relative intensity among CO2 emission scenarios
    co2em$hi_ssp126 <- co2em$hi * co2em$ratio * co2em$co2em_ssp126
    co2em$hi_ssp245 <- co2em$hi * co2em$ratio * co2em$co2em_ssp245
    co2em$hi_ssp370 <- co2em$hi * co2em$ratio * co2em$co2em_ssp370
    co2em$hi_ssp585 <- co2em$hi * co2em$ratio * co2em$co2em_ssp585
    
    ## rasterize separately
    rs.sf <- st_as_sf(co2em, coords = c('x','y'), crs=4326)
    rs.sp <- as(rs.sf, "Spatial")
    ### ssp126
    rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1),
                 ext = extent(c(-180, 180, -90, 90))) %>%
      rasterize(rs.sp, ., field='hi_ssp126', fun='first')
    writeRaster(rs, paste0('hi_pred/',d,'/ssp126/hi_',d,'_ssp126_',yr,'.tif'), overwrite=T)
    
    ### ssp245
    rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1),
                 ext = extent(c(-180, 180, -90, 90))) %>%
      rasterize(rs.sp, ., field='hi_ssp245', fun='first')
    writeRaster(rs, paste0('hi_pred/',d,'/ssp245/hi_',d,'_ssp245_',yr,'.tif'), overwrite=T)
    
    ### ssp370
    rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1),
                 ext = extent(c(-180, 180, -90, 90))) %>%
      rasterize(rs.sp, ., field='hi_ssp370', fun='first')
    writeRaster(rs, paste0('hi_pred/',d,'/ssp370/hi_',d,'_ssp370_',yr,'.tif'), overwrite=T)
    
    ### ssp585
    rs <- raster(crs = crs(rs.sp), vals = 0, resolution = c(1, 1),
                 ext = extent(c(-180, 180, -90, 90))) %>%
      rasterize(rs.sp, ., field='hi_ssp585', fun='first')
    writeRaster(rs, paste0('hi_pred/',d,'/ssp585/hi_',d,'_ssp585_',yr,'.tif'), overwrite=T)
    
  }
}


