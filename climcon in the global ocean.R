#climcon in the global ocean
library(raster)
library(magrittr)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(ggplot2)
library(patchwork)
library(dplyr)

#reclassify climcon
depths <- c("surface","mesopelagic","bathypelagic","abyssopelagic")#,"abyssopelagic"
scens <- c("ssp126","ssp245","ssp585")#"ssp126",
for (depth in depths){
  # if (depth == "surface"){
  #   rcl <- matrix(c(-9,-8,-7,-6,-5,-4,-3,-2,-1,0,-8,-7,-6,-5,-4,-3,-2,-1,0,35,seq(-9,-1,1),1),ncol = 3,nrow = 10)
  # }
  # else if (depth == "mesopelagic"){
  #   rcl <- matrix(c(-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,35,seq(-10,-1,1),1),ncol=3,nrow=11)
  # }
  # else if (depth == "bathypelagic"){
  #   rcl <- matrix(c(-12,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,35,seq(-11,-1,1),1),ncol=3,nrow=11)
  # }
  # else {
  #   rcl <-matrix(c(-2,-1.5,-1,-0.5,0,-1.5,-1,-0.5,0,35,seq(-4,-1,1),1),ncol=3,nrow=5)
  # }
  rcl <-matrix(c(-12,-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0,-5,-4,-3,-2.5,-2,-1.5,-1,-0.5,0,35,seq(-9,-1,1),1),ncol=3,nrow=10)
  
  
    
  for (scen in scens){
    r <- raster(paste("G:/sine/connectivity/draw_data/ClimCon_2020/",depth,"/ClimCon_",depth,"_",scen,"_2020.tif",sep = ""))
    
    
    r_rcl <- reclassify(r,rcl = rcl)
    
    writeRaster(r_rcl,paste("G:/sine/connectivity/draw_data/ClimCon_rcl/ClimCon_",depth,"_",scen,"_rcl.tif",sep = ""),overwrite = T)
    
  }
} 


depths <- c("surface","mesopelagic","bathypelagic","abyssopelagic")
scens <- c("ssp245","ssp585")
climcon <- function(r){
  
  r_rcl_sf <- rasterToPolygons(r,na.rm = FALSE) %>% st_as_sf()
  colnames(r_rcl_sf) <- c("layer","geometry")#指定layer名字
  world_map_data <- ne_countries(scale = "medium", returnclass = "sf")
  
  lons <- seq(-180,180,360)
  lats <- seq(-90,90,180)
  grat <- graticule::graticule(lons,lats,proj = "+proj=robin")
  grat_sf <- st_as_sf(grat)
  
  
  
  p0 <- ggplot() + 
    geom_sf(data = r_rcl_sf,
            mapping = aes(fill = factor(layer),color = factor(layer)))+
    geom_sf(data = world_map_data,color ="grey30",fill = "grey30" )+
    geom_sf(data = grat_sf,color = "grey30",size = 1)+#加上外轮廓
    coord_sf(crs="+proj=robin")+#robin,moll+
    scale_fill_manual(values =c("1"="#E5E5E5","-1"="#ffeda0","-2"="#feb24c","-3"="#fd8d3c","-4"="#fc4e2a",
                                "-5"="#e31a1c","-6"="#b10026","-7"="#D22F63","-8"="#E84E8B","-9"="#8b3a62"),
                      na.value = "white")+
    scale_color_manual(values =c("1"="#E5E5E5","-1"="#ffeda0","-2"="#feb24c","-3"="#fd8d3c","-4"="#fc4e2a",
                                 "-5"="#e31a1c","-6"="#b10026","-7"="#D22F63","-8"="#E84E8B","-9"="#8b3a62"),
                       na.value = "white")+
    theme(plot.title = element_text(hjust = 0.5,size = 16,color = "grey30"),
          panel.background = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          legend.position = "none")
  p0
}


#按情景画，一列一列画
scenario <- c("SSP1-2.6","SSP2-4.5","SSP5-8.5")
depths <- c("mesopelagic","bathypelagic","abyssopelagic")
Depths <- c("Epipelagic","Mesopelagic","Bathypelagic","Abyssopelagic")
scens <- c("ssp126","ssp245","ssp585")
i <- 0
for (scen in scens){
  i <- i + 1
  r<-raster(paste("G:/sine/connectivity/draw_data/ClimCon_rcl/ClimCon_surface_",scen,"_rcl.tif",sep = ""))

  p <- climcon(r)+
    labs(title = scenario[i],y ="Epipelagic")+
    theme(plot.margin = unit(c(0,0,0,0),"mm"),
          axis.title.y = element_text(size = 14))
  j <- 1
  for (depth in depths){
    j <- j + 1
    r<-raster(paste("G:/sine/connectivity/draw_data/ClimCon_rcl/ClimCon_",depth,"_",scen,"_rcl.tif",sep = ""))
    
    p0 <- climcon(r)+
      ylab(Depths[j])+
      theme(plot.margin = unit(c(0,0,0,0),"mm"),
            axis.title.x = element_blank(),
            axis.title.y = element_text(size = 14),
            plot.title = element_blank())
    p <- p / p0
    print(paste(depth,"_",scen,"Done!",sep = ""))
    
  }
  p
  ggsave(paste("G:/sine/connectivity/mapping/cc/",scen,"_ver0615.png",sep = ""),width = 12,height = 24,units = "cm")
  
}

#draw,按深度画

scenario <- c("SSP1-2.6","SSP2-4.5","SSP5-8.5")
depths <- c("surface","mesopelagic","bathypelagic","abyssopelagic")
Depths <- c("Epipelagic","Mesopelagic","Bathypelagic","Abyssopelagic")
scens <- c("ssp245","ssp585")
j<-0
for (depth in depths){
  j<-j+1
  r<-raster(paste("G:/sine/connectivity/draw_data/ClimCon_rcl/ClimCon_",depth,"_ssp126_rcl.tif",sep = ""))
  p <- climcon(r)+
    labs(title = "SSP1-2.6",y = Depths[j])+
    theme(plot.margin = unit(c(0,0,0,0),"mm"),
          axis.title.y = element_text(size = 14))
  i <- 1
  for (scen in scens){
    i <- i + 1
    r<-raster(paste("G:/sine/connectivity/draw_data/ClimCon_rcl/ClimCon_",depth,"_",scen,"_rcl.tif"
                    ,sep = ""))
    p0 <- climcon(r)+
      labs(title = scenario[i])+
      theme(plot.margin = unit(c(0,0,0,0),"mm"),
            axis.title.y = element_blank())
    p <- p | p0
    print(paste(depth,"_",scen,"Done!",sep = ""))
  }
  p
  ggsave(paste("G:/sine/connectivity/mapping/cc/",depth,"_ver0610.png",sep = ""),width = 30,height = 6,units = "cm")
}