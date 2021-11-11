library(rgdal)
hi_sur_sp <- readOGR("F:/Lconnectivity/P3_S1_processing/hi_1deg_processed/surf","hi_sur_all")
hi_sur <- as.data.frame(hi_sur_sp)#转化为dataframe
str(hi_sur)

hi_sur_lm <- hi_sur[,3:13]#提取需要的历年hi，此时有11列，每列为不同年份hi

hi_sur_lm <- as.data.frame(t(hi_sur_lm))#行列转换，行为年，列为点。11 observations

#最终待处理数据
hi_sur_lm$time <- c(2003:2013)#新建1列存放年份信息
str(hi_sur_lm)

#循环回归并把slope和intercept添加至某一数据框
data_sl_in <- data.frame(slope_lm = c(1:nrow(hi_sur)), 
                         int_lm = c(1:nrow(hi_sur)),
                         R2_lm = c(1:nrow(hi_sur)),
                         
                         slope_lmr = c(1:nrow(hi_sur)), 
                         int_lmr = c(1:nrow(hi_sur)),
                         R2_lmr = c(1:nrow(hi_sur)))


#开始回归
for (i in 1:nrow(hi_sur)){
  
  #35447、35700有问题
  #21,37356报错'dimnames'的长度[1]必需与陈列范围相等，可以单独跑，其他继续
  
  hi_lm <- lm(hi_sur_lm[,i] ~ time, data = hi_sur_lm)
  data_sl_in$slope_lm[i] <- hi_lm$coefficients[[2]]#提取参数
  data_sl_in$int_lm[i] <- hi_lm$coefficients[[1]]#提取参数
  data_sl_in$R2_lm[i] <- summary(hi_lm)$r.squared#提取参数
  
  if (sum(hi_sur_lm[,i])==0){
    data_sl_in$slope_lmr[i] <- 999
    data_sl_in$int_lmr[i] <- 999
    data_sl_in$R2_lmr[i] <- 999
    #lmrob在y全为0的时候会报错，Error in numeric(seq_len(ar)) : 'length'参数不对
    
  }
  else{
    hi_lmr <- lmrob(hi_sur_lm[,i] ~ time, data = hi_sur_lm)
    data_sl_in$slope_lmr[i] <- hi_lmr$coefficients[[2]]#提取参数
    data_sl_in$int_lmr[i] <- hi_lmr$coefficients[[1]]#提取参数
    data_sl_in$R2_lmr[i] <- summary(hi_lmr)$r.squared#提取参数
  }
  
}

#把有问题的参数都设为0
data_sl_in$slope_lmr[which(data_sl_in$slope_lmr>1)] <- 0
data_sl_in$int_lmr[which(data_sl_in$int_lmr>1)] <- 0
data_sl_in$R2_lmr[which(data_sl_in$R2_lmr>1)] <- 0

#最后参数导出
str(data_sl_in)
hi_lm_result <- cbind(hi_sur,data_sl_in)
str(hi_lm_result)

write.csv(hi_lm_result,"F:/Lconnectivity/P3_S1_processing/hi_1deg_processed/surf/hi_lm_rlm_result_sur.csv")


#检查有无nan,infinate
value_p <- c()
value <- c()

for (i in 1:nrow(hi_sur_lm)){
  if (any(is.inf(hi_sur_lm[,i]))== TRUE){
    append(value_p,i)
  }
}

for (i in 1:nrow(hi_sur_lm)){
  if (any(is.na(hi_sur_lm[,i]))== TRUE){
    append(value_p,i)
  }
}

for (i in 1:nrow(hi_sur)){
  if (data_sl_in[i,4] == i){
    value_p <- append(value_p,i)
  }
}
