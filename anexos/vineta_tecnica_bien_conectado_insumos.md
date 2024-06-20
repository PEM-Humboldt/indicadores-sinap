# VIÑETA TÉCNICA DE INDICADORES
## Cambio en el porcentaje de área protegida y conectada del SINAP

### Identificación del indicador

**Iniciativa en la que se encuentra:** Sistema de Información de Monitoreo del SINAP.

**Atributo\*:** Bien Conectado.

**Cobertura geográfica**

- Nacional
- Subsistema

### Insumos del indicador:

- [Mapas de Huella Humana](http://geonetwork.humboldt.org.co/geonetwork/srv/spa/catalog.search#/metadata/3f37fa6b-5290-4399-9ea3-eaafcd0b2fbe)
- [Mapa Límites Nacionales de la República de Colombia](https://drive.google.com/drive/folders/17TpVc0A0v9Pll9lkG_4QifiO3ibkLlLn?usp=drive_link)
- [Mapas del Sistema Nacional de Áreas Protegidas de Colombia](https://docs.google.com/document/d/1ikapUO27gE1hucJHv512WV4G1QmUP--B2Toj_jI3ggI/edit?usp=sharing)
- [Mapas de Áreas Protegidas del Mundo](https://www.protectedplanet.net/en/thematic-areas/wdpa?tab=WDPA)

En la [viñeta tecnica del indicador](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/vineta_tecnica_bien_conectado.md) fueron descritos los procesos geograficos para la ejecución del indicador. **En este documento se presenta una rutina en R para generar la capa que une los Mapas del Sistema Nacional de Áreas Protegidas de Colombia y los Mapas de Áreas Protegidas del Mundo.** Esta, aunque escrita en lenguaje R utiliza el paquete `qgisprocess` la cual usa las funciones disponibles dentro del software QGIS ([mayor información](https://r-spatial.github.io/qgisprocess/articles/qgisprocess.html)). El uso de esta paqueteria se hace necesario porque las librerias nativas de R para el procesamiento geografico dejan residuos de errores topologicos y geometricos en las capas. Problemas que no suelen ser graves en la mayoria de aplicaciones, pero que en este caso imposibilitan el uso de la herramienta [MAKHURINI](https://github.com/connectscape/Makurhini) el cual es muy sensible a estos errores (topologia y geometria). Se usa como ejemplo las capas para el año 2023.

#### Cargar Librerías

Primero, cargamos todas las librerías necesarias para nuestro análisis.

```
library(wdpar)
library(dplyr)
library(terra)
library(qgisprocess)
library(sf)
```

#### Descargar WDPA (base de datos de Areas Protegidas del mundo)

Para poder descargar la base de datos WDPA, es necesario instalar y configurar phantomjs.

```
webdriver::install_phantomjs()
```

Iniciar la descarga.

```
country_codes <- c("BRA", "ECU", "NLD", "PAN", "PER", "VEN")

# Descargar y limpiar los datos para cada país
mult_data <- lapply(X = country_codes, FUN = function(X) {
    wdpa_fetch(X, wait = FALSE) |> wdpa_clean()
})

# Unir los datasets
mult_data <- st_as_sf(as_tibble(bind_rows(mult_data)))
WDPA2023 <- mult_data[mult_data$STATUS_YR < 2024,] |> 
  st_transform("EPSG:4686")
```

Representación geográfica de la base de datos de Areas Protegidas del mundo circunscritas a los paises limitrofes con Colombia

![WDPAWOrld](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/wdpa_world.png)

#### Cargar datos RUNAP

Cargar datos del RUNAP

```
RUNAP2023 <- read_sf("RUNAP_2023.shp") |> 
  st_transform("EPSG:4686")
```

Representación geográfica de la base de datos RUNAP.

 ![RUNAP](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/RUNAP.png)

#### Crear Buffer

Creamos un buffer de 500 km alrededor del poligono continental de Colombia. Aunque en el indicador se usa 100 km, nos aseguramos que todas las Areas Protegidas relevantes esten dentro de nuestra región de analisis.

```
col <- read_sf("D:/humboldt/indicadores-sinap/capas_base_ejemplos/Nacional/Colombia_FINAL.shp") |>
  st_transform(st_crs("EPSG:4686")) |>
  st_buffer(dist = units::set_units(500, km))
```

#### Arreglar Estructura de las Geometrías WDPA

Utilizamos primero el metodo structure (`METHOD = 1`) el cual primero valida todos los anillos y luego fusiona las envolventes y resta los huecos de las envolventes para generar un resultado válido. Asume que los huecos y las envolventes están categorizados correctamente y las   para arreglar las geometrías.Segundo Linework (`METHOD = 0`) el cual combina todos los anillos en un conjunto de líneas nodadas y luego extrae polígonos válidos de ese trabajo de líneas ([vease](https://www.qgistutorials.com/en/docs/3/handling_invalid_geometries.html)

```
WDPA2023 <- qgis_run_algorithm(
  "native:fixgeometries",
  INPUT = WDPA2023, 
  METHOD = 1
) %>% 
  st_as_sf()

WDPA2023 <- qgis_run_algorithm(
  "native:fixgeometries",
  INPUT = WDPA2023, 
  METHOD = 0
) %>% 
  st_as_sf()
```

#### Arreglar Estructura de las Geometrías RUNAP

Arreglamos las geometrías de RUNAP utilizando los metodos structure y linework.

```
RUNAP2023 <- qgis_run_algorithm(
  "native:fixgeometries",
  INPUT = RUNAP2023, 
  METHOD = 1
) |>
  sf::st_as_sf()

RUNAP2023 <- qgis_run_algorithm(
  "native:fixgeometries",
  INPUT = RUNAP2023, 
  METHOD = 0
) |>
  sf::st_as_sf()
```

#### Cortar WDPA con Buffer de 500 km

Cortamos WDPA utilizando el buffer creado previamente.

```
WDPA2023 <- qgis_run_algorithm(
  "native:clip",
  INPUT = WDPA2023, 
  OVERLAY = col
)%>% 
  st_as_sf()
```

![WDPABuffCol](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/wdpaBuffCol.png)


#### Unir WDPA y RUNAP

Una vez se obtiene el WDPA cortado con el buffer de 500km y previamente arreglada su geometria, se une con la capa de RUNAP, lacual fue igualmente arreglada su geometria y topologia. 

```
AP_2023 <- qgis_run_algorithm(
  "native:union",
  INPUT = RUNAP2023, 
  OVERLAY = WDPA2023
) |>
  sf::st_as_sf()
```
![WDPARUNAP](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/WDPARUNAP.png)
