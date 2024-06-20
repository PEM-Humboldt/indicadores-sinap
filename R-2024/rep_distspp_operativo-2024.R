#________________________________________#
# Codigo escrito por Felipe Suarez       #
# Version :  01-07-2020                  #
#________________________________________#
#                                        #
# Revisado, modificado y complementado   #
#por Carlos Munoz                        #
# Agosto de 2021                         #
#________________________________________#

# If.t. Cambio en la media de representatividad ecologica del SINAP - Distribucion de 
# Especies

library(terra)
library(sf)
library(dplyr)
library(plyr)

# load("rep_distspp_cod/rep_distspp_objetos_operativo.RData")

# 1. Cargar insumos

# 1.1 Cargar rutas de los modelos Nivel1 BioModelos

list_raster <-list.files(path = "D:/otros_procesos/biomodelos/Presente_SIMSINAP2023/", pattern="*.tif$", full.names = T)

# 1.2 Leer archivos RUNAP, en formato shp

# Función para leer shapefiles desde archivos ZIP
leer_shp_desde_zip <- function(zip_file,epsg = "EPSG:4326") {
  # Intenta leer el shapefile directamente
  tryCatch(
    {
      shp <- read_sf(paste0("/vsizip/", zip_file), quiet = T) %>% 
        st_transform(crs = st_crs(epsg)) %>% 
        st_zm()
      # Asegurarse de que las geometrías sean 2D
      return(shp)
    },
    error = function(e) {
      # Si hay un error, listar archivos dentro del ZIP
      archivos_en_zip <- unzip(zip_file, list = TRUE)$Name
      # Buscar archivos .shp
      shp_files <- archivos_en_zip[grep("\\.shp$", archivos_en_zip)]
      # Leer el primer shapefile encontrado en el ZIP
      shp <- read_sf(paste0("/vsizip/", zip_file, "/", shp_files[1]), quiet = T) %>% 
        st_transform(crs = st_crs(epsg)) %>% 
        st_zm()
      return(shp)
    }
  )
}

# 10 minutes to load all ap db
path_ap <- "D:/otros_procesos/ap_sinap"
nms <- list.dirs(path_ap, recursive = F, full.names = F)

shps <- list.dirs(path_ap, recursive = F, full.names = T) %>% 
  lapply(X = ., function(X){
    a <- list.files(X, pattern = "*.zip$", full.names = T, recursive = T )
    return(a)
  }) %>% lapply(X = ., function(X){
    tmpShp <- list()
    for(i in 1:length(X)){
     tmpShp[[i]] <- leer_shp_desde_zip(X[i])
    }
    tmpShp <- bind_rows(tmpShp)
    
    # remover duplicados (algunas AP estan duplicados sus poligonos)
    nm <- sub(".*[^0-9]([0-9]+)$", "\\1", tmpShp$URL)
    tmpShp$id <- nm
    tmpShp <- tmpShp[!duplicated(nm),]
    return(tmpShp)
  })
names(shps) <- nms

# 1.3 Cargar archivo shapefiile Territorial

Territoriales <- read_sf("rep_distspp_otros/Territoriales/Territorales.shp") %>% 
                  st_transform(crs(shps[[1]]))

# 2. Funciones

# 2.0 Función para mostrar una barra de progreso en la consola.
#
# Argumentos:
#   current: Valor actual del progreso.
#   total: Valor total para completar el progreso.

progress_bar <- function(current, total) {
  progress <- (current / total) * 100
  cat(sprintf("\rProgress: [%-50s] %d%%", 
              paste(rep("=", progress / 2), collapse = ""), round(progress)))
  flush.console()
}

# 2.1 Función para calcular el área de representatividad de especies en áreas protegidas (AP).
#
# Argumentos:
#   gruposSize: Tamaño de los grupos de rasters a procesar (por defecto es 100).
#   raster.spp: Lista de archivos raster que representan la distribución de especies.
#   shp.RUNAP: Objeto `sf` que contiene las geometrías de las áreas protegidas (AP).
#
# Return:
#   vector con los resultados del área calculada por grupo de especies.

aP_Area <- function(gruposSize = 1000, raster.spp = list_raster, shp.RUNAP = shps[[1]]){
  
  aPTempL <- list()
  
  grupos <- ceiling(length(raster.spp) / gruposSize)
  
  for(i in 1:grupos) {
    #i <- 1
    progress_bar(i, grupos)
    
    if(i == 1) {
      r0 <- 1
      r1 <- min(gruposSize, length(raster.spp))  # Asegurarse de no exceder la longitud
    } else if(i == grupos) {
      r0 <- (i - 1) * gruposSize + 1
      r1 <- length(raster.spp)
    } else {
      r0 <- (i - 1) * gruposSize + 1
      r1 <- i * gruposSize
    }
    
    wCol <- terra::ext(-79.0083333333333, -66.85, -4.23333333333333, 12.4583333333333)
    
    focus_sp <- lapply(X = raster.spp[r0:r1], FUN = function(X){
      terra::crop(terra::rast(X), wCol)
    })
    
    # Convertir la lista de archivos raster en un objeto 'rast' usando el paquete 'terra'
    focus_sp <- terra::rast(focus_sp)
    
    if (crs(shp.RUNAP) != crs(focus_sp)) {
      shp.RUNAP <- st_transform(shp.RUNAP, crs(focus_sp))
    }
    
    suppressMessages(
      expr = {
        aPTempL[[i]] <- exactextractr::exact_extract(focus_sp, shp.RUNAP, 'sum', progress = F)
      }, classes = "message"
    )
    
    rm(focus_sp);gc()
    
  }
  
  progress_bar(grupos, grupos)
  cat("\n")  # Nueva línea después de completar la barra de progreso
  
  aPTemp <- do.call("cbind", aPTempL) %>% 
    round(digits = 0)
  rm(aPTempL);gc()
  
  aPTemp$idAP <- shp.RUNAP$id 
  
  # Transformar el data.frame usando solo dplyr y funciones base
  aPTemp <- aPTemp %>%
    # Convertir el data.frame a un formato largo usando funciones base
    { data.frame(RUNAP = rep(.$idAP, times = ncol(.) - 1),
                 species = rep(names(.)[-1], each = nrow(.)),
                 freq = as.numeric(unlist(.[-1]))) } %>%
    # Filtrar las filas donde COLB es mayor que 0
    filter(freq > 0)
  row.names(aPTemp) <- NULL
  
  aPTemp <- aPTemp[which(aPTemp$species != "idAP"), ] 
  
  aPTemp$species <- sub("^[^.]+\\.([^.]+_[^_]+)_.+$", "\\1", aPTemp$species)
  
  gc()
  
  return(aPTemp)
}

# 2.2 Función para calcular el área total de distribucion de especies en un territorio específico.
#
# Argumentos:
#   gruposSize: Tamaño de los grupos de rasters a procesar (por defecto es 100).
#   raster_spp: Lista de archivos raster que representan la distribución de especies.
#   pathArea: Ruta al archivo shapefile del área territorial (por defecto es "rep_distspp_otros/Nacional/nacional_wgs84.shp").
#
# Retorna:
#   Lista con los resultados del área total calculada por grupo de especies.

aT_Area<- function(gruposSize = 100, raster.spp = list_raster, 
                   pathArea = "rep_distspp_cod-2024/NACIONAL/Colombia_FINAL.shp") {
  
  aTTempL <- list()
  
  grupos <- ceiling(length(raster.spp) / gruposSize)
  
  for(i in 1:grupos) {
    #i <- 1
    progress_bar(i, grupos)
    
    if(i == 1) {
      r0 <- 1
      r1 <- min(gruposSize, length(raster.spp))  # Asegurarse de no exceder la longitud
    } else if(i == grupos) {
      r0 <- (i - 1) * gruposSize + 1
      r1 <- length(raster.spp)
    } else {
      r0 <- (i - 1) * gruposSize + 1
      r1 <- i * gruposSize
    }
    
    wCol <- terra::ext(-79.0083333333333, -66.85, -4.23333333333333, 12.4583333333333)
    
    focus_sp <- lapply(X = raster.spp[r0:r1], FUN = function(X){
      terra::crop(terra::rast(X), wCol)
    })
    
    # Convertir la lista de archivos raster en un objeto 'rast' usando el paquete 'terra'
    focus_sp <- terra::rast(focus_sp)
    
    Area <- read_sf(pathArea) %>% 
      st_transform(st_crs("EPSG:4326"))
    
    aTTempL[[i]] <- exactextractr::exact_extract(focus_sp, Area, 'sum') %>% 
      colSums() %>% 
      round(digits = 0)
    rm(focus_sp); gc()
    
  }
  
  aTTemp <- do.call("c", aTTempL)
  
  rm(aTTempL);gc()
  
  names(aTTemp) <- sub("^[^.]+\\.([^.]+_[^_]+)_.+$", "\\1", names(aTTemp))
  
  gc()
  
  return(aTTemp)
  
}

# 2.3 Distribución de especies en el RUNAP (DistSpRUNAP)
#
#   aP: Vector numérico, área protegida para la especie.
#   aT: Vector numérico, área de distribución total para la especie.
#   nm: Vector de caracteres, nombres de los años de areas protegidas
#
# Return: 
# data.frame con las siguientes columnas
#
# RUNAP: Area Protegida ID
# freq: numero de pixeles de la distribucion de la especie dentro de cada parque
# species: nombre del archivo raster de la distribucion de la especie
# in_RUNAP: ¿existen pixeles dentro del RUNAP?
# per_protected: porcentaje de la distribución de la especie en Colombia que es protegida
# needed_to_protect: porcentaje de la distribución de la especie a proteger
# total_area_km2: area de distribución de la especie en km2
# prop_achieved: proporcion del area de la distribucion a ser protegida que 
# esta siendo realmente protegida
# achieved: 0 si la proporcion de area protegida real (prop_achieved) es < 0.9, y 1 
# si es > 0.9
#
# Details: Rodrigues, A.S.L., et al, (2004a) Effectiveness of the global protected 
# area network in representing species diversity. Nature 428(6983), 640-643.
# Rodrigues, A.S.L., et al. (2004b) Global Gap Analysis: Priority Regions for 
# Expanding the Global Protected-Area Network. BioScience 54(12), 1092-1100.

DistSpRUNAP <- function(aP = aPspp[[3]], aT = aTspp, nm = nms[3]) {
  # Elimina filas donde la especie es "idAP"
  aP <- aP[which(aP$species != "idAP"), ]
  
  # Convierte la frecuencia a numérico
  aP$freq <- as.numeric(aP$freq)
  
  # Sumariza el área protegida por especie
  temp <- aP %>% group_by(species) %>% dplyr::summarise(area = sum(freq))
  area_protegida <- temp$area
  
  # Filtra el área total para incluir solo las especies presentes en aP
  area_total <- aT[names(aT) %in% unique(aP$species)]
  
  # Calcula el porcentaje del área protegida
  per_protected <- (area_protegida / area_total) * 100
  
  # Calcula la cantidad necesaria para proteger según el área total
  needed_to_protect <- sapply(area_total, function(area) {
    if (is.na(area)) {
      return(NA)
    } else if (area <= 1000) {
      return(100)
    } else if (area >= 250000) {
      return(10)
    } else {
      return(lm.func(area))
    }
  })
  
  # Calcula la proporción lograda
  prop_achieved <- per_protected / needed_to_protect
  
  # Evalúa si se ha logrado proteger más del 90% de la distribución necesaria
  achieved <- sapply(prop_achieved, function(prop) {
    if (is.na(prop)) {
      return(NA)
    } else if (prop > 0.9) {
      return(1)
    } else {
      return(0)
    }
  })
  
  # Crear el data frame InterSpAP para almacenar los resultados
  InterSpAP <- as.data.frame(matrix(nrow = nrow(aP), ncol = 10))
  colnames(InterSpAP) <- c("RUNAP", "freq", "species", "year_RUNAP", "in_RUNAP", 
                           "per_protected", "needed_to_protect", "total_area_km2",   
                           "prop_achieved", "achieved")
  
  # Asignar valores a InterSpAP
  InterSpAP$RUNAP <- aP$RUNAP
  InterSpAP$freq <- aP$freq
  InterSpAP$species <- aP$species
  InterSpAP$year_RUNAP <- nm
  
  # Sumariza el número de observaciones por especie
  temp <- aP %>% group_by(species) %>% dplyr::summarise(n = n())
  
  # Repetir los valores de acuerdo a la frecuencia observada
  InterSpAP$in_RUNAP <- rep(area_protegida, times = temp$n)
  InterSpAP$per_protected <- rep(per_protected, times = temp$n)
  InterSpAP$needed_to_protect <- rep(needed_to_protect, times = temp$n)
  InterSpAP$total_area_km2 <- rep(area_total, times = temp$n)
  InterSpAP$prop_achieved <- rep(prop_achieved, times = temp$n)
  InterSpAP$achieved <- rep(achieved, times = temp$n)
  
  # Crear el data frame InterSpAT para almacenar los resultados totales
  InterSpAT <- as.data.frame(matrix(nrow = length(area_total), ncol = 10))
  colnames(InterSpAT) <- c("RUNAP", "freq", "species", "year_RUNAP", "in_RUNAP", 
                           "per_protected", "needed_to_protect", "total_area_km2",   
                           "prop_achieved", "achieved")
  
  # Asignar valores a InterSpAT
  InterSpAT$RUNAP <- NA
  InterSpAT$freq <- area_total - area_protegida
  InterSpAT$in_RUNAP <- area_protegida
  InterSpAT$species <- names(area_total)
  InterSpAT$year_RUNAP <- nm
  InterSpAT$per_protected <- per_protected
  InterSpAT$needed_to_protect <- needed_to_protect
  InterSpAT$total_area_km2 <- area_total
  InterSpAT$prop_achieved <- prop_achieved
  InterSpAT$achieved <- achieved
  
  # Combinar ambos data frames
  InterSp <- rbind(InterSpAP, InterSpAT)
  
  # Ordenar el data frame por especie
  InterSp <- InterSp[order(InterSp$species), ]
  rm(InterSpAT, InterSpAP);gc()
  return(InterSp)
}

# 2.4 Calculo del area a proteger cuando el area de distribución se encuentra entre
# 1000 km2 y 250000 km2
# 
# x = vector numeric, area de distribucion total de la especie
# 
# return:
# Area minima a protegerpara especies con distribuciones mayores a 1000 km2 y 
# menores a 250000 km2
#
# Details: Rodrigues, A.S.L., et al, (2004a) Effectiveness of the global protected 
# area network in representing species diversity. Nature 428(6983), 640-643.
# Rodrigues, A.S.L., et al. (2004b) Global Gap Analysis: Priority Regions for 
# Expanding the Global Protected-Area Network. BioScience 54(12), 1092-1100.


lm.func<-function(x){
  
  # El area a proteger es calculada como una función del área de distribución 
  # de la especie y se escala como una función lineal > 10% para especies 
  # con distribuciones menores a 250000 km2, hasta < 100% para especies 
  # con distribuciones mayores a 1000 km2
  
  areas <- c(1000, 2.5e5)
  proporcion <- c(100, 10)
  TempDF <- data.frame("xTemp" = areas, "yTemp" = proporcion)
  m <- diff(TempDF$yTemp) / diff(TempDF$xTemp)
  b <- ((TempDF$yTemp[[1]]*TempDF$xTemp[[2]]) - (TempDF$yTemp[[2]]*TempDF$xTemp[[1]])) /
    (TempDF$xTemp[[2]] - TempDF$xTemp[[1]])
  
  y <- m*x + b
  
  return(y)
}

# 2.5 Función para rasterizar un shapefile utilizando un raster de referencia.
#
# Argumentos:
#   shp.RUNAP: Objeto `sf` que contiene las geometrías del shapefile a rasterizar (por defecto es `shps[[1]]`).
#   raster.sp: Raster de referencia utilizado para definir la extensión y resolución del raster de salida (por defecto es `list_raster[1]`).
#
# Retorna:
#   Un objeto `SpatRaster` con las geometrías del shapefile rasterizadas y con el CRS transformado según el raster de referencia.


shp_to_raster <- function(shp.RUNAP = shps[[1]], raster.sp = list_raster[1]){
  
  focus_sp <- terra::rast(raster.sp)
  
  if (crs(shp.RUNAP) != crs(focus_sp)) {
    shp.RUNAP <- st_transform(shp.RUNAP, crs(focus_sp))
  }
  
  ras.RUNAP <- terra::rasterize(shp.RUNAP, focus_sp, field = as.numeric(shp.RUNAP$id))
  names(ras.RUNAP) <- "RUNAP"
  
  return(ras.RUNAP)
}

# 2.6 Calcula el valor de la representatividad de la distribución de especies en un sistema de referencia 
# (nacional o territorial) y por area protegida dentro de ese sistema de referencia 
# 
# stats_periodo = estadisticas de la distribución por especie y por area en un sistema de referencia,
# objeto creado con la función DistSpRunap
#
# return: lista con 3 objetos,
#
# media_rep_distSpp = media de la representatividad de la distribución de especes en el sistema de referencia
# media_rep_distSpp_AP = media de la representitividad de la distribucion de especies por Area Protegida 
# id_AP = Identificador unico de cada area protegida

rep_distSpp <- function(stats_periodo = stats_spp[[4]], raster_runap = rasRUNAP[[4]]){
  
  #stats_allsp es la tabla generada por el loop.
  
  ind_PNN <- stats_periodo %>% dplyr::count(RUNAP, achieved)
  
  #contar número de especies que están en un área
  PNN_sp <- aggregate(ind_PNN$n,list(RUNAP = ind_PNN$RUNAP), "sum")
  
  #contar cuántas de esas especies alcanzan su target
  PNN_achieved <- subset(ind_PNN, ind_PNN$achieved == 1)
  
  PNN_stats <- merge(PNN_sp, PNN_achieved, "RUNAP", all.x = T)
  
  colnames(PNN_stats)<-c("RUNAP","no_species","ac","sp_ach")
  
  PNN_stats[which(is.na(PNN_stats$ac)),"sp_ach"] <- 0
  
  #calcular indicador por área
  PNN_stats$ac <- (PNN_stats$sp_ach/PNN_stats$no_species)*100
  
  #media indicador:
  
  media_all <-  mean(PNN_stats$ac)
  
  unique_ID_AP <- unique(na.omit(as.data.frame(raster_runap)))
  
  colnames(unique_ID_AP) <- "RUNAP"
  
  no_distsspp <- unique_ID_AP$RUNAP[which(unique_ID_AP$RUNAP %in% PNN_stats$RUNAP == F)]
  
  # Crear un vector que mapea los valores de RUNAP a los valores de ac
  map_values <- setNames(PNN_stats$ac, PNN_stats$RUNAP)
  
  # Obtener los valores únicos de RUNAP del raster y convertirlos en caracteres
  runap_values <- as.character(values(raster_runap))
  
  # Asignar los valores de 'ac' correspondientes a cada celda del raster
  updated_values <- map_values[runap_values]
  
  # Asignar NA a las celdas correspondientes a áreas sin especies distribuidas
  updated_values[runap_values %in% no_distsspp] <- NA
  
  # Actualizar los valores del raster con los valores calculados
  values(raster_runap) <- updated_values
  
  # objetos para resultados
  id_AP <- PNN_stats$RUNAP
  medias_rep_distrspp_AP <- PNN_stats$ac
  
  
  return(list(media_rep_distSpp = media_all, media_rep_distSpp_AP = medias_rep_distrspp_AP, 
              id_AP = id_AP, raster_rep_distrSpp = raster_runap, AP_stats = PNN_stats))
  
}

# 3. Aplicacion

# 3.1 Nacional

# 3.1.1 calculo de la representatividad de la distribución de especies en SINAP

# A. Establecer la cantidad de distribucion dentro de Areas protegidas por especie
# en cada año

aPspp <- lapply(X = shps, FUN = function(X){
    aP_Area(
      gruposSize = 1000, 
      raster.spp = list_raster, 
      shp.RUNAP = X
    )})

# B. Establecer la cantidad total de distribucion por especie

aTspp <- aT_Area()

# C. Calcular las estadisticas de representatividad

stats_spp <- list()

for(i in 1:length(nms)){
  stats_spp[[i]] <- DistSpRUNAP(
    aP = aPspp[[i]],
    nm = nms[i],
    aT = aTspp
  )
  gc()
}  

# D. rasterizar shps

rasRUNAP <- lapply(shps, shp_to_raster)


# E. calcular la representatividad de la distribución de especies en SINAP

rep_distSpp <- mapply(FUN = rep_distSpp,
                      stats_periodo = stats_spp,
                      raster_runap = rasRUNAP,
                      SIMPLIFY = FALSE)
names(rep_distSpp) <- nms


# vector de la media de representatividad de distribucion para cada periodo a nivel nacional
rep_distSpp_Nal <- lapply(X = rep_distSpp, FUN = function(X){
                            X$media_rep_distSpp
                          }) %>% 
  unlist() %>% 
  round(3)
  
# 3.1.2 calculo de la diferencia de integridad entre años (indicador)
Delta_rep_distSpp_Nal <- c(0, diff(rep_distSpp_Nal)) %>% 
  round(3) %>% 
  abs()

# 3.2 Territorial

# 3.2.1 calculo de la representatividad de la distribución de especies en SIRAP


# Definir la función que procesa los datos territoriales
process_territorial_data <- function(rep.distSpp = rep_distSpp[[1]], Terr = Territoriales) {
  
  result <- lapply(1:nrow(Terr), function(x) { 
    # x <- Terr[2,]
    # Cortar las áreas protegidas a la extensión de cada territorial
    raster.Areas.terrx <- crop(rep.distSpp$raster_rep_distrSpp, Territoriales[x, ]) %>%
      mask(Territoriales[x, ]) 
    
    df.Areas.terrx <- as.data.frame(raster.Areas.terrx, xy = TRUE) %>% na.omit() %>% 
      unique()
    
    media_territorialx <- mean(df.Areas.terrx[, 3], na.rm = TRUE)
    
    if(is.nan(media_territorialx)){
      media_territorialx <- 0
    }
    
    return(list(raster.terrx = raster.Areas.terrx, media_terrx = media_territorialx))
  })
  
  return(result)
}

rep_distSpp_Terr <- lapply(rep_distSpp, process_territorial_data)


# 3.2.2 Calcular delta de la la representatividad de la distribución de especies en SIRAP

# Cada una de las listas de calculo la representatividad de la distribución de especies por territorial 
# tiene el mismo orden que el shapefile de las territoriales, que se puede obtener con Territoriales$nombre

resTerr <- list()

for(i in 1:length(rep_distSpp_Terr)){
  #i <- 1
  repT <- list()
  for(a in 1:nrow(Territoriales)){
    #a <- 1
    repi <- rep_distSpp_Terr[[i]][[a]]
    repi_media <- repi$media_terrx %>%
      unlist() %>%
      round(3)
    repT[[a]] <- repi_media
  }
  resTerr[[i]] <- do.call("rbind", repT)
}

x <- do.call("cbind", resTerr)
d <- t(x) %>% diff() %>% t()

rep_distSpp_Terr_res <- cbind(x,d)

colnames(rep_distSpp_Terr_res) <- c(paste0("rep_distSpp_", nms), paste0("Delta_rep_distSpp_", nms[-1]))
rownames(rep_distSpp_Terr_res) <- Territoriales$nombre

# 3.3 Area protegida

# 3.3.1 calculo de la representatividad de la distribución de especies por AP

# se desarrollo en el 3.1.1

# 3.3.2 Calcular delta de la la representatividad de la distribución de especies por AP

deltasAP <- function(X, Y){
  x <- X$raster_rep_distrSpp
  y <- Y$raster_rep_distrSpp
  return(y-x)
  }

drep_distSpp_AP <- mapply(FUN = deltasAP, 
                     X = rep_distSpp[1:(length(nms)-1)], 
                     Y = rep_distSpp[2:(length(nms))],
                     SIMPLIFY = FALSE)
names(drep_distSpp_AP) <- nms[2:length(nms)]

# Time difference of 7.011262 hours
