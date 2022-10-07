library(sf)
a <- st_read("bien_conectado_capas_base/NACIONAL/Colombia_FINAL.shp") %>% 
  st_buffer(dist = units::set_units(500, value = km)) %>%  st_transform(st_crs("EPSG:4326"))
st_write(a, "bien_conectado_capas_base/WDPA_Sep2022_Public_shp/NACIONAL_BUFFER.shp", delete_dsn = T)

nal <- st_read("bien_conectado_capas_base/NACIONAL/Colombia_FINAL.shp")
Runap1970 <- st_read("bien_conectado_capas_base/RUNAP_WDPA/RUNAP/1970.shp") %>% st_transform(st_crs(nal))
Runap1990 <- st_read("bien_conectado_capas_base/RUNAP_WDPA/RUNAP/1990.shp") %>% st_transform(st_crs(nal))
Runap2000 <- st_read("bien_conectado_capas_base/RUNAP_WDPA/RUNAP/2000.shp") %>% st_transform(st_crs(nal))
Runap2010 <- st_read("bien_conectado_capas_base/RUNAP_WDPA/RUNAP/2010.shp") %>% st_transform(st_crs(nal))
Runap2020 <- st_read("bien_conectado_capas_base/RUNAP_WDPA/RUNAP/2020.shp") %>% st_transform(st_crs(nal))
wdpa <- st_read("bien_conectado_capas_base/RUNAP_WDPA/wdpa_2022_merge.shp") %>% st_transform(st_crs(nal))

st_write(Runap1970, "bien_conectado_capas_base/RUNAP_WDPA/RUNAP/1970_.shp")
st_write(Runap1990, "bien_conectado_capas_base/RUNAP_WDPA/RUNAP/1990_.shp")
st_write(Runap2000, "bien_conectado_capas_base/RUNAP_WDPA/RUNAP/2000_.shp")
st_write(Runap2010, "bien_conectado_capas_base/RUNAP_WDPA/RUNAP/2010_.shp")
st_write(Runap2020, "bien_conectado_capas_base/RUNAP_WDPA/RUNAP/2020_.shp")
st_write(wdpa, "bien_conectado_capas_base/RUNAP_WDPA/wdpa_2022.shp", delete_layer = T, delete_dsn = T)

Runap1970 <- st_read("bien_conectado_capas_base/RUNAP_WDPA/AP_1990.shp")
wdpa <- st_read("bien_conectado_capas_base/RUNAP_WDPA/wdpa_2022_merge.shp") %>% st_transform(st_crs(Runap1970))
st_write(wdpa, "bien_conectado_capas_base/RUNAP_WDPA/wdpa_2022.shp", delete_layer = T, delete_dsn = T)

