
# Default

default_1990 <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990,
                      z = 0.5, beta = 1, rad = 17, reescal = T)

# Variando el radio del buffer

radios <- c(seq(2, 30, 4), 26.5) %>% sort()

radios_res_1990 <- lapply(X = radios, function(X){
    All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, rad = X)
    ResX <- All$integ_vector
    return(ResX)
  }
)

# Variando el beta

betas <- c(seq(0, 1, 0.1))

betas_res_1990 <- lapply(X = betas, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, beta = X)
  ResX <- All$integ_vector
  return(ResX)
}
)

# reescalando

reescals <- c(T, F)

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
      all_data <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, 
               beta = betas[a], rad = radios[b], reescal = reescals[c])
      index <- length(list_vector)+1
      list_vector[index] <- all_data$integ_vector
      names_vector[index] <- paste0("b", betas[a],"_", "r", radios[b], "_", "rs", reescals[c])
    }
  }
}

all_pars_1990 <- as.data.frame(do.call(cbind, all_pars_1990))

############################################
# Default 2010 (mas areas pequeñas)

Standard_2010 <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = RUNAP_shp_2010,
                          z = 0.5, beta = NULL, rad = 26.5, reescal = T)
