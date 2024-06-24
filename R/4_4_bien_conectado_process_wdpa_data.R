library(wdpar)
library(dplyr)
library(terra)
library(qgisprocess)

# Insumos

# bajar wdpa

webdriver::install_phantomjs()

country_codes <- c("BRA", "ECU", "NLD", "PAN", "PER", "VEN")

## download data for each country
mult_data <- lapply(X = country_codes, FUN = function(X){
    wdpa_fetch(X, wait = FALSE) |> wdpa_clean()
  }
  )

## merge datasets together
mult_data <- st_as_sf(as_tibble(bind_rows(mult_data)))
WDPA2023 <- mult_data[mult_data$STATUS_YR < 2024,] |> 
  st_transform("EPSG:4686")

WDPA2023 <- read_sf("WDPA2023.shp") |> 
  st_transform("EPSG:4686")

#---------------

RUNAP2023 <- read_sf("RUNAP_2023.shp") |> 
  st_transform("EPSG:4686")

#---------------
# crear buffer

col <- read_sf("D:/humboldt/indicadores-sinap/capas_base_ejemplos/Nacional/Colombia_FINAL.shp") |>
  st_transform(st_crs("EPSG:4686")) |>
  st_buffer(dist = units::set_units(500, km))

#-------------

# arreglar estructura de las geometrias wdpa

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

#-----------------

# arreglar estructura de las geometrias RUNAP

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

#----------------

# cortar wdpa con bufer de 500km 

WDPA2023 <- qgis_run_algorithm(
  "native:clip",
  INPUT = WDPA2023, 
  OVERLAY = col
)%>% 
  st_as_sf()

#-----------------
# Unir WDPA cortado a buffer y RUNAP arreglados

AP_2023 <- qgis_run_algorithm(
  "native:union",
  INPUT = RUNAP2023, 
  OVERLAY = WDPA2023
) |>
  sf::st_as_sf()

write_sf(AP_2023, "AP_2023.shp")
