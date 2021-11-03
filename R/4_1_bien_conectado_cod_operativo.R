# Cambio en el porcentaje de área protegida y conectada del SINAP

# Paquetes

library(formattable)
library(cowplot)
library(raster)
library(sf)
library(dplyr)
library(rmapshaper)
library(Makurhini) 
library(terra) # necesaria version 1.3-22
library(Rcpp)

# Para instalar Makurhini use por favor 
# library(devtools)
# library(remotes)
# install_github("connectscape/Makurhini", dependencies = TRUE, upgrade = "never")
# Ver documentacion en https://github.com/connectscape/Makurhini 

# Para cargar los archivos del objeto RData
# load("bien_conectado_cod/bien_conectado_cod_operativo_objetos.RData")

# 1. Insumos

# 1.1. Huella Humana
# Preproceso:
# - Dejar a la misma extension del SINAP unido a las areas transfronterizas
# - Para referencia de 2020 se toma la mas cercana, 2018

HH1990 <- raster("capas_base_ejemplos/HuellaHumana/HH1990.tif")
HH2010 <- raster("capas_base_ejemplos/HuellaHumana/HH2010.tif")

# 1.2 Union SINAP y Areas transfronterizas 

# Preproceso:
# - Se remueven las areas colombianas de la capa de areas protegidas del mundo
# - Se recorta tal capa a un buffer de 100 km de los limites Nacionales (areas transfronterizas)
# - Se une las areas transfronterizas al RUNAP

AP_1990 <- read_sf("capas_base_ejemplos/RUNAP_WDPA/AP_1990.shp") %>% 
  st_transform(crs(HH1990)) %>%
  st_simplify(preserveTopology = TRUE, 100) %>% 
  st_buffer(0)

AP_2010 <- read_sf("capas_base_ejemplos/RUNAP_WDPA/AP_2010.shp") %>% 
  st_transform(crs(HH2010)) %>% 
  st_simplify(preserveTopology = TRUE,100) %>% 
  st_buffer(0)


# 1.3. Territorio nacional

COLOMBIA_FINAL <- read_sf("capas_base_ejemplos/NACIONAL/Colombia_FINAL.shp") %>% 
  st_transform(crs(HH2010)) %>%
  st_simplify(preserveTopology = TRUE, 100) %>% 
  st_buffer(0)

# 1.4 Territorial

Territorial <- read_sf("capas_base_ejemplos/Territorial/Territoriales_final.shp") %>% 
  st_transform(crs(HH2010)) %>%
  st_simplify(preserveTopology = TRUE,100) %>% 
  st_buffer(0)

# 2. Funciones

# 2.1 Extraer datos de la funcion MK_ProtConn por region estudiada
#
# obj_protcon: Protconn list, objeto creado al usar la funcion MK_ProtConn
# tiempo: temporalidad del calculo
#
#
# return: data.frame, ProtConn_only: mantiene los datos del calculo de ProtConn 
# Columnas "ProtConn" 
# Row name: temporalidad del del calculo
#

extract_data_protconn <- function(obj_protcon, tiempo){
  if(class(obj_protcon) == "list"){
    y.2 <- obj_protcon[[1]] %>% as.data.frame()
    y.2 <- y.2[,3:4]
  }else{
    y.2 <- obj_protcon[, 3:4]
  }
  y.2 <- t(y.2) %>% as.data.frame()
  names(y.2) <- y.2[1,]
  y.2 <- y.2[2,]
  row.names(y.2) <- NULL
  
  ProtConn_only <- y.2[ , "ProtConn"] %>% as.numeric()
  
  return(data.frame(ProtConn = ProtConn_only, row.names = tiempo))
}

# 2.2 Diferencia de porcentaje de areas protegidas y conectadas en dos periodos de tiempo

dProtconn <- function(vector_protconn){
  diff_vector <- diff(vector_protconn)
  dProtConni <- diff_vector / vector_protconn[1:length(vector_protconn)-1] * 100
  dProtConn_vector <- c(0, dProtConni)
  names(dProtConn_vector) <- "dProtConn"
  return(dProtConn_vector)
}

# Nota: funciones necesarias para el calculo del indicador protconn se encuentran 
# dentro del paquete Makhurini,

# 3. Aplicación

# 3.1 Nacional

dir.create("productos/bien_conectado")

dir.create("productos/bien_conectado/bien_conectado_gdb")

dir.create("productos/bien_conectado/bien_conectado_gdb/Nacional")

# 3.1.1 Calcular ProtConn

# A. 1990

AP_1990_10k_cost <- MK_ProtConn(nodes = AP_1990, region = COLOMBIA_FINAL,area_unit = "ha",
                                distance = list(type= "least-cost", resistance = HH1990,
                                                least_cost.java = TRUE, cores.java = 3, 
                                                ram.java = 4),
                                distance_thresholds = 10000,probability = 0.5, 
                                transboundary = 100000,LA = NULL, plot = TRUE,
                                write = "productos/bien_conectado/bien_conectado_gdb/Nacional/AP_1990_10k_cost", 
                                intern = TRUE)

# C. 2010

AP_2010_10k_cost <- MK_ProtConn(nodes = AP_2010, region = COLOMBIA_FINAL,area_unit = "ha",
                                distance = list(type= "least-cost", resistance = HH2010,
                                                least_cost.java = TRUE, cores.java = 3, 
                                                ram.java = 4),
                                distance_thresholds = 10000,probability = 0.5, 
                                transboundary = 100000,LA = NULL, plot = TRUE,
                                write = "productos/bien_conectado/bien_conectado_gdb/Nacional/AP_2010_10k_cost", intern = TRUE)

# Compilar corridas Areas Protegidas ProtConn a 10 km costo
AP_10k_data <- list(AP_1990_10k_cost, AP_2010_10k_cost)

# Vector de periodos corridos
tiempos = c("1990", "2000", "2010", "2020")

AP_10k_ProtConn <- mapply(FUN = extract_data_protconn, AP_10k_data, tiempos, SIMPLIFY = F)
AP_10k_ProtConn <- do.call(rbind, AP_10k_ProtConn)

# 3.1.2 Calcular cambio o delta ProtConn

AP_10k_dProtConn <- dProtconn(AP_10k_ProtConn[ , "ProtConn"]) %>%
  round(2) %>% as.data.frame()

colnames(AP_10k_dProtConn) <- "dProtConn"

# 3.2 Territorial

# Crear carpeta territoriales
dir.create("productos/bien_conectado/bien_conectado_gdb/Territoriales")

# 3.2.1 Calcular ProtConn

# A. 1990

TERR_AP_1990_10k_cost <- lapply(1:nrow(Territorial), function(x) { 
  
  #Terrx salida (intermedia)
  Terrx <- MK_ProtConn(nodes = AP_1990,region = Territorial[x,],
                       area_unit = "ha",
                       distance = list(type= "least-cost",resistance = HH1990,
                                       resist.units = FALSE, least_cost.java = TRUE,
                                       cores.java = 3, ram.java = 4),
                       distance_thresholds = 10000, probability = 0.5,
                       transboundary = 20000, transboundary_type = "region",
                       protconn_bound = FALSE, LA = NULL, plot = TRUE,
                       intern = TRUE)
  }
)

# B. 2010

TERR_AP_2010_10k_cost <- lapply(1:nrow(Territorial), function(x) { 
  
  #Terrx salida (intermedia)
  Terrx <- MK_ProtConn(nodes = AP_2010,region = Territorial[x,],
                       area_unit = "ha",
                       distance = list(type= "least-cost",resistance = HH2010,
                                       resist.units = FALSE, least_cost.java = TRUE,
                                       cores.java = 3, ram.java = 4),
                       distance_thresholds = 10000, probability = 0.5,
                       transboundary = 20000, transboundary_type = "region",
                       protconn_bound = FALSE, LA = NULL, plot = TRUE,
                       intern = TRUE)
}
)

TERR_AP_10k_data <- list(TERR_AP_1990_10k_cost, TERR_AP_2010_10k_cost)

# Datos protconn

TERR_AP_10k_ProtConn <- list()
for(i in 1:length(TERR_AP_10k_data)){
  tmp <- mapply(extract_data_protconn, TERR_AP_10k_data[[i]], tiempo = "", 
                SIMPLIFY = F)
  tmp <- do.call(rbind, tmp)
  TERR_AP_10k_ProtConn[[i]] <- tmp
}

TERR_AP_10k_ProtConn <- do.call(cbind, TERR_AP_10k_ProtConn)

colnames(TERR_AP_10k_ProtConn) <- paste0("ProtConn", tiempos)
row.names(TERR_AP_10k_ProtConn) <- Territorial$nombre

# 3.2.2 Calcular delta Protconn Territoriales

TERR_AP_10k_dProtConn <- apply(TERR_AP_10k_ProtConn, MARGIN = 1, dProtconn) %>% 
  round(2) %>% t() %>% as.data.frame()

colnames(TERR_AP_10k_dProtConn) <- paste0("dProtConn", tiempos)

# Agregar al Shapefile

TERRITORIAL_dProtConn <- cbind(Territorial, TERR_AP_10k_ProtConn, TERR_AP_10k_dProtConn) 

# Escribir shapefiles

write_sf(TERRITORIAL_dProtConn, paste0("productos/bien_conectado/bien_conectado_gdb/
                                       Territoriales/Territorial_bien_conectado.shp"))


# save(AP_1990, AP_1990_10k_cost, AP_2000, AP_2000_10k_cost, AP_2010, AP_2010_10k_cost,
#      AP_2020, AP_2020_10k_cost, COLOMBIA_FINAL, HH1990, HH2000, HH2010, HH2020,
#      TERR_AP_1990_10k_cost, TERR_AP_2000_10k_cost, TERR_AP_2010_10k_cost, TERR_AP_2020_10k_cost,
#      Territorial, extract_data_protconn, tiempos, dProtconn,
#      TERR_AP_10k_data, TERR_AP_10k_ProtConn, TERR_AP_10k_dProtConn,
#      AP_10k_data, AP_10k_ProtConn, AP_10k_dProtConn, TERRITORIAL_dProtConn,
#      file = "bien_conectado_cod/bien_conectado_cod_operativo_objetos.RData")
