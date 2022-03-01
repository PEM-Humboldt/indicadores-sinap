
# Estandar

Standard_1990 <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990,
                      z = 0.5, beta = NULL, rad = 26.5, reescal = T)

# Variando el radio del buffer

radios <- c(seq(2, 30, 4), 26.5) %>% sort()

radios_res_1990 <- lapply(X = radios, function(X){
    All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, rad = X)
    ResX <- All$integ_vector
    return(ResX)
  }
)

# Variando el beta

betas <- seq(0.1, 1, 0.1)

betas_res_1990 <- lapply(X = betas, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, beta = X)
  ResX <- All$integ_vector
  return(ResX)
}
)

# reescalando

reescals <- c(F, T)

reescal_res_1990 <- lapply(X = reescals, function(X){
  All <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990, reescal = X)
  ResX <- All$integ_vector
  return(ResX)
}
)

all_pars_1990 <- lapply()



Standard_2010 <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = RUNAP_shp_2010,
                          z = 0.5, beta = NULL, rad = 26.5, reescal = T)
