# Efectos del tamaño del radio sobre el cálculo del índice de integridad estructural

Con el fin de identificar el efecto del tamaño del radio sobre el índice de integridad, calculamos la diferencia del índice para cada área protegida en un mismo año utilizando nueve diferentes radios: 2, 6, 10, 14, 18, 22, 26, 26.5 y 30 km. Al comparar la diferencia entre pares de radios adyacentes (e.g. 2-6 km, 6-10 km) y manteniendo un valor beta constante (Beta = 0.2), nuestros resultados muestran que las diferencias entre el índice de integridad son mayores a medida que el radio disminuye (Figura 1). Sin embargo, la diferencia máxima es del 15 %. Los cálculos utilizados en este análisis pueden ser consultados en [este enlace](https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional/datos_idPNN). El codigo para la generación de los datos crudos del analisis se encuentra en [3_3_test_repFunc.R](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/R/3_3_test_repFunc.R) y el codigo del analisis [aquí](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/R/3_4_analisis_sensibilidad_rep_func.R).

![Figura 1](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos_boxplot/difgnra_2020.png)

Figura 1. Diferencias de integridad de las Áreas Protegidas del SINAP entre radios adyacentes para el año 2020.

Al comparar la relación entre valores de índices calculados con diferentes radios, encontramos que la correlación siempre fue positiva independientemente del tamaño y la varianza explicada por un radio sobre otro fue superior al 85 % (Figura 2, Véase carpeta [pareamientos](https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos))

a)

![a](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos/1990/regresion_r2_r6_1990.png)

b)

![b](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos/1990/regresion_r10_r14_1990.png)

c)

![c](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos/1990/regresion_r26.5_r30_1990.png)

Figura 2. Correlación de la integridad calculada con diferentes radios para el año 1990. Los radios correlaciones son: a) 2 y 6 kilómetros, b) 10 y 14 kilómetros, c) 26.5 y 30 kilómetros. Nótese que el ajuste entre la integridad de las Áreas Protegidas calculado con radios de buffer adyacentes son iguales a 1.  

Al revisar las relaciones entre el tamaño y el cambio de integridad encontramos que a mayor tamaño del Área Protegida (Transformado logarítmicamente) el índice de integridad presenta una mayor variación. Sin embargo esta variación siempre es menor al 17.5%, incluso cuando se utiliza un radio de tan solo 2 kilómetros (Figura 3 y figura 4, Véase carpeta [pareamientos](https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos)).

![Figura 3](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos/1990/intvsSize_r2_r6_1990.png)

Figura 3. Tamaño de las Áreas Protegidas del SINAP y cambio de integridad calculada con un radio de 2 y 6 kilómetros para el año 1990.

![Figura 4](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pareamientos/1990/mapadif_r2_r6_1990.png)

Figura 4. mapa de diferencias en la integridad calculada de las Áreas Protegidas del SINAP usando un radio de 2 y 6 kilómetros para el año 1990.

![Figura 5](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/cambio_integridad_radio.png)

Figura 5. Cambio en la integridad media anual de las Áreas Protegidas del SINAP según radio.

Al revisar el cambio de integridad para todo el SINAP a través del tiempo , se puede evidenciar que a medida que aumenta el radio, se detectan menos cambios en la media de integridad para diferentes años (Figura 5). Además, la pendiente de cambio es mayor para aquellas áreas protegidas de tamaño pequeño (Figura 6, véase carpeta [pendientes_radios_xpnn](https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional/pendientes_radios_xpnn) en donde encontrará las tablas usadas para el cálculo, las gráficas y los recursos espaciales asociados).

a)						b)

![](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pendientes_radios_xpnn/pendiente%201990-2020%20r2.png)![](https://github.com/PEM-Humboldt/indicadores-sinap/blob/master/anexos/analisis_sensibilidad_representatividad_funcional/pendientes_radios_xpnn/pendiente%201990-2020%20r10.png)

Figura 6. Mapa de la pendiente de cambio de integridad de cada Área Protegida del SINAP entre los años 1990-2020 para diferentes tamaños de radio de buffer. a) radio de 2 kilómetros, b) radio de 10 kilómetros. Dado que para muchas Áreas Protegidas no se tienen datos para cada periodo analizado debido a su año de creación, en el mapa se muestra la información para 101 Áreas protegidas. El objeto geográfico puede ser encontrado en la carpeta [pendientes_radios_xpnn](https://github.com/PEM-Humboldt/indicadores-sinap/tree/master/anexos/analisis_sensibilidad_representatividad_funcional/pendientes_radios_xpnn).


**Conclusión**

Nuestros resultados muestran que a medida que el tamaño del radio utilizado para calcular el índice disminuye, existe una mayor variación en los valores de integridad a través del tiempo. Además, los valores de integridad tienden a disminuir a medida que se disminuye el tamaño del radio.

A pesar de que los radios más pequeños muestran cambios más abruptos en la media de integridad cuando se comparan diferentes años, todos los radios muestran un patrón similar, en donde hay una disminución de la integridad a través del tiempo. En este sentido, mostramos que el índice cumple su propósito de monitoreo siempre y cuando se utilice el mismo radio para comparar diferentes periodos.

Teniendo en cuenta los resultados presentados, recomendamos utilizar un valor de radio de 10 km ya que este valor muestra la misma correlación con radios pequeños (inferiores a 5 km) y grandes (mayores a 15 km). Además, un valor de 10 km calculará los valores de integridad tomando en cuenta no sólo los píxeles que se encuentran al interior de las áreas más pequeñas, sino también las zonas de amortiguamiento que cumplen un papel aún más preponderante cuando disminuye el tamaño del área protegida.
