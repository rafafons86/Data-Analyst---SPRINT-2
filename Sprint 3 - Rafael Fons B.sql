###### SPRINT 3

/*
NIVEL I - Ejercicio 1
Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. La nueva tabla 
debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company").
Después de crear la tabla será necesario que ingreses la información del documento denominado "datos_introducir_credit". Recuerda mostrar el
diagrama y realizar una breve descripción del mismo.
*/
CREATE TABLE credit_card(
						id VARCHAR(20) NOT NULL PRIMARY KEY,
                        iban VARCHAR(40) UNIQUE,
						pan VARCHAR(20),
						pin VARCHAR(4),
						cvv VARCHAR(3),
						expiring_date DATE
);

-- modifico el tipo de dato del campo "expiring_date" porque no cumple con el formato de fecha de mysql = YYYY-MM-DD
ALTER TABLE credit_card      
MODIFY COLUMN expiring_date VARCHAR(8);

-- agreggo la relacion entre el PK de "credit_card" y la FK de "transaction":
ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_ID) REFERENCES credit_card(id);

DESCRIBE credit_card;

/*
NIVEL 1 - Ejercicio 2
El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario con ID CcU-2938.
La información que debe mostrarse para este registro es: R323456312213576817699999. Recuerda mostrar que el cambio se realizó.
*/
-- primero verifico que el usuario exista
SELECT *
FROM credit_card
WHERE id="CcU-2938";

-- actualizo los dato del usuario
UPDATE credit_card
SET iban="R323456312213576817699999"
WHERE id="CcU-2938";

/*
NIVEL 1 - Ejercicio 3
En la tabla "transaction" ingresa un nuevo usuario con la siguiente información:
*/
-- primero agrego la companía "b-9999":
INSERT INTO company(id, company_name, phone, email, country, website)
VALUES ("b-9999", "", "", "", "", "");

-- primero agrego la tarjeta "CcU-9999":
INSERT INTO credit_card(id, iban, pan, pin, cvv, expiring_date)
VALUES ("CcU-9999", "", "", "", "", "");

INSERT INTO transaction(id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", 829.999, -117.999, CURRENT_DATE, 111.11, 0);

SELECT *
FROM transaction
WHERE id="108B1D1D-5B23-A76C-55EF-C568E49A99DD";

/*
NIVEL I - Ejercicio 4
Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado
*/
-- primero veo los campos de la tabla para ver si existe y verifiar le nombre:
DESCRIBE credit_card;

-- elimino el campo "pan"
ALTER TABLE credit_card
DROP pan;

-- verifico la estrucutra final de la tabla:
DESCRIBE credit_card;

/*
NIVEL II - Ejercicio 1
Elimina de la tabla transacción el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de datos.
*/
-- verifico que el registro exista:
SELECT *
FROM transaction
WHERE id="02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- elimino el registro:
DELETE FROM transaction
WHERE id="02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- verifico que relamente se haya eliminado el registro:
SELECT* FROM transaction
WHERE id="02C6201E-D90A-1859-B4EE-88D2986D3B02";

/*
NIVEL II - Ejercicio 2
La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. Será necesaria que crees 
una vista llamada VistaMarketing que contenga la siguiente información: Nombre de la compañía. Teléfono de contacto. País de residencia. 
Media de compra realizado por cada compañía. Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.
*/
-- creo la vista solicitada:
CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, ROUND(AVG(t.amount),2) AS media_compra
FROM transaction t
JOIN company c
ON t.company_id = c.id
GROUP BY c.company_name, c.phone, c.country
ORDER BY media_compra DESC;

-- muestro la vista
SELECT * FROM vistamarketing;

/*
NIVEL II - Ejercicio 3
Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"
*/
SELECT *
FROM vistamarketing
WHERE country = "Germany";

/*
NIVEL III - Ejercicio 1
La próxima semana tendrás una nueva reunión con los gerentes de marketing. Un compañero de tu equipo realizó modificaciones en la base de datos, 
pero no recuerda cómo las realizó. Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:
*/
-- Creamos el indice para el campo "user_id" de la tabla transaction. De lo contrario no puedo agregar la vinculación de la FK entre ambas tablas.
CREATE INDEX idx_user_id ON transaction(user_id);
-- Ahora si podemos crear la tabla user
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id)        
    );

-- elimino la restriccion de FK de la tabla "user" que estaban en el script original. Primero  ejecute un "show create table" para ver el nombre de la constraint.
ALTER TABLE user													
DROP CONSTRAINT user_ibfk_1;			

-- la relación entre user y transaction es incorrecta. Debería se 1:n de user a transaction.
ALTER TABLE transaction
ADD FOREIGN KEY(user_id) REFERENCES user(id);

-- verifico que la constraint haya sido borrada
SHOW CREATE table user;

-- inserto los datos en la tabla user usando el script "datos_introducir_user (1)"

-- Se debe modificar varios aspectos de la estructura del modelos de datos:
		# 1.Cambiar nombre tabla “user” por “data_user”
		RENAME TABLE user TO data_user;
        
        DESCRIBE data_user;

		# 2.Cambiar el nombre del campo “email” de la tabla “user” por “personal_email”
		ALTER TABLE data_user
        CHANGE email personal_email VARCHAR(150);
		
        DESCRIBE data_user;
        
		# 3.Eliminar campo “website” de la tabla “company”
		DESCRIBE company;
        
        ALTER TABLE company
        DROP website;
        
        DESCRIBE company;
        
		# 4.Agregar el campo “fecha_actual DATE” en la tabla “credit_card”
		ALTER TABLE credit_card
        ADD fecha_actual DATE;
        
        describe credit_card;
        
		# 5.Cambiar algunos tipos de datos de los campos de la tabla “credit_card”: 
		ALTER TABLE credit_card
			CHANGE iban IBAN VARCHAR(50),
			CHANGE expiring_date expiring_date VARCHAR(20);
            
		 describe credit_card;
         
         -- para modificar el campo "cvv" debo modificar el registo que ingrese con id "CcU-9999", porque en ese campo ingrese un string vacío "".
         -- primero actualizo ese valor:
         UPDATE credit_card
         SET cvv=NULL WHERE id = "CcU-9999";
         
         ALTER TABLE credit_card
			CHANGE cvv cvv INT;

		describe credit_card;
/*
NIVEL III - Ejercicio 2
La empresa también te solicita crear una vista llamada "InformeTecnico" que contenga la siguiente información:

ID de la transacción
Nombre del usuario/a
Apellido del usuario/a
IBAN de la tarjeta de crédito usada.
Nombre de la compañía de la transacción realizada.
Asegúrate de incluir información relevante de ambas tablas y utiliza alias para cambiar de nombre columnas según sea necesario.
Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción.
*/
-- creo la vista
CREATE VIEW InformeTecnico AS
SELECT t.id AS id_transaction, u.name AS user_name, u.surname AS user_surname, cd.iban AS IBAN, c.company_name AS company_name
FROM transaction t
JOIN data_user u
ON t.user_id = u.id
JOIN credit_card cd
ON t.credit_card_id = cd.id
JOIN company c
ON t.company_id = c.id
;

-- muestro la vista y ordeno por ID:
SELECT *
FROM informetecnico
ORDER BY id_transaction DESC;
