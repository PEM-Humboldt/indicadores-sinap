# Indicadores Sistema Nacional de Areas Protegidas

Cálculo de indicadores del sistema de monitoreo del SINAP.  Los indicadores permiten establecer si el SINAP es representativo ecológicamente a nivel de especies y si estas áreas y los sistemas en los que se encuentran cuentan con integridad funcional y conectividad que permitan su viabilidad a largo plazo. Los indicadores son: porcentaje y cambio de la representatividad de la riqueza de especies, cambio en el porcentaje de representatividad de la distribución de especies, cambio en la media de representatividad de la integridad y cambio en el porcentaje de areas protegidas y conectadas. 

En desarrollo.

## Prerequisitos

### Dependencias y archivos

* [R](https://cran.r-project.org/mirrors.html) 4.1.1 o superior
* [RStudio](https://www.rstudio.com/products/rstudio/download/#download) Opcional

### Librerias

Librerias requeridas y sus versiones por cada indicador

1. Porcentaje y cambio de la representatividad de la riqueza de especies del SINAP

```
"dismo" 1.3-3
"sf" 1.0-2
"rgdal" 1.5-27 (puede presentar incompatibilidad desde 2023)
"raster" 3.4-13 
"qpcR" 1.4-1
"dplyr" 1.0.7
```

2. Cambio en el porcentaje de representatividad ecológica del SINAP - Distribución de Especies

```
"SpaDES" 2.0.7
"raster" 3.4-13
"xfun" 0.25
"rgdal" 1.5-27 (puede presentar incompatibilidad desde 2023)
"ReIns" 1.4-1 (1.0.10)
"dplyr" 1.0.7 
```

3. Cambio en la media de la representatividad de integridad estructural del SINAP	

```
"sf" 1.0-2
"raster" 3.4-13
"rgdal" 1.5-27 (puede presentar incompatibilidad desde 2023)
"dplyr" 1.0.7 
```

4. Cambio en el porcentaje de área protegida y conectada del SINAP

```
"formattable" 0.2.1
"cowplot" 1.1.1
"raster" 3.4-13
"sf" 1.0-2
"dplyr" 1.0.7
"rmapshaper" 0.4.5
"Makurhini" 2.0.4
"terra" 1.3-22
"Rcpp" 1.0.5 
```

Para instalar Makurhini use por favor:

```
library(devtools)
library(remotes)
install_github("connectscape/Makurhini", dependencies = TRUE, upgrade = "never")
```

Para mas información, ver documentacion del [paquete](https://github.com/connectscape/Makurhini).

##### Representaciones

Dentro del contexto del proyecto SIM-SINAP las representaciones númericas, gráficas y geográficas hace alusión a tablas, graficas y mapas respectivamente. Las representaciones generadas con las capas base de ejemplo ubicadas dentro de este repositorio son ejemplos de las reales, no versiones finales, por lo que tales representaciones no coinciden con los presentados en el proyecto SIM-SINAP. Revise los documentos en la carpeta anexos para encontrar enlaces a versiones finales.

```
"sf" version 1.0-2
"rgdal" version 1.5-23
"raster" version 3.4-13
"ggplot2" version 3.3.5
"dplyr" version 1.0.7
"ggsn" version 0.5.0
"heatmaply" version 1.2.1
"maptools" 1.1-2
```

### Archivos requeridos

Dependiendo del indicador a trabajar usted necesitar dos o más de los siguientes:

* BioModelos
* Secuencia de limites del RUNAP historico disponible
* Mapa de limites Nacionales
* Secuencia de imagenes raster de Huella Humana en diferentes periodos y que concuerde con los años dispobibles para RUNAP
* Mapa territorial
* Secuencia de mapas de Areas Protegidas en Sudamerica con un buffer minimo de 100 km desde los limites nacionales, incluyendo las areas protegidas Colombianas.

Dentro de este repositorio se encuentra un conjunto de  [capas base de ejemplo]() 

## Como se ejecuta

Se sugiere correr las rutinas paso por paso, siguiendo el orden de cada script. Sin embargo, usted puede obtener los resultados de cada indicador independientemente.


## Autores y contacto

* **[Elkin Alexi Noguera Urbano](enoguera@humboldt.org.co)**

* **[Camilo Andrés Correa Ayram](ccorrea@humboldt.org.co)**

* **[Andrés Felipe Suárez Castro](felipesuarezca@gmail.com)** 

* **[Carlos Jair Muñoz Rodriguez](cmunoz@humboldt.org.co)**


## Licencia

Este proyecto tiene licencia MIT. consulte el archivo [LICENSE.md](LICENSE.md) para obtener más detalles.
