# Indicadores Sistema Nacional de Areas Protegidas

Cálculo de indicadores del sistema de monitoreo del SINAP.  Los indicadores permiten establecer si el SINAP es representativo ecológicamente a nivel de especies y si estas áreas y los sistemas en los que se encuentran cuentan con integridad funcional y conectividad que permitan su viabilidad a largo plazo. Los indicadores son: porcentaje y cambio de la representatividad de la riqueza de especies, cambio en el porcentaje de representatividad de la distribución de especies, cambio en la media de representatividad de la integridad y cambio en el porcentaje de areas protegidas y conectadas. 

En desarrollo.

## Prerequisitos

### Dependencias y archivos

* [R](https://cran.r-project.org/mirrors.html) 4.1 o superior
* [RStudio](https://www.rstudio.com/products/rstudio/download/#download) Opcional

### Librerias

Librerias requeridas y sus versiones por cada indicador

1. Representatividad ecológica: Riqueza de especies 

```
"dismo" 1.3-3
"sf" 1.0-2
"rgdal" 1.5-27 (puede presentar incompatibilidad desde 2023)
"raster" 3.4-13 
"qpcR" 1.4-1
"dplyr" 1.0.7
```

2. Representatividad ecológica: distribución de especies

```
"SpaDES" 2.0.7
"raster" 3.4-13
"xfun" 0.25
"rgdal" 1.5-27 (puede presentar incompatibilidad desde 2023)
"ReIns" 1.4-1 (1.0.10)
"dplyr" 1.0.7 
```

##### Representaciones

Las representaciones generadas con las capas base de ejemplo ubicadas dentro de este repositorio son ejemplos del código usado, no versiones finales, por lo que las representaciones númericas, gráficas y geográficas no coinciden con los presentados en el proyecto SIM-SINAP. Revise los documentos en la carpeta anexos para encontrar enlaces a versiones finales.

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

* BioModelos
* RUNAP historico
* Mapa Nacional
* raster de Huellas Humanas
* Mapa territorial


## Como se ejecuta

### Bien representado

#### Porcentaje y cambio de la representatividad de la riqueza de especies

#### Cambio en la media de representatividad de la distribución de especies

#### Cambio en la media de representatividad de la integridad 

### Bien conectado: 

#### cambio en el porcentaje de conectividad. 


## Autores y contacto

* **[Elkin Alexi Noguera Urbano](enoguera@humboldt.org.co)**

* **[Camilo Andrés Correa Ayram](ccorrea@humboldt.org.co)**

* **[Andrés Felipe Suárez Castro](felipesuarezca@gmail.com)** 

* **[Carlos Jair Muñoz Rodriguez](cmunoz@humboldt.org.co)**


## Licencia

Este proyecto tiene licencia MIT. consulte el archivo [LICENSE.md](LICENSE.md) para obtener más detalles.
