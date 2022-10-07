library("sf")
library("rgdal")
library("raster")
library("ggplot2")
library("dplyr")
library("ggsn")
library("heatmaply")
library("maptools")

load("bien_conectado_cod/bien_conectado_cod_operativo_objetos.RData")

#######################################

# 1. Representaciones

# 1.1. Nacional

# A. Representacion numerica


Table_Protcon <- cbind(AP_10k_ProtConn, AP_10k_dProtConn)

write.csv(Table_Protcon, "bien_conectado/rep_num/bien_conectado_rep_num_NAL.csv")

# B. Representacion grafica

jpeg("bien_conectado/rep_gra/bien_conectado_rep_num_NAL.jpg", res = c(300,300), width = 1240, height = 1240)
repr_plot<- ggplot(Table_Protcon, aes(x= factor(rownames(Table_Protcon)), y = dProtConn, group = 1)) +
  geom_line()+
  ggtitle("Cambio en el porcentaje de área protegida y conectada del SINAP")+
  labs(y= "dProtConn (%)", x = "Año")+
  theme_classic()
print(repr_plot)
dev.off()

# C. Sin representacion geografica nacional

################################

# 2.2. Territorial

# 2.2.1 RRi, Ic: Porcentaje de la representatividad de la riqueza de especies por territorial (RRi)

# A. Representacion numerica

Tabla_Terr <- cbind(TERR_AP_10k_ProtConn, TERR_AP_10k_dProtConn)

## values
write.csv(Tabla_Terr, "bien_conectado/rep_num/bien_conectado_rep_num_TERR.csv")


# B. Representacion grafica

tiempos <- c("1970", "1990", "2000", "2010", "2020")

jpeg("bien_conectado/rep_gra/bien_conectado_rep_num_TERR.jpg", res = c(300,300), width = 2480, height = 2480)
par(mfrow=c(3,2))
  plot(t(TERR_AP_10k_dProtConn[1,]), type= "l", main="Direccion Territorial Amazonia", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="dProtConn", ylim = c(0,100))
  axis(side = 1, at = 1:length(tiempos), labels = tiempos, )
  plot(t(TERR_AP_10k_dProtConn[2,]), type= "l", main="Direccion Territorial Andes Nororientales", sub="RUNAP",
       xlab="Año", xaxt= "n",ylab="dProtConn", ylim = c(0,200))
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(t(TERR_AP_10k_dProtConn[3,]), type= "l", main="Direccion Territorial Andes Occidentales", sub="RUNAP",
       xlab="Año", xaxt= "n",ylab="dProtConn", ylim = c(0,100))
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(t(TERR_AP_10k_dProtConn[4,]), type= "l", main="Direccion Territorial Caribe", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="dProtConn", ylim = c(0,100))
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(t(TERR_AP_10k_dProtConn[5,]), type= "l", main="Direccion Territorial Orinoquia", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="dProtConn", ylim = c(0,100))
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
  plot(t(TERR_AP_10k_dProtConn[6,]), type= "l", main="Direccion Territorial Pacifico", sub="RUNAP",
       xlab="Año", xaxt= "n", ylab="dProtConn", ylim = c(0,100))
  axis(side = 1, at = 1:length(tiempos), labels = tiempos)
dev.off()

# C. Representacion geografica territoriales

# todas las columnas del delta protconn
coldProtConn <- grep(names(TERRITORIAL_dProtConn), pattern = "dProtConn")


for(i in 2:length(tiempos)){
  
  datai <- TERRITORIAL_dProtConn[, coldProtConn[i]]
  index <- names(TERRITORIAL_dProtConn)[coldProtConn[i]]
  
  toconvert <- as.data.frame(datai)[, index]
  # categorizar los datos del cambio de la conectividad
  
  datai$convert <- cut(x = toconvert, breaks = c(-1,5, 10, 20, 40, 60, 100, 150, 10000000),
                       labels = c("0—5%", "5—10%", "10—20%", "20—40%", "40—60%", "60—100%", "100—150%", ">150%"))
  
  # etiquetas y colores para la leyenda
  cols <- viridis(8)# RdYlGn(8)
  names(cols) <- c("0—5%", "5—10%", "10—20%", "20—40%", "40—60%", "60—100%", "100—150%",">150%")
  
  tiff(paste0("bien_conectado/rep_geo/TERR", tiempos[i], ".tif"), res = c(300,300), width = 2480, height = 3508, compression = "lzw")
  
  
  plotdatai <-  ggplot() + 
    geom_sf(data = datai, aes(fill =convert))+
    scale_fill_manual(values = cols, aesthetics = "fill",
                      name = paste0("Cambio en el porcentaje", "\nde conectividad RUNAP", "\npor territoriales",
                                    "\n", tiempos[i-1], "-", tiempos[i]))+
    theme_void()+
    theme(plot.background = element_rect(colour = "transparent"),
          legend.background = element_rect(fill = "white", color = "transparent"),
          legend.title = element_text(size = 10,face = "bold"))
  print(plotdatai)
  dev.off()
  
}

