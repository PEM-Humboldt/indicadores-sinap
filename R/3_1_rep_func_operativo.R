# Cambio en la media de la representatividad de integridad estructural del SINAP	

#________________________________________#
# Codigo escrito por Felipe Suarez       #
# Version :  01-07-2020                  #
#________________________________________#
#                                        #
# Revisado y modificado por Carlos Munoz #
# Agosto-Octubre de 2021                 #
#________________________________________#

library(devtools)
install_version("raster", version = "3.4-13", repos = "http://cran.us.r-project.org")
install_version("sf", version = "1.0-2", repos = "http://cran.us.r-project.org")

library(raster)
library(rgdal)
library(dplyr)
library(sf)
library(rgeos)

options(warn = -1)
# load("rep_func_cod/rep_func_objetos_operativo.RData")

# 1. Insumos
# 1.1 Cargar Huella humana Colombia
# El mapa de huella humana a utilizar varia según el año a analizar, 2018 se usa como base para 2020

human.footprint_1990 <- raster("capas_base_ejemplos/HuellaHumana/HH1990.tif")
human.footprint_2010 <- raster("capas_base_ejemplos/HuellaHumana/HH2010.tif")

# 1.2 Cargar archivo shapefile del RUNAP, en este caso se refiere a 2010 y 2020

RUNAP_shp_1990 <- readOGR("capas_base_ejemplos/RUNAP_shapefiles/RUNAP_1990.shp") %>% spTransform(crs(human.footprint_1990))
RUNAP_shp_2010 <- readOGR("capas_base_ejemplos/RUNAP_shapefiles/RUNAP_2010.shp") %>% spTransform(crs(human.footprint_2010))

# 1.3 Cargar archivo shapefiile Territorial

Territoriales <- readOGR("capas_base_ejemplos/Territorial/Territoriales_final.shp")

# 2. Funciones
# Cuantifica la integridad de un conjunto de poligonos de areas protegidas (AP).
# https://conbio.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fconl.12692&file=conl12692-sup-0001-SuppMat.pdf
#
# ras.cal: raster, indice de huella humana
# shp.Areas: shape, multipoligono de areas protegidas
#
# z: integer, es un exponente que escala el producto de dos dimensiones.
# "El t?rmino de potencia escala el producto de dos valores de calidad. Aqu?,
# seleccionamos valores de z = 0.5 ya que este valor asegura que el peso 
# combinado (wiwj)^z es directamente proporcional al peso wi cuando i = j 
# (es decir, wi = (wiwj)^z ). En otras palabras, el valor de una celda 
# individual es directamente proporcional a su calidad. Valores de z > 0.5 
# indicar?an que el el valor combinado de dos celdas es desproporcionadamente 
# mayor para los pares de alta calidad que para los de baja calidad. Por el 
# contrario, z < 0,5 indicar?a una penalizaci?n desproporcionadamente mayor 
# para los pares de baja calidad" (Beyer et al, 2019)
#
# beta: integer, "El t?rmino de penalizaci?n de distancia beta determina c?mo 
# el valor combinado de dos celdas disminuye a medida que funci?n de la 
# distancia entre ellos (Fig. SM.2a). La elecci?n de beta = 0,2 corresponde a 
# un 50% de penalizaci?n a una separaci?n de 5 km y una reducci?n del 95% a 
# los 15 km, y se bas? en una evaluaci?n de c?mo la m?trica de integridad 
# var?a a trav?s de un conjunto de paisajes hipot?ticos que difieren en
# ?rea total del h?bitat, calidad y fragmentaci?n" (Beyer et al, 2019)
#
# rad: integer, radio sobre el cual se crean zonas buffer por Area Protegida
# para el calculo de la integridad."En nuestra aplicaci?n estas m?tricas se 
# calculan utilizando un radio de 26,5 km, que capta el 99,5% de la 
# distribuci?n exponencial (es decir, la contribuci?n de las celdas m?s all? 
# de ese radio es insignificante peque?o debido al componente de ponderaci?n
# de distancia exponencial de la funci?n). Sin embargo, si el m?trica se
# implementa con valores alternativos del par?metro beta, que determina la 
# ponderaci?n de la distancia, ser?a necesario ajustar el radio adecuado" 
# (Beyer et al, 2019). 
#
# reescal: logic, reescalar variable de huella humana a 1km o mantener
# resoluci?n original.
#
# return lista con seis objetos: 
# integ_media_total, vector numerico, integridad media total del conjunto de Areas protegidas 
# ingestadas (shp.Areas)
# integ_sd_total, vector numerico, desviación de la integridad total del conjunto de areas protegidas 
# ingestadas (shp.areas)
# num_AP, vector numerico, numero de areas protegidas ingestadas
# integ_vector, vector numerico, integridad media de cada area protegida
# integ_raster, lista, lista de rasters con la información por pixel de integridad por area protegida
# integ_shp, shapefile, datos vectoriales de las areas protegidas ingestadas con su valor de integridad
# media.
#
# Bibliografia
# Beyer H, Venter O, Grantham H, Watson JEM. 2019. Catastrophic erosion of 
# ecoregion intactness highlights urgency of globally coordinated action. 
# Conservation Letters
# Beyer, H.L., Venter, O., Grantham, H.S., & Watson, J.E.M.. (2020). 
# Substantial losses in ecoregion intactness highlights urgency of globally 
# coordinated action. Conservation Letters. 13:e12692. 

IntegAPS <- function(ras.Cal, shp.Areas, z = 0.5, beta = NULL, rad = 26.5, reescal = T){
  
  print(c(paste0("z=", z), paste0("beta=", beta), paste0("rad=", rad), paste0("reescal=", reescal)))
  
  # Parametro z, basado en Beyer et al. 2020
  
  # No se configuro un parámetro gamma para la transformación de la huella humana.
  # Se uso una transformación lineal para la capa de huella humana propuesta por 
  # Correa et al. (2020). Sin embargo, podría discutirse si se requiere una 
  # transformación exponencial
  # gamma <- 0.2 # linea 108 para prender o apagar
  
  # En este loop se calculara el valor de integridad para cada área
  
  integ <- vector()#para guardar los valores de integridad por parque
  rasters_integ <- list()#para guardar los rasters con los valores calculados
  
  for(p in 1:length(shp.Areas)){
    
    print(paste0("total poligonos (AP) en shp.Areas ", length(shp.Areas), ". Corriendo poligono (AP) numero ", p ))
    
    # El raster de calidad de habitat sobrelapa con el poligono p con un buffer de 5km?
    if(is.null(raster::intersect(extent(ras.Cal), (extent(shp.Areas[p,])+ 5000)))){
      integ[p] <- NA
      rasters_integ[[p]] <- NA
    }else{
      
      # primero: obtener el raster de calidad de habitat
      # Transformar huella humana donde 1 es el valor mas integro y 0 el menos
      # se aplica un buffer de 5 km alrededor de cada area protegida 
      # el valor es arbitrario pero asegura que las areas pequenas tambien sean 
      # seleccionadas
      r.hfi <- 1 - (crop(ras.Cal, ( extent(shp.Areas[p,]) + 5000) ) /100)
      
      # plot(r.hfi)
      # plot(shp.Areas[p,], add = TRUE)
      
      # Agregar Huella Humana a 1 km, este proceso homologa el raster para aplicar
      # metodologia de Beyer
      
      if(isTRUE(reescal)){
        r.q <- aggregate(r.hfi, fact=3)  
      }else{
        r.q <- r.hfi
      }
      
      rad <- rad 
      
      # plot(r.q)
      
      # Segundo: Calcular la distancia entre todas las celdas
      # definir la ventana focal del kernell y el weight vector
      # Ajustar dependiendo el tamaño de celda y el tamaño deseado del kernel
      #
      # ventana focal para calcular la metrica, matriz de 53*53
      # 
      foc.w <- matrix(NA, nrow=53, ncol=53)
      
      for (i in 1:53){
        for (j in 1:53){
          d <- sqrt((i - 27)^2 + (j - 27)^2)
          if(is.null(beta)) beta <- 0
          if(beta == 0){
            if (d <= rad) foc.w[i,j] <- 1   
          }else{
            if (d <= rad) foc.w[i,j] <- exp(-beta * d)  
          }
        }
      }
      
      #image(foc.w)
      #foc.w[27,]
      
      # vector de distancia
      dvect <- as.vector(foc.w)
      
      # Funcion qprime: Cuantifica la integridad de cada de area protegida.
      #
      # x = raster, medición de la calidad de hábitat 
      # devect = vector numeric, distancia entre celdas dentro de una ventana de pixeles dada
      #
      # return: valor de integridad por pixel de x
      #
      # Details: Beyer, H.L., Venter, O., Grantham, H.S., & Watson, J.E.M.. (2020). 
      # Substantial losses in ecoregion intactness highlights urgency of globally 
      # coordinated action. Conservation Letters. 13:e12692. 
      # https://doi.org/10.1111/conl.12692
      
      qprime <- function(x, dvec = dvect){
        
        # 1405 es el valor de la celda central
        if (is.na(x[1405])) return(NA) 
        
        recs <- which(!is.na(x))
        return(sum((x[1405] * x[recs])^z * dvec[recs]) / sum(dvec[recs]))
      }
      
      # Correr la métrica de integridad dentro de la ventana focal
      r.qp <- raster::focal(r.q, foc.w, fun = qprime, pad = TRUE, dvec = dvect)
      
      # plot(r.qp)
      
      # crop raster de integridad a la extensión del AP
      r.qpAP <- crop(r.qp, shp.Areas[p,])
      
      # plot(r.qpAP)
      
      # Extent de la integridad del Area Protegida
      ext <- extent(r.qpAP)
      
      if(ext[2]-ext[1] == res(r.qp)[[1]]){
        r.qpAP2 <- r.qpAP
      }else{
        r.qpAP2 <- raster::rasterize(st_as_sf(shp.Areas[p,]), r.qpAP, mask = T)
      }
      
      # Calcular la media de integridad para cada AP
      integ[p] <- mean(as.data.frame(rasterToPoints(r.qpAP2))[[3]],na.rm = T)
      
      #guardar los rasters
      rasters_integ[[p]] <- r.qpAP2
      
    }

    #RUNAP_shp[p,]@data$integ<- integ
    #plot(hola)
    #plot(RUNAP_shp[p,],add = TRUE)
  }
  
  # integridad media del numero total de areas protegidas del poligono que se ingresa 
  integ_media_total <- mean(integ, na.rm = T)
  # desviacion estandar
  integ_sd_total <- sd(integ, na.rm = TRUE)
  
  # numero de no NA areas protegidas
  num_AP <- length(integ)
  
  shp.Areas$integ <- integ  

  return(list(integ_media_total = integ_media_total, integ_sd_total = integ_sd_total, num_AP = num_AP, 
              integ_vector = integ, integ_raster = rasters_integ, integ_shp = shp.Areas))
  
}

# 2.4 Calculo del cambio en la media y pixel en la integridad de cada Area Protegida (AP) 
# Util para representaciones geograficas
# Establece el cambio en la integridad entre un par de años consecutivos (t2 y t1). 
# En terminos simples, calcula t2 - t1 por area protegida en terminos de media y pixel en rasters.
# Deja afuera de la comparación aquellas areas protegidas que no se habian creado en la temporalidad 2 (t2)

# Integ1: objeto integridad creado por la función IntegAPS en el periodo 1
# Integ2: objeto integridad creado por la función IntegAPS en el periodo 2
# tiempo1: vector character, de temporalidad del SINAP en el periodo 1. Por 
#ejemplo el año el que representa las AP's 
# tiempo2: vector character, de temporalidad del SINAP en el periodo 2. Por 
#ejemplo el año el que representa las AP's 
#
# return lista con cuatro objetos:
# 1. shp_dInteg_tiempo2, shapefile en donde se guardan los deltas de la media de integridad por Ap entre
# el tiempo 2 y el tiempo 1
# 2. ras1, rasterLater, almacena los datos de integridad por pixel de AP en el tiempo 1
# 3. ras2, rasterLater, almacena los datos de integridad por pixel de AP en el tiempo 2
# 4. raster_dInteg_tiempo, rasterLayer en donde se almacenan los deltas o el cambio de integridad por 
# pixel de AP

delta_IntegAPS <- function(Integ1, tiempo1, Integ2, tiempo2 ){
  
  # A. deltas en medias por AP, guardadas en los shapefiles de los objetos Integ

  shp1 <- Integ1[["integ_shp"]]
  shp2 <- Integ2[["integ_shp"]]
  
  # estandarizar nombres de columnas
  
  colnames(shp1@data) <- toupper(colnames(shp1@data))
  colnames(shp2@data) <- toupper(colnames(shp2@data))
  
  IDPNN_1 <- grep(pattern = "PNN", x = colnames(shp1@data))
  IDPNN_2 <- grep(pattern = "PNN", x = colnames(shp2@data))
  
  index <-  shp2@data[, IDPNN_2] %in% shp1@data[, IDPNN_1]
  
  # Restar el valor del aporte de la riqueza por AP en los dos periodos
  diff_21 <-  shp2$INTEG[which(index == T)] - shp1$INTEG
  
  # crear un vector en donde se guarde la diferencia de los dos vectores
  deltaInteg  <- rep(NA, nrow(shp2@data))
  deltaInteg[which(index == T)] <- diff_21
  shp2$dInteg <- deltaInteg
  
  # B. deltas en pixel por AP, guardadas en los raster de los objetos Integ
  
  # Los datos raster estan almacenados en una lista, por lo que se debe pasar de listas de raster a 
  # un solo raster por periodo
  
  list_ras1 <- Integ1[["integ_raster"]]
  list_ras2 <- Integ2[["integ_raster"]]
  
  #raster periodo 1
  for(i in 1:length(list_ras1)){
    print(i)
    # iniciar en 1 pero sacarlo del loop
    if(i == 1){
      dat1 <- list_ras1[[i]]
      dat2 <- list_ras1[[i+1]]
      # algunas areas protegidas no fueron usadas porque estan en el mar o no caen dentro del area
      # de interseccion con la huella humana por lo que se trabaja solo con aquellos que sean raster
      if(class(dat1) == "RasterLayer" | class(dat2) == "RasterLayer"){
        # merge el raster 1 con el segundo
        ras1 <- merge(dat1, dat2,tolerance = 1)  
      }
      # condicion para no incluir el area protegida final porque no tiene con quien guardarse porque se usa
      # i+1 como forma general de buscar el siguiente, siendo pues que para el ultimo registro no hay siguiente
    }else if(i < length(list_ras1)){
      dat2 <- list_ras1[[i+1]]
      if(class(dat2) == "RasterLayer"){
        # merge los raster de 2 a n-1, siendo n el numero de areas utilizadas 
        ras1 <- raster::merge(ras1, dat2, tolerance = 1)  
      }
    }
  }
  
  crs(ras1) <- crs(Integ2[["integ_shp"]])
  
  # raster periodo 2 (mismos comentarios de arriba)
  for(i in 1:length(list_ras2)){
    print(i)
    if(i == 1){
      dat1 <- list_ras2[[i]]
      dat2 <- list_ras2[[i+1]]
      if(class(dat1) == "RasterLayer" | class(dat2) == "RasterLayer"){
        ras2 <- merge(dat1, dat2,tolerance = 1)  
      }
    }else if(i < length(list_ras2)){
      dat2 <- list_ras2[[i+1]]
      if(class(dat2) == "RasterLayer"){
        ras2 <- raster::merge(ras2, dat2, tolerance = 1)  
      }
    }
  }
  
  crs(ras2) <- crs(Integ2[["integ_shp"]])
  
  # hallando diferencias entre pixels en los objetos raster
  
  # alinear origenes
  
  template<- projectRaster(from = ras1, to= ras2, alignOnly=TRUE)
  
  #template is an empty raster that has the projected extent of r2 but is aligned with r1 (i.e. same resolution, origin, and crs of r1)
  ras1 <- projectRaster(from = ras1, to= template)
  
  dInteg_pixel <- ras2 - ras1
  
  return(list(shp_dInteg_tiempo2 = shp2, ras1 = ras1, ras2 = ras2, raster_dInteg_tiempo = dInteg_pixel))
}

# 3. Aplicación

# 3.1 Nacional

# 3.1.1 Calcular integridad
Integ1990 <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = RUNAP_shp_1990)
Integ2010 <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = RUNAP_shp_2010)

# vector de la media de integridad para cada periodo a nivel nacional
Integ_Nal <- c(Integ1990$integ_media_total, Integ2010$integ_media_total) %>% round(3)

# diferencia de integridad entre años (indicador)
Delta_Integ_Nal <- c(0, diff(Integ_Nal)) %>% round(3)

# 3.2 Territorial

# 3.2.1 Calcular integridad

Integ_Terr_1990 <- lapply(1:nrow(Territoriales), function(x) { 
  #Terrx salida (intermedia)
  
  # cortar las areas protegidas a la extension de cada territorial
  shp.Areas.terrx = rgeos::intersect(RUNAP_shp_1990, Territoriales[x, ])
  
  # establecer la integridad y valores asociados por territorial
  Terrx <- IntegAPS(ras.Cal = human.footprint_1990, shp.Areas = shp.Areas.terrx)
  }
)

Integ_Terr_2010 <- lapply(1:nrow(Territoriales), function(x) { 
  #Terrx salida (intermedia)
  
  # cortar las areas protegidas a la extension de cada territorial
  shp.Areas.terrx = rgeos::intersect(RUNAP_shp_2010, Territoriales[x, ])
  
  # establecer la integridad y valores asociados por territorial
  Terrx <- IntegAPS(ras.Cal = human.footprint_2010, shp.Areas = shp.Areas.terrx)
}
)

# 3.2.2 Calcular delta de la integridad

# Cada una de las listas de calculo de la integridad por territorial tiene el mismo orden que el shapefile de
# las territoriales, que se puede obtener con Territoriales$nombre

Integ_Terr_res <- list()

for(i in 1:length(Territoriales)){
  
  Integ_terri <- c(Integ_Terr_1990[[i]]$integ_media_total, Integ_Terr_2010[[i]]$integ_media_total)
  
  Delta_Integ_terri <- c(0, diff(Integ_terri))
  
  terri_df <- data.frame(c(Integ_terri, Delta_Integ_terri))

  Integ_Terr_res[[i]] <- terri_df
}

Integ_Terr_res <- do.call(cbind.data.frame, Integ_Terr_res) %>% t() %>% round(3)

tiempos <- c("1990", "2010")
colnames(Integ_Terr_res) <- c(paste0("Integ_", tiempos), paste0("Delta_Integ_", tiempos))
rownames(Integ_Terr_res) <- Territoriales$nombre

# 3.3 Extraer medias por Area protegida individual y calcular deltas en Q por pixel

dir.create("productos/rep_func")
dir.create("productos/rep_func/rep_func_gdb")

Integ2010_1990_AP <- delta_IntegAPS(Integ1 = Integ1990, tiempo1 = "1990", Integ2 = Integ2010, tiempo2 = "2010")
writeRaster(Integ2010_1990_AP$raster_dInteg_tiempo, "productos/rep_func/rep_func_gdb/dInteg_2000_1990.tif", overwrite = T)
writeRaster(Integ2010_1990_AP$ras1, "productos/rep_func/rep_func_gdb/Integ_1990.tif", overwrite = T)
writeRaster(Integ2010_1990_AP$ras2, "productos/rep_func/rep_func_gdb/Integ_2010.tif", overwrite = T)
shapefile(Integ2010_1990_AP$shp_dInteg_tiempo2, "productos/rep_func/rep_func_gdb/dInteg_2010_1990.shp", overwrite = T)



#save(human.footprint_1990, human.footprint_2000, human.footprint_2010, human.footprint_2020, RUNAP_shp_1990,
#     RUNAP_shp_2000, RUNAP_shp_2010, RUNAP_shp_2020, Territoriales, IntegAPS, Integ1990, Integ2000,
#     Integ2010, Integ2020, Integ_Nal, Delta_Integ_Nal, Integ_Terr_1990, Integ_Terr_2000, Integ_Terr_2010,
#     Integ_Terr_2020, Integ_Terr_res,  tiempos, Integ2000_1990_AP, Integ2010_2000_AP, Integ2020_2010_AP,
#     terri_df, Territoriales, Delta_Integ_terri, Integ_terri, delta_IntegAPS, IntegAPS, delta_IntegAPS,
#     file = "rep_func_cod/rep_func_objetos_operativo.RData")




