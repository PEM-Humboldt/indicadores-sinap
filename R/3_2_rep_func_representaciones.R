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

# load("rep_func_cod/rep_func_objetos_operativo.RData")

# 1. Shapefile utiles

col_sf <- read_sf("capas_base_ejemplos/Nacional/Colombia_FINAL.shp")

# 2. Cambio en la media de integridad

#_____________________________________________
#   2.1 Nacional
#     A. numerica

dir.create("productos/rep_func/rep_num")

tiempos <- c(1990, 2010) %>% as.data.frame()

Integ_table <- data.frame(tiempos, Integ_Nal, Delta_Integ_Nal)

colnames(Integ_table) <- c("Periodo", "Integ_Nal", "Delta_Integ_Nal")

write.csv(Integ_table, "productos/rep_func/rep_num/dInteg_Nal.csv", row.names = F)


#     B. grafica

# medias de integridad

dir.create("productos/rep_func/rep_gra")

jpeg("productos/rep_func/rep_gra/Repre_integ_Sist_AP.jpg", res = c(300,300), width = 2480, height = 2480)
repr_plot<- ggplot(Integ_table, aes(factor(Periodo), Integ_Nal, color = Periodo)) +
  geom_line(color="red", aes(group=1)) +
  ylim(c(0,1))+
  ggtitle("Media de la representatividad de integridad \nestructural del SINAP")+ 
  labs(y= "Media de Integridad (Q) ", x = "Año")+
  theme_classic()
print(repr_plot)
dev.off()


# deltas de integridad
jpeg("productos/rep_func/rep_gra/Repre_dinteg_Sist_AP.jpg", res = c(300,300), width = 2480, height = 2480)
repr_plot<- ggplot(Integ_table, aes(factor(Periodo), Delta_Integ_Nal, color = Periodo)) +
  geom_line(color="red", aes(group=1)) +
  ylim(c(-0.1,0.1))+
  geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
  ggtitle("Cambio en la media de la representatividad de integridad \nestructural del SINAP")+ 
  labs(y= "Delta en media de Integridad (Q) ", x = "Año")+
  theme_classic()
print(repr_plot)
dev.off()


#     C. geografica

dir.create("productos/rep_func/rep_geo", showWarnings = F)

dir.create("productos/rep_func/rep_geo/NACIONAL", showWarnings = F)

Inte_xAps <- list(Integ2010_1990_AP$ras1, Integ2010_1990_AP$ras2)

# cada objeto dInte_xAps guarda: 
# 1. shp_dInteg_tiempo2, shapefile en donde se guardan los deltas de la media de integridad por Ap entre
# el tiempo 2 y el tiempo 1
# 2. ras1, rasterLater, almacena los datos de integridad por pixel de AP en el tiempo 1
# 3. ras2, rasterLater, almacena los datos de integridad por pixel de AP en el tiempo 2
# 4. raster_dInteg_tiempo, rasterLayer en donde se almacenan los deltas o el cambio de integridad por 
# pixel de AP

# Por tanto se pueden usar para construir los mapas nacionales de la media y el cambio de la media


# Mapas de la media

for(i in 1:nrow(tiempos)){ # el desencadenante son el numero de años que se usan en el analisis
  
  # extraer del año i, si i es igual a 1 extraiga el el raster 1 del objeto creado con la funcion
  # delta_IntegAPS
  
  rasInte <- Inte_xAps[[i]]
  
  info_rasInte <- raster::as.data.frame(rasInte, xy = TRUE)
  info_rasInte <- na.omit(info_rasInte)
  
  cols <- RdYlGn(4)
  
  tiff(paste0("productos/rep_func/rep_geo/NACIONAL/Integ_", tiempos[i, 1], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plot_datai <- ggplot() +
    geom_sf(data = col_sf, fill = "transparent", color = "gray20") +
    geom_raster(data = info_rasInte, aes(x = x, y = y, fill = layer))+ 
    scale_fill_gradientn(colours = cols, name = paste0("Integridad SINAP \n ", tiempos[i, 1]), limits = c(0, 1), 
                         breaks=c(0,0.5,1), labels=c("0 - Baja",0.5,"1.0 - Alta"))+
    theme_void()
  print(plot_datai)
  dev.off()
}
  

# Mapas de deltas

dInte_xAps <- list(Integ2010_1990_AP$raster_dInteg_tiempo)
runaps_shps <- list(RUNAP_shp_2010) # lista de runaps sin el primer año

periodos <- c("1990-2010")


for(i in 1:length(dInte_xAps)){
  
  # extraer raster i
  rasdInte <- dInte_xAps[[i]]
  
  info_rasdInte <- raster::as.data.frame(rasdInte, xy = TRUE)
  info_rasdInte <- na.omit(info_rasdInte)
  
  # Binarizar el delta entre valores negativos vs constantes o positivos
  
  info_rasdInte_df <- mutate(.data = info_rasdInte, dInteg_bin = cut(layer, breaks = c(-1, 0, 1 ),
                                                                     labels = c("Negativo",
                                                                                "Positivo o constante")))
  
  # colores rojo a verde para representar 
  cols <- RdYlGn(2)
  names(cols) <- c("Negativo", "Positivo o constante")
  
  runap_sf <- runaps_shps[[i]]  %>% spTransform(crs(col_sf)) %>% st_as_sf()
  runap_sf <- runap_sf[col_sf, ]
  
  tiff(paste0("productos/rep_func/rep_geo/NACIONAL/dInteg_", periodos[i], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plotdatai <- ggplot() +
    geom_sf(data = runap_sf, fill = "transparent", color = "gray90") +
    geom_sf(data = col_sf, fill = "transparent", color = "gray20") +
    geom_raster(data = info_rasdInte_df , aes(x = x, y = y, fill = dInteg_bin))+
    scale_fill_manual(values = cols, name = paste0("Cambio integridad\n", periodos[i]))+
    theme_void()+
    theme(plot.background = element_rect(colour = "transparent"),
          legend.position = c(0.23, 0.10),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title.align = 0.5,
          legend.title = element_text(size = 11, face = "bold"))
  print(plotdatai)
  dev.off()
  
}

#_____________________________________
#   2.2 Territorial

#     A. numerica


write.csv(Integ_Terr_res, "productos/rep_func/rep_num/dInteg_Ter.csv", row.names = T)

terr_nombres_small <- c("Amazonia", "Andes_Noro", "Andes_Occ", "Caribe", "Orinoquia", "Pacifico")

#     B. grafica

# medias
jpeg("productos/rep_func/rep_gra/Integ_territoriales.jpg", res = c(300,300), width = 3508, height = 2480)
par(mfrow=c(3,2))
plot(Integ_Terr_res[1, c(1:2)], type= "l", main="Direccion Territorial Amazonia", sub="RUNAP",
     xlab="Año", xaxt= "n", ylab="Cambio integridad (Q)")
axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
plot(Integ_Terr_res[2, c(1:2)], type= "l", main="Direccion Territorial Andes Nororientales", sub="RUNAP",
     xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
plot(Integ_Terr_res[3, c(1:2)], type= "l", main="Direccion Territorial Andes Occidentales", sub="RUNAP",
     xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
plot(Integ_Terr_res[4, c(1:2)], type= "l", main="Direccion Territorial Caribe", sub="RUNAP",
     xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
plot(Integ_Terr_res[5, c(1:2)], type= "l", main="Direccion Territorial Orinoquia", sub="RUNAP",
     xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
plot(Integ_Terr_res[6, c(1:2)], type= "l", main="Direccion Territorial Pacifico", sub="RUNAP",
     xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
dev.off()


# deltas
jpeg("productos/rep_func/rep_gra/dInteg_territoriales.jpg", res = c(300,300), width = 3508, height = 2480)
  par(mfrow=c(3,2))
  plot(Integ_Terr_res[1, c(3:4)], type= "l", main="Direccion Territorial Amazonia", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="Cambio integridad (Q)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(Integ_Terr_res[2, c(3:4)], type= "l", main="Direccion Territorial Andes Nororientales", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(Integ_Terr_res[3, c(3:4)], type= "l", main="Direccion Territorial Andes Occidentales", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(Integ_Terr_res[4, c(3:4)], type= "l", main="Direccion Territorial Caribe", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(Integ_Terr_res[5, c(3:4)], type= "l", main="Direccion Territorial Orinoquia", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
  plot(Integ_Terr_res[6, c(3:4)], type= "l", main="Direccion Territorial Pacifico", sub="RUNAP",
       xlab="Año", xaxt= "n",  ylab="Cambio integridad (Q)")
  axis(side = 1, at = 1:nrow(tiempos), labels = tiempos[ , 1])
dev.off()


#     C. geografica

dir.create("rep_func/rep_geo/TERRITORIALES", showWarnings = F)

# unir datos con shapefile

Territoriales@data <- cbind(Territoriales@data, Integ_Terr_res)

dir.create("productos/rep_func/rep_geo/TERRITORIALES")

# Mapas de la media

for(i in 1:nrow(tiempos)){ # el desencadenante son el numero de años que se usan en el analisis
  
  # extraer del año i, si i es igual a 1 extraiga el el raster 1 del objeto creado con la funcion
  # delta_IntegAPS
  
  tiempo.chr <- tiempos[i,1] %>% as.character()
  
  targetAll <- colnames(Territoriales@data)
  
  Integridades = grep(tiempo.chr, x = targetAll)
  
  # columna en donde esta la media de la integridad dentro del shapefile
  integ_media = targetAll[Integridades[1]]
  
  Integ_cat <- cut(x = Territoriales@data[, integ_media], breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1),
                   labels = c("0—0.2", "0.2—0.4", "0.4—0.6", "0.6—0.8", "0.8—1"))
  
  terr_Integi <- Territoriales[, integ_media] %>% st_as_sf()
  
  # etiquetas y colores para la leyenda
  cols <- RdYlGn(5)
  names(cols) <- c("0—0.2", "0.2—0.4", "0.4—0.6", "0.6—0.8", "0.8—1")
  
  tiff(paste0("productos/rep_func/rep_geo/TERRITORIALES/Integ_", tiempos[i, 1], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plot_datai <- ggplot() +
    geom_sf(data = col_sf, fill = "transparent", color = "grey25", linetype = "dashed")+
    geom_sf(data = terr_Integi, aes(fill = Integ_cat)) + 
    scale_fill_manual(values = cols, name = paste0("Media integridad", 
                                                 "\n", "por Dirección territorial","\n", 
                                                 tiempos[i,1]))+
    theme_void()
  print(plot_datai)
  dev.off()
}

# Mapas de deltas

for(i in 1:length(dInte_xAps)){
  
  tiempo.chr <- tiempos[i+1, 1] %>% as.character()
  
  targetAll <- colnames(Territoriales@data)
  
  Integridades = grep(tiempo.chr, x = targetAll)
  
  # columna en donde esta la media de la integridad dentro del shapefile
  dinteg = targetAll[Integridades[2]]
  
  dInteg_cat <- cut(x = Territoriales@data[, dinteg], breaks = c(-Inf, 0, Inf),
                   labels = c("Negativo", "Positivo o Constante"))
  
  terr_dIntegi <- Territoriales[, dInteg_cat] %>% st_as_sf()
  
  # etiquetas y colores para la leyenda
  cols <- RdYlGn(2)
  names(cols) <- c("Negativo", "Positivo o Constante")
  
  tiff(paste0("productos/rep_func/rep_geo/TERRITORIALES/dInteg_", periodos[i], ".tif"), res = c(300,300), 
       width = 2480, height = 3508, compression = "lzw")
  plot_datai <- ggplot() +
    geom_sf(data = col_sf, fill = "transparent", color = "grey25", linetype = "dashed")+
    geom_sf(data = terr_dIntegi, aes(fill = dInteg_cat)) + 
    scale_fill_manual(values = cols, name = paste0("Cambio en la media de integridad", 
                                                   "\n", "por Dirección territorial","\n", 
                                                   periodos[i]))+
    theme_void()
  print(plot_datai)
  dev.off()
}

#_____________________________________________

#   2.3 Territorial individual

nombre_corto <- c("Amazonia", "AndesNoro", "AndesOcc", "Caribe", "Orinoquia", "Pacifico")

for(i in 1:length(Territoriales@data$nombre)){
  
  print(Territoriales@data$nombre[i])
  
  #  A. numerica
  
  dir.create(paste0("productos/rep_func/rep_num/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
  
  
  res_territorial_i <- cbind(tiempos, Integ_Terr_res[i, 1:2], Integ_Terr_res[i, 3:4]) %>% as.data.frame()
  colnames(res_territorial_i) <- c("Periodo", "Integ_terr", "dinteg_terr")
  
  write.csv(Integ_table, paste0("productos/rep_func/rep_num/TERRITORIALES_INDIVIDUAL/", nombre_corto[i], ".csv"), 
            row.names = F)
  
  #     B. grafica

  dir.create(paste0("productos/rep_func/rep_gra/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
  
  jpeg(paste0("productos/rep_func/rep_gra/TERRITORIALES_INDIVIDUAL/Repre_dinteg_", nombre_corto[i], ".jpg"), res = c(300,300),
       width = 2480, height = 2480)
  repr_plot<- ggplot(res_territorial_i, aes(factor(Periodo), dinteg_terr, color = Periodo)) +
    geom_line(color="red", aes(group=1))+
    ylim(c(-1,1))+
    #  xlim(c(1990, 2020))+
    ggtitle("Cambio en la media de la representatividad de integridad \nestructural del SINAP")+ 
    labs(y= "Delta en media de Integridad (Q) ", x = "Año")+
    theme_classic()
  print(repr_plot)
  dev.off()
  

  #    C. geografica
  
  # territorial i 
  Territorial_i <- Territoriales[i, ]
  
  # Mapas de la media
  
  for(a in 1:nrow(tiempos)){ # el desencadenante son el numero de años que se usan en el analisis
    
    rasInte <- Inte_xAps[[a]]
    
    rasInte_a <- rasInte %>% crop(Territorial_i) %>% mask(Territorial_i)
    
    info_rasInte_a <- raster::as.data.frame(rasInte_a, xy = TRUE)
    info_rasInte_a <- na.omit(info_rasInte_a)
    
    cols <- RdYlGn(4)
    
    Territorial_i_sf <- st_as_sf(Territorial_i)
    
    dir.create(paste0("productos/rep_func/rep_geo/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
    dir.create(paste0("productos/rep_func/rep_geo/TERRITORIALES_INDIVIDUAL/", nombre_corto[i]), showWarnings = F)
    
    
    tiff(paste0("productos/rep_func/rep_geo/TERRITORIALES_INDIVIDUAL/", nombre_corto[i], "/", "Integ_", tiempos[a, 1],
                ".tif"), 
         res = c(300,300), width = 2480, height = 2480, compression = "lzw")
    plot_dataa <- ggplot() +
      geom_sf(data = Territorial_i_sf, fill = "transparent", color = "gray20") +
      geom_raster(data = info_rasInte_a, aes(x = x, y = y, fill = layer))+ 
      scale_fill_gradientn(colours = cols, name = paste0("Integridad sistema territorial \n ", 
                                                         nombre_corto[i], "\n", tiempos[a, 1]),
                           limits = c(0, 1), breaks=c(0,0.5,1), labels=c("0 — Baja",0.5,"1.0 — Alta"))+
      theme_void()
    print(plot_dataa)
    dev.off()
  }
  
  
  # Mapas de deltas
  
  for(b in 1:length(dInte_xAps)){
     
     # extraer raster i
    rasdInte_b <- dInte_xAps[[b]]
    rasdInte_b <- rasdInte_b %>% crop(Territorial_i) %>% mask(Territorial_i)
     
    info_rasdInte_b <- raster::as.data.frame(rasdInte_b, xy = TRUE)
    info_rasdInte_b <- na.omit(info_rasdInte_b)
     
     # Binarizar el delta entre valores negativos vs constantes o positivos
     
     info_rasdInte_df_b <- mutate(.data = info_rasdInte_b, dInteg_bin = cut(layer, breaks = c(-1, 0, 1 ),
                                                                        labels = c("Negativo",
                                                                                       "Positivo o constante")))
     
     # colores rojo a verde para representar 
     cols <- RdYlGn(2)
     names(cols) <- c("Negativo", "Positivo o constante")
     
     runap_sf <- runaps_shps[[b]]  %>% spTransform(crs(col_sf)) %>% st_as_sf()
     runap_sf <- runap_sf[Territorial_i_sf, ]
     
     
     tiff(paste0("productos/rep_func/rep_geo/TERRITORIALES_INDIVIDUAL/", nombre_corto[i], "/", "dInteg_", periodos[b],
     ".tif"), res = c(300,300), 
          width = 2480, height = 3508, compression = "lzw")
     plotdatai <- ggplot() +
       geom_sf(data = runap_sf, fill = "transparent", color = "gray90")+ 
       geom_sf(data = Territorial_i_sf, fill = "transparent", color = "gray20")+
       geom_raster(data = info_rasdInte_df_b , aes(x = x, y = y, fill = dInteg_bin))+
       scale_fill_manual(values = cols, name = paste0("Cambio integridad\nsistema territorial ", 
                                                      nombre_corto[i], "\n", periodos[b]))+
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





