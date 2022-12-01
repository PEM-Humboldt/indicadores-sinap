# VIÑETA TÉCNICA DE INDICADORES
## Cambio en la media de la representatividad de integridad estructural del SINAP

### Identificación del indicador

**Iniciativa en la que se encuentra:** Sistema de Información de Monitoreo del SINAP.

**Atributo\*:** Representatividad Ecológica (I).

**Cobertura geográfica**

- Nacional
- Subsistema
- Departamental

**Insumos del indicador:**

- Mapas de Huella Humana nacional para 1990, 2000, 2010, 2020
- Mapas del Sistema Nacional de Áreas Protegidas de Colombia 1990, 2000, 2010, 2020

### Descripción general del indicador

**Definición:** El indicador “Cambio en la media de la representatividad de integridad estructural del SINAP” corresponde al  cambio en la integridad ecológica de las unidades representativas del patrimonio natural y cultural del país, incluidas dentro del sistema nacional de áreas protegidas entre dos momentos de medición. Este indicador resume información  sobre el cambio en la proporción de área con diferente nivel de presión antrópica y su grado de fragmentación. Para la medición de este indicador, se utilizó la aproximación de Beyer et al. (2019), quienes desarrollaron una métrica que cuantifica explícitamente los efectos combinados de la pérdida de hábitat, la fragmentación y la pérdida en la calidad de hábitat sobre unidades espaciales de interés. Como insumo, esta métrica requiere de una grilla continua de celdas que representan los valores de calidad de hábitat. Para ello se utilizó como proxy la capa de huella humana desarrollada por Correa - Ayram et al. (2020). Esta escogencia se basa en el supuesto de que las áreas menos degradadas (con los valores más bajos de presión humana)  tienen un mayor potencial de mantener su funcionalidad. Aunque este supuesto varía dependiendo la escala espacial de análisis, se considera apropiada cuando se cuenta con datos que pueden ser analizados en grandes extensiones con una alta resolución (grano) espacial (e.g. Correa-Ayram et al. 2020). La métrica de Beyer equivale a 1 si el área protegida tiene un bajo nivel de degradación y se aproxima a 0 cuando la degradación es máxima. Luego de establecer la métrica por área protegida se calcula la media de todas las áreas protegidas al sumar el valor individual y dividirlo por la cantidad total de áreas protegidas en un periodo específico. Finalmente, se calcula el indicador al hallar la diferencia entre dos períodos sucesivos. Dado que el proceso se repite con cada uno de los periodos seleccionados del SINAP, se obtienen medidas multitemporales y a escalas nacionales de la integridad, permitiendo identificar la variación de la funcionalidad de las unidades del SINAP dentro de una matriz de cambio antrópico.

**Marco conceptual:** El programa de trabajo de áreas protegidas (PTAP) aprobado por el Convenio de Diversidad Biológica –CDB-, establece que “El Sistema Nacional de Áreas Protegidas es representativo ecológicamente, si en el conjunto de sus áreas protegidas se encuentran “muestras” de la biodiversidad del país a sus diferentes niveles (especies, comunidades y ecosistemas) y si estas áreas y los sistemas en los que se encuentran cuentan con las cualidades necesarias para garantizar su viabilidad en el largo plazo”. Teniendo esto en mente, durante el desarrollo de la política de sistema de monitoreo del SINAP, quedó establecido en el documento de conceptualización, que el Sistema Nacional de Áreas Protegidas es representativo ecológicamente si *i)* la biodiversidad que se protege alcanza las metas de conservación específicas para cada nivel y, *ii)* si estas áreas y los sistemas en los que se encuentran cuentan con la funcionalidad y otras cualidades ecológicas que permitan su viabilidad a largo plazo.

En cuanto al aspecto de “funcionalidad y otras cualidades ecológicas”, existen múltiples aproximaciones que toman en cuenta aspectos como la diversidad funcional (Carter et al. 2019) y la capacidad de las áreas protegidas para proveer servicios ecosistémicos (He et al. 2018). Sin embargo, la medición de estos aspectos requiere de la colección intensiva de datos que por cuestiones logísticas, dificulta su uso programas de monitoreo a escalas regionales y nacionales. Por lo tanto, este ejercicio se enfocará en utilizar sustitutos (proxies) que tomen en cuenta los impactos acumulativos de las presiones humanas sobre las áreas protegidas. Esta selección se basa en el supuesto de que las áreas menos degradadas en términos de integridad ecológica son aquellas con los valores más bajos de presión humana. Aunque este supuesto varía dependiendo la escala espacial de análisis, consideramos que es apropiada cuando se cuenta con datos que pueden ser analizados en grandes extensiones con una alta resolución (grano) espacial (e.g. Correa-Ayram et al. 2020).

**Unidad de medida del indicador\*:** fracción de degradación estructural (Q)

### Metodología de cálculo

El cálculo del indicador tiene 3 momentos. El primero es a nivel de área protegida, en donde se requiere una medida relativa de la calidad de hábitat entre celdas a escala fina. Para ello, se adoptó una medida genérica de calidad de hábitat propuesta por Beyer et al. (2019) para medir los patrones generales de degradación conocida como *Q*. Esta métrica está diseñada y parametrizada de manera que cumple los siguientes criterios: es proporcional a la cantidad de hábitat cuando no existe fragmentación, declina monotónicamente a medida que la fragmentación aumenta y es sensible al número de parches y a la separación entre parches. De acuerdo con Beyer, estos criterios se alcanzan cuando el valor de Beta es igual a 0.2 y el de z a 0.5. En este proyecto se utilizó la capa de huella humana como proxy de la calidad de hábitat en cada área protegida para cuatro periodos de tiempo (1990, 2000, 2010, 2020). La métrica de degradación se calculó utilizando buffers de 26 km alrededor de cada unidad. El  valor reportado para cada unidad constituye el promedio de la métrica *Q* en la extensión total del área. El segundo momento usa la métrica de Beyer calculada por área protegida, para luego computar la media de todo el sistema de Áreas Protegidas en el Sistema Nacional o Regional, es decir, se suma el valor Q de todas las áreas y se divide por el número de unidades del sistema de referencia en un periodo dado. En el tercero y último momento, se busca la diferencia entre períodos sucesivos, bien sea a nivel de unidad de área protegida o sistemas nacionales y regionales. El indicador tiene un valor mínimo de -1 y máximo de 1, siendo -1 el menor valor de cambio negativo de la integridad y 1 el mayor valor de cambio positivo de la integridad.

El cálculo de *Q* para cada área se define en la ecuación 1,


\1. ![Ecuacion 1](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/rep_func_eq1.png)

Donde *Qa* es el indicador de degradación estructural en la unidad *a*, *dij* corresponde a la distancia entre dos celdas *i* y *j* (km), *g* es una medida de la calidad que hábitat cuyo rango se encuentra entre 0 y 1 (calculado aquí como 1 - [huella humana/100]), *z* es un exponente que escala el producto de dos dimensiones, y n es el número de celdas dentro de un área protegida. El parámetro beta determina cómo el valor combinado de los pares de celdas disminuye como una función de la distancia entre ellas, mientras que el denominador estandariza la métrica de manera que el estado actual es relativo a un estado hipotético en el que no ha ocurrido pérdida de hábitat o fragmentación, es decir todos los valores de calidad de hábitat corresponden a 1.

El cálculo del  indicador ‘Cambio en el porcentaje de la representatividad de integridad estructural del SINAP’ se define en la ecuación 2,

\2. ![Ecuacion 2](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/rep_func_eq2.png)

Donde *Qa* es el indicador de degradación estructural en el área protegida *a* (ecuación 1) y *N* es el número total de áreas protegidas.								

Variables:  Mapas de Huella Humana nacional y límites geográficos de las áreas protegidas del SINAP en diferentes periodos.

**Pasos para el cálculo:**

- Se cruza la información geográfica del Sistema Nacional de Áreas Protegidas en un periodo específico con la capa proxy para calcular Q. En este caso se utilizó la huella humana para diferentes periodos
- Se definen el parámetro z
- Se genera un buffer alrededor de las áreas protegidas para asegurar que existen suficientes celdas para calcular el indicador
- Se aplica la ecuación 1  a cada área protegida y se halla el promedio
- Se computa con la ecuación 2 el cambio a nivel nacional y territorial de la integridad de las áreas protegidas.


**Mapa de flujo de datos:**

![Flujo de datos](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/rep_Func_flujo_dDatos.jpg)

**Proceso SIG:**

![Diagrama Sig](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/img/rep_Func_dSig.jpg)

**Ejecutar el indicador:**

La rutina estandarizada y documentada para el cálculo del indicador se encuentra escrito en lenguaje R y se denomina [3_1_rep_func_operativo.R](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/R/3_1_rep_func_operativo.R). Mientras que las representaciones geograficas, graficas y tabulares se construyen con el codigo [3_2_rep_func_representaciones.R](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/R/3_2_rep_func_representaciones.R).

**Análisis de sensibilidad:**

Con el fin de identificar el efecto del tamaño del radio sobre el índice de integridad, calculamos la diferencia del índice para cada área protegida en un mismo año utilizando nueve diferentes radios: 2, 6, 10, 14, 18, 22, 26, 26.5 y 30 km. Al comparar la diferencia entre pares de radios adyacentes (e.g. 2-6 km, 6-10 km) y manteniendo un valor beta constante (Beta = 0.2), los resultados muestran que las diferencias entre el índice de integridad son mayores a medida que el radio disminuye (Figura 1). Sin embargo, la diferencia máxima es del 15 %. Por otra parte, a medida que el tamaño del radio utilizado para calcular el índice disminuye, existe una mayor variación en los valores de integridad a través del tiempo. Además, los valores de integridad tienden a disminuir a medida que se disminuye el tamaño del radio. Los radios más pequeños muestran cambios más abruptos en la media de integridad cuando se comparan diferentes años, todos los radios muestran un patrón similar, en donde hay una disminución de la integridad a través del tiempo. En este sentido, mostramos que el índice cumple su propósito de monitoreo, siempre y cuando se utilice el mismo radio para comparar diferentes periodos. Se recomienda utilizar un valor de radio de 10 km ya que este valor muestra la misma correlación con radios pequeños (inferiores a 5 km) y grandes (mayores a 15 km). Además, un valor de 10 km calculará los valores de integridad tomando en cuenta no sólo los píxeles que se encuentran al interior de las áreas más pequeñas, sino también las zonas de amortiguamiento que cumplen un papel aún más preponderante cuando disminuye el tamaño del área protegida. Para más información vease [este enlace](https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional)

### Observaciones y aclaraciones generales del indicador

**Interpretación del indicador:** Un cambio en la media de integridad del SINAP implica cambios a nivel en el hábitat, fragmentación y pérdida en la calidad de hábitat;  cuando es positivo o igual a cero supone una menor o constante degradación al comparar con el primer periodo de análisis, mientras que un cambio negativo deja ver una mayor degradación del Sistema de Áreas Protegidas.

**Forma de presentación de los resultados:**

Representación espacial:  Mapas de cambio en la media de la representatividad de integridad estructural del SINAP Áreas Protegidas del orden nacional y territorial y áreas protegidas en diferentes momentos en el tiempo.  

Representación gráfica:  Cambio en la media de la representatividad de integridad estructural, con estimaciones en diferentes momentos en el tiempo.

Reporte comparativo: Mapas de cambio media de la representatividad de integridad estructural de diferentes rangos en un tiempo determinado.

**Pertinencia del indicador**

**Finalidad/Propósito/Justificación:** Este indicador permite monitorear el patrimonio natural en el SINAP a nivel de integridad, con el fin de determinar la variación de la integridad de las unidades de conservación representadas dentro del SINAP. Lo anterior en relación a las metas de conservación nacionales e internacionales vigentes.

**Restricciones o limitaciones del indicador:** El cálculo del indicador depende por una parte, de las modificaciones de las áreas protegidas del territorio colombiano de acuerdo a la inscripción de nuevas áreas protegidas en el Registro Único Nacional de Áreas Protegidas (RUNAP) o cambios en su delimitación. El cálculo del indicador depende también del parámetro *z* de  reescalado a usar en el cálculo de la métrica de calidad de hábitat; sin embargo, se recomienda que se sigan los lineamientos de 0.5 por tener un amplio uso y estar suficientemente soportado en literatura (Beyer et al, 2019).

### Bibliografía/Literatura citada

Beyer, Hawthorne L., Venter, Oscar, Grantham, Hedley S. and Watson, James E. M. (2019).Substantial losses in ecoregion intactness highlight urgency of globally coordinated action. Conservation Letters, 13 (2) e12592, e12592. doi: 10.1111/conl.12692

Carter, S. K., Fleishman, E., Leinwand, I. I. F., Flather, C. H., Carr, N. B., Fogarty, F. A., . . . Wood, D. J. A. 2019. Quantifying Ecological Integrity of Terrestrial Systems to Inform Management of Multiple-Use Public Lands in the United States. Environmental Management, 64(1), 1-19. doi:10.1007/s00267-019-01163.

Correa Ayram, C. A., Etter, A., Díaz-Timoté, J., Rodríguez Buriticá, S., Ramírez, W., & Corzo, G. (2020). Spatiotemporal evaluation of the human footprint in Colombia: Four decades of anthropic impact in highly biodiverse ecosystems. Ecological Indicators, 117, 106630. https://doi.org/https://doi.org/10.1016/j.ecolind.2020.106630

He, S., Gallagher, L., Su, Y., Wang, L., & Cheng, H. 2018. Identification and assessment of ecosystem services for protected area planning: A case in rural communities of Wuyishan national park pilot. Ecosystem Services, 31, 169-180. doi:https://doi.org/10.1016/j.ecoser.2018.04.001
