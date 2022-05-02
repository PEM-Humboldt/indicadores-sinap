library(data.table)

# parametros
radios <- c(seq(2, 30, 4), 26.5) %>% sort()
# betas <- c(seq(0, 1, 0.2))
# reescals <- c(T, F)

# aplicando parametros a diferentes años

# radios
radios_res_1990 <- lapply(X = radios, function(X){
    All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, rad = X, z = 0.5,
                    beta = 0.2, reescal = F)
    ResX <- All$integ_vector
    return(ResX)
  }
)

radios_1990 <- as.data.frame(do.call(cbind, radios_res_1990))
fwrite(radios_1990, "test_parameters_1990.csv", row.names = F)

############################################
# 2000

# radios
radios_res_2000 <- lapply(X = radios, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_2000, shp.Areas = RUNAP_shp_2000, rad = X, z = 0.5,
                  beta = 0.2, reescal = F)
  ResX <- All$integ_vector
  return(ResX)
}
)

radios_2000 <- as.data.frame(do.call(cbind, radios_res_2000))
fwrite(radios_2000, "test_parameters_2000.csv", row.names = F)

############################################
# 2010

# radios
radios_res_2010 <- lapply(X = radios, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = RUNAP_shp_2010, rad = X, z = 0.5,
                  beta = 0.2, reescal = F)
  ResX <- All$integ_vector
  return(ResX)
}
)

radios_2010 <- as.data.frame(do.call(cbind, radios_res_2010))
fwrite(radios_2010, "test_parameters_2010.csv", row.names = F)

############################################
# 2020

# radios
radios_res_2020 <- lapply(X = radios, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_2020, shp.Areas = RUNAP_shp_2020, rad = X, z = 0.5,
                  beta = 0.2, reescal = F)
  ResX <- All$integ_vector
  return(ResX)
}
)

radios_2020 <- as.data.frame(do.call(cbind, radios_res_2020))
colnames(radios_2020) <- radios
fwrite(radios_2020, "test_parameters_2020.csv", row.names = F)


#rm(RUNAP_shp_1990,RUNAP_shp_2010, human.footprint_1990, human.footprint_2010, size_1990, size_2010)


# ## Variando el beta
# 
# betas_res_1990 <- lapply(X = betas, function(X){
#   All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, beta = X)
#   ResX <- All$integ_vector
#   return(ResX)
# }
# )
# 
# # reescalando
# 
# reescal_res_1990 <- lapply(X = reescals, function(X){
#   All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, reescal = X)
#   ResX <- All$integ_vector
#   return(ResX)
# }
# )
# 
# # varying all parameters to 
# 
# list_vector <- list()
# names_vector <- as.character()
# 
# for(a in 1:length(betas)){
#   for(b in 1:length(radios)){
#     for(c in 1:length(reescals)){
#       index <- length(list_vector)+1
#       all_data <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, 
#                            beta = betas[a], rad = radios[b], reescal = reescals[c])
#       list_vector[[index]] <- all_data$integ_vector
#       names_vector[[index]] <- paste0("b", betas[a],"_", "r", radios[b], "_", "rs", reescals[c])
#     }
#   }
# }
# 
# names(list_vector) <- names_vector
# 

# 2010 all parameters
# list_vector <- list()
# names_vector <- as.character()
# 
# for(a in 1:length(betas)){
#   for(b in 1:length(radios)){
#     for(c in 1:length(reescals)){
#       index <- length(list_vector)+1
#       all_data <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = RUNAP_shp_2010, 
#                            beta = betas[a], rad = radios[b], reescal = reescals[c])
#       list_vector[[index]] <- all_data$integ_vector
#       names_vector[[index]] <- paste0("b", betas[a],"_", "r", radios[b], "_", "rs", reescals[c])
#     }
#   }
# }
# 
# names(list_vector) <- names_vector
# all_pars_2010 <- as.data.frame(do.call(cbind, list_vector))
# 
# ################
# ### Analisis ###
# ################
# 
# ## rescalar (TRUE-FALSE), existen diferencias cuando se varia?
# 
# inte_true <- test_parameters_1990[ , seq(1,108,2)]
# inte_false <- test_parameters_1990[ , seq(2,108,2)]
# 
# windows()
# boxplot(apply(inte_true, MARGIN = 2, mean, na.rm = T),
#         apply(inte_false, MARGIN = 2, mean, na.rm = T),
#         ylab = "Integridad media", xlab = c("Reescalado"), 
#         names = c("TRUE", "FALSE"), ylim = c(0, 1))
# 
# ## variación de las diferencias
# 
# diff_true_false <- inte_true - inte_false
# 
# mean.vector <- apply(diff_true_false, MARGIN = 2, FUN = mean, na.rm = T)
# 
# windows()
# for(i in 1:ncol(diff_true_false)){
#   mean.vector[i] <- mean(diff_true_false[,i], na.rm = T)
#   if(i == 1){
#     plot(1:125, diff_true_false[, i], ylim = c(-0.1, 0.5), type = "l",
#          xlab = "Areas protegidas", ylab = "Diferencia de la media de integridad al reescalar y no reescalar")  
#   }else{
#     lines(1:125, diff_true_false[, i], ylim = c(-0.1, 0.5))  
#   }
# }
# 
# ## Desagregacion de la variacion
# 
# grupos <- (1:length(betas))*(length(radios))
# 
# # reescalar x beta
# 
# mean.vector.betas <- list()
# integs <- list(inte_true, inte_false)
# names.integs <- c("Reescalado TRUE", "Reescalado FALSE")
# 
# windows()
# par(mfrow = c(1,2))
# for(a in 1:2){
#   integ <- integs[[a]]
#   for(i in 1:length(betas)){
#     if(i == 1){
#       mean.vector.betas[[i]] <- apply(integ[ , 1:grupos[i]], 2, FUN = mean, na.rm = T)    
#     }else{
#       mean.vector.betas[[i]] <- apply(integ[ , (grupos[i-1]+1): grupos[i]], 2, FUN = mean,
#                                       na.rm = T)  
#     }
#   }
#   names(mean.vector.betas) <- betas
#   mean.vector.betas <- as.data.frame(do.call(cbind, mean.vector.betas))
#   boxplot(mean.vector.betas, main = names.integs[a], ylim = c(0, 1),
#           xlab = "betas", ylab = "Integridad")
# }
# 
# # reescalar x buffer
# 
# mean.vector.buffer <- list()
# 
# windows()
# par(mfrow = c(1,2))
# for(a in 1:2){
#   integ <- integs[[a]]
#   for(i in 1:length(radios)){
#     cols <- seq(i,54,length(radios))
#     mean.vector.buffer[[i]] <- apply(integ[ , cols], MARGIN = 2, FUN = mean, na.rm = T)    
#   }
#   names(mean.vector.buffer) <- radios
#   mean.vector.buffer <- as.data.frame(do.call(cbind, mean.vector.buffer))
#   boxplot(mean.vector.buffer, main = names.integs[a], ylim = c(0, 1),
#           xlab = "Radio del buffer", ylab = "Integridad")
# }
# 
# # reescalar x beta x buffer
# 
# for(a in 1:2){
#   windows()
#   integ <- integs[[a]]
#   par(mfrow = c(1, length(grupos)))
#   for(i in 1:length(grupos)){
#     if(i == 1 ){
#       boxplot(integ[,1:grupos[i]], ylim = c(0.4, 1), names = radios, 
#               main = betas[i], xlab = "Radio del buffer", ylab = "Integridad")
#     }else{
#       boxplot(integ[(grupos[i-1]+1): grupos[i]], ylim = c(0.4, 1), 
#               names = radios, main = betas[i], yaxt='n', xaxt = 'n')
#     }
#   }
#   mtext(names.integs[a], side = 3, line = -1.5, outer = TRUE)
# }
# 
# ###
# 
# # betas 0, 0.2, 0.4, 0.6, 0.8, 1
