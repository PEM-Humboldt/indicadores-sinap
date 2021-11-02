# Representaciones
# Las representaciones con las capas base de ejemplo del repositorio son ejemplos, no versiones finales por lo que 
# las representaciones graficas y geograficas no coinciden con los presentados en el proyecto SIM-SINAP.

library("sf")
library("rgdal")
library("raster")
library("ggplot2")
library("dplyr")
library("ggsn")
library("heatmaply")
library("maptools")

options(warn = -1)

# load("rep_distspp_cod/rep_distspp_objetos_operativo.RData")

# 1. Shapefile utiles

col_sf <- read_sf("capas_base_ejemplos/Nacional/Colombia_FINAL.shp")

RUNAP_1990_shp <- read_sf("capas_base_ejemplos/RUNAP_shapefiles/RUNAP_1990.shp")
RUNAP_2010_shp <- read_sf("capas_base_ejemplos/RUNAP_shapefiles/RUNAP_2010.shp")


dir.create("productos/rep_distspp/")

# 2. Cambio en el porcentaje de representatividad distribución de especies

#_____________________________________________
#   2.1 Nacional
#     A. numerica

dir.create("productos/rep_distspp/rep_num")

tiempos <- c(1990, 2010) %>% as.data.frame()

rep_distSpp_Nal <- data.frame(tiempos, rep_distSpp_Nal, Delta_rep_distSpp_Nal)

colnames(rep_distSpp_Nal) <- c("Periodo", "rep_distSpp_Nal", "Delta_rep_distSpp_Nal")

write.csv(rep_distSpp_Nal, "productos/rep_distspp/rep_num/rep_distSpp_Nal.csv", row.names = F)


#     B. grafica

dir.create("productos/rep_distspp/rep_gra")

# porcentaje representatividad

jpeg("productos/rep_distspp/rep_gra/rep_distSpp_Nal.jpg", res = c(300,300), width = 2480, height = 2480)
repr_plot<- ggplot(rep_distSpp_Nal, aes(factor(Periodo), rep_distSpp_Nal, color = Periodo)) +
  geom_line(color="red", aes(group=1)) +
  ylim(c(0,100))+
  ggtitle("Porcentaje de representatividad ecologica SINAP\n distribución de especies")+ 
  labs(y= "Porcentaje (%)", x = "Año")+
  theme_classic()
print(repr_plot)
dev.off()


# deltas del porcentaje de representatividad

jpeg("productos/rep_distspp/rep_gra/drep_distSpp_Nal.jpg", res = c(300,300), width = 2480, height = 2480)
repr_plot<- ggplot(rep_distSpp_Nal, aes(factor(Periodo), Delta_rep_distSpp_Nal, color = Periodo)) +
  geom_line(color="red", aes(group=1)) +
  ylim(c(-5,20))+
  geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
  ggtitle("Cambio en el porcentaje de representatividad ecologica SINAP\n distribución de especies")+ 
  labs(y= "Porcentaje (%)", x = "Año")+
  theme_classic()
print(repr_plot)
dev.off()


#     C. geografica

dir.create("productos/rep_distspp/rep_geo", showWarnings = F)

dir.create("productos/rep_distspp/rep_geo/NACIONAL", showWarnings = F)

rep_distSpp_xAps <- list(rep_distSpp_1990$raster_rep_distrSpp,
                         rep_distSpp_2010$raster_rep_distrSpp)

# Mapas del porcentaje por periodo

for(i in 1:nrow(tiempos)){ # el desencadenante son el numero de años que se usan en el analisis
  
  # extraer del año i, si i es igual a 1 extraiga el el raster 1 del objeto creado con la funcion
  # delta_IntegAPS
  
  rasdistSpp <- rep_distSpp_xAps[[i]]
  
  info_rasdistSpp <- raster::as.data.frame(rasdistSpp, xy = TRUE)
  info_rasdistSpp <- na.omit(info_rasdistSpp)
  
  colnames(info_rasdistSpp) <- gsub(pattern = "_[[:digit:]]+", replacement = "", x = colnames(info_rasdistSpp))
  
  info_rasdistSpp_df <- mutate(.data = info_rasdistSpp, rasdistSpp_cat = cut(RUNAP_pnnid, 
                               breaks = c(0, 20, 40, 60, 80, 100), 
                               labels = c("0-20", "20-40", "40-60", "60-80", "80-100"), 
                               include.lowest = TRUE, right = FALSE
                               ))
  
  cols <- RdYlGn(5)
  names(cols) <- c("0-20", "20-40", "40-60", "60-80", "80-100")
  
  tiff(paste0("productos/rep_distspp/rep_geo/NACIONAL/rep_distSpp_", tiempos[i, 1], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plot_datai <- ggplot() +
    geom_sf(data = col_sf, fill = "transparent", color = "gray20") +
    geom_raster(data = info_rasdistSpp_df, aes(x = x, y = y, fill = rasdistSpp_cat))+ 
    scale_fill_manual(values = cols, name = paste0("Porcentaje representatividad ecologica\nDistribución de especies\n", tiempos[i, 1]))+
    theme_void()+
    theme(plot.background = element_rect(colour = "transparent"),
          legend.position = c(0.23, 0.10),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title.align = 0.5,
          legend.title = element_text(size = 11, face = "bold"))
  print(plot_datai)
  dev.off()
}
  

# Mapas de deltas

drep_distSpp_xAps <- list(drep_distSpp_AP_1990_2010)

runaps_shps <- list(RUNAP_2010_shp) # lista de runaps sin el primer año

periodos <- c("1990-2010")


for(i in 1:length(drep_distSpp_xAps)){
  
  # extraer raster i
  ras_drep_distSpp_xAps <- drep_distSpp_xAps[[i]]
  
  info_ras_drep_distSpp_xAps <- raster::as.data.frame(ras_drep_distSpp_xAps, xy = TRUE)
  info_ras_drep_distSpp_xAps <- na.omit(info_ras_drep_distSpp_xAps)
  
  colnames(info_ras_drep_distSpp_xAps) <- gsub(pattern = "_[[:digit:]]+", 
                                               replacement = "", x = colnames(info_ras_drep_distSpp_xAps))
  
  info_rasdistSpp_df <- mutate(.data = info_ras_drep_distSpp_xAps, drasdistSpp_cat = cut(drep_distSpp_AP,
                               breaks = c(-Inf, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80), 
                               labels = c( "< -10",  "-10 - 0", 
                                          "0 - 10", "10 - 20", "20 - 30", "30 - 40",
                                          "40 - 50", "50 - 60", "60 - 70", "70 - 80"),
                               include.lowest = TRUE, right = FALSE
  ))

  # colores rojo a verde para representar 
  cols <- RdYlGn(10)
  names(cols) <- c( "< -10",  "-10 - 0", 
                    "0 - 10", "10 - 20", "20 - 30", "30 - 40",
                    "40 - 50", "50 - 60", "60 - 70", "70 - 80")
  
  runap_sf <- runaps_shps[[i]]
  
  tiff(paste0("productos/rep_distspp/rep_geo/NACIONAL/drep_distspp_", periodos[i], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plotdatai <- ggplot() +
    geom_sf(data = st_transform(runap_sf, st_crs(col_sf)), fill = "transparent", color = "gray90") +
    geom_sf(data = col_sf, fill = "transparent", color = "gray20") +
    geom_raster(data = info_rasdistSpp_df , aes(x = x, y = y, fill = drasdistSpp_cat))+
    scale_fill_manual(values = cols, name = paste0("Cambio en el porcentaje \n de representatividad ecologica\nDistribución de especies\n", periodos[i]))+
    theme_void()+
    theme(plot.background = element_rect(colour = "transparent"),
          legend.position = c(0.23, 0.12),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title.align = 0.5,
          legend.title = element_text(size = 11, face = "bold"))
  print(plotdatai)
  dev.off()
  
}

#_____________________________________
#   2.2 Territorial

#     A. numerica


write.csv(rep_distSpp_Terr_res, "productos/rep_distspp/rep_num/drep_distSpp_Ter.csv", row.names = T)

terr_nombres_small <- c("Amazonia", "Andes_Noro", "Andes_Occ", "Caribe", "Orinoquia", "Pacifico")

#     B. grafica

# porcentaje representatividad
jpeg("productos/rep_distspp/rep_gra/rep_distSpp_territoriales.jpg", res = c(300,300), width = 3508, height = 2480)
  par(mfrow=c(3,2))
  plot(rep_distSpp_Terr_res[1, c(1:2)], type= "l", main="Direccion Territorial Amazonia", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="Representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[2, c(1:2)], type= "l", main="Direccion Territorial Andes Nororientales", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[3, c(1:2)], type= "l", main="Direccion Territorial Andes Occidentales", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[4, c(1:2)], type= "l", main="Direccion Territorial Caribe", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[5, c(1:2)], type= "l", main="Direccion Territorial Orinoquia", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[6, c(1:2)], type= "l", main="Direccion Territorial Pacifico", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Porcentaje representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
dev.off()


# deltas en el porcentaje representatividad
jpeg("productos/rep_distspp/rep_gra/drep_distSpp_territoriales.jpg", res = c(300,300), width = 3508, height = 2480)
  par(mfrow=c(3,2))
  plot(rep_distSpp_Terr_res[1, c(3:4)], type= "l", main="Direccion Territorial Amazonia", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="Cambio representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[2, c(3:4)], type= "l", main="Direccion Territorial Andes Nororientales", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[3, c(3:4)], type= "l", main="Direccion Territorial Andes Occidentales", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[4, c(3:4)], type= "l", main="Direccion Territorial Caribe", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[5, c(3:4)], type= "l", main="Direccion Territorial Orinoquia", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(rep_distSpp_Terr_res[6, c(3:4)], type= "l", main="Direccion Territorial Pacifico", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio representatividad (%)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
dev.off()


#     C. geografica

dir.create("productos/rep_distspp/rep_geo/TERRITORIALES", showWarnings = F)

# unir datos con shapefile

Territoriales@data <- cbind(Territoriales@data, rep_distSpp_Terr_res)

# Mapas del porcentaje representatividad

for(i in 1:nrow(tiempos)){ # el desencadenante son el numero de años que se usan en el analisis
  
  # extraer del año i, si i es igual a 1 extraiga el el raster 1 del objeto creado con la funcion
  # delta_IntegAPS
  
  tiempo.chr <- tiempos[i,1] %>% as.character()
  
  targetAll <- colnames(Territoriales@data)
  
  reps = grep(tiempo.chr, x = targetAll)
  
  # columna en donde esta la media de la integridad dentro del shapefile
  rep_porc = targetAll[reps[1]]
  
  rep_cat <- cut(x = Territoriales@data[ , rep_porc], breaks = c(0, 10, 20, 30, 40, 50, 60, 70),
                   labels = c("0—10", "10—20", "20—30", "30—40", "40—50", "50—60", "60—70"),
                include.lowest = TRUE, right = FALSE)
  
  terr_rep <- Territoriales[, rep_porc] %>% st_as_sf()
  
  # etiquetas y colores para la leyenda
  cols <- RdYlGn(7)
  names(cols) <- c("0—10", "10—20", "20—30", "30—40", "40—50", "50—60", "60—70")
  
  tiff(paste0("productos/rep_distspp/rep_geo/TERRITORIALES/rep_", tiempos[i, 1], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plot_datai <- ggplot() +
    geom_sf(data = col_sf, fill = "transparent", color = "grey25", linetype = "dashed")+
    geom_sf(data = terr_rep, aes(fill = rep_cat)) + 
    scale_fill_manual(values = cols, name = paste0("Porcentaje representatividad \nDistribución de especies", 
                                                 "\n", "por Dirección territorial","\n", 
                                                 tiempos[i,1]))+
    theme_void()
  print(plot_datai)
  dev.off()
}


# Mapas de deltas del porcentaje representatividad

for(i in 1:length(periodos)){
  
  tiempo.chr <- tiempos[i+1,1] %>% as.character()
  
  targetAll <- colnames(Territoriales@data)
  
  reps = grep(tiempo.chr, x = targetAll)
  
  # columna en donde esta la media de la integridad dentro del shapefile
  dreps = targetAll[reps[2]]
  
  drep_cat <- cut(x = Territoriales@data[, dreps], breaks = c(-5, 0, 5, 10, 15, 20, 25),
                   labels = c("-5—0", "0—5", "5—10", "10—15", "15—20", "20—25"),
                   include.lowest = TRUE, right = FALSE)
  
  terr_drep <- Territoriales[, dreps] %>% st_as_sf()
  
  # etiquetas y colores para la leyenda
  cols <- RdYlGn(6)
  names(cols) <- c("-5—0", "0—5", "5—10", "10—15", "15—20", "20—25")
  
  tiff(paste0("productos/rep_distspp/rep_geo/TERRITORIALES/dreps_", periodos[i], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plot_datai <- ggplot() +
    geom_sf(data = col_sf, fill = "transparent", color = "grey25", linetype = "dashed")+
    geom_sf(data = terr_drep, aes(fill = drep_cat)) + 
    scale_fill_manual(values = cols, name = paste0("Cambio en el \nporcentaje representatividad \nDistribución de especies", 
                                                   "\n", "por Dirección territorial","\n", 
                                                   periodos[i]))+
    theme_void()
  print(plot_datai)
  dev.off()
}

#_____________________________________________

#   2.3 Territorial individual

nombre_corto <- c("Amazonia", "AndesNoro", "AndesOcc", "Caribe", "Orinoquia", "Pacifico")

runaps_sf <- list(RUNAP_1990_shp, RUNAP_2010_shp)

for(i in 1:length(Territoriales@data$nombre)){
  
  print(Territoriales@data$nombre[i])
  
  #  A. numerica
  
  dir.create(paste0("productos/rep_distspp/rep_num/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
  
  
  res_territorial_i <- cbind(tiempos, rep_distSpp_Terr_res[i, 1:2], rep_distSpp_Terr_res[i, 3:4]) %>% as.data.frame()
  colnames(res_territorial_i) <- c("Periodo", "rep_distSpp", "drep_distSpp")
  
  write.csv(res_territorial_i, paste0("productos/rep_distspp/rep_num/TERRITORIALES_INDIVIDUAL/", nombre_corto[i], ".csv"), 
            row.names = F)
  
  #     B. grafica

  dir.create(paste0("productos/rep_distspp/rep_gra/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
  
  jpeg(paste0("productos/rep_distspp/rep_gra/TERRITORIALES_INDIVIDUAL/drep_distSpp_", nombre_corto[i], ".jpg"), res = c(300,300),
       width = 2480, height = 2480)
  repr_plot<- ggplot(res_territorial_i, aes(factor(Periodo), drep_distSpp, color = Periodo)) +
    geom_line(color="red", aes(group = 1))+
    ylim(c(-5, 25))+
    #  xlim(c(1990, 2020))+
    geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
    ggtitle(paste0("Cambio en el porcentaje de representatividad \nDistribución de especies\n"), Territoriales@data$nombre[i])+ 
    labs(y= "Cambio representatividad (%) ", x = "Año")+
    theme_classic()
  print(repr_plot)
  dev.off()
  

  #    C. geografica
  
  # territorial i 
  Territorial_i <- Territoriales[i, ]
  
  # Mapas porcentaje representatividad
  
  for(a in 1:nrow(tiempos)){ # el desencadenante son el numero de años que se usan en el analisis
    
    ras_rep_distSpp <- rep_distSpp_xAps[[a]]
    
    ras_rep_distSpp_a <- ras_rep_distSpp %>% crop(Territorial_i) %>% mask(Territorial_i)
    
    info_rasrep_a <- raster::as.data.frame(ras_rep_distSpp_a, xy = TRUE)
    info_rasrep_a <- na.omit(info_rasrep_a)
    
    colnames(info_rasrep_a) <- gsub(pattern = "_[[:digit:]]+", replacement = "", x = colnames(info_rasrep_a))
    
    info_rasrep_a <- mutate(.data = info_rasrep_a, rasdistSpp_cat = cut(RUNAP_pnnid, 
                                                                        breaks = c(0, 20, 40, 60, 80, 100), 
                                                                        labels = c("0-20", "20-40", "40-60", "60-80", "80-100"), 
                                                                        include.lowest = TRUE, right = FALSE
    ))
    
    cols <- RdYlGn(5)
    names(cols) <- c("0-20", "20-40", "40-60", "60-80", "80-100")
    
    Territorial_i_sf <- st_as_sf(Territorial_i)
    
    dir.create(paste0("productos/rep_distspp/rep_geo/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
    dir.create(paste0("productos/rep_distspp/rep_geo/TERRITORIALES_INDIVIDUAL/", nombre_corto[i]), showWarnings = F)
    
    
    tiff(paste0("productos/rep_distspp/rep_geo/TERRITORIALES_INDIVIDUAL/", nombre_corto[i], "/", "rep_distSpp_", tiempos[a, 1],
                ".tif"), res = c(300,300), width = 2480, height = 2480, compression = "lzw")
    plot_datai <- ggplot() +
      geom_sf(data = Territorial_i_sf, fill = "transparent", color = "gray20") +
      geom_raster(data = info_rasrep_a, aes(x = x, y = y, fill = rasdistSpp_cat))+ 
      scale_fill_manual(values = cols, name = paste0("Porcentaje representatividad ecologica\nDistribución de especies\n", tiempos[a, 1]))+
      theme_void()+
      theme(plot.background = element_rect(colour = "transparent"),
            legend.background = element_rect(fill = "white", color = "transparent"),
            legend.title.align = 0.5,
            legend.title = element_text(size = 11, face = "bold"))
    print(plot_datai)
    dev.off()
  }
    
  # Mapas de deltas
  
  for(b in 1:length(drep_distSpp_xAps)){
     
     # extraer raster i
    rasdrep_b <- drep_distSpp_xAps[[b]]
    rasdrep_b <- rasdrep_b %>% crop(Territorial_i) %>% mask(Territorial_i)
     
    info_rasdrep_b <- raster::as.data.frame(rasdrep_b, xy = TRUE)
    info_rasdrep_b <- na.omit(info_rasdrep_b)
    
    colnames(info_rasdrep_b) <- gsub(pattern = "_[[:digit:]]+", 
                                                 replacement = "", x = colnames(info_rasdrep_b))
     
    info_rasdrep_b <- mutate(.data = info_rasdrep_b, drasrep_cat = cut(drep_distSpp_AP,
                                                                       breaks = c(-Inf, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80), 
                                                                       labels = c( "< -10",  "-10 - 0", 
                                                                                   "0 - 10", "10 - 20", "20 - 30", "30 - 40",
                                                                                   "40 - 50", "50 - 60", "60 - 70", "70 - 80"),
                                                                       include.lowest = TRUE, right = FALSE
                                                                       )
                             )
     
    cols <- RdYlGn(10)
    names(cols) <-  c( "< -10",  "-10 - 0", 
                     "0 - 10", "10 - 20", "20 - 30", "30 - 40",
                     "40 - 50", "50 - 60", "60 - 70", "70 - 80")
     
    runap_sf <- runaps_sf[[b]] %>%  st_transform(st_crs(Territorial_i_sf))
    runap_sf <- runap_sf[Territorial_i_sf, ]
    
    tiff(paste0("productos/rep_distspp/rep_geo/TERRITORIALES_INDIVIDUAL/", nombre_corto[i], "/", "drep_distSpp", periodos[b],
    ".tif"), res = c(300,300), 
          width = 2480, height = 3508, compression = "lzw")
    plotdatai <- ggplot() +
       geom_sf(data = runap_sf, fill = "transparent", color = "gray90")+ 
       geom_sf(data = Territorial_i_sf, fill = "transparent", color = "gray20")+
       geom_raster(data = info_rasdrep_b, aes(x = x, y = y, fill = drasrep_cat))+
       scale_fill_manual(values = cols, name = paste0("Cambio en el porcentaje \n de representatividad ecologica\nDistribución de especies\n",
                                                      nombre_corto[i], periodos[b]))+
       theme_void()+
       theme(plot.background = element_rect(colour = "transparent"),
             legend.position = "right",
             legend.background = element_rect(fill = "white", color = "transparent"),
             legend.title.align = 0.5,
             legend.title = element_text(size = 11, face = "bold")
             )
     print(plotdatai)
     dev.off()
     
  }
}





