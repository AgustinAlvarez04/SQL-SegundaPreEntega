CREATE DATABASE agencia_aseguradora;
USE agencia_aseguradora;


-- CREAMOS TABLA PARA REGISTRAR USUARIOS
CREATE TABLE usuario (
id_usuario INT NOT NULL AUTO_INCREMENT,
nombre_de_usuario VARCHAR(15) NOT NULL,
nombre VARCHAR(20) NOT NULL,
apellido VARCHAR(20) NOT NULL,
PRIMARY KEY (id_usuario));

-- CREAMOS TABLAS PARA REGISTRAR LOS VEHICULOS
CREATE TABLE  IF NOT EXISTS seguros_vehiculos (
vehiculo VARCHAR(30) NOT NULL,
marca VARCHAR(20) NOT NULL,
modelo VARCHAR(20) NOT NULL,
id_patente FLOAT(10) NOT NULL AUTO_INCREMENT PRIMARY KEY,
id_usuario INT AUTO_INCREMENT,
PRIMARY KEY (id_patente),
FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario));

ALTER TABLE seguros_vehiculos ADD CONSTRAINT fk_seguros_vehiculos FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE RESTRICT;

-- CREAMOS TABLAS PARA REGISTRAR LAS VIVIENDAS
CREATE TABLE IF NOT EXISTS seguros_viviendas (
pais VARCHAR(30) NOT NULL,
localidad VARCHAR(30) NOT NULL,
direccion VARCHAR(30) NOT NULL,
altura NUMERIC(10) NOT NULL,
id_usuario INT AUTO_INCREMENT,
PRIMARY KEY (direccion),
FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario));

ALTER TABLE seguros_viviendas ADD CONSTRAINT fk_seguros_viviendas FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE RESTRICT;
ALTER TABLE seguros_viviendas modify localidad VARCHAR(50) NOT NULL;
ALTER TABLE seguros_viviendas modify direccion VARCHAR(50) NOT NULL;


-- CREAMOS TABLAS PARA REGISTRAR INFORMACION ADICIONAL DE LOS USUARIOS
CREATE TABLE IF NOT EXISTS informacion_personal (
nombre VARCHAR(40) NOT NULL,
apellido VARCHAR(40) NOT NULL,
telefono FLOAT(20) NOT NULL,
email VARCHAR(30) NOT NULL,
dni NUMERIC(20) NOT NULL,
id_usuario INT AUTO_INCREMENT,
PRIMARY KEY (id_usuario, dni),
FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario));


-- CREAMOS TABLAS PARA REGISTRAR LOS SERVICIOS 
CREATE TABLE IF NOT EXISTS servicios(
id_producto INT AUTO_INCREMENT,
tipo VARCHAR(30) NOT NULL,
precios_servicios INT NOT NULL,
PRIMARY KEY (Id_producto)
);

ALTER TABLE servicios modify tipo VARCHAR(150) NOT NULL;

-- CREAMOS TABLAS PARA REGISTRAR LOS SERVICIOS CONTRATADOS
CREATE TABLE IF NOT EXISTS servicios_contratados(
id_orden INT AUTO_INCREMENT,
fecha DATE NOT NULL,
nombre VARCHAR(30) NOT NULL,
tipo VARCHAR(30) NOT NULL,
PRIMARY KEY(id_orden)
);


-- INSERTAMOS DATOS PARA LOS VEHICULOS
INSERT INTO seguros_vehiculos (vehiculo, marca, modelo, id_patente) 
	VALUES ("Auto", "Alfa Romeo", "Giulietta", "132"),
    ("Auto", "Alfa Romeo", "Stelvio", "112"),
    ("Auto", "ASTON MARTIN", "Vantage V8", "864"),
    ("Auto", "ASTON MARTIN", "Rapide", "667"),
    ("Auto", "AUDI", "A8", "409"),
	("Moto", "Benelli", "752S", "001"),
	("Moto", "BMW", "G 310 R", "113"),
	("Moto", "BMW", "R 1250 R", "743"),
	("Moto", "Ducati", "Hypermotard 698 Mono", "590"),
    ("Moto", "Ducati", "Monster SP", "263");
    
-- COMPROBAMOS QUE LOS DATOS ESTEN INSERTADOS CORRECTAMENTE, USE DATOS IMPORTADOS
SELECT * FROM usuario;
SELECT * FROM seguros_vehiculos;
SELECT * FROM seguros_viviendas;
SELECT * FROM informacion_personal;

-- PROBAMOS BORRAR UN DATO DE LA TABVLA DE LOS VEHICULOS
DELETE FROM seguros_vehiculos WHERE id_patente = 132;

-- INSERTAMOS LOS SERVICIOS PARA PODER REGISTRARLOS
INSERT INTO servicios (id_producto, tipo, precios_servicios)
VALUES (101,'Autos - 2000', 10000),
(102, 'Motos', 5000),
(103, 'Viviendas', 25000);

INSERT INTO servicios (id_producto, tipo, precios_servicios)VALUES
(104,'Autos 2000-2010', 20000),
(105,'Autos 2010-2020', 30000),
(106,'Autos 2010-2024', 40000);

INSERT INTO servicios (id_producto, tipo, precios_servicios)VALUES
(107,'Motos 2000-2010', 10000),
(108,'Motos 2010-2020', 24000),
(109,'Motos 2010-2024', 39000);

INSERT INTO servicios (id_producto, tipo, precios_servicios)VALUES
(110,'Viviendas Monoambiente', 100000),
(111,'Viviendas 4 habitaciones', 150000),
(112,'Viviendas 4 habitaciones, patio y garage', 350000);

-- SE CREAN LAS VISTAS PARA PÓDER OBTENER LOS PRECIOS DE CADA SERVICIO --
CREATE OR REPLACE VIEW servicios_autos_vw AS
SELECT tipo, precios_servicios
FROM servicios
WHERE tipo LIKE "%Autos%";

CREATE OR REPLACE VIEW servicios_motos_vw AS
SELECT tipo, precios_servicios
FROM servicios
WHERE tipo LIKE "%Motos%";

CREATE OR REPLACE VIEW servicios_viviendas_vw AS
SELECT tipo, precios_servicios
FROM servicios
WHERE tipo LIKE "%Viviendas%";

SELECT * FROM servicios_autos_vw;
SELECT * FROM servicios_motos_vw;
SELECT * FROM servicios_viviendas_vw;

-- SE CREA LA VISTA PARA VER QUE SERVICIO CONTRATO CADA USUARIO -- 
CREATE OR REPLACE VIEW servicio_contratado_vw AS
SELECT u.nombre_de_usuario, u.nombre, s.id_producto, s.tipo
FROM usuario AS u JOIN servicios AS s ;

-- COMPROBAMOS QUE ESTEN INSERTADOS CORRECTAMENTE
select * from servicio_contratado_vw;

-- STORED PROCEDURE PARA ORDENAR LAS TABLAS --
DELIMITER $$
CREATE PROCEDURE ordenar_tablas_sp (IN tabla VARCHAR (20), IN campo VARCHAR (20), IN orden VARCHAR (4))
BEGIN
SET @ordenar = CONCAT( 'SELECT * FROM', ' ', tabla, ' ','ORDER BY',' ', campo,' ', orden);
PREPARE consulta FROM @ordenar;
EXECUTE consulta;
DEALLOCATE PREPARE consulta;
END $$
DELIMITER ;

-- TABLA SERVICIOS ORDENADA CON LOS PRECIOS DE FORMA DESCENDENTE -- 
CALL ordenar_tablas_sp ('servicios', 'precios_servicios', 'DESC');
-- TABLA SERVICIOS ORDENADA CON LOS PRECIOS DE FORMA ASCENDENTE -- 
CALL ordenar_tablas_sp ('servicios', 'precios_servicios', 'ASC');

-- REGISTRAR LAS CONTRATACIONES A MEDIDA QUE SE LAS CONTRATAN --
DELIMITER $$
CREATE PROCEDURE servicios_contratados_sp (IN orden INT, IN sp_fecha DATE, IN sp_nombre VARCHAR (30), in sp_tipo VARCHAR (30))
BEGIN
INSERT INTO servicios_contratados
(id_orden,fecha, nombre, tipo)
VALUES
(orden, sp_fecha, sp_nombre, sp_tipo);
END $$
DELIMITER ;

-- INSERTAR SERVICIOS CONTRATADOS -- 
CALL servicios_contratados_sp (1, '2024-08-15', 'Roombo', "Autos");
CALL servicios_contratados_sp (2, '2023-02-03', 'Capitan', "Autos 2010");
CALL servicios_contratados_sp (3, '2021-05-11', 'SubCapitan', "Motos 2011");
CALL servicios_contratados_sp (4, '2022-10-29', 'Teniente', "Vivienda Monoambiente");
CALL servicios_contratados_sp (5, '2024-11-09', 'InnoZ', "Autos 2022");
CALL servicios_contratados_sp (6, '2020-06-17', 'Voonte', "Motos 2024");
CALL servicios_contratados_sp (7, '2024-01-10', 'Zazio', "Viviendas 4 habitaciones");

-- COMPROBAMOS QUE ESTEN BIEN INSERTADOS --
SELECT * FROM servicios_contratados;	

-- STORED PROCEDURE PARA INSERTAR NUEVOS USUARIOS
DELIMITER $$
CREATE PROCEDURE insertar_nuevo_usuario_sp(
       IN p_nombre_de_usuario VARCHAR(15),
       IN p_nombre VARCHAR(20),
       IN p_apellido VARCHAR(20))
BEGIN
    INSERT INTO usuario (nombre_de_usuario, nombre, apellido)
    VALUES (p_nombre_de_usuario, p_nombre, p_apellido);
END $$
DELIMITER ;

-- COMPROBAMOS QUE FUNCIONE
call insertar_nuevo_usuario_sp ("CAPITAN", "Nelson", "Baigorria");
call insertar_nuevo_usuario_sp ("SubCapitan", "Bota", "Garcia");
call insertar_nuevo_usuario_sp ("Teniente", "Gabriel", "Alvarez");

-- CREAMOS FUNCION PARA AVERIGUAR EL PRECIO DE VENTA DE UN SERVICIO
DELIMITER $$
CREATE FUNCTION `precio_servicio_venta_final_fn` (monto DECIMAL(11,2), cargo DECIMAL(4,2))
RETURNS DECIMAL (11,2)
NO SQL
BEGIN 
	DECLARE resultado DECIMAL(11,2);
    SET resultado = monto + monto * (cargo/100);
    RETURN resultado;
END$$
DELIMITER ;

-- COMPROBAMOS QUE FUNCIONE
SELECT precio_servicio_venta_final_fn(7800, 28.21) AS precio_venta; -- parametro 7.800 = monto, parametro 28.21 = cargo / PRECIO FINAL DE AUTOS
SELECT precio_servicio_venta_final_fn(4000, 25.00) AS precio_venta; -- parametro 4.000 = monto, parametro 25.00 = cargo / PRECIO FINAL DE MOTOS
SELECT precio_servicio_venta_final_fn(23000, 8.70) AS precio_venta; -- parametro 23.000 = monto, parametro 8.70 = cargo / PRECIO FINAL DE VIVIENDAS

-- FUNCION PARA CALCULAR EL IVA DE LA VENTA
DROP function if exists calcular_iva_venta_fn;
DELIMITER $$
CREATE FUNCTION calcular_iva_venta_fn(monto DECIMAL(11,2))
RETURNS DECIMAL(11,2)
NO SQL
BEGIN
	DECLARE resultado DECIMAL(11,2);
    DECLARE impuesto DECIMAL(11,2);
    SET impuesto = 15.00;
    SET resultado = monto * (impuesto / 100);
    RETURN resultado;
END$$
DELIMITER ;

-- CON LA FUNCION DE ARRIBA CREADA, PODEMOS AVERIGUAR DE MANERA MAS SENCILLA CUANTO ES EL TOTAL QUE SE LES COBRARA AL CONTRATAR UN SERVICIO
DELIMITER $$
CREATE FUNCTION calcular_total_venta_fn(monto DECIMAL(11,2))
RETURNS DECIMAL (11,2)
NO SQL
BEGIN 
	DECLARE resultado DECIMAL(11,2);
    SET resultado = monto + calcular_iva_venta_fn(monto);
    RETURN resultado;
END$$
DELIMITER ; 

SELECT calcular_total_venta_fn (10000) AS precio_con_iva; -- Tomando el valor del 15% del iva -- 11500.00
SELECT calcular_total_venta_fn (5000) AS precio_con_iva; -- Tomando el valor del 15% del iva -- 5750.00
SELECT calcular_total_venta_fn (25000) AS precio_con_iva; -- Tomando el valor del 15% del iva -- 28750.00


-- Se crea la tabla LOG--
CREATE TABLE clientes
(
nombre_de_usuario VARCHAR(15) NOT NULL,
nombre VARCHAR(20) NOT NULL,
apellido VARCHAR(20) NOT NULL
);

