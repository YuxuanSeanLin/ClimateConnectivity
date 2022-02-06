library(magrittr)
library(dplyr)
library(raster)
library(sf)

setwd('D:/LinkageMapper/Statistics')

for (h in c('surface','mesopelagic','bathypelagic','abyssopelagic')){
  for (s in c('ssp126','ssp245','ssp370','ssp585')){
    for (yr in seq(2020,2050,10)){
      #####
      print(paste0('----Start: ',h,'-',s,'-',yr,'----'))
      
      # load linkage data
      link <- read.csv(paste0('linkage_global/',h,'/',s,'/link_',h,'_',s,'_',yr,'.csv'))
      
      cc_patch <- c() %>% as.data.frame()
      for (p in unique(link$Origin)){
        #####
        # Step1: exhaust all possible routes for migration (LCP only)
        print(paste0('Start core #',p,' ...'))
        
        ## calculate number of loops
        to_p <- subset(link, Origin==p)$Dest
        loop <- 1
        route <- cbind(From=p,To_1=to_p) %>% as.data.frame()
        
        ## exhaustion of all possible combinations
        repeat{
          new_to_p <- to_p
          for (rec in to_p){new_to_p <- append(new_to_p, subset(link, Origin==rec)$Dest)}
          new_to_p <- unique(new_to_p)
          
          if (length(new_to_p)==length(to_p)){break}else{
            loop=loop+1
            
            ## add to new routine table
            route_add <- cbind(route, -1)
            colnames(route_add)[ncol(route_add)] <- 'To'
            for (n in new_to_p){
              if (n %in% to_p == F){
                route_add <- rbind(route_add, cbind(route,To=n))
              }
            }
            route_add <- subset(route_add, To>0)
            colnames(route_add)[ncol(route_add)] <- paste0('To_',loop)
            row.names(route_add) <- seq(1,nrow(route_add))
            
            ## eliminate wrong pairs (comparing with linkage table)
            for (c in 2:(ncol(route_add)-1)){
              ### scan all routes
              for (r in 1:nrow(route_add)){
                from=route_add[r,c] %>% as.numeric()
                to=route_add[r,c+1] %>% as.numeric()
                ### set NA for wrong routes
                if (length(which(link$Origin==from & link$Dest==to))==0){
                  route_add[r,(c+1):ncol(route_add)] <- NA
                }
              }
              ### eliminate duplicate records
              route_add <- unique(route_add)
              row.names(route_add) <- seq(1,nrow(route_add))
            }
            
            ## renew
            to_p=new_to_p
            route <- route_add
          }
        }

        ## calculate number of step stones
        steps <- ncol(route)-1
        
        
        
        #####
        # Step2: calculate climate connectivity
        
        ## create temperature table
        temp_pre <- cbind(From=link$Origin, From_pre=link$Origin_pre) %>% 
          unique() %>% as.data.frame()
        temp_fut <- cbind(To=link$Dest, To_fut=link$Dest_fut) %>% 
          unique() %>% as.data.frame()
        
        ## join present origin temperature to routine table
        route_cc <- route
        route_cc <- left_join(route_cc, temp_pre, by = 'From')
        
        ## join future destination temperature to routine table
        for (c in 2:(steps+1)){
          colnames(route_cc)[c] <- 'To'
          route_cc <- left_join(route_cc, temp_fut, by = 'To')
          colnames(route_cc)[c(c,(c+steps+1))] <- c(paste0('To_',(c-1)),paste0('ClimCon_',(c-1)))
        }
        
        ## calculate climate connectivity of each designated end patch
        for (c in (steps+3):ncol(route_cc)){
          for (r in which(is.na(route_cc[,c])==F)){
            route_cc[r,c] <- route_cc$From_pre[r]-route_cc[r,c]
          }
        }
        route_cc <- route_cc[,-(steps+2)]

        ## select maximum climate connectivity (capacity to sustain climate-driven migration)
        max_cc <- route_cc[,(steps+2):ncol(route_cc)] %>% 
          as.matrix() %>% as.numeric() %>% na.omit() %>% max()
        
        ## combine tables
        cc_patch <- rbind(cc_patch, cbind(patch=p, ClimCon=max_cc))
        
        
        print(paste0('Complete core #',p))
        print('----------------')
      }
      
      # export data
      write.csv(cc_patch, 
                paste0('ClimCon/',h,'/ClimCon_',h,'_',s,'_',yr,'.csv'), 
                row.names = F)

      print(paste0('----Complete: ',h,'-',s,'-',yr,'----'))
    }
  }
}

