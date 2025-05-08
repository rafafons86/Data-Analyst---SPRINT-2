## SPRINT 2
## NIVEL 2

/* 
NIVEL 2 - EJERCICIO 1
Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción
junto con el total de las ventas.
*/

SELECT DATE(t.timestamp) AS fecha, sum(t.amount) AS total_amount  -- uso la funcion DATE() para convertir el datetime en tipo fecha o date
FROM transaction t
GROUP BY fecha
ORDER BY total_amount DESC
LIMIT 5;

/* 
NIVEL 2 - EJERCICIO 2
¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.
*/

SELECT c.country AS Country, ROUND(AVG(t.amount),2) AS Prom_amount
FROM company c
JOIN transaction t
ON c.id = t.company_id
GROUP BY c.country
ORDER BY Prom_amount DESC;

/*
NIVEL 2 - EJERCICIO 3
En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”.
Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.
*/

# a) Muestra el listado aplicando JOIN y subconsultas.

SELECT *
FROM transaction t
JOIN (
		SELECT id 
		FROM company
        WHERE country = (SELECT country FROM company WHERE company_name = "Non Institute")
			  AND company_name != "Non Institute"       -- para quitar la empresa con la que me quiero comparar
	) AS sub
ON t.company_id = sub.id;


# b) Muestra el listado aplicando solo subconsultas.

SELECT *
FROM transaction t
WHERE t.company_id IN (
						SELECT c.id        -- filtro por id de companías que tengan el mismo país que Non Institute 
						FROM company c
						WHERE c.country = (SELECT country FROM company WHERE company_name = "Non Institute")   -- subconsulta para obtener el país en forma dinámica
							AND company_name != "Non Institute"       -- para quitar la empresa con la que me quiero comparar
                    );



