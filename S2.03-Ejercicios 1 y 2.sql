## SPRINT 2
## NIVEL 3

/*
NIVEL 3 - EJERCICIO 1
Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 100 y 200 euros y,
en alguna de estas fechas: 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. Ordena los resultados de mayor a menor cantidad.
*/

SELECT c.company_name, c.phone, c.country, t.timestamp, t.amount 
FROM transaction t, company c
WHERE c.id = t.company_id
	AND t.amount BETWEEN 100 and 200
    AND DATE(t.timestamp) IN ("2021-04_29", "2021-07-20", "2022-03-13")
ORDER BY t.amount DESC;

/*
NIVEL 3 - EJERCICIO 2
Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden 
la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente
y quiere un listado de las empresas en las que especifiques si tienen más de 4 transacciones o menos.
*/

SELECT c.id,
		c.company_name,
        -- count(t.id) AS qty_transacion (solo para chequear cantidades)
        IF (count(t.id) > 4, "YES", "No" ) AS more_than_4
FROM transaction t
JOIN company c
ON c.id = t.company_id
GROUP BY c.company_name, c.id
;

