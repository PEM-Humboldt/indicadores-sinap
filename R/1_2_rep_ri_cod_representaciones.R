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

# cargar objetos creados con el script operativo
# load("productos/rep_ri/rep_ri_objetos_operativo.RData")

# 1. Cargar shapefiles utiles

# 1.1 Shapefile territorrial

terr <- shapefile("capas_base_ejemplos/Territorial/Territoriales_final.shp") # %>% 
#  spTransform(CRS("+init=epsg:4326"))
nombre_corto <- c("Amazonia", "AndesNoro", "AndesOcc", "Caribe", "Orinoquia", "Pacifico")

# 1.2 Shapefile Nacional

col_sf <- shapefile("capas_base_ejemplos/Nacional/Colombia_FINAL.shp") %>% 
#  spTransform(CRS("+init=epsg:4326")) %>% 
  st_as_sf()

# 1.4 Shapefiles union runap territorial (paso codigo operativo 5.1.1)
shapefiles_runap_terr <- list.files("productos/rep_ri/RUNAPRRi/", "terr.shp$", full.names = T)
shapefiles_runap_terr <- lapply(shapefiles_runap_terr, shapefile)

#######################################

# 2. Representaciones

# 2.1. Nacional

# 2.1.1 RRi, Ic: Porcentaje de la representatividad de la riqueza de especies del SINAP (%RRi)

# A. Representacion numerica

dir.create("productos/rep_ri/rep_num", showWarnings = F)

Rep.num <- c(Rep_aps, tasa.increm.anual)
Rep.num <- qpcR:::cbind.na(Rep_aps, tasa.increm.anual)
mean(na.omit(Rep_aps))

tiempos <- c(1990, 2010)

Repre_total <- as.data.frame(cbind(tiempos, Rep_aps))

write.csv(Repre_total, "productos/rep_ri/rep_num/RRi_nac.csv")

# B. Representacion grafica

dir.create("productos/rep_ri/rep_gra", showWarnings = F)

jpeg("productos/rep_ri/rep_gra/Repre_riqueza_Sist_AP.jpg", res = c(300,300), width = 2480, height = 2480)
repr_plot<- ggplot(Repre_total, aes(factor(tiempos), Rep_aps, color = tiempos)) +
  geom_boxplot(color = "black") +
  geom_smooth(method = "auto", se=FALSE, color="red", aes(group=1)) +
  geom_hline(yintercept = 100, color = "red", linetype = "dashed")+
  ylim(c(76,100))+
  ggtitle("Representatividad de riqueza Sistema SINAP")+ 
  labs(y= "Porcentaje (%)", x = "Año")+
  theme_classic()
print(repr_plot)
dev.off()

# C. Representacion geografica

smallestExtent <- extent(ap1990) 

# extent San Andres para generar innset en el mapa
SAExtent <- extent(c(-82, -81, 12.25,  13.5))
SACut  <- ggplot(data = col_sf) +
  geom_sf(fill = "white") +
  coord_sf(xlim = c(SAExtent[1], SAExtent[2]), ylim = c(SAExtent[3], SAExtent[4]),
           datum = NA)+
  theme_bw()

# lista de shapefiles del RUNAP con el aporte al porcentaje de 
# representatividad por AP
data_rep_ap <- list(ap1990, ap2010) 

# mapa por capa temporal del RUNAP, porcentaje de representatividad

dir.create("productos/rep_ri/rep_geo", showWarnings = F)

for(i in 1:length(tiempos)){
  print(tiempos[i])
  datai <- data_rep_ap[[i]]
  
  datai <- crop(datai, smallestExtent)
  colRRi <- names(datai)[grep(names(datai), pattern = "RRi")][1]
  
  # categorizar los datos de representatividad 
  datai@data[, colRRi] <- cut(x = datai@data[, colRRi], breaks = c(0, 0.5, 1, 1.5, 2 , 2.5, 3, 100),
                              labels = c("0 — 0.5%", "0.5 — 1%", "1 — 1.5%", "1.5 — 2%", "2 — 2.5%", "2.5 — 3%", "> 3%"))
  datai <- st_as_sf(datai)
  
  # etiquetas y colores para la leyenda
  cols <- RdYlGn(7)
  names(cols) <- c("0 — 0.5%", "0.5 — 1%", "1 — 1.5%", "1.5 — 2%", "2 — 2.5%", "2.5 — 3%", "> 3%")
  
  dir.create("productos/rep_ri/rep_geo/NACIONAL", showWarnings = F)
  
  tiff(paste0("productos/rep_ri/rep_geo/NACIONAL/", tiempos[i], ".tif"), res = c(300,300), width = 2480, height = 3508, compression = "lzw")
  
  plotdatai <- ggplot() + 
    geom_sf(data = col_sf, fill = "transparent", color = "black") +
    geom_sf(data = datai, aes_string(fill = colRRi), color = "transparent") +
    scale_fill_manual(values = cols, name = paste0(tiempos[i],"\n" ,"% Representatividad", "\nde la Riqueza RUNAP")) +
    theme_void()+
    theme(plot.background = element_rect(colour = "black"),
          legend.position = c(0.23, 0.2),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title.align = 0.5,
          legend.title = element_text(size = 16, face = "bold"))+
    ggsn::scalebar(data = datai, location = "bottomright", model = "WGS84", dist_unit = "km", dist = 100,
                   st.size=3, height=0.01, transform = T, 
                   anchor = c("x" = -70, "y" = -6))+
    annotation_custom(ggplotGrob(SACut), xmax = -82, xmin = -78, ymin = 9, ymax = 14)
  
  print(plotdatai)
  dev.off()
}

# 2.1.2 dRRi, Id: Cambio en el porcentaje de la representatividad de la riqueza de especies
# del SINAP (dRRi)

# A. Representacion numerica

tiempo.periodo <- c("1990-2010")

Acumacion_total <- as.data.frame(cbind(tiempo.periodo, tasa.increm.anual))

write.csv(Acumacion_total, "productos/rep_ri/rep_num/deltaRRi_nac.csv")

# B. Representacion grafica

jpeg("productos/rep_ri/rep_gra/Diferencia_internanual SINAP.jpg", res = c(300,300), width = 2480, height = 2480)
repr_plot_diff <- ggplot(Acumacion_total, aes(factor(tiempo.periodo), tasa.increm.anual, color = tiempo.periodo)) +
  geom_boxplot(color = "black") +
  geom_smooth(method = "loess", se=FALSE, color="red", aes(group=1)) +
  ylim(c(-0.5,4))+
  geom_hline(yintercept = median(as.numeric(Acumacion_total$cambio.rep.anual)), 
             color = "red", linetype = "dashed")+
  ggtitle("Diferencia interanual de la representatividad de la riqueza en SINAP") + 
  labs(y= "Porcentaje (%)", x = "Año")+
  theme_classic()
print(repr_plot_diff)
dev.off()


# C. Representacion geografica

# mapa por capa temporal del RUNAP,diferencia en el porcentaje de representatividad

for(i in 1:length(tiempos)){
  print(tiempos[i])
  if(i+1>length(tiempos)){
    stop("el año no puede compararse porque es el ultimo de la serie")
  }
  
  datai <- data_rep_ap[[i+1]]
  coldRRi <- names(datai)[grep(names(datai), pattern = "dRRi")][1]
  
  # categorizar los datos de diferencia en la representatividad
  datai@data$diffdata1_2 <- cut(x = datai@data[, coldRRi], breaks = c(-4, -2, 0, 2, 4, 6, 8, 10, 100),
                                labels = c("-4— -2", "-2—0", "0—2%", "2—4%", "4—6%", "6—8%", "8—10%", "> 10%"))
# datai@data$diffdata1_2[is.na(datai@data$diffdata1_2)] <- "NA"
  datai <- st_as_sf(datai)
  
  # etiquetas y colores para la leyenda
  cols <- c(  RdYlGn(8), "gray25")
  names(cols) <- c("-4— -2", "-2—0", "0—2%", "2—4%", "4—6%", "6—8%", "8—10%", "> 10%", NA)
  
  tiff(paste0("productos/rep_ri/rep_geo/NACIONAL/", tiempo.periodo[i], ".tif"), res = c(300,300), width = 2480, height = 3508, compression = "lzw")
  
  plotdatai <- ggplot() + 
    geom_sf(data = col_sf, fill = "transparent", color = "black") +
    geom_sf(data = datai, aes(fill = diffdata1_2), color = "transparent") +
    scale_fill_manual(values = cols,
                    #na.value = "black",
                        name = paste0(tiempo.periodo[i],"\n" , "Diferencia en el", 
                                                   "\n% Representatividad", "\n", "de la Riqueza RUNAP "))+
    theme_void()+
    theme(plot.background = element_rect(colour = "black"),
          legend.position = c(0.23, 0.2),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title.align = 0.5,
          legend.title = element_text(size = 14, face = "bold"))+
    ggsn::scalebar(data = datai, location = "bottomright", model = "WGS84", dist_unit = "km", dist = 100,
                   st.size=3, height=0.01, transform = T, 
                   anchor = c("x" = -70, "y" = -6))+
    annotation_custom(ggplotGrob(SACut), xmax = -82, xmin = -78, ymin = 9, ymax = 14)
  
  print(plotdatai)
  dev.off()
}


################################

# 2.2. Territorial

# 2.2.1 RRi, Ic: Porcentaje de la representatividad de la riqueza de especies por territorial (RRi)

# A. Representacion numerica

colnames(dat_rep_ri_terr) <- terr$nombre
rownames(dat_rep_ri_terr) <- tiempos

## media
media_rep_territorial <- data.frame("media" = apply(dat_rep_ri_terr, 2, mean))
write.csv(media_rep_territorial, "productos/rep_ri/rep_num/RRi_terr_media.csv")

## values
write.csv(dat_rep_ri_terr, "productos/rep_ri/rep_num/RRi_terr.csv")


# B. Representacion grafica

jpeg("productos/rep_ri/rep_gra/Repre_riqueza_territoriales.jpg", res = c(300,300), width = 3508, height = 2480)
  par(mfrow=c(3,2))
  plot(dat_rep_ri_terr[,1], type= "l", main="Direccion Territorial Amazonia", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="Porcentaje")
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(dat_rep_ri_terr[,2], type= "l", main="Direccion Territorial Andes Nororientales", sub="RUNAP",
       xlab="Año", xaxt= "n",ylab="Porcentaje")
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(dat_rep_ri_terr[,3], type= "l", main="Direccion Territorial Andes Occidentales", sub="RUNAP",
       xlab="Año", xaxt= "n",ylab="Porcentaje")
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(dat_rep_ri_terr[,4], type= "l", main="Direccion Territorial Caribe", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="Porcentaje")
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(dat_rep_ri_terr[,5], type= "l", main="Direccion Territorial Orinoquia", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="Porcentaje")
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(dat_rep_ri_terr[,6], type= "l", main="Direccion Territorial Pacifico", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="Porcentaje")
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
dev.off()

# C. Representacion geografica

for(i in 1:length(tiempos)){
  
  print(tiempos[i])
  datai <- shapefiles_runap_terr[[i]] %>% spTransform(CRS("+init=epsg:4326"))
  
  tosaveNum <- as.numeric()
  for(a in 1:length(unique(terr$nombre))){
    indexa <- which(datai$nombre_1 == unique(terr$nombre)[a])
    tosaveNum[indexa] <- dat_rep_ri_terr[i,a]
  }
  datai@data$RRITerr <- tosaveNum
  
  # categorizar datos
  tosaveNumCat <- cut(x = tosaveNum, breaks = c(0, 10, 20, 30, 40, 50, 60, 100),
                      labels = c("0 — 10%", "10 — 20%", "20 — 30%", "30 — 40%", "40 — 50%", "50 — 60%", "> 60%"))
  datai@data$RRITerrCat <- tosaveNumCat
  datai <- crop(datai, smallestExtent)
  
  # guardando info
#  shapefiles_runap_terr[[i]] <- datai
  
  #convirtiendo a simple feature
  datai <- st_as_sf(datai)
  terr_sf <- st_as_sf(terr)
  
  # etiquetas y colores para la leyenda
  cols <- RdYlGn(7)
  names(cols) <- c("0 — 10%", "10 — 20%", "20 — 30%", "30 — 40%", "40 — 50%", "50 — 60%", "> 60%")
  
  dir.create("productos/rep_ri/rep_geo/TERRITORIAL", showWarnings = F)
  
  tiff(paste0("productos/rep_ri/rep_geo/TERRITORIAL/", tiempos[i], ".tif"), res = c(300,300), width = 2480, height = 3050, compression = "lzw")
  
  plotdatai <- ggplot() + 
    geom_sf(data = col_sf, fill = "transparent", color = "grey25", linetype = "dashed")+
    geom_sf(data = terr_sf, fill = "transparent", color = "grey25")+
    geom_sf(data = datai, aes(fill = RRITerrCat), color = "transparent")+
    scale_fill_manual(values = cols, name = paste0(tiempos[i],
                                                   "\n" ,"% Representatividad", 
                                                   "\n de la Riqueza RUNAP", 
                                                   "\n", "por Direccion Territorial"))+
    theme_void()+
    theme(plot.background = element_rect(colour = "black"),
          legend.position = c(0.23, 0.2),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title.align = 0.5,
          legend.title = element_text(size = 12, face = "bold"))+
    ggsn::scalebar(data = datai, location = "bottomright", model = "WGS84", dist_unit = "km", dist = 100,
                   st.size=3, height=0.01, transform = T, 
                   anchor = c("x" = -70, "y" = -6))+
    annotation_custom(ggplotGrob(SACut), xmax = -82, xmin = -78, ymin = 9, ymax = 14)
  
  print(plotdatai)
  dev.off()
}

# 2.2.2 dRRi, Id: Cambio en el porcentaje de la representatividad de la riqueza de especies
# del SINAP (dRRi)


# A. Representacion numerica

tiempo.periodo.2 <- c("90-10")

colnames(tasa.incremento.territorial) <- tiempo.periodo.2

#media

media_rep_territorial <- data.frame("media" = apply(tasa.incremento.territorial, 1, mean))
write.csv(media_rep_territorial, "productos/rep_ri/rep_num/deltaRRi_terr_media.csv")

write.csv(tasa.incremento.territorial, "productos/rep_ri/rep_num/deltaRRi_terr_.csv")

# B. Representacion grafica

jpeg("productos/rep_ri/rep_gra/Diferencia_internanual_territoriales.jpg", res = c(300,300), width = 3508, height = 2480)
  par(mfrow=c(3,2))
  plot(tasa.incremento.territorial[1,], xaxt= "n", type= "l", main="Direccion Territorial Amazonia", sub="RUNAP",
       xlab="Año", ylab="Porcentaje")
#  axis(1, seq(1, 2, by=1), labels= tiempo.periodo.2)
  plot(tasa.incremento.territorial[2,], xaxt= "n",type= "l", main="Direccion Territorial Andes Nororientales", sub="RUNAP",
       xlab="Año", ylab="Porcentaje")
#  axis(1, seq(1, 2, by=1), labels= tiempo.periodo.2)
  plot(tasa.incremento.territorial[3,], xaxt= "n",type= "l", main="Direccion Territorial Andes Occidentales", sub="RUNAP",
       xlab="Año", ylab="Porcentaje")
#  axis(1, seq(1, 2, by=1), labels= tiempo.periodo.2)
  plot(tasa.incremento.territorial[4,], xaxt= "n",type= "l", main="Direccion Territorial Caribe", sub="RUNAP",
       xlab="Año", ylab="Porcentaje")
#  axis(1, seq(1, 2, by=1), labels= tiempo.periodo.2)
  plot(tasa.incremento.territorial[5,], xaxt= "n",type= "l", main="Direccion Territorial Orinoquia", sub="RUNAP",
       xlab="Año", ylab="Porcentaje")
#  axis(1, seq(1, 2, by=1), labels= tiempo.periodo.2)
  plot(tasa.incremento.territorial[6,], xaxt= "n",type= "l", main="Direccion Territorial Pacifico", sub="RUNAP",
       xlab="Año", ylab="Porcentaje")
#  axis(1, seq(1, 2, by=1), labels= tiempo.periodo.2)
dev.off()

# Representacion geografica

for(i in 1:length(tiempos)){
  
  print(tiempos[i])
  if(i+1 > length(tiempos)){
    stop("el año no puede compararse porque es el ultimo de la serie")
  }
  
  datai <- shapefiles_runap_terr[[i+1]] %>% spTransform(CRS("+init=epsg:4326"))
  
  tosaveNum <- as.numeric()
  for(a in 1:length(unique(terr$nombre))){
    indexa <- which(datai$nombre_1 == unique(terr$nombre)[a])
    tosaveNum[indexa] <- tasa.incremento.territorial[a, i]
  }  
  
  # categorizar datos
  tosaveNumCat <- cut(x = tosaveNum, breaks = c(-4, -2, 0, 2, 4, 6, 8, 10, 100),
                      labels = c("-4— -2", "-2—0", "0—2%", "2—4%", "4—6%", "6—8%", "8—10%", "> 10%"))
  datai@data$dRRITerrCat <- tosaveNumCat
  datai <- crop(datai, smallestExtent)
  
  #convirtiendo a simple feature
  datai <- st_as_sf(datai)
  terr_sf <- st_as_sf(terr)
  
  # etiquetas y colores para la leyenda
  cols <- RdYlGn(8)
  names(cols) <- c("-4— -2", "-2—0", "0—2%", "2—4%", "4—6%", "6—8%", "8—10%", "> 10%")
  
  tiff(paste0("productos/rep_ri/rep_geo/TERRITORIAL/", tiempo.periodo[i], ".tif"), res = c(300,300), width = 2480, height = 2480, compression = "lzw")
  
  plotdatac <- ggplot() + 
    geom_sf(data = col_sf, fill = "transparent", color = "grey25", linetype = "dashed")+
    geom_sf(data = terr_sf, fill = "transparent", color = "grey25")+
    geom_sf(data = datai, aes(fill = dRRITerrCat), color = "transparent")+ 
    scale_fill_manual(values = cols, name = paste0(tiempo.periodo[i],"\n" , 
                                                   "Diferencia en el", 
                                                   "\n%", "de Representatividad", 
                                                   "\n", "por Dirección territorial"))+
    theme_void()+
    theme(plot.background = element_rect(colour = "transparent"),
          legend.position = c(0.18, 0.2),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title.align = 0.5,
          legend.title = element_text(size = 9, face = "bold"),
          legend.key.size = unit(0.35, 'cm')
          )+
    ggsn::scalebar(data = datai, location = "bottomright", model = "WGS84", dist_unit = "km", dist = 100,
                   st.size=3, height=0.01, transform = T, 
                   anchor = c("x" = -70, "y" = -6))+
    annotation_custom(ggplotGrob(SACut), xmax = -82, xmin = -78, ymin = 9, ymax = 14)
  
  print(plotdatac)
  dev.off()
}

###################################

# 2.3 Territorial individual

for(i in 1:length(terr@data$nombre)){
  
  print(colnames(dat_rep_ri_terr)[i])
  
  # territorial i 
  shapefiles_runap_terri <- list()
  
  for(a in 1:length(shapefiles_runap_terr)){
    shapefilesa <- shapefiles_runap_terr[[a]]
    shapefiles_runap_terri[[a]] <- shapefilesa[shapefilesa@data$nombre_1 == colnames(dat_rep_ri_terr)[i], ]
  }
  
  # 2.3.1 RRi, Ic: Porcentaje de la representatividad de la riqueza de especies por territorial (RRi)

  # A. Representaon numerica
  
  print("porcentaje representatividad")
  
  print("numerica")
  
  dir.create("productos/rep_ri/rep_num/TERRITORIALES_INDIVIDUAL", showWarnings = F)
  
  Repre_totali <- data.frame("tiempos" = tiempos, "SIRAP" = dat_rep_ri_terr[, i])
  
  write.csv(Repre_totali, file = paste0("productos/rep_ri/rep_num/TERRITORIALES_INDIVIDUAL/",
                                        nombre_corto[i], ".csv"))
  # B. Representación grafica
  
  print("grafica")
  
  dir.create(paste0("productos/rep_ri/rep_gra/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
  
    
  jpeg(paste0("productos/rep_ri/rep_gra/TERRITORIALES_INDIVIDUAL/Repre_riqueza_", nombre_corto[i], ".jpg"), res = c(300,300), width = 2480, height = 2480)
  repr_plot<- ggplot(Repre_totali, aes(factor(tiempos), SIRAP, color = tiempos)) +
    geom_boxplot(color = "black") +
    geom_smooth(method = "auto", se=FALSE, color="red", aes(group=1)) +
    geom_hline(yintercept = 100, color = "red", linetype = "dashed")+
    ylim(c(0,100))+
    ggtitle(paste0("Representatividad de riqueza ", colnames(dat_rep_ri_terr)[i]))+ 
    labs(y= "Porcentaje (%)", x = "Año")+
    theme_classic()
  print(repr_plot)
  dev.off()
  
  # C. Representación geografica
  
  print("geografica")
  
  dir.create("productos/rep_ri/rep_geo/TERRITORIALES_INDIVIDUAL/", showWarnings = F)
  
  # territoriales small  
  terr_small <- terr[terr@data$nombre == colnames(dat_rep_ri_terr)[i], ] %>% 
    st_as_sf()
  
  # Shape colombia oficial
  col_small_sf <- shapefile("capas_base_ejemplos/Nacional/Colombia_FINAL.shp") %>% 
                  crop(terr_small) %>% 
                  st_as_sf()
  
  # preparacion de carpetas
  dir.create(paste0("productos/rep_ri/rep_geo/TERRITORIALES_INDIVIDUAL/", 
                    nombre_corto[i]), showWarnings = F)
  
  # particularidades por mapa  
  if(nombre_corto[i] == "Pacifico" | nombre_corto[i] == "Caribe"){
    col_small_sf_color <- "grey25"
  }else{
    col_small_sf_color <- "transparent"
  }
  
  if(nombre_corto[i] == "Amazonia" | nombre_corto[i] == "Caribe") scale_location <- "bottomleft"
  if(nombre_corto[i] == "AndesNoro" | nombre_corto[i] == "AndesOcc" | nombre_corto[i] == "Orinoquia") scale_location <- "bottomright"
  if(nombre_corto[i] == "Pacifico") scale_location <- "topleft"
  
  # mapa por capa temporal del RUNAP por territorial, porcentaje de representatividad y diferencia
  
  dir.create(paste0("productos/rep_ri/rep_geo/TERRITORIALES_INDIVIDUAL/",
                    nombre_corto[i]), showWarnings = FALSE)
    
  for(c in 1:length(tiempos)){
    
    print(tiempos[c])
    
    datac <- shapefiles_runap_terri[[c]]
    colRRc <- names(datac)[grep(names(datac), pattern = "RRi")][1]
    
    # categorizar los datos de representatividad
    datac@data[, colRRc] <- cut(x = datac@data[, colRRc], breaks = c(0, 0.5, 1, 1.5, 2 , 2.5, 3, 100),
                                labels = c("0 — 0.5%", "0.5 — 1%", "1 — 1.5%", "1.5 — 2%", "2 — 2.5%", "2.5 — 3%", "> 3%"))
    datac <- st_as_sf(datac)
    
    # etiquetas y colores para la leyenda
    cols <- RdYlGn(7)
    names(cols) <- c("0 — 0.5%", "0.5 — 1%", "1 — 1.5%", "1.5 — 2%", "2 — 2.5%", "2.5 — 3%", "> 3%")
    
    tiff(paste0("productos/rep_ri/rep_geo/TERRITORIALES_INDIVIDUAL/", nombre_corto[i], "/", tiempos[c], ".tif"), res = c(300,300), width = 2480, height = 2480, compression = "lzw")
    
    plotdatac <- ggplot() + 
      geom_sf(data = terr_small, fill = "transparent", color = "grey25")+
      geom_sf(data = col_small_sf, fill = "transparent", color = col_small_sf_color, linetype = "dashed")+
      geom_sf(data = datac, aes_string(fill = colRRc), color = "transparent")+
      scale_fill_manual(values = cols, name = paste0(tiempos[c],
                                                     "\n" ,"% Representatividad", 
                                                     "\n de la Riqueza SIRAP", 
                                                     "\n", colnames(dat_rep_ri_terr)[i])) +
      theme_void()+
      theme(plot.background = element_rect(colour = "transparent"),
            legend.background = element_rect(fill = "white", color = "transparent"),
            legend.title.align = 0.5,
            legend.title = element_text(size = 12, face = "bold"))+
      ggsn::scalebar(data = terr_small, location = scale_location, model = "WGS84", dist_unit = "km", dist = 100,
                     st.size=3, height=0.01, transform = T)
    
    print(plotdatac)
    dev.off()
    
  }
  
  # 2.3.2 dRRi, Id: Cambio en el porcentaje de la representatividad de la riqueza de especies
  # del SINAP (dRRi)
  
  print("cambio en el porcentaje de representatividad")
  
  print("numerica")
  
  # A. Representación numerica
  
  dir.create(paste0("productos/rep_ri/rep_num/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
  
  Acumacion_totali <- data.frame("tiempo.periodo" = tiempo.periodo, "SIRAP" = t(tasa.incremento.territorial)[,i])
  
  write.csv(Acumacion_totali, file = paste0("productos/rep_ri/rep_num/TERRITORIALES_INDIVIDUAL/",
                                        nombre_corto[i], ".csv"), row.names = F)
  
  # B. Representacion grafica de la diferencia del % de representatividad 
  
  print("grafica")
  
  dir.create(paste0("productos/rep_ri/rep_gra/TERRITORIALES_INDIVIDUAL"), showWarnings = F)
  
  jpeg(paste0("productos/rep_ri/rep_gra/TERRITORIALES_INDIVIDUAL/Diferencia_internanual_", nombre_corto[i],".jpg"), res = c(300,300), width = 2480, height = 2480)
  repr_plot_diff <- ggplot(Acumacion_totali, aes(factor(tiempo.periodo), SIRAP, color = tiempo.periodo)) +
    geom_boxplot(color = "black") +
    geom_smooth(method = "loess", se=FALSE, color="red", aes(group=1)) +
    ylim(c(-21,21))+
    geom_hline(yintercept = median(as.numeric(Acumacion_total$cambio.rep.anual)), 
               color = "red", linetype = "dashed")+
    ggtitle(paste0("Diferencia interanual de la representatividad de la riqueza ", colnames(dat_rep_ri_terr)[i])) + 
    labs(y= "Porcentaje (%)", x = "Año")+
    theme_classic()
  print(repr_plot_diff)
  dev.off()
  
  # C. Representación geográfica de la diferencia de la representatividad por territorial individual
  
  dir.create(paste0("rep_rri_Id_cambio_spp/rep_geo/TERRITORIALES_INDIVIDUAL/",
                    nombre_corto[i]), showWarnings = FALSE)
  
  for(c in 1:length(tiempos)){
    
    print(tiempos[c])
    
    if(c+1 > length(tiempos)){
      "not possible"
    }else{

      datac <- shapefiles_runap_terri[[c+1]]
      coldRRc <- names(datac)[grep(names(datac), pattern = "dRRi")]
      
      # categorizar los datos de representatividad
      datac@data[ , coldRRc] <- cut(x = datac@data[, coldRRc], breaks = c(-4, -2, 0, 2, 4, 6, 8, 10, 100),
                                    labels = c("-4— -2", "-2—0", "0—2%", "2—4%", "4—6%", "6—8%", "8—10%", "> 10%"))
      datac <- st_as_sf(datac)
      
      # etiquetas y colores para la leyenda
      cols <- c(RdYlGn(8), "gray25")
      names(cols) <- c("-4— -2", "-2—0", "0—2%", "2—4%", "4—6%", "6—8%", "8—10%", "> 10%", "NA")
      
      tiff(paste0("rep_rri_Id_cambio_spp/rep_geo/TERRITORIALES_INDIVIDUAL/",nombre_corto[i],"/",tiempo.periodo[c], ".tif"), res = c(300,300), width = 2480, height = 2480, compression = "lzw")
      
      plotdatai <- ggplot() + 
        geom_sf(data = terr_small, fill = "transparent", color = "grey25")+
        geom_sf(data = col_small_sf, fill = "transparent", color = col_small_sf_color, linetype = "dashed")+
        geom_sf(data = datac, aes_string(fill = coldRRc), color = "transparent")+
        scale_fill_manual(values = cols, name = paste0(tiempo.periodo[c],"\n" , 
                                                       "Diferencia en el", 
                                                       "\n%", "Representatividad", 
                                                       "\n", "de la Riqueza SIRAP", 
                                                       "\n", colnames(dat_rep_ri_terr)[i]))+
        theme_void()+
        theme(plot.background = element_rect(colour = "transparent"),
              legend.background = element_rect(fill = "white", color = "transparent"),
              legend.title.align = 0.5,
              legend.title = element_text(size = 11, face = "bold"))+
        ggsn::scalebar(data = terr_small, location = scale_location, model = "WGS84", dist_unit = "km", dist = 100,
                       st.size=3, height=0.01, transform = T)
      print(plotdatai)
      dev.off()
    }
  }
}
