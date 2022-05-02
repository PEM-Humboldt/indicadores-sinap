library(data.table)
library(dplyr)
library(ggplot2)
library(sf)
library(gridExtra)

# cargar información geografica

# shapefiles runap

RUNAP_shp_1990 <- st_read("rep_func_capas_base/RUNAP_proj/RUNAP_1990.shp")
RUNAP_shp_2000 <- st_read("rep_func_capas_base/RUNAP_proj/RUNAP_2000.shp")
RUNAP_shp_2010 <- st_read("rep_func_capas_base/RUNAP_proj/RUNAP_2010.shp")
RUNAP_shp_2020 <- st_read("rep_func_capas_base/RUNAP_proj/RUNAP_2020.shp")

nacional <- st_read("rep_func_otros/Nacional/Colombia_FINAL.shp")

# plot(runap[,1])

#Cargar información de integridad
testresults <- list.files(path = getwd(), pattern = "test", full.names = T) %>% 
  lapply(X = ., FUN = function(X){y = read.csv(file = X, stringsAsFactors = F)})

testresults[[1]]$idPNN <- RUNAP_shp_1990$IDPNN
testresults[[2]]$idPNN <- RUNAP_shp_2000$IDPNN
testresults[[3]]$idPNN <- RUNAP_shp_2010$IDPNN
testresults[[4]]$idPNN <- RUNAP_shp_2020$id_pnn

pares_integridad <- function(DB, reference, another, runap, tiempo, id, shp_back){
  
  dir.create(tiempo, showWarnings = F)
  
  labref <- sub(pattern = "X", replacement = "radio ", x = reference)
  labanot <- sub(pattern = "X", replacement = "radio ", x = another) 
  
  # elegir las columnas a comparar
  compar <- DB[, c(another, reference)]
  
  # modelo lineal entre las columnas
  form <- as.formula(paste0(another, "~", reference))
  model <- lm(form, data = compar)
  
  # ajuste entre columnas
  r2adj <- summary(model)$adj.r.squared
  cat(r2adj)
  
  # establecer diferencias (absolutas)
  differences <- (compar[, reference] - compar[, another]) %>% abs(.)
  
  compar$differences <- differences
  
  #
  try(
    runap$HARES2 <- log10(as.numeric(runap$HARES))
  )
  try(
    runap$HARES2 <- log10(as.numeric(runap$hectareas_))
  )
  
  # agregar a una columna del runap las diferencias entre las dos columnas de comparación
  colrefano <- paste0(another, "_", reference)
  runap[[colrefano]] <-  differences

  # graficas
  
  #diagrama de dispersión y recta de regresión
  p1 <- ggplot(data = compar) +
    ggplot2::aes_string(x = reference, y = another)+
    ggplot2::  geom_point()+
    geom_smooth(method=lm)+ xlab(labref)+ ylab(labanot)+
    geom_text(x = min(compar[, reference], na.rm = T)+0.01, y = max(compar[, another], na.rm = T),
              label = paste0("R2 = ", round(r2adj, 2)))
  
  
  # mapa de las diferencias
  p2 <- ggplot(shp_back) +
    geom_sf() +
    geom_sf(data = runap, aes_string(fill = paste0(another, "_", reference)))+
    scale_fill_viridis_c(trans = "sqrt", alpha = .4) 
  
  p3 <- ggplot(data = runap) +
    ggplot2::aes_string(x = "HARES2", y = paste0(another, "_", reference))+
    ggplot2::geom_point()+ ylab("Cambio en Integridad") + xlab("Tamaño ANP (log)")
  
  png(file = paste0(tiempo, "/", another, "_", reference, "_", tiempo, ".png"), 
      width = 1920, height = 1080, res = c(200, 200))
    grid.arrange(
      p1, p3, p2,
      layout_matrix = rbind(c(1, 3),
                            c(2, 3)),
      top = paste0(labanot, " vs ", labref)
    )
  dev.off()
  
  return(runap)
}

dataRunap <- list(RUNAP_shp_1990, RUNAP_shp_2000, RUNAP_shp_2010, RUNAP_shp_2020)
tiempos <- c("1990", "2000", "2010", "2020")
radios <- c(seq(2, 30, 4), 26.5) %>% sort() %>% paste0("X", .)

for(i in 1:length(tiempos)){
  
  print(i)
  for(a in 1:length(radios)){
    print(a)
    if(a == 1){
      b <- pares_integridad(another = radios[a], reference = radios[a+1], DB = testresults[[i]], 
                            runap = dataRunap[[i]], tiempo = tiempos[i], id = "idPNN", shp_back = nacional)
    }
    if(a > 1 & a < length(radios)){
      b <- pares_integridad(another = radios[a], reference = radios[a+1], DB = testresults[[i]], 
                            runap = b, tiempo = tiempos[i], id = "idPNN", shp_back = nacional)
    }
    if(a == length(radios)){
      all <- b %>% st_drop_geometry()
      boxplot(x = all[, 14:ncol(all)], main= paste0("Diferencias de integridad entre radios ", tiempos[i]),
              xlab="radios comparados", ylab="Diferencia integridad") #12 en 2020
    } 
  }
}

# from wide to long shape
testresults_long <- lapply(X = testresults, FUN = function (X){
  X$idPNN <-  as.factor(X$idPNN)
  Y <-  as.data.table(X)
  Ylong <- melt(data = Y, id.vars = "idPNN", variable.name = "radio", value.name = "integridad")
})

# add time
for(i in 1:length(testresults_long)){
  x <- testresults_long[[i]]
  x <- x[ , tiempo:= tiempos[i]]
  testresults_long[[i]] <- x
}

# adding tables
testresults_long <- rbindlist(testresults_long)
testresults_long <- testresults_long[order(testresults_long$idPNN), ]

# resumir datos

data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}

df2 <- data_summary(testresults_long, varname="integridad", 
                    groupnames=c("radio", "tiempo"))

# graphics

ggplot(df2, aes(x=tiempo, y=integridad, group=radio, color=radio)) + 
  geom_line() +
  geom_point()+
  #geom_errorbar(aes(ymin=integridad-sd, ymax=integridad+sd), width=.2, position=position_dodge(0.05))+
  labs(title="Cambio en la integridad media anual según radio", x="Año", y = "Integridad (media)")+
  theme_classic() +
  scale_fill_brewer(palette = "Dark2")


# data slope

testresults_pnnAll <- list()

for(i in 1:length(unique(testresults_long$idPNN))){
  pnn <- unique(testresults_long$idPNN)[i]
  index_pnn <- grep(pattern = pnn, x = testresults_long$idPNN, perl = T)
  tiempos <- testresults_long[index_pnn, tiempo ] %>% unique()
  if(length(tiempos) == 4){
    testresults_pnnAll[[i]] <- testresults_long[index_pnn, ]
  }
}

testresults_pnnAll <- rbindlist(testresults_pnnAll) %>% na.omit()

grouped <- testresults_pnnAll %>% group_by(idPNN, radio) %>% 
  group_map(~ broom::tidy(lm(integridad ~ tiempo, data = .x, na.action=na.omit)))

names(grouped) <- paste0(testresults_pnnAll$idPNN, "_", testresults_pnnAll$radio) %>% unique()

grouped2 <- list()

for(i in 1:length(grouped)){
  x <- grouped[[i]]
  slope <- x$estimate[2:4] %>% mean() %>% abs()
  id_radio <- strsplit(names(grouped[i]), split = "_") %>% unlist()
  df <- data.frame(idPNN =id_radio[1], radio =id_radio[2], slope)
  grouped2[[i]] <- df
}

grouped2 <- grouped2 %>% rbindlist() 

# long to wide forma, dejando como variable de cada celda la pendiente
group_wide <- dcast(data = grouped2, formula = idPNN  ~ radio, value.var = "slope")

indexpnn_runap <- RUNAP_shp_2020$id_pnn %in% group_wide$idPNN 
RUNAP_shp_2020B <- RUNAP_shp_2020[indexpnn_runap, ]

RUNAP_shp_2020B <- cbind(RUNAP_shp_2020B, group_wide)

# mapa de las diferencias
for(i in 1:length(radios)){
  png(file = paste0( "pendiente 1990-2020 ", radios[i], ".png"), 
      width = 1920, height = 1080, res = c(200, 200))
    p4 <- ggplot(nacional) +
      geom_sf() +
      geom_sf(data = RUNAP_shp_2020B, aes_string(fill = radios[i]))+
      scale_fill_viridis_c(trans = "sqrt", alpha = .4)+
      labs(title = paste0("Pendiente de cambio absoluta de integridad 1990-2020, radio ", radios[i]),
         subtitle = "Datos para 97 Areas Naturales Protegidas de 1990 a 2020")
    print(p4)
  dev.off()
}

write_sf(RUNAP_shp_2020B, "pendiente_radios_1990_2020.shp", delete_layer = T)
fwrite(group_wide, "pendiente_radios_xpnn_wide.csv", row.names = F)
fwrite(grouped2, "pendiente_radios_xpnn_long.csv", row.names = F)
fwrite(testresults_long, "integridad_radios_test_long.csv", row.names = F)


####
# elegir unicamente los de beta y sin reescalar de la tabla en donde se deja mover betas, radio y reescalamiento
#colsb0.2 <- testresults[ , grepl(pattern = "(?=.*b0.2)(?=.*rsFALSE)", x = colnames(testresults), perl = T)]

# nombres acordes al radio, lo unico que esta variando
#colnames(colsb0.2) <- colnames(colsb0.2) %>% strsplit(split = "_") %>% 
#  lapply(X = ., FUN = function(X){data <- X[2]}) %>% unlist()


# anp que esta cambiando mas
#maxcambio <- max(compar[, "differences"], na.rm = T)
#anpmaxcambio <- runap[which(as.vector(runap[, colrefano]) == maxcambio), id ]
