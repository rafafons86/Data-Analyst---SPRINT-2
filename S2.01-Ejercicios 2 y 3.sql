## SPRINT 2
/*
NIVEL 1 - EJERCICIO 2
Utilizando JOIN realizarás las siguientes consultas:
*/

# a) Listado de los países que están realizando compras.

SELECT DISTINCT c.country
FROM company c
INNER JOIN transaction t
ON c.id=t.company_id
ORDER BY c.country ASC;

# b) Desde cuántos países se realizan las compras.

SELECT count(DISTINCT c.country)
FROM company c
INNER JOIN transaction t
ON c.id=t.company_id;

# c) Identifica a la compañía con la mayor media de ventas.

SELECT c.company_name
FROM company c
INNER JOIN transaction t
ON c.id=t.company_id
GROUP BY c.company_name
ORDER BY avg(t.amount) DESC
LIMIT 1;

/*
NIVEL 1 - EJERCICIO 3
Utilizando sólo subconsultas (sin utilizar JOIN):
*/

# a) Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT * 
FROM transaction t
WHERE t.company_id IN (SELECT id
						FROM company c
                        WHERE c.country = "Germany" 
						);

# b) Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT DISTINCT c.id, c.company_name -- pongo los 2 campos sólo para mas claridad, aunque con el id ya sería suficiente.
FROM transaction t, company c
WHERE t.company_id=c.id
	AND t.amount > (SELECT avg(t.amount) AS prom_general
						FROM transaction t
						)
ORDER BY c.company_name ASC;

# c) Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

SELECT DISTINCT c.company_name
FROM company c
WHERE c.id NOT IN (SELECT DISTINCT t.company_id
						FROM transaction t
						);
                        
-- Aqui solo verifico por medio de un el resultado, porque es nulo (es decir todas las empresas han realizado trnsacciones)
SELECT DISTINCT c.company_name, COUNT(t.id)
FROM company c
RIGHT JOIN transaction t
ON  t.company_id=c.id
GROUP BY c.company_name;