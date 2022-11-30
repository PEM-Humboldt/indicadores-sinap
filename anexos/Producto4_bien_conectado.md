#VIÑETA TÉCNICA DE INDICADORES
##Cambio en el porcentaje de área protegida y conectada del SINAP

**Identificación del indicador**

**Iniciativa en la que se encuentra:** Sistema de Información de Monitoreo del SINAP.

**Atributo\*:** Bien Conectado (I).

**Objetivo:** Aumentar el patrimonio natural y cultural conservado en el SINAP.

**Cobertura geográfica**

- Nacional
- Subsistema

**Insumos del indicador:**

- Mapas de Huella Humana
- Mapa Límites Nacionales de la República de Colombia
- Mapas del Sistema Nacional de Áreas Protegidas de Colombia
- Mapas de Áreas Protegidas del Mundo

**Descripción general del indicador\***

**Definición:** El indicador "Cambio en el Porcentaje de área protegida y conectada del SINAP" corresponde al cambio en el porcentaje de la superficie terrestre del país cubierta por tierras protegidas y bien conectadas establecida por medio de la métrica de conectividad Protconn en diferentes periodos y su variación temporal. El índice usa como insumos el mapa de huella humana que abarca toda Colombia para los años 1990, 2000, 2010 y 2018 (como variable más cercana al 2020). Además, usa los límites geográficos nacionales (o territoriales) como área de estudio en donde se establece el porcentaje conectado y protegido. También se hace uso de los límites geográficos de las unidades del Sistema Nacional de Áreas Protegidas (SINAP) de cuatro periodos (1990, 2000, 2010 y 2020) y los límites de las Áreas Protegidas del Mundo (WDPA) de la misma temporalidad del SINAP. El indicador usa las Áreas Protegidas mundiales informadas en el WDPA para establecer la influencia potencial de estas a la conectividad del SINAP, al generarse un buffer de 100 km alrededor de los límites nacionales (20 kilómetros para los límitesterritoriales) e incluir todas las Áreas Protegidas (AP) que interceptan total o parcialmente tal zona y fueron unidas a los mapas del SINAP Colombia. Luego se calcula la métrica ProtConn usando el paquete Makurhini por cada período usando una distancia de dispersión de 10 kilómetros. El indicador cambio en el Porcentaje de área protegida y conectada del SINAP se calcula al buscar la diferencia en el ProtConn de periodos sucesivos. Dado que el proceso se repite con cada uno de los periodos seleccionados del SINAP, se obtienen medidas multitemporales y a escalas nacionales de la conectividad, permitiendo identificar la variación de las unidades del SINAP para proteger el flujo de materia, organismos y energía a través del paisaje dentro de una matriz de cambio antrópico y de resistencia a la movilidad de las especies.

**Marco conceptual:** El programa de trabajo de áreas protegidas (PTAP) aprobado por el Convenio de Diversidad Biológica –CDB-, establece que "El Sistema Nacional de Áreas Protegidas es representativo ecológicamente, si en el conjunto de sus áreas protegidas se encuentran "muestras" de la biodiversidad del país a sus diferentes niveles (especies, comunidades y ecosistemas) y si estas áreas y los sistemas en los que se encuentran cuentan con las cualidades necesarias para garantizar su viabilidad en el largo plazo". Teniendo esto en mente, durante el desarrollo de la política de sistema de monitoreo del SINAP, quedó establecido en el documento de conceptualización, que el Sistema Nacional de Áreas Protegidas es representativo ecológicamente si _i)_ la biodiversidad que se protege alcanza las metas de conservación específicas para cada nivel y, _ii)_ si estas áreas y los sistemas en los que se encuentran cuentan con la funcionalidad y otras cualidades ecológicas que permitan su viabilidad a largo plazo.

La conectividad del paisaje es una de las cualidades vitales de las Áreas Protegidas. El concepto hace referencia al flujo de materiales, organismos y energía a través del paisaje los cuales son imprescindibles para la integridad y funcionalidad de los ecosistemas, sus servicios ecosistémicos asociados y el mantenimiento de la biodiversidad (Crooks y Sanjayan, 2006). En tal sentido los objetivos de conservación de las Áreas Protegidas sólo pueden lograrse si tales unidades tienen vínculos o puentes que permitan el flujo de los procesos ecológicos como la migración, flujo de genes, dispersión y colonización (Rudnick et al., 2012). En los últimos años los estudios que evalúan la conectividad del paisaje han incrementado, aportando a la planificación de estrategias de conservación y a un mejor manejo del paisaje (Correa Ayram et al., 2016). Este tipo de información se ha convertido en una herramienta esencial al momento de monitorear, proponer y priorizar, por ejemplo, Áreas protegidas y corredores biológicos.

**Unidad de medida del indicador\*:** Porcentaje (%)

**Metodología de cálculo\*:**

La Conectividad de las Áreas Protegidas (AP) en Colombia se cuantificó por medio de la métrica Protected Connected Land (ProtConn; Saura et al. 2017, Saura et al. 2018, Saura 2019). ProtConn corresponde al porcentaje de la superficie terrestre del país cubierta por tierras protegidas y bien conectadas. La métrica es el resultado de la combinación, a través del análisis de redes, de los tamaños, la cobertura y la disposición espacial de las AP con distancias de dispersión consideradas para las especies.  En esta red, los nodos corresponden a las AP ponderadas. Los enlaces representan la posibilidad de movimiento entre nodos (áreas protegidas) y están ponderados por la probabilidad de dispersión directa entre ellos. Dada esta representación gráfica, la probabilidad de conectividad se define como la probabilidad de que dos ubicaciones seleccionadas al azar dentro de un ecosistema caigan en zonas protegidas que están conectadas entre sí.  El indicador ProtConn es, en su forma propuesta, fácil de comunicar a los usuarios finales y permite la comparación con los objetivos nacionales y globales para la conectividad de las AP así como su análisis de cambio en el tiempo.

El análisis se basa en el estudio reciente de Castillo et al (2020) sobre conectividad de AP Andino-Tropicales y calculamos ProtConn considerando una distancia media (_dmed_) de dispersión de 10 km. _dmed_ se refiere a la distancia media recorrida por un dispersor (por ejemplo, un animal) desde su hogar actual a uno nuevo, según Saura y colaboradores (2017 y 2018) 10 km corresponde al valor central del rango de transformación logarítmica de todos los dmed considerados en su estudio y ha sido usado frecuentemente para alcances de metas globales de conservación.

Teniendo en cuenta que las AP fuera del país pueden contribuir a la conectividad de las AP colombianas, seleccionamos un buffer de 100 km alrededor de los límites nacionales (20 kilómetros para territoriales) para incluir todas las AP transnacionales informadas en la base de datos de Áreas Protegidas del Mundo (WDPA) en las fechas seleccionadas en esta evaluación (1990-2000-2010-2020). Todas las AP que interceptan total o parcialmente esta zona de amortiguación se denominaron áreas transfronterizas que potencialmente influyen en la conectividad entre las AP dentro de las ecorregiones. Para definir áreas transfronterizas, aplicamos el mismo método para análisis globales utilizado por Santini et al. (2015).

Para la evaluación se utilizó una versión de este indicador de conectividad que incluye el grado de resistencia que ofrece la heterogeneidad del paisaje al movimiento de especies entre AP. Para esto se integraron los mapas de Huella Espacial Humana de 300 m de resolución espacial que abarca toda Colombia y derivado del estudio de Correa et al. (2020) para cada fecha. Estos mapas para cada año (1990-2000-2010 y 2018) incorporan de una forma espacialmente explícita el impacto acumulado del hombre sobre el paisaje por medio de dos dimensiones espaciales la intensidad del uso del suelo y el tiempo de intervención antrópica sobre los ecosistemas y permite cuantificar la resistencia de la matriz para la movilidad de una amplia gama de especies (como se necesita en una evaluación nacional e incluso regional) (Castillo et al. 2020). En este sentido las distancias entre áreas protegidas son ponderadas por el costo que ofrece atravesar cada píxel entre ellas, asumiendo que este costo genera un efecto sobre la conectividad que es más alto a medida que el nivel de huella humana se incrementa. Este enfoque se ha utilizado ampliamente en los análisis de conectividad porque funciona como un buen indicador genérico de la heterogeneidad del paisaje (Correa et al. 2017). El índice ProtConn en cada año de esta evaluación se calculó utilizando el paquete R Makurhini versión 2.0.3 diseñado específicamente para optimizar las medidas de conectividad del paisaje (Godinez y Correa, 2020). Este paquete está disponible en línea en [https://github.com/connectscape/Makurhini](https://github.com/connectscape/Makurhini).

Entonces, la probabilidad conectividad continental del SINAP se evaluó por medio del cálculo del porcentaje del país (o en las territoriales) protegido y conectado (ProtConn) para cuatro tiempos (1990, 2000, 2010, 2020). Finalmente, se cuantificó el cambio en el indicador ProtConn entre los pares de años 1990-2000, 2000-2010, 2010-2020 (dProtConn) como la diferencia entre los pares de años ponderado a el primer año del par multiplicado por 100.

El cálculo de ProtConn se define en la ecuación 1,

1.


En donde _n_ corresponde a la cantidad de AP dentro del territorio Colombiano, t es el número de AP dentro de un área buffer transfronteriza (en este caso para el nivel nacional se propone 100 km y en el nivel regional 20 km) fuera de los límites geográficos, ai y aj son el atributo de las AP i y j (en este caso el tamaño del AP), AL es el máximo atributo de paisaje (aquí el área total de la unidad de análisis), y p \* ij es la probabilidad máxima del producto de todas las rutas que conectan los nodos i y j.). El atributo de las AP es igual al área de las AP, en particular para esas AP que están dentro de la unidad de análisis, e igual a 0 para las AP transfronterizas fuera de la unidad de análisis. De esta manera, en la evaluación se analiza una red en la que las fuentes y destinos de los flujos de dispersión son solo aquellas AP dentro de la unidad de análisis (aquellas con ai \> 0), pero en la que el papel potencial de las AP fuera de los límites de la unidad aportan como conectores o stepping stones entre las AP (Saura et al. 2017).

El cálculo del indicador _dProtConn_corresponde al porcentaje de variación de Protconn y se define en la ecuación 2,

2.

En donde ProtConntn+1 corresponde al valor de Protconn en un tiempo 2 (final) y ProtConntn

corresponde al valor de Protconn en un tiempo 1 (inicial).

**Pasos para el cálculo:**

- Extraer del SINAP de cada periodo las áreas protegidas terrestres
- Remover de la capa WDPA de cada periodo las áreas colombianas dejando únicamente las áreas fuera de Colombia.
- Recortar áreas fuera de Colombia con un buffer de 100 km de los límites nacionales dejando las áreas transfronterizas
- Unir la capa del SINAP terrestre con áreas transfronterizas.
- Extender capa de huella humana a la extensión de SINAP terrestre + áreas transfronterizas.
- Se calcula la métrica ProtConn para cada período usando una distancia de 10 km, SINAP terrestre + Áreas transfronterizas y huella humana extendida
- Establecer el dProtConn para cada período sucesivo

**Proceso SIG:**

![](RackMultipart20221129-1-43ifm4_html_dda6706e60c377ae.png)

**Mapa de flujo de datos:**

![](RackMultipart20221129-1-43ifm4_html_ef908669eb16a3f4.png)

**Interpretación del indicador:**

Suponiendo que un país o región al que se calculó la métrica Protconn, presenta el 2% de su área protegida y conectada en el tiempo n y 4% en el tiempo n+1, entonces el cambio en el Porcentaje de áreas protegidas y conectadas o dProtConn entre n y n+1 es de 100%. Habiendo pues un cambio entre períodos del 100% (en otras palabras, del doble) en áreas protegidas y conectadas.

**Forma de almacenamiento de los resultados:** El resultado de análisis estará alojado en el XXXX del sistema de información de monitoreo y puede ser descargado de XXXX.

**Forma de presentación de los resultados:**

Representación espacial: Mapas del cambio en el porcentaje de áreas conectadas y protegidas del orden territorial. En cuanto al orden nacional no fueron creados mapas ya que el índice resume la información de todo el territorio Colombiano en un único dato porcentual, por lo que su representación geográfica no tiene sentido cartográfico.

Representación gráfica: Cambio en el porcentaje de áreas conectadas y protegidas del orden nacional y territorial con estimaciones en diferentes momentos en el tiempo.

**Pertinencia del indicador**

**Finalidad/Propósito/Justificación:** Este indicador permite monitorear la conectividad del SINAP, con el fin de determinar si el Sistema Nacional de Áreas Protegidas está bien conectado. Lo anterior en relación a las metas de conservación nacionales e internacionales vigentes.

**Observaciones y aclaraciones generales del indicador**

**Observaciones\*:**

**Restricciones o limitaciones del indicador:** El cálculo del indicador depende por una parte, de las modificaciones de las áreas protegidas del territorio colombiano de acuerdo a la inscripción de nuevas áreas protegidas en el Registro Único Nacional de Áreas Protegidas (RUNAP) o cambios en su delimitación; por otra depende de la periodicidad y calidad de las actualizaciones globales de áreas protegidas dentro de la base de datos WDPA. El cálculo del indicador depende también de la distancia media a usar en el cálculo de la métrica ProtConn; sin embargo, se recomienda que se sigan los lineamientos de 10 km por tener un amplio uso en el campo de la conectividad y estar suficientemente soportado en literatura. Asimismo, las distancias usadas desde los límites nacionales (o territoriales) para definir las áreas transfronterizas pueden hacer variar el indicador, sin embargo pruebas realizadas han demostrado que tal variación es mínima.

**Fuentes de incertidumbre:** La insuficiente delimitación de áreas protegidas, depuración del RUNAP y parámetros usados en el cálculo de la metrica ProtConn.

**Fuentes de los datos\***

INSUMO 1

**Nombre\*:** LHFI para los años 1990, 2000, 2010, 2018

**Descripción:** Mapa de la huella humana para Colombia en los años 1990-2000-2010-2018

**Referencia:**

Correa Ayram, C. A., Etter, A., Díaz-Timoté, J., Rodríguez Buriticá, S., Ramírez, W., & Corzo, G. (2020). Spatiotemporal evaluation of the human footprint in Colombia: Four decades of anthropic impact in highly biodiverse ecosystems. Ecological Indicators, 117, 106630.

**URL:** [http://geonetwork.humboldt.org.co/geonetwork/srv/spa/catalog.search#/metadata/e29b399c-24ee-4c16-b19c-be2eb1ce0aae](http://geonetwork.humboldt.org.co/geonetwork/srv/spa/catalog.search#/metadata/e29b399c-24ee-4c16-b19c-be2eb1ce0aae)

**Tipo:** Raster (tif).

**Institución responsable\*:** Instituto de Investigación de Recursos Biológicos Alexander von Humboldt (IAVH)

**Datos del responsable:**

- Programa de Evaluación y Monitoreo

Instituto de Investigación de Recursos Biológicos Alexander von Humboldt

Camilo Correa

ccorrea@humboldt.org.co

Tel 3202767

- Administrador información geoespacial (Infraestructura Institucional de Datos - I2D)

Instituto de Investigación de Recursos Biológicos Alexander von Humboldt

Tel 3202767

**Bibliografía/Literatura citada** _._

Beyer, Hawthorne L., Venter, Oscar, Grantham, Hedley S. and Watson, James E. M. (2019).Substantial losses in ecoregion intactness highlight urgency of globally coordinated action. Conservation Letters, 13 (2) e12592, e12592. doi: 10.1111/conl.12692

Castillo, L. S., Correa Ayram, C. A., Matallana Tobón, C. L., Corzo, G., Areiza, A., González-M., R., Serrano, F., Chalán Briceño, L., Sánchez Puertas, F., More, A., Franco, O., Bloomfield, H., Aguilera Orrury, V. L., Rivadeneira Canedo, C., Morón-Zambrano, V., Yerena, E., Papadakis, J., Cárdenas, J. J., Golden Kroner, R. E., & Godínez-Gómez, O. (2020). Connectivity of Protected Areas: Effect of Human Pressure and Subnational Contributions in the Ecoregions of Tropical Andean Countries. In Land (Vol. 9, Issue 8). [https://doi.org/10.3390/land9080239](https://doi.org/10.3390/land9080239)

Correa Ayram, Camilo A. Manuel E. Mendoza, Andrés Etter, Diego R & Pérez Salicrup (2017). Anthropogenic impact on habitat connectivity: A multidimensional human footprint index evaluated in a highly biodiverse landscape of Mexico, _Ecological Indicators_, 72(1), 895-909

Correa Ayram, Camilo & Mendoza, Manuel & Etter, Andres & Pérez-Salicrup, Diego. (2016). Habitat connectivity in biodiversity conservation: A review of recent studies and applications. Progress in Physical Geography. 40. 7-37. 10.1177/0309133315598713.

Crooks K R and Sanjayan M (2006) Connectivity Conservation. Cambridge, UK: Cambridge University Press.

Godínez-Gómez, O., & Correa Ayram C.A. (2020). Makurhini: Analyzing landscape connectivity.

Rudnick D, Ryan S, Beier P, et al. (2012) The role of landscape connectivity in planning and implementing conservation and restoration priorities. Issues in Ecol-ogy 16: 20–20

Santini, L., Saura, S., & Rondinini, C. (2016), Connectivity of the global network of protected areas. Diversity Distrib., 22: 199-211. https://doi.org/10.1111/ddi.12390

Saura, S., Pascual-Hortal, L., (2007). A new habitat availability index to integrate connectivity in landscape conservation planning: comparison with existing indices and application to a case study. Landsc. Urban Plan. 83, 91–103.

Saura, S., Rubio, L., (2010). A common currency for the different ways in which patches and links can contribute to habitat availability and connectivity in the landscape. Ecography 33, 523–537.

Saura, S., Bastin, L., Battistella, L., Mandrici, A., & Dubois, G. (2017). Protected areas in the world's ecoregions: How well connected are they? Ecological Indicators, 76, 144–158. https://doi.org/10.1016/J.ECOLIND.2016.12.047

Saura, S., Bertzky, B., Bastin, L., Battistella, L., Mandrici, A., & Dubois, G. (2018). Protected area connectivity: Shortfalls in global targets and country-level priorities. Biological Conservation, 219(July 2017), 53–67. https://doi.org/10.1016/j.biocon.2017.12.020

Saura, S., Bertzky, B., Bastin, L., Battistella, L., Mandrici, A., & Dubois, G. (2019). Global trends in protected area connectivity from 2010 to 2018. Biological Conservation, 238(May 2019), 108183. https://doi.org/10.1016/j.biocon.2019.07.028
