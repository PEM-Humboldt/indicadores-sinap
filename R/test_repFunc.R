library(data.table)

# Default

default_1990 <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990,
                      z = 0.5, beta = NULL, rad = 26.5, reescal = T)

# parametros
radios <- c(seq(2, 30, 4), 26.5) %>% sort()
betas <- c(seq(0, 1, 0.2))
reescals <- c(T, F)

# aplicando parametros a diferentes años

# radios
radios_res_1990 <- lapply(X = radios, function(X){
    All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, rad = X)
    ResX <- All$integ_vector
    return(ResX)
  }
)

# Variando el beta

betas_res_1990 <- lapply(X = betas, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, beta = X)
  ResX <- All$integ_vector
  return(ResX)
}
)

# reescalando

reescal_res_1990 <- lapply(X = reescals, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, reescal = X)
  ResX <- All$integ_vector
  return(ResX)
}
)

# varying all parameters to 

list_vector <- list()
names_vector <- as.character()

for(a in 1:length(betas)){
  for(b in 1:length(radios)){
    for(c in 1:length(reescals)){
      index <- length(list_vector)+1
      all_data <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, 
                           beta = betas[a], rad = radios[b], reescal = reescals[c])
      list_vector[[index]] <- all_data$integ_vector
      names_vector[[index]] <- paste0("b", betas[a],"_", "r", radios[b], "_", "rs", reescals[c])
    }
  }
}

names(list_vector) <- names_vector
all_pars_1990 <- as.data.frame(do.call(cbind, list_vector))

fwrite(all_pars_1990, "test_parameters_1990.csv", row.names = F)

############################################
# Default 2010 (mas areas pequeñas)

Standard_2010 <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = RUNAP_shp_2010,
                          z = 0.5, beta = NULL, rad = 26.5, reescal = T)


list_vector <- list()
names_vector <- as.character()

for(a in 1:length(betas)){
  for(b in 1:length(radios)){
    for(c in 1:length(reescals)){
      index <- length(list_vector)+1
      all_data <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = RUNAP_shp_2010, 
                           beta = betas[a], rad = radios[b], reescal = reescals[c])
      list_vector[[index]] <- all_data$integ_vector
      names_vector[[index]] <- paste0("b", betas[a],"_", "r", radios[b], "_", "rs", reescals[c])
    }
  }
}

names(list_vector) <- names_vector
all_pars_2010 <- as.data.frame(do.call(cbind, list_vector))

fwrite(all_pars_2010, "test_parameters_2010.csv", row.names = F)

