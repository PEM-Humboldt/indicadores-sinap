# Indicadores Sistema Nacional de Areas Protegidas

Cálculo de indicadores del sistema de monitoreo del SINAP.  Los indicadores permiten establecer si el SINAP es representativo ecológicamente a nivel de especies y si estas áreas y los sistemas en los que se encuentran cuentan con integridad funcional y conectividad que permitan su viabilidad a largo plazo. Los indicadores son: porcentaje y cambio de la representatividad de la riqueza de especies, cambio en el porcentaje de representatividad de la distribución de especies, cambio en la media de representatividad de la integridad y cambio en el porcentaje de areas protegidas y conectadas.

En desarrollo.

## Prerequisitos

### Dependencias y archivos

* [R](https://cran.r-project.org/mirrors.html) 4.1.1 o superior
* [RStudio](https://www.rstudio.com/products/rstudio/download/#download) Opcional

### Librerias

Librerias requeridas y sus versiones por cada indicador. Asegurese que tiene las versiones exactas de cada paquete y son compatibles con la versión de R.

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
"raster" 3.5-15
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
En caso de encontrar problemas al ejecutar el código, es posible que la versión de Makhurini sea responsable del mal funcionamiento. Desinstale la versión de Makhurini que tenga e instale con los siguientes comandos

```
library(devtools)
library(remotes)
remotes::install_github("connectscape/Makurhini@0d9958b38a320de472a3c6245a1d3bb9353929df")
```

Para mas información, ver documentacion del [paquete](https://github.com/connectscape/Makurhini).

##### Representaciones

Dentro del contexto del proyecto SIM-SINAP las representaciones númericas, gráficas y geográficas hace alusión a tablas, graficas y mapas respectivamente. Las representaciones generadas con las capas base de ejemplo ubicadas dentro de este repositorio son ejemplos de las reales, no versiones finales, por lo que tales representaciones no coinciden con los presentados en el proyecto SIM-SINAP.

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

Dependiendo del indicador a trabajar usted necesitara dos o más de los siguientes:

* BioModelos (Modelos de distribución de especies)
* Secuencia de limites del RUNAP historico disponible
* Mapa de limites Nacionales
* Secuencia de imagenes raster de Huella Humana en diferentes periodos y que concuerde con los años dispobibles para RUNAP
* Mapa territorial
* Secuencia de mapas de Areas Protegidas en Sudamerica con un buffer minimo de 100 km desde los limites nacionales, incluyendo las areas protegidas Colombianas.

Dentro de este repositorio se encuentra un conjunto completo de [capas base de ejemplo](capas_base_ejemplos.zip) comprimidas para ejecutar todos los indicadores.

## Como se ejecuta

Se sugiere correr las rutinas paso por paso, siguiendo el orden de cada script. Sin embargo, usted puede obtener los resultados de cada indicador independientemente. Las capas base de ejemplo deben ser descromprimidas dentro del directorio de trabajo asignado por el usuario.


## Descripción

#### Porcentaje y cambio de la representatividad de la riqueza de especies del SINAP

El indicador “Cambio en el porcentaje de la representatividad de la riqueza de especies del SINAP” corresponde al cambio entre periodos en el porcentaje del número de especies protegidas dentro de las unidades del patrimonio natural y cultural del país incluidas dentro del Sistema Nacional de Áreas Protegidas. El índice usa como insumos la distribución geográfica de especies de interés identificadas por medio de modelos de distribución de especies, modelos que son examinados, verificados y curados por especialistas de cada especie (BioModelos Nivel 1). Por otra parte, usa los límites geográficos de las unidades del Sistema Nacional de Áreas Protegidas (SINAP) disponibles desde 1990 a 2020. La distribución geográfica de cada especie es cruzada o sobrelapada con cada una de las capas disponibles del SINAP, para luego contar la cantidad de especies que según la distribución geográfica son protegidas en cada unidad del sistema en un periodo determinado. Enseguida, se calcula el total de especies protegidas en todas las unidades y se divide por el número de especies consideradas y se multiplica por 100, obteniendo un porcentaje de especies representadas. Por último, se calcula la diferencia entre cada periodo consecutivo, obteniendo el índice. Como resultados se obtienen, por una parte, el aporte  de cada unidad en el cambio del porcentaje de cada unidad del SINAP a la representatividad total, y por otra, el cambio en la representatividad total del sistema.

#### Cambio en el porcentaje de representatividad ecológica del SINAP - Distribución de Especies

El indicador “Cambio en el porcentaje de representatividad ecológica del SINAP - Distribución de Especies” cuantifica la proporción de especies incluidas dentro del sistema nacional de áreas protegidas que alcanzan una cobertura adecuada de su área de distribución. Para ello, se requiere información sobre el total de especies que se encuentran en cada unidad de análisis, el área total de distribución de cada especie, el porcentaje de área de distribución protegida para cada especie, así como el objetivo de representatividad para cada especie. En tal sentido, el índice usa como insumos la distribución geográfica de especies de interés identificadas por medio de modelos de distribución de especies,  modelos que son examinados, verificados y curados por especialistas de cada especie (Biomodelos Nivel 1) y los límites geográficos de las unidades del Sistema Nacional de Áreas Protegidas (SINAP) para los años 1990, 2000, 2010 a 2020. Luego, mediante un “análisis de brecha”, se calcula la proporción del área de distribución de cada especie que se superpone con el sistema nacional de áreas protegidas. Esta área es comparada con una meta de área de conservación para cada especie denominada “área mínima de representatividad”. El área mínima de representatividad es calculada como una función del área de distribución de la especie y se escala logarítmicamente desde el 10% para especies con distribuciones mayores a 250,000km2, hasta el 100% para especies con distribuciones menores a 1,000km2 (Rodrigues et al. 2004a, Rodrigues et al. 2004b). El índice equivale a 100 cuando todas las especies con presencia en una unidad han alcanzado el objetivo de representatividad dentro de las áreas del SINAP. Valores cercanos a 0 indican que la mayoría de las especies con presencia en una unidad no cuentan con una protección suficiente en todo el sistema de áreas protegidas.


#### Cambio en la media de la representatividad de integridad estructural del SINAP

El indicador “Cambio en la media de la representatividad de integridad estructural del SINAP” corresponde al  cambio en la integridad ecológica de las unidades representativas del patrimonio natural y cultural del país, incluidas dentro del sistema nacional de áreas protegidas entre dos momentos de medición. Este indicador resume información  sobre el cambio en la proporción de área con diferente nivel de presión antrópica y su grado de fragmentación. Para la medición de este indicador, se utilizó la aproximación de Beyer et al. (2019), quienes desarrollaron una métrica que cuantifica explícitamente los efectos combinados de la pérdida de hábitat, la fragmentación y la pérdida en la calidad de hábitat sobre unidades espaciales de interés. Como insumo, esta métrica requiere de una grilla continua de celdas que representan los valores de calidad de hábitat. Para ello se utilizó como proxy la capa de huella humana desarrollada por Correa - Ayram et al. (2020). Esta escogencia se basa en el supuesto de que las áreas menos degradadas (con los valores más bajos de presión humana)  tienen un mayor potencial de mantener su funcionalidad. Aunque este supuesto varía dependiendo la escala espacial de análisis, se considera apropiada cuando se cuenta con datos que pueden ser analizados en grandes extensiones con una alta resolución (grano) espacial (e.g. Correa-Ayram et al. 2020). La métrica de Beyer equivale a 1 si el área protegida tiene un bajo nivel de degradación y se aproxima a 0 cuando la degradación es máxima. Luego de establecer la métrica por área protegida se calcula la media de todas las áreas protegidas al sumar el valor individual y dividirlo por la cantidad total de áreas protegidas en un periodo específico. Finalmente, se calcula el indicador al hallar la diferencia entre dos períodos sucesivos.

#### Cambio en el porcentaje de área protegida y conectada del SINAP

El indicador “Cambio en el Porcentaje de área protegida y conectada del SINAP” corresponde al cambio en el porcentaje de la superficie terrestre del país cubierta por tierras protegidas y bien conectadas establecida por medio de la métrica de conectividad Protconn en diferentes periodos y su variación temporal. El índice usa como insumos el mapa de huella humana que abarca toda Colombia para los años 1990, 2000, 2010 y 2018 (como variable más cercana al 2020). Además, usa los límites geográficos nacionales (o territoriales) como área de estudio en donde se establece el porcentaje conectado y protegido. También se hace uso de los límites geográficos de las unidades del Sistema Nacional de Áreas Protegidas (SINAP) de cuatro periodos (1990, 2000, 2010 y 2020) y los límites de las Áreas Protegidas del Mundo (WDPA) de la misma temporalidad del SINAP. El indicador usa las Áreas Protegidas mundiales informadas en el WDPA para establecer la influencia potencial de estas a la conectividad del SINAP, al generarse un buffer de 100 km alrededor de los límites nacionales (20 kilómetros para los límites territoriales) e incluir todas las Áreas Protegidas (AP) que interceptan total o parcialmente tal zona y fueron unidas a los mapas del SINAP Colombia. Luego se calcula la métrica ProtConn usando el paquete Makurhini por cada período usando una distancia de dispersión de 10 kilómetros. El indicador cambio en el Porcentaje de área protegida y conectada del SINAP se calcula al buscar la diferencia en el ProtConn de periodos sucesivos.

Para mayor información tecnica revisar el [Documento técnico extenso del indicador: Cambio en el porcentaje de área protegida y conectada del SINAP](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/Producto4_bien_conectado.md)

Aquí encontrara el [codigo operativo](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/R/4_1_bien_conectado_cod_operativo.R) del indicador y el [codigo de representaciones](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/R/4_2_bien_conectado_cod_representaciones.R).


### Referencias

Beyer, Hawthorne L., Venter, Oscar, Grantham, Hedley S. and Watson, James E. M. (2019).Substantial losses in ecoregion intactness highlight urgency of globally coordinated action. Conservation Letters, 13 (2) e12592, e12592. doi: 10.1111/conl.12692

Castillo, L. S., Correa Ayram, C. A., Matallana Tobón, C. L., Corzo, G., Areiza, A., González-M., R., Serrano, F., Chalán Briceño, L., Sánchez Puertas, F., More, A., Franco, O., Bloomfield, H., Aguilera Orrury, V. L., Rivadeneira Canedo, C., Morón-Zambrano, V., Yerena, E., Papadakis, J., Cárdenas, J. J., Golden Kroner, R. E., & Godínez-Gómez, O. (2020). Connectivity of Protected Areas: Effect of Human Pressure and Subnational Contributions in the Ecoregions of Tropical Andean Countries. In Land (Vol. 9, Issue 8). https://doi.org/10.3390/land9080239

Correa Ayram, Camilo A. Manuel E. Mendoza, Andrés Etter, Diego R & Pérez Salicrup (2017). Anthropogenic impact on habitat connectivity: A multidimensional human footprint index evaluated in a highly biodiverse landscape of Mexico, Ecological Indicators, 72(1), 895-909

Correa Ayram, Camilo & Mendoza, Manuel & Etter, Andres & Pérez-Salicrup, Diego. (2016). Habitat connectivity in biodiversity conservation: A review of recent studies and applications. Progress in Physical Geography. 40. 7-37. 10.1177/0309133315598713.

Crooks K R and Sanjayan M (2006) Connectivity Conservation. Cambridge, UK: Cambridge University Press.

Godínez-Gómez, O., & Correa Ayram C.A. (2020). Makurhini: Analyzing landscape connectivity.

Peterson, A., Soberón, J., G. Pearson, R., Anderson, R., Martínez-Meyer, E., Nakamura,M., y Araújo, M. (2011) Ecological Niches and Geographic Distributions, tomo 49.  360 pp.

Rodrigues, A.S.L., Andelman, S.J., Bakarr, M.I., Boitani, L., Brooks, T.M., Cowling, R.M., Fishpool, L.D.C., da Fonseca, G.A.B., Gaston, K.J., Hoffmann, M., Long, J.S., Marquet, P.A., Pilgrim, J.D., Pressey, R.L., Schipper, J., Sechrest, W., Stuart, S.N., Underhill, L.G., Waller, R.W., Watts, M.E.J. &Yan, X. (2004a) Effectiveness of the global protected area network in representing species diversity. Nature 428(6983), 640-643.

Rodrigues, A.S.L., Da Fonseca, G.A.B., Akçakaya, H.R., Schipper, J., Chanson, J.S., Pilgrim, J.D., Gaston, K.J., Underhill, L.G., Fishpool, L.D.C., Boitani, L., Watts, M.E.J., Hoffmann, M., Bakarr, M.I., Marquet, P.A., Pressey, R.L., Waller, R.W., Andelman, S.J., Stuart, S.N., Brooks, T.M., Sechrest, W. &Yan, X. (2004b) Global Gap Analysis: Priority Regions for Expanding the Global Protected-Area Network. BioScience 54(12), 1092-1100.


Rudnick D, Ryan S, Beier P, et al. (2012) The role of landscape connectivity in planning and implementing conservation and restoration priorities. Issues in Ecol-ogy 16: 20–20

Santini, L., Saura, S., & Rondinini, C. (2016), Connectivity of the global network of protected areas. Diversity Distrib., 22: 199-211. https://doi.org/10.1111/ddi.12390

Saura, S., Rubio, L., (2010). A common currency for the different ways in which patches and links can contribute to habitat availability and connectivity in the landscape. Ecography 33, 523–537.

Soberon, J., Osorio-Olvera, L., & Peterson, T. (2017). Diferencias conceptuales entre modelación de nichos y modelación de  áreas de distribución. Revista Mexicana de Biodiversidad 88 (2):437–441

Velásquez-Tibata,  J. I., Olaya-Rodríguez, M. H., López-Lozano, D. F., Gutierrez, C., Gonzales, I., & Londoño-Murcia, M. C. 2019. Biomodelos: a collaborative online system to map species distributions. Plos One, 14(3), e0214522.  https://doi.org/10.1371/journal.pone.0214522

## Autores y contacto

* **[Elkin Alexi Noguera Urbano](enoguera@humboldt.org.co)**

* **[Camilo Andrés Correa Ayram](ccorrea@humboldt.org.co)**

* **[Andrés Felipe Suárez Castro](felipesuarezca@gmail.com)**

* **[Carlos Jair Muñoz Rodriguez](cmunoz@humboldt.org.co)**


## Licencia

Este proyecto tiene licencia MIT. consulte el archivo [LICENSE.md](LICENSE.md) para obtener más detalles.
