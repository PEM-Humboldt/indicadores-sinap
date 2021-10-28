library("dismo")
library("sf")
library("rgdal")
library("raster")
library("qpcR")
library("dplyr")

# to load objects in the RData file
# load("rep_rri_cod/rep_ri_objetos_operativo.RData")

# 1. Insumos

# 1.1 modelos de especies
# Primero descromprimir el archivo Nivel1.7z en su respectiva carpeta
espec_mod <- stack(list.files("rep_rri_capas_base/BioModelos_N1/Nivel1/","tif",full.names=TRUE)) 

# 1.2 Cargar SINAP alias historico RUNAP a WGS84.

ap1990 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_1990.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap1994 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_1994.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap1998 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_1998.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap2000 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_2000.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap2002 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_2002.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap2006 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_2006.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap2010 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_2010.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap2014 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_2014.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap2018 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_2018.shp") %>% spTransform(CRS("+init=epsg:4326"))
ap2020 <- shapefile("rep_rri_capas_base/RUNAP_historico/RUNAP_2020.shp") %>% spTransform(CRS("+init=epsg:4326"))

# 2. Funciones

# 2.1 Representatividad de especies por periodo de SINAP
#
# raster_spec: raster stack, de modelos de distribución de especies  
# SINAP_shp: shape, de periodo de SINAP
# name_table: vector character, para darle nombre a la matriz de riqueza, describe el contenido y temporalidad del SINAP
#
# return matriz de riqueza de especies en el conjunto de Areas Protegidas (AP) del SINAP
# por especie y vector de representatividad total 

rep_spp_SINAP <- function(raster_spp, SINAP_shp, name_table){
  # De Raster Stack binario a data.frame binaria
  x <- as.data.frame(raster_spp, xy=TRUE)
  
  # Espacializar el data frame
  coordinates(x) <- ~ x + y
  
  # Homologar sistemas de coordenadas de insumos
  crs(x) <- crs(SINAP_shp)
  
  # Cruzar datos geográficos de los insumos 
  temp <- over(SINAP_shp, x)
  
  #generar matriz presencia-ausencia, numero de Areas Protegidas por especie
  temp[is.na(temp)] = 0
  temp <- t(temp)
  
  # Cantidad de Areas Protegidas en las cuales esta presente cada especie
  ap_spec.sum <-apply(temp,1,sum)
  ap.riqueza.1 <-cbind(temp,ap_spec.sum)
  
  # presencia-ausencia de especies en el conjunto de AP dentro del SINAP
  nc <- ncol(ap.riqueza.1) # columna en la que se ubica el conteo
  pres_espec_all_ap <- replace(ap.riqueza.1[,nc], ap.riqueza.1[,nc] > 0 , 1)
  ap.riqueza.1 <-cbind(ap.riqueza.1,pres_espec_all_ap)
  
  # Porcentaje de la representatividad de especies en las AP, en otras palabras,
  # porcion de las especies usadas en el calculo que estan presentes en el 
  # conjunto del AP's
  sumPresAus <- sum(ap.riqueza.1[,ncol(ap.riqueza.1)])
  repre_riqueza <-sumPresAus/(dim(espec_mod)[[3]])*100
  list_data <- list(ap.riqueza.1,repre_riqueza)
  names(list_data) <- c(paste0("Matriz riqueza"," ", name_table), 
                        "Representatividad total")
  return(list_data)
}

# 2.2 Calculo del aporte de cada Area Protegida (AP) a la representatividad 
#de la riqueza de especies.
# matriz_rique: matriz, de riqueza de especies calculada con rep_spp_SINAP()  
# tiempo: vector character, de temporalidad de las unidades de analisis, por 
#ejemplo el año el que representa las AP's 
#
# return data.frame, porcion de representatividad por cada AP

repre_ind_AP <- function(matriz_rique = matriz_rique, tiempo){
  
  # extraer matriz binaria calculada con la funcion rep_spp_SINAP
  mat_bin <-matriz_rique[[1]]
  temp <- mat_bin[,1:(ncol(mat_bin)-2)]/mat_bin[,(ncol(mat_bin)-1)]
  temp[is.na(temp)] <- 0
  temp <-apply(temp,2,sum)
  
  # Porcion de representatividad de cada especie en cada UAE
  repre_sp_AP <- 100*(as.data.frame(temp))/nrow(mat_bin)
  names(repre_sp_AP) <- paste0("RRi", tiempo)
  return(repre_sp_AP)
}

# 2.3 Cambio en la representatividad de especies en SINAP
#
# cambio_rep_anual: vector numeric, de la representatividad de especies total 
# del conjunto de Areas Protegidas por periodo

cambio_rep_anual <- function(rep_aps = Rep_aps){
  cambio.rep.anual<- abs(diff(rep_aps))
  colnames(cambio.rep.anual) <- "cambio.rep.anual"
  return(cambio.rep.anual)
}

# 2.4 Calculo del aporte de cada Area Protegida (AP) al cambio de la representatividad 
#de la riqueza de especies.
# Establece el cambio en la representatividad de la riqueza de especies entre 
# un par de años consecutivos (t2 y t1). En terminos simples, calcula t2 - t1 por
# area protegida.
# shp1: shapefile, datos vectoriales del SINAP para el periodo 1
# rique_ind1: data.frame, aporte de riqueza calculada con la funcion rep_ind_AP
# en el periodo 1
# tiempo1: vector character, de temporalidad del SINAP en el periodo 1. Por 
#ejemplo el año el que representa las AP's 
# rique_ind2: matriz, de riqueza de especies calculada con rep_spp_SINAP() 
# para el periodo 2 
# tiempo1: vector character, de temporalidad del SINAP en el periodo 2. Por 
#ejemplo el año el que representa las AP's 
#
# return data.frame, porcion de aporte en el cambio de la representatividad por cada AP

repre_deltaind_AP <- function(shp1, rique_ind1, tiempo1, shp2, rique_ind2, tiempo2 ){
  
  # Areas protegidas que comparten los periodos
  index <-  shp2@data$IDPNN %in% shp1@data$IDPNN
  
  # Restar el valor del aporte de la riqueza por AP en los dos periodos
  diff_21 <-  rique_ind2[which(index == T) , 1] - rique_ind1[, 1]
  
  # crear un vector en donde se guarde la diferencia de los dos vectores
  deltaRRi  <- rep(NA, nrow(shp2@data))
  deltaRRi[which(index == T)] <- diff_21
  
  # Porcion del cambio de representatividad de cada especie por AP
  repre_delta_AP <- as.data.frame(deltaRRi) 
  names(repre_delta_AP) <- paste0("dRRi_", tiempo1, "_", tiempo2)
  return(repre_delta_AP)
}

# 3. Aplicación 

# 3.1 Indicador
# Ic: Porcentaje de la representatividad de la riqueza de especies del SINAP (%RRi)

# 3.1.1 Aplicar la funcion rep_spp_SINAP() para toda la serie de shapefiles 
# (historico RUNAP)

repres_90 <- rep_spp_SINAP(espec_mod, ap1990,"RUNAP1990")
repres_94 <- rep_spp_SINAP(espec_mod, ap1994,"RUNAP1994")
repres_98 <- rep_spp_SINAP(espec_mod, ap1998,"RUNAP1998")
repres_00 <- rep_spp_SINAP(espec_mod, ap2000,"RUNAP2000")
repres_02 <- rep_spp_SINAP(espec_mod, ap2002,"RUNAP2002")
repres_06 <- rep_spp_SINAP(espec_mod, ap2006,"RUNAP2006")
repres_10 <- rep_spp_SINAP(espec_mod, ap2010,"RUNAP2010")
repres_14 <- rep_spp_SINAP(espec_mod, ap2014,"RUNAP2014")
repres_18 <- rep_spp_SINAP(espec_mod, ap2018,"RUNAP2018")
repres_20 <- rep_spp_SINAP(espec_mod, ap2020,"RUNAP2020")

# extraer representatividad por cada temporalidad
Rep_aps <- rbind(
  repres_90$`Representatividad total`,
  repres_94$`Representatividad total`,
  repres_98$`Representatividad total`,
  repres_00$`Representatividad total`,
  repres_02$`Representatividad total`,
  repres_06$`Representatividad total`,
  repres_10$`Representatividad total`,
  repres_14$`Representatividad total`,
  repres_18$`Representatividad total`,
  repres_20$`Representatividad total`)

colnames(Rep_aps) <- "Repre_APs"
rownames(Rep_aps) <- c("RUNAP 1990",
                       "RUNAP 1994",
                       "RUNAP 1998",
                       "RUNAP 2000",
                       "RUNAP 2002",
                       "RUNAP 2006",
                       "RUNAP 2010",
                       "RUNAP 2014",
                       "RUNAP 2018",
                       "RUNAP 2020")

# 3.2 Indicador
# Id: Cambio en el porcentaje de la representatividad de la riqueza de especies
# del SINAP (dRRi)
# Incremento tiempo 1 a tiempo 2 en la representatividad riqueza total

tasa.increm.anual <- cambio_rep_anual(rep_aps = Rep_aps)

# 3.3 Aporte de cada Area Protegida

# 3.3.1 Aporte de cada AP a la representatividad de la riqueza de especies 
# (RRi). Se evalua el % de representatividad de cada AP al total

RP_AP1990_AP <- repre_ind_AP(repres_90, "1990")
RP_AP1994_AP <- repre_ind_AP(repres_94, "1994")
RP_AP1998_AP <- repre_ind_AP(repres_98, "1998")
RP_AP2000_AP <- repre_ind_AP(repres_00, "2000")
RP_AP2002_AP <- repre_ind_AP(repres_02, "2002")
RP_AP2006_AP <- repre_ind_AP(repres_06, "2006")
RP_AP2010_AP <- repre_ind_AP(repres_10, "2010")
RP_AP2014_AP <- repre_ind_AP(repres_14, "2014")
RP_AP2018_AP <- repre_ind_AP(repres_18, "2018")
RP_AP2020_AP <- repre_ind_AP(repres_20, "2020")

# 3.3.2 Aporte de cada AP al cambio de la representatividad de la riqueza de 
# especies (dRRi). Se evalua el delta del % de representatividad de cada AP
# total

deltaRP_AP1990_AP <- repre_deltaind_AP(ap1990, RP_AP1990_AP, "90", ap1990, RP_AP1990_AP, "90")
deltaRP_AP1994_AP <- repre_deltaind_AP(ap1990, RP_AP1990_AP, "90", ap1994, RP_AP1994_AP, "94")
deltaRP_AP1998_AP <- repre_deltaind_AP(ap1994, RP_AP1994_AP, "94", ap1998, RP_AP1998_AP, "98")
deltaRP_AP2000_AP <- repre_deltaind_AP(ap1998, RP_AP1998_AP, "98", ap2000, RP_AP2000_AP, "00")
deltaRP_AP2002_AP <- repre_deltaind_AP(ap2000, RP_AP2000_AP, "00", ap2002, RP_AP2002_AP, "02")
deltaRP_AP2006_AP <- repre_deltaind_AP(ap2002, RP_AP2002_AP, "02", ap2006, RP_AP2006_AP, "06")
deltaRP_AP2010_AP <- repre_deltaind_AP(ap2006, RP_AP2006_AP, "06", ap2010, RP_AP2010_AP, "10")
deltaRP_AP2014_AP <- repre_deltaind_AP(ap2010, RP_AP2010_AP, "10", ap2014, RP_AP2014_AP, "14")
deltaRP_AP2018_AP <- repre_deltaind_AP(ap2014, RP_AP2014_AP, "14", ap2018, RP_AP2018_AP, "18")
deltaRP_AP2020_AP <- repre_deltaind_AP(ap2018, RP_AP2018_AP, "18", ap2020, RP_AP2020_AP, "20")

# 3.3.3 Agregar columnas %RRi y deltaRRi al shapefile original

ap1990@data <- cbind(ap1990@data, round(RP_AP1990_AP, 3), round(deltaRP_AP1990_AP, 3))
ap1994@data <- cbind(ap1994@data, round(RP_AP1994_AP, 3), round(deltaRP_AP1994_AP, 3))
ap1998@data <- cbind(ap1998@data, round(RP_AP1998_AP, 3), round(deltaRP_AP1998_AP, 3))
ap2000@data <- cbind(ap2000@data, round(RP_AP2000_AP, 3), round(deltaRP_AP2000_AP, 3))
ap2002@data <- cbind(ap2002@data, round(RP_AP2002_AP, 3), round(deltaRP_AP2002_AP, 3))
ap2006@data <- cbind(ap2006@data, round(RP_AP2006_AP, 3), round(deltaRP_AP2006_AP, 3))
ap2010@data <- cbind(ap2010@data, round(RP_AP2010_AP, 3), round(deltaRP_AP2010_AP, 3))
ap2014@data <- cbind(ap2014@data, round(RP_AP2014_AP, 3), round(deltaRP_AP2014_AP, 3))
ap2018@data <- cbind(ap2018@data, round(RP_AP2018_AP, 3), round(deltaRP_AP2018_AP, 3))
ap2020@data <- cbind(ap2020@data, round(RP_AP2020_AP, 3), round(deltaRP_AP2020_AP, 3))

# 4. Se escribe un shapefile nuevo que incluya la representatividad y el cambio en
# la representatividad contenidas en las columnas %RRi(año) y deltaRRi.

dir.create("rep_rri_gdb/RUNAPRRi", showWarnings = FALSE)

# escribir shapefiles por tiempos
shapefile(x = ap1990, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_1990_rri.shp", overwrite = TRUE)
shapefile(x = ap1994, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_1994_rri.shp", overwrite = TRUE)
shapefile(x = ap1998, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_1998_rri.shp", overwrite = TRUE)
shapefile(x = ap2000, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_2000_rri.shp", overwrite = TRUE)
shapefile(x = ap2002, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_2002_rri.shp", overwrite = TRUE)
shapefile(x = ap2006, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_2006_rri.shp", overwrite = TRUE)
shapefile(x = ap2010, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_2010_rri.shp", overwrite = TRUE)
shapefile(x = ap2014, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_2014_rri.shp", overwrite = TRUE)
shapefile(x = ap2018, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_2018_rri.shp", overwrite = TRUE)
shapefile(x = ap2020, filename = "rep_rri_gdb/RUNAPRRi/RUNAP_2020_rri.shp", overwrite = TRUE)

# 5 Representatividad riqueza por territorial

# 5.1 Preparación y calculo de representatividad por territorial

# 5.1.1. Se aplico union de mapas ArcGis 10.5 entre shapefile territoriales con multitemporal RUNAP. Luego se eliminaron 
#       los poligonos de incongruencia "FID_RUNAP_" = -1 OR "FID_Territ" = -1

# 5.1.2. Cargar todos los dbf de RUNAP-territorial
dir_mapas <- "rep_rri_gdb/Union_Terr_RUNAPRRi/"
mapas_runap_ter <- list.files(dir_mapas, pattern="\\.dbf$", full.names=TRUE)
mapas_runap_ter <- lapply(mapas_runap_ter, foreign::read.dbf)

# 5.1.3. Se agregan los porcentajes por Territorial y se hace una sumatoria.

terr_1990<- aggregate(mapas_runap_ter[[1]]$RRi1990 ~ mapas_runap_ter[[1]]$nombre_1, data=mapas_runap_ter[[1]], FUN=sum)
colnames(terr_1990) <- c("Terr", "RRi1990")

terr_1994<-aggregate(mapas_runap_ter[[2]]$RRi1994 ~ mapas_runap_ter[[2]]$nombre_1, data=mapas_runap_ter[[2]], FUN=sum)
colnames(terr_1994) <- c("Terr", "RRi1994")

terr_1998<-aggregate(mapas_runap_ter[[3]]$RRi1998 ~ mapas_runap_ter[[3]]$nombre_1, data=mapas_runap_ter[[3]], FUN=sum)
colnames(terr_1998) <- c("Terr", "RRi1998")

terr_2000<-aggregate(mapas_runap_ter[[4]]$RRi2000 ~ mapas_runap_ter[[4]]$nombre_1, data=mapas_runap_ter[[4]], FUN=sum)
colnames(terr_2000) <- c("Terr", "RRi2000")

terr_2002<-aggregate(mapas_runap_ter[[5]]$RRi2002 ~ mapas_runap_ter[[5]]$nombre_1, data=mapas_runap_ter[[5]], FUN=sum)
colnames(terr_2002) <- c("Terr", "RRi2002")

terr_2006<-aggregate(mapas_runap_ter[[6]]$RRi2006 ~ mapas_runap_ter[[6]]$nombre_1, data=mapas_runap_ter[[6]], FUN=sum)
colnames(terr_2006) <- c("Terr", "RRi2006")

terr_2010<-aggregate(mapas_runap_ter[[7]]$RRi2010 ~ mapas_runap_ter[[7]]$nombre_1, data=mapas_runap_ter[[7]], FUN=sum)
colnames(terr_2010) <- c("Terr", "RRi2010")

terr_2014<-aggregate(mapas_runap_ter[[8]]$RRi2014 ~ mapas_runap_ter[[8]]$nombre_1, data=mapas_runap_ter[[8]], FUN=sum)
colnames(terr_2014) <- c("Terr", "RRi2014")

terr_2018<-aggregate(mapas_runap_ter[[9]]$RRi2018 ~ mapas_runap_ter[[9]]$nombre_1, data=mapas_runap_ter[[9]], FUN=sum)
colnames(terr_2018) <- c("Terr", "RRi2018")

terr_2020<-aggregate(mapas_runap_ter[[10]]$RRi2020 ~ mapas_runap_ter[[10]]$nombre_1, data=mapas_runap_ter[[10]], FUN=sum)
colnames(terr_2020) <- c("Terr", "RRi2020")

# 5.1.4. Se unen todos los valores de cada RUNAP en una sola tabla.

dat_rep_ri_terr <- as.data.frame(t(cbind(terr_1990[,2], terr_1994[,2], terr_1998[,2],
                                         terr_2000[,2], terr_2002[,2], terr_2006[,2],
                                         terr_2010[,2], terr_2014[,2], terr_2018[,2], 
                                         terr_2020[,2])))

# 5.2 Calculo de la diferencia en la representatividad entre territoriales, dRRIterr 

tasa.incremento.territorial <- t(apply(dat_rep_ri_terr, 2, diff)) %>% as.data.frame()
row.names(tasa.incremento.territorial) <- as.vector(terr_1990[,1])
colnames(tasa.incremento.territorial) <- tiempo.periodo

# save(espec_mod, ap1990, ap1994, ap1998, ap2000, ap2002, ap2006, ap2010, ap2014, ap2018, ap2020, rep_spp_SINAP,
#      repre_ind_AP, cambio_rep_anual, repre_deltaind_AP, Rep_aps, tasa.increm.anual, RP_AP1990_AP, 
#      RP_AP1994_AP, RP_AP1998_AP, RP_AP2000_AP, RP_AP2002_AP, RP_AP2006_AP, RP_AP2010_AP, RP_AP2014_AP,
#      RP_AP2018_AP, RP_AP2020_AP, deltaRP_AP1990_AP, deltaRP_AP1994_AP, deltaRP_AP1998_AP, 
#      deltaRP_AP2000_AP, deltaRP_AP2002_AP, deltaRP_AP2006_AP, deltaRP_AP2010_AP, deltaRP_AP2014_AP,
#      deltaRP_AP2018_AP, deltaRP_AP2020_AP, dir_mapas, mapas_runap_ter, terr_1990, terr_1994, terr_1998,
#      terr_2000, terr_2002, terr_2006, terr_2010, terr_2014, terr_2018, terr_2020, dat_rep_ri_terr,
#      tasa.incremento.territorial, file = "rep_ri_objetos_operativo.RData"
# )
