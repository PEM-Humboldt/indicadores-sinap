# Mayo de 2022

# Con el fin de identificar el efecto del tamaño del radio sobre el índice de integridad, 
# este codigo ayuda a calcular la diferencia del índice para cada área protegida en un mismo año utilizando 
# nueve diferentes radios: 2, 6, 10, 14, 18, 22, 26, 26.5 y 30 km. Este codigo crea los 
# datos crudos para desarrollar el analisis de sensibilidad
# vease: 
# https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional/datos_raw
# https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional

# Para ejecutar este codigo es necesario primero que:
# 1. Cargue los insumos del indicador de representatividad funcional/integridad
# 2. Cargue las funciones dentro del codigo operativo del indicador de representatividad funcional/integridad
# En terminos simples, ejecute el script 3_1_rep_func_operativo.R hasta la linea 354
# https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/R/3_1_rep_func_operativo.R#L354

# Librerias

library(data.table)

# parametros
radios <- c(seq(2, 30, 4), 26.5) %>% sort()

# aplicando parametros a diferentes años

############################################
# 1990

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
