### SPRINT 4
### RAFAEL FONS BIBILONI

############################## Nivel 1 ##############################
/*
Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga,
al menos 4 tablas de las que puedas realizar las siguientes consultas:
*/
CREATE DATABASE sprint4;
USE sprint4;

-- primero creo las tabla de dimensiones "users" porque no tiene claves foráneas.
CREATE TABLE users (
	id INT PRIMARY KEY,
	name VARCHAR(50),
    surname VARCHAR(50),
	phone VARCHAR(50),
	email VARCHAR(50),
	birth_date VARCHAR(20),
	country VARCHAR(50),
    city VARCHAR(100),
	postal_code VARCHAR(50),
    address VARCHAR(200)
);

-- segundo la tabla de dimensiones "credit_cards" vinculada a "users":
CREATE TABLE credit_cards (
	id VARCHAR(8) PRIMARY KEY,
	user_id INT,
	iban VARCHAR(50),
	pan VARCHAR(50),
	pin INT,
	cvv INT,
	track1 VARCHAR(100),
	track2 VARCHAR(100),
	expiring_date DATE, 
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ahora las tablas de dimensiones vinculadas a a "transactions": "companies" y "products":
CREATE TABLE companies (
	company_id VARCHAR(6) PRIMARY KEY,
	company_name VARCHAR(50),
	phone VARCHAR(20),
	email VARCHAR(50),
	country VARCHAR(20),
	website VARCHAR(50)
);

CREATE TABLE products (
	id INT PRIMARY KEY,
	product_name VARCHAR(100),
	price DECIMAL(10,2),
	colour VARCHAR(10),
	weight DECIMAL(5,1),
	warehouse_id VARCHAR(10)
);

-- finalmente creo la tabla de hechos principales "transactions"
CREATE TABLE transactions (
	id VARCHAR(150) PRIMARY KEY,
    card_id VARCHAR(8),
    business_id VARCHAR(6),
    timestamp DATETIME,     	-- uso DATETIME porque el formato de los datos cumple con YYYY-MM-DD HH:MM:SS
    amount DECIMAL(10,2),
    declined INT,
    product_ids VARCHAR(30), -- REVISAR EL TEMA DEL LISTADO DE IDS¿??¿
    user_id INT,
    lat DECIMAL(20,18),
    longitude FLOAT,
    FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (business_id) REFERENCES companies(company_id)
    -- FOREIGN KEY (product_ids) REFERENCES products(id), NO SE PUEDE HACER DIRECTAMENTE
);

/*
NIVEL I - - Ejercicio 1
Realiza una subconsulta que muestre a todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas.
*/
-- Inserto los datos/registros en las tabla "users":
LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/users_uk.csv'
INTO TABLE users						
FIELDS TERMINATED BY ','
ENCLOSED BY '"'					
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/users_ca.csv'
INTO TABLE users						
FIELDS TERMINATED BY ','
ENCLOSED BY '"'					
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/users_usa.csv'
INTO TABLE users						
FIELDS TERMINATED BY ','
ENCLOSED BY '"'					
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

-- Ahora importo los datos del fichero “transactions.cvs” a la tabla “transactions”:
SET foreign_key_checks = 0;
LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/transactions.csv'
INTO TABLE transactions						
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'					
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);
SET foreign_key_checks = 1;

-- hago la consulta que muestre a todos los usuarios con más de 30 transacciones:
SELECT t.user_id, u.name, u.surname, count(*) AS cant_transaction
FROM transactions t
JOIN users u ON t.user_id = u.id
WHERE declined = 0
GROUP BY t.user_id, u.name, u.surname
HAVING count(*)>30;

/*
NIVEL I - Ejercicio 2
Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas
*/
-- Intento cargar los datos en la tabla "credit_cards", pero aparece un error relacionado con la FK users.id.

-- verifico que la cantidad de id en la tabla users no esta completa (hay 274 registros, numerados del 1 al 275): 
SELECT COUNT(*), MIN(id), MAX(id) FROM users;

-- Para saber que id aparecía en el fichero “credit_cards” pero NO estaba en el campo “users.id”,
-- cargue los datos del CVS en una tabla temporal e hice una consulta para identificar el “users.id” que no se correspondía. 
CREATE TABLE temp_credit_cards (
    id VARCHAR(8),
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin INT,
    cvv INT,
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date DATE
);

LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/credit_cards.csv'
INTO TABLE temp_credit_cards
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

SELECT tcd.user_id
FROM temp_credit_cards tcd
WHERE tcd.user_id not in (
	SELECT tcd.user_id
    FROM temp_credit_cards tcd
    JOIN users u ON tcd.user_id = u.id
);
-- falta el users.id = 201. Lo agrego manualmente según los datos del fichero csv.
UPDATE users
SET name= 'Iola', surname='Powers', phone='018-139-4717', email='ante.blandit@outlook.edu', birth_date='Mar 20, 2000',
	country='Canada', city='Rigolet', postal_code='V6T 6M7', address='154-5415 Auctor St.'
WHERE id=201;

-- cargo los datos nuevamente en la tabla "credit_cards":
LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/credit_cards.csv'
INTO TABLE credit_cards							
FIELDS TERMINATED BY ','					
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)      -- el @ me aLmacena temporalmente el valor y luego lo carga
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');			-- indico el formato en el que esta la fecha en el fichero csv

-- cargo los datos en la tabla "companies":
LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/companies.csv'
INTO TABLE companies						
FIELDS TERMINATED BY ','					
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(company_id, company_name, phone, email, country, website);


-- Hago la consulta solicitada, mostrando la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd:
SELECT c.company_name, cd.iban, ROUND(AVG(t.amount),2) AS prom_amount
FROM transactions t
JOIN credit_cards cd ON t.card_id = cd.id
JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = "Donec Ltd"
GROUP BY cd.iban;

############################## Nivel 2 ##############################

/*
NIVEL II - Ejercicio 1
Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones fueron declinadas
 y genera la siguiente consulta: ¿Cuántas tarjetas están activas?
*/
-- Creo la nueva tabla "active_cards"
CREATE TABLE cards_status(      				-- no tendría mas sentido crear una vista? ya que sería algo dinámico en lugar de estático
	card_id VARCHAR(8),
    card_status BOOL,
    FOREIGN KEY (card_id) REFERENCES credit_cards(id)
 );

-- vamos a hacer la consulta entre la tabla credit_cards y transactions para poder verificar las tarjetas que estan incativas (ninguna)
SELECT cd.id
FROM credit_cards cd
WHERE (										-- pongo el where para ejecutar la verificacion de cada tarjeta (como si fuera un for)
    SELECT COUNT(*)							-- consultaré que las ultimas 3 transacciones de la tarjeta de credito sena nulas (por eso el count)
    FROM (									
        SELECT t2.declined
        FROM transactions t2
        WHERE t2.card_id = cd.id					-- asegura q para cada tarjeta en credit_card, evalue esta subconsutla
        ORDER BY t2.timestamp DESC		
        LIMIT 3
		) AS temp
    WHERE temp.declined = 1       			-- verifico que todas las ultimas transacciones sean "declined" 
	) = 3      								-- verifico si cumple la condicion (si las ultimas 3 transacciones son declinadas, card_status = INACTIVE)                         
;

-- inserto los datos en la tabla "cards_status"
INSERT INTO cards_status (card_id, card_status)
SELECT 
    cd.id AS card_id,
    IF(								-- uso un IF para que verifique la condición en cada credit_card (como un for) y devuelva INACTIVE o ACTIVE
        (SELECT COUNT(*) 
         FROM (
             SELECT t2.declined
             FROM transactions t2
             WHERE t2.card_id = cd.id					-- asegura q para cada tarjeta en credit_card, evalue esta subconsutla
             ORDER BY t2.timestamp DESC					-- ordeno las transaciones por date para ver las ultimas, y con limit cuento solo las últimas 3
             LIMIT 3
			) temp
         WHERE temp.declined = 1
        ) = 3,				-- si las ultimas 3 transacciones tienen un declined =1, entoces tarjeta INACTIVE
        0,			-- caso si verdadero (las 3 ultimas son declinadas)
        1			-- caso si falso (las 3 ultimmas no son declinadas)
    ) AS card_status
FROM credit_cards cd;   
  
-- visualizo los datos:
SELECT * FROM cards_status;

-- Finalmente, respondo a la consulta, de cuantas tarjetas “activas” (card_status=1) hay:
SELECT count(*)
FROM cards_status
WHERE card_status = 1;

############################## Nivel 3 ##############################
/*
Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde
transaction tienes product_ids. 
*/
-- primero creare una tabla donde recogeré los campos: transaccion.id y transaction_products_ids:
CREATE TABLE transaction_products (
    transaction_id VARCHAR(150),
    product_id VARCHAR(30)
);

INSERT INTO transaction_products (transaction_id, product_id)
SELECT t.id AS transaction_id, p.id AS product_id
FROM transactions t
JOIN products p
ON FIND_IN_SET(CAST(p.id AS CHAR), REPLACE(t.product_ids, ' ', ''))>0;


-- Agrego en la tabla “transaction_products” las claves foráneas a FK transactions.id y products.id:
ALTER TABLE transaction_products
ADD FOREIGN KEY (transaction_id) REFERENCES transactions(id),
ADD FOREIGN KEY (product_id) REFERENCES products(id);


/*
Nivel III - Ejercicio 1
Genera la siguiente consulta: Necesitamos conocer el número de veces que se ha vendido cada producto.
*/

SELECT tp.product_id, p.product_name, count(*) AS cant_vendida
FROM transaction_products tp
JOIN transactions t ON tp.transaction_id = t.id
JOIN products p ON tp.product_id = p.id
WHERE t.declined = 0
GROUP BY tp.product_id
ORDER BY cant_vendida DESC;
























############## método altenativo para contar ids, unir 2 tablas paa generar una nuev tabla con nuevas filas, etc. ##############
-- averiguo el maximo de ids que hay en una transaction = 4 ids
SELECT MAX(id_count) AS max_ids
FROM (
    SELECT LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 AS id_count
    FROM transactions
    WHERE product_ids IS NOT NULL
) sub;

-- creo una tabla auxiliar para combinarla con la tabla "transaction_products" de forma de generar 4 filas por cada transacion:
CREATE TEMPORARY TABLE numbers(				-- crea una tabla auxiliar que solo existe en este script (no afecta la base de datos)
	n INT
);
-- agrego filas porque es la cantidad maxima de ids por transaction en transactions.products_ids
INSERT INTO numbers (n)
VALUES (1),(2), (3), (4)			-- agrego filas porque es la cantidad maxima de ids por transaction en transactions.products_ids
;			

-- hago una union entre "transactions" y "numbers" para generar 4 filas por cada transaction
INSERT INTO transaction_products (transaction_id, product_id)
SELECT 
    t.id AS transaction_id,
    CAST(										-- la funcion CAST convierte el string en INT UNSIGNED (enteros positivos)
        SUBSTRING_INDEX(						-- la funcion SUBSTRING_INDEX coge los datos de un string hasta su separador ","
            SUBSTRING_INDEX(t.product_ids, ',', numbers.n),
            ',',
            -1									-- el -1 indica que coge la ultima cadena a la derecha del separador indicado
        ) AS UNSIGNED
    ) AS product_id
FROM transactions t
JOIN numbers
WHERE 
    t.product_ids IS NOT NULL
    AND numbers.n <= (LENGTH(t.product_ids) - LENGTH(REPLACE(t.product_ids, ',', '')) + 1)	-- evita carga de duplicados (verifica la cant de ids en cada fila)
;

-- Inserto los datos/registros en las tabla "products":
LOAD DATA INFILE '/Users/rafafons/Library/Mobile Documents/com~apple~CloudDocs/2_Rafa/01-Capacitaciones/IT Academy/sprint 4/datos/products.csv'
INTO TABLE products						
FIELDS TERMINATED BY ','		
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,product_name,@price,colour,weight,warehouse_id)
SET price = CAST(REPLACE(@price, '$', '') AS DECIMAL(10,2));

-- Agrego en la tabla “transaction_products” las claves foráneas a FK transactions.id y products.id:
ALTER TABLE transaction_products
ADD FOREIGN KEY (transaction_id) REFERENCES transactions(id),
ADD FOREIGN KEY (product_id) REFERENCES products(id);




