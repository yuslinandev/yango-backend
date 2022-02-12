-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 03-05-2021 a las 07:36:17
-- Versión del servidor: 10.4.14-MariaDB
-- Versión de PHP: 7.4.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_calculate_balance_kardex`$$
CREATE PROCEDURE `sp_calculate_balance_kardex` (`p_id_product` INT, `p_id_local` SMALLINT, `p_id_warehouse` SMALLINT, `p_date_1` DATE)  BEGIN

-- Variables para obtener el saldo anterior 
  DECLARE v_balance DECIMAL(14,4) DEFAULT (
  SELECT balance FROM kardex 
  WHERE id_product = p_id_product AND id_local = p_id_local AND id_warehouse = p_id_warehouse AND state = 'A' AND date < p_date_1 
  ORDER BY date DESC LIMIT 1);
  DECLARE v_balance_value DECIMAL(14,4) DEFAULT (
  SELECT balance_value FROM kardex 
  WHERE id_product = p_id_product AND id_local = p_id_local AND id_warehouse = p_id_warehouse AND state = 'A' AND date < p_date_1 
  ORDER BY date DESC LIMIT 1);
  
-- Variables donde almacenar lo que nos traemos desde el SELECT
  DECLARE v_id_kardex INT;
  DECLARE v_quantity DECIMAL(14,4);
  DECLARE v_quantity_value DECIMAL(14,4);
  DECLARE v_movement_type CHAR(1);
-- Variable para controlar el fin del bucle
  DECLARE v_end INTEGER DEFAULT 0;
  
-- El SELECT que vamos a ejecutar
  DECLARE kardex_cursor CURSOR FOR
    SELECT id_kardex,quantity,quantity_value,movement_type
    FROM kardex
    WHERE
        id_product = p_id_product AND id_local = p_id_local AND id_warehouse = p_id_warehouse AND state = 'A' 
        AND date >= p_date_1
    ORDER BY date ASC;

-- Condición de salida
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_end=1;
  
  IF v_balance IS NULL THEN SET v_balance = 0; END IF;
  IF v_balance_value IS NULL THEN SET v_balance_value = 0; END IF;

  OPEN kardex_cursor;
  get_row_kardex: LOOP
    FETCH kardex_cursor INTO v_id_kardex, v_quantity, v_quantity_value, v_movement_type;
  
    IF v_end = 1 THEN
       LEAVE get_row_kardex; 
    END IF;

  IF v_movement_type = 'I' THEN
    SET v_balance = v_balance + v_quantity;
    SET v_balance_value = v_balance_value + (v_quantity_value * v_quantity);
  END IF;
  
  IF v_movement_type = 'S' THEN
    SET v_balance = v_balance - v_quantity;
    SET v_balance_value = v_balance_value - (v_quantity_value * v_quantity);
  END IF;
  
  UPDATE kardex SET balance = v_balance,balance_value = v_balance_value WHERE id_kardex = v_id_kardex;

  END LOOP get_row_kardex;

  CLOSE kardex_cursor;
    
END$$

DELIMITER ;

--
-- Funciones
--

DELIMITER $$
CREATE FUNCTION `fn_product_obtener_saldo`(_id_product int,
    _id_local int,
    _id_warehouse int
) RETURNS decimal(14,4)
BEGIN
  
    set @stock = (
  Select balance from kardex
    where 
    id_product = _id_product and
        id_local = _id_local and 
        id_warehouse = _id_warehouse and
        state = 'A' 
        order by date desc
        limit 1
        );
    
RETURN @stock;
END$$
DELIMITER ;


DELIMITER $$
CREATE FUNCTION `fn_sale_document_obtener_totales`(_id_sale_order int,
    _currency varchar(5),
    _currency_national varchar(5)
) RETURNS decimal(14,4)
BEGIN
  
    set @total = (
    select sum(ifnull(
      case when sd.currency = _currency then 
        sd.total_sale 
      else (
        case when _currency = _currency_national then 
          sd.total_sale * sd.exchange_rate 
        else 
          sd.total_sale / sd.exchange_rate 
        end) 
      end,0)) as total 
    from sale sd
    where sd.state = 'A' and sd.id_sale_order = _id_sale_order
  );
    
RETURN @total;
END$$
DELIMITER ;

--
-- Estructura de tabla para la tabla `bank`
--

DROP TABLE IF EXISTS `banks`;
CREATE TABLE IF NOT EXISTS `banks` (
  `id_bank` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_bank`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `brand`
--

DROP TABLE IF EXISTS `brands`;
CREATE TABLE IF NOT EXISTS `brands` (
  `id_brand` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_brand`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorization`
--

DROP TABLE IF EXISTS `categorizations`;
CREATE TABLE IF NOT EXISTS `categorizations` (
  `id_categorization` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` varchar(50) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` varchar(50) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_categorization`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `classification`
--

DROP TABLE IF EXISTS `classifications`;
CREATE TABLE IF NOT EXISTS `classifications` (
  `id_classification` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `parent_id` smallint(4) NOT NULL,
  PRIMARY KEY (`id_classification`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `config`
--

DROP TABLE IF EXISTS `configs`;
CREATE TABLE IF NOT EXISTS `configs` (
  `id_config` int(4) NOT NULL AUTO_INCREMENT,
  `table` varchar(20) NOT NULL,
  `code` varchar(20) NOT NULL,
  `field` varchar(50) DEFAULT NULL,
  `alp_num_value` varchar(50) DEFAULT NULL,
  `num_value` decimal(14,4) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  `validity_date_start` datetime(6) DEFAULT NULL,
  `validity_date_end` datetime(6) DEFAULT NULL,
  `order_number` int(4) DEFAULT NULL,
  PRIMARY KEY (`id_config`),
  KEY `idx_config_1` (`table`,`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `config`
--

INSERT INTO `configs` (`id_config`, `table`, `code`, `field`, `alp_num_value`, `num_value`, `state`, `validity_date_start`, `validity_date_end`, `order_number`) VALUES
(1, 'ESTADO_BASE', 'A', 'ACTIVO', NULL, NULL, NULL, '2020-01-01 00:00:00.000000', NULL, NULL),
(3, 'ESTADO_BASE', 'I', 'INACTIVO', NULL, NULL, NULL, '2020-01-01 00:00:00.000000', NULL, NULL),
(4, 'ESTADO_BASE', 'E', 'ELIMINADO', NULL, NULL, NULL, '2020-01-01 00:00:00.000000', NULL, NULL),
(5, 'CORREL_MOVIMIENTO', 'IPR', '', NULL, '0.0000', NULL, NULL, NULL, NULL),
(6, 'TIPO_DOC_INTERNO', '01', 'DOCUMENTO INTERNO', NULL, NULL, 'A', NULL, NULL, NULL),
(7, 'TIPO_DOC_COMPROBANTE', '01', 'FACTURA', NULL, '1.0000', 'A', NULL, NULL, 1),
(8, 'TIPO_DOC_COMPROBANTE', '03', 'BOLETA', NULL, '1.0000', 'A', NULL, NULL, 2),
(9, 'TIPO_DOC_IDENTIDAD', 'DNI', 'D.N.I.', 'Documento Nacional de Identidad', NULL, 'A', NULL, NULL, 1),
(10, 'TIPO_DOC_IDENTIDAD', 'CE', 'C.E.', 'Carnet de Extranjería', NULL, 'A', NULL, NULL, 2),
(11, 'TIPO_LOCAL', 'PP', 'Planta de producción', NULL, NULL, 'A', NULL, NULL, NULL),
(12, 'TIPO_LOCAL', 'TD', 'Tienda-distribuidora', NULL, NULL, 'A', NULL, NULL, NULL),
(13, 'TIPO_UNID_MEDIDA', 'PS', 'PESO', NULL, NULL, 'A', NULL, NULL, NULL),
(14, 'TIPO_UNID_MEDIDA', 'LG', 'LONGITUD', NULL, NULL, 'A', NULL, NULL, NULL),
(15, 'TIPO_UNID_MEDIDA', 'CP', 'CAPACIDAD', NULL, NULL, 'A', NULL, NULL, NULL),
(16, 'TIPO_UNID_MEDIDA', 'IF', 'INFORMATICA', NULL, NULL, 'A', NULL, NULL, NULL),
(17, 'TIPO_UNID_MEDIDA', 'TP', 'TIEMPO', NULL, NULL, 'A', NULL, NULL, NULL),
(18, 'TIPO_UNID_MEDIDA', 'UN', 'UNIDAD', NULL, NULL, 'A', NULL, NULL, NULL),
(22, 'CORREL_MOVIMIENTO', 'ICP', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(23, 'CORREL_MOVIMIENTO', 'ITR', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(25, 'CORREL_MOVIMIENTO', 'IRS', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(26, 'CORREL_MOVIMIENTO', 'IDV', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(27, 'CORREL_MOVIMIENTO', 'IAJ', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(28, 'CORREL_MOVIMIENTO', 'SVT', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(29, 'CORREL_MOVIMIENTO', 'SPR', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(30, 'CORREL_MOVIMIENTO', 'SMR', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(31, 'CORREL_MOVIMIENTO', 'SPM', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(32, 'CORREL_MOVIMIENTO', 'STR', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(33, 'CORREL_MOVIMIENTO', 'SAJ', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(34, 'TIPO_PRECIO', 'MIN', 'MINORISTA', NULL, NULL, 'A', NULL, NULL, NULL),
(35, 'TIPO_PRECIO', 'MAY', 'MAYORISTA', NULL, NULL, 'A', NULL, NULL, NULL),
(36, 'TIPO_MONEDA', 'USD', 'DOLARES', '$', NULL, 'A', NULL, NULL, 2),
(37, 'TIPO_MONEDA', 'PEN', 'SOLES', 'S/', NULL, 'A', NULL, NULL, 1),
(38, 'CONDICION_PRECIO', 'ME', 'MENOR A ', '<', NULL, 'A', NULL, NULL, NULL),
(39, 'CONDICION_PRECIO', 'MEI', 'MENOR O IGUAL A', '<=', NULL, 'A', NULL, NULL, NULL),
(40, 'CONDICION_PRECIO', 'MA', 'MAYOR A', '>', NULL, 'A', NULL, NULL, NULL),
(41, 'CONDICION_PRECIO', 'MAI', 'MAYOR O IGUAL A', '>=', NULL, 'A', NULL, NULL, NULL),
(42, 'CONDICION_PRECIO', 'IG', 'IGUAL A', '=', NULL, 'A', NULL, NULL, NULL),
(43, 'CONDICION_PRECIO', 'SC', 'SIN CONDICION', '', NULL, 'A', NULL, NULL, NULL),
(44, 'CORREL_MOVIMIENTO', 'ISI', '', NULL, '0.0000', 'A', NULL, NULL, NULL),
(45, 'TIPO_PERSONA', 'PN', 'NATURAL', 'Persona Natural', NULL, 'A', NULL, NULL, 1),
(46, 'TIPO_PERSONA', 'PJ', 'JURIDICA', 'Persona Jurídica', NULL, 'A', NULL, NULL, 2),
(48, 'CLASE_PERSONA', 'PR', 'PROVEEDOR', NULL, NULL, 'A', NULL, NULL, 2),
(49, 'CLASE_PERSONA', 'CL', 'CLIENTE', NULL, NULL, 'A', NULL, NULL, 1),
(52, 'CORREL_MANTENIMIENTO', 'PER', NULL, NULL, '85.0000', 'A', NULL, NULL, NULL),
(53, 'TIPO_VEHICULO', 'CM', 'CAMION', NULL, NULL, 'A', NULL, NULL, NULL),
(54, 'TIPO_VEHICULO', 'SW', 'STATION WAGON', NULL, NULL, 'A', NULL, NULL, NULL),
(55, 'TIPO_VEHICULO', 'SD', 'SEDAN', NULL, NULL, 'A', NULL, NULL, NULL),
(56, 'TIPO_VEHICULO', 'CN', 'CAMIONETA', NULL, NULL, 'A', NULL, NULL, NULL),
(57, 'CORREL_MANTENIMIENTO', 'VEH', NULL, NULL, '18.0000', 'A', NULL, NULL, NULL),
(58, 'CLASE_PERSONA', 'CP', 'CLIENTE Y PROVEEDOR', NULL, NULL, 'A', NULL, NULL, 3),
(59, 'TIPO_PRODUCTO', 'PC', 'COMPRADO', 'Para compra y venta', NULL, 'A', NULL, NULL, 2),
(60, 'TIPO_PRODUCTO', 'PP', 'PRODUCIDO', 'Producto propio', NULL, 'A', NULL, NULL, 1),
(62, 'METODO_PAGO', 'EE', 'EFECTIVO', NULL, NULL, 'A', NULL, NULL, 1),
(63, 'METODO_PAGO', 'DE', 'CTA. BANCARIA', NULL, NULL, 'A', NULL, NULL, 2),
(64, 'METODO_PAGO', 'POS', 'POS', NULL, NULL, 'A', NULL, NULL, 3),
(65, 'CONDICION_PAGO', 'CT', 'CONTADO', NULL, NULL, 'A', NULL, NULL, 1),
(66, 'CONDICION_PAGO', 'CD', 'CREDITO', NULL, NULL, 'A', NULL, NULL, 2),
(67, 'ESTADO_PEDIDO', 'SLC', 'SOLICITADO', 'gray', NULL, 'A', NULL, NULL, 1),
(68, 'ESTADO_PEDIDO', 'CFM', 'CONFIRMADO', 'mediumseagreen', NULL, 'A', NULL, NULL, 2),
(69, 'ESTADO_PEDIDO', 'DSP', 'DESPACHADO', 'steelblue', NULL, 'A', NULL, NULL, 3),
(70, 'ESTADO_PEDIDO', 'ATD', 'ATENDIDO', 'black', NULL, 'A', NULL, NULL, 5),
(72, 'APLICACION_IGV', 'GRB', 'GRAVADO', NULL, NULL, 'A', NULL, NULL, 1),
(73, 'APLICACION_IGV', 'NGRB', 'NO GRAVADO / EXONERADO', NULL, NULL, 'A', NULL, NULL, 2),
(74, 'IMPUESTO', 'IGV', 'Impuesto General a las Ventas', NULL, '0.1800', 'A', '2019-01-01 00:00:00.000000', '2021-01-01 00:00:00.000000', NULL),
(75, 'CORREL_PEDIDO', 'TVAL', NULL, '001', '32.0000', 'A', NULL, NULL, NULL),
(76, 'CORREL_PEDIDO', 'TMIL', NULL, '002', '1.0000', 'A', NULL, NULL, NULL),
(77, 'CORREL_PEDIDO', 'TMAY', NULL, '003', '1.0000', 'A', NULL, NULL, NULL),
(78, 'ESTADO_PEDIDO', 'DSPP', 'DESP. PARCIAL', 'cornflowerblue', NULL, 'A', NULL, NULL, 4),
(79, 'MONEDA_NACIONAL', 'MN', 'SOL', 'PEN', NULL, 'A', NULL, NULL, NULL),
(80, 'ESTADO_BASE', 'N', 'ANULADO', NULL, NULL, NULL, '2020-01-01 00:00:00.000000', NULL, NULL),
(81, 'ESTADO_PEDIDO', 'ANL', 'ANULADO', 'firebrick', NULL, 'A', NULL, NULL, 0),
(82, 'ESTADO_VENTA', 'EM', 'EMITIDO', 'gray', NULL, 'A', NULL, NULL, 1),
(83, 'ESTADO_VENTA', 'PG', 'PAGADO', 'green', NULL, 'A', NULL, NULL, 2),
(84, 'ESTADO_VENTA', 'DSP', 'DESPACHADO', 'blue', NULL, 'A', NULL, NULL, 3),
(85, 'ESTADO_COMPRA', 'RE', 'REGISTRADO', 'gray', NULL, 'A', NULL, NULL, 1),
(86, 'ESTADO_COMPRA', 'INV', 'INVENTARIADO', 'green', NULL, 'A', NULL, NULL, 3),
(87, 'ESTADO_COMPRA', 'INVP', 'INVENTARIADO PARCIAL', 'yellow', NULL, 'A', NULL, NULL, 2),
(88, 'TIPO_DOC_COMPROBANTE', 'I01', 'NOTA DE VENTA', NULL, '2.0000', 'A', NULL, NULL, 3),
(89, 'CORREL_NOTA_VENTA', 'TVAL', NULL, '001', '5.0000', 'A', NULL, NULL, NULL),
(90, 'ESTADO_VENTA', 'ANL', 'ANULADO', 'firebrick', NULL, 'A', NULL, NULL, 0),
(91, 'CORREL_PAGO', 'TVAL', NULL, '001', '6.0000', 'A', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `delivery_point`
--

DROP TABLE IF EXISTS `delivery_points`;
CREATE TABLE IF NOT EXISTS `delivery_points` (
  `id_delivery_point` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `delivery_point_type` varchar(5) NOT NULL,
  `address` varchar(200) DEFAULT NULL,
  `multiple_customers` char(1) NOT NULL,
  `id_customer` int(4) DEFAULT NULL,
  `id_customer_local` int(4) DEFAULT NULL,
  `id_ubigeo` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_delivery_point`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `discount`
--

DROP TABLE IF EXISTS `discounts`;
CREATE TABLE IF NOT EXISTS `discounts` (
  `id_discount` smallint(2) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `discount_type` varchar(5) NOT NULL,
  `value` decimal(14,4) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_discount`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `employee`
--

DROP TABLE IF EXISTS `employees`;
CREATE TABLE IF NOT EXISTS `employees` (
  `id_employee` int(4) NOT NULL AUTO_INCREMENT,
  `document_number` varchar(20) DEFAULT NULL,
  `document_type` varchar(5) DEFAULT NULL,
  `names` varchar(100) NOT NULL,
  `last_name_1` varchar(50) NOT NULL,
  `last_name_2` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `id_ubigeo` int(4) DEFAULT NULL,
  `id_employee_area` smallint(2) DEFAULT NULL,
  `id_employee_job` smallint(2) DEFAULT NULL,
  `id_warehouse_assigned` int(4) DEFAULT NULL,
  `id_local_assigned` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_employee`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `employee_area`
--

DROP TABLE IF EXISTS `employee_areas`;
CREATE TABLE IF NOT EXISTS `employee_areas` (
  `id_employee_area` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_employee_area`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `employee_group`
--

DROP TABLE IF EXISTS `employee_groups`;
CREATE TABLE IF NOT EXISTS `employee_groups` (
  `id_employee` int(11) NOT NULL,
  `id_group` smallint(6) NOT NULL,
  PRIMARY KEY (`id_employee`,`id_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `employee_job`
--

DROP TABLE IF EXISTS `employee_jobs`;
CREATE TABLE IF NOT EXISTS `employee_jobs` (
  `id_employee_job` smallint(2) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_employee_job`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formula`
--

DROP TABLE IF EXISTS `formulas`;
CREATE TABLE IF NOT EXISTS `formulas` (
  `id_formula` int(4) NOT NULL AUTO_INCREMENT,
  `id_product_produce` int(4) NOT NULL,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `batch_quantity` decimal(10,2) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_formula`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formula_detail`
--

DROP TABLE IF EXISTS `formula_details`;
CREATE TABLE IF NOT EXISTS `formula_details` (
  `id_formula_detail` int(4) NOT NULL AUTO_INCREMENT,
  `id_formula` int(4) NOT NULL,
  `id_product` int(4) NOT NULL,
  `id_unit` int(4) NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `commentary` varchar(200) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  PRIMARY KEY (`id_formula_detail`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `group`
--

DROP TABLE IF EXISTS `groups`;
CREATE TABLE IF NOT EXISTS `groups` (
  `id_group` smallint(2) NOT NULL AUTO_INCREMENT,
  `group_type` varchar(5) NOT NULL,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `kardex`
--

DROP TABLE IF EXISTS `kardex`;
CREATE TABLE IF NOT EXISTS `kardex` (
  `id_kardex` int(4) NOT NULL AUTO_INCREMENT,
  `id_product` int(4) NOT NULL,
  `date` datetime(6) NOT NULL,
  `movement_type` char(1) NOT NULL,
  `id_movement_detail` int(4) NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `quantity_value` decimal(14,4) NOT NULL,
  `balance` decimal(14,4) NOT NULL,
  `balance_value` decimal(14,4) NOT NULL,
  `commentary` varchar(100) DEFAULT NULL,
  `id_local` int(4) NOT NULL,
  `id_warehouse` int(4) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_kardex`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `kardex_movement_detail`
--

DROP TABLE IF EXISTS `kardex_movement_details`;
CREATE TABLE IF NOT EXISTS `kardex_movement_details` (
  `id_kardex` int(4) NOT NULL,
  `id_movement_detail` int(4) NOT NULL,
  PRIMARY KEY (`id_kardex`,`id_movement_detail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `local`
--

DROP TABLE IF EXISTS `locals`;
CREATE TABLE IF NOT EXISTS `locals` (
  `id_local` smallint(2) NOT NULL AUTO_INCREMENT,
  `internal_code` varchar(5) DEFAULT NULL,
  `short_name` varchar(20) NOT NULL,
  `long_name` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `id_ubigeo` int(4) DEFAULT NULL,
  `type` varchar(5) NOT NULL,
  `id_responsible_employee` int(4) DEFAULT NULL,
  `manage_warehouse` char(1) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_local`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log`
--

DROP TABLE IF EXISTS `logs`;
CREATE TABLE IF NOT EXISTS `logs` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `table` varchar(50) NOT NULL,
  `field` varchar(50) NOT NULL,
  `action` varchar(5) NOT NULL,
  `previous_value` varchar(50) NOT NULL,
  `new_value` varchar(50) NOT NULL,
  `user_edit` smallint(4) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movement`
--

DROP TABLE IF EXISTS `movements`;
CREATE TABLE IF NOT EXISTS `movements` (
  `id_movement` int(4) NOT NULL AUTO_INCREMENT,
  `date` datetime(6) NOT NULL,
  `document_number` varchar(20) DEFAULT NULL,
  `document_type` varchar(5) DEFAULT NULL,
  `voucher_number` varchar(20) DEFAULT NULL,
  `voucher_type` varchar(5) DEFAULT NULL,
  `id_movement_type` tinyint(1) NOT NULL,
  `id_local_origin` smallint(2) DEFAULT NULL,
  `id_warehouse_origin` smallint(2) DEFAULT NULL,
  `id_local_arrival` smallint(2) DEFAULT NULL,
  `id_warehouse_arrival` smallint(2) DEFAULT NULL,
  `id_responsible_employee` int(4) DEFAULT NULL,
  `id_movement_transfer` int(4) DEFAULT NULL,
  `commentary` varchar(200) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_movement`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movement_detail`
--

DROP TABLE IF EXISTS `movement_details`;
CREATE TABLE IF NOT EXISTS `movement_details` (
  `id_movement_detail` int(4) NOT NULL AUTO_INCREMENT,
  `id_movement` int(4) NOT NULL,
  `id_product` int(4) NOT NULL,
  `id_product_lot` int(4) DEFAULT NULL,
  `id_product_ui` int(4) DEFAULT NULL,
  `id_product_formula` int(4) DEFAULT NULL,
  `id_unit` smallint(2) NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `quantity_formula` decimal(14,4) DEFAULT NULL,
  `value` decimal(14,4) DEFAULT NULL,
  `commentary` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_movement_detail`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movement_type`
--

DROP TABLE IF EXISTS `movement_types`;
CREATE TABLE IF NOT EXISTS `movement_types` (
  `id_movement_type` tinyint(1) NOT NULL,
  `short_name` varchar(20) NOT NULL,
  `long_name` varchar(50) NOT NULL,
  `description` varchar(200) NOT NULL,
  `prefix` varchar(5) NOT NULL,
  `type` char(1) NOT NULL,
  `state` varchar(5) NOT NULL,
  `visible` bit(1) NOT NULL,
  PRIMARY KEY (`id_movement_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `movement_type`
--

INSERT INTO `movement_types` (`id_movement_type`, `short_name`, `long_name`, `description`, `prefix`, `type`, `state`, `visible`) VALUES
(1, 'Compra', 'Ingreso por compra', 'Para ingresos por compras, de insumos, suministros de oficina, equipos electrónicos, etc. Sea mediante comprobante o cualquier otro documento.', 'ICP', 'I', 'A', b'1'),
(2, 'Transferencia', 'Ingreso por transferencia entre locales-almacenes', 'Para la transferencia entre locales (sea puntos de ventas o centros de producción) y sus almacenes; independiente si es para venta o para almacenaje u otro motivo.', 'ITR', 'I', 'A', b'1'),
(3, 'Producción', 'Ingreso por área de producción', 'Para registrar el ingreso de productos elaborados por el área de producción, sea para venta o almacenaje.', 'IPR', 'I', 'A', b'1'),
(4, 'Residual', 'Ingreso de productos residuales', 'Para el ingreso de productos que sobraron o quedaron sin usar, a pesar de haber salido para su consumo o utilización', 'IRS', 'I', 'A', b'1'),
(5, 'Devolución', 'Ingreso por devolución de productos', 'Para productos que fueron vendidos o entregados, y fueron devueltos por cualquier motivo y desea volver a almacenarlos.', 'IDV', 'I', 'A', b'1'),
(6, 'Ajuste de stock', 'Ingreso para ajustar stock físico', 'Para registrar el ingreso o salida de productos del stock físico, luego que realizado un inventario se encuentre diferencias.', 'IAJ', 'I', 'A', b'0'),
(7, 'Saldo Inicial', 'Ingreso por saldo inicial de productos', 'Para ingreso inicial al sistema del stock de productos', 'ISI', 'I', 'A', b'1'),
(51, 'Venta', 'Salida por venta de productos', 'Para productos que salen del almacén por haberse vendido por un valor monetario o gratuito. No aplica para ceder stock a otro local o almacén.', 'SVT', 'S', 'A', b'0'),
(52, 'Producción', 'Salida para área de producción', 'Para todos los productos que salen del almacén para hacer usados para elaborar productos propios.', 'SPR', 'S', 'A', b'1'),
(53, 'Merma', 'Salida por merma o descarte de producto', 'Para realizar la salida de productos por motivos varios (robo, mal estado, destrucción, consumo natural,etc.) ', 'SMR', 'S', 'A', b'1'),
(54, 'Préstamo', 'Salida por préstamo a cliente/proveedor', 'Para productos prestamos a clientes o proveedores sin un valor monetario, por condición a devolver.', 'SPM', 'S', 'A', b'1'),
(55, 'Transferencia', 'Salida por transferencia de productos', 'Para la salida de productos que son transferidos o trasladados a otro local o almacén.', 'STR', 'S', 'A', b'1'),
(56, 'Ajuste de stock', 'Salida para ajustar stock físico', 'Para registrar el ingreso o salida de productos del stock físico, luego que realizado un inventario se encuentre diferencias.', 'SAJ', 'S', 'A', b'0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `payment`
--

DROP TABLE IF EXISTS `payments`;
CREATE TABLE IF NOT EXISTS `payments` (
  `id_payment` int(4) NOT NULL AUTO_INCREMENT,
  `internal_code` varchar(20) NOT NULL,
  `id_bank` int(4) DEFAULT NULL,
  `date` datetime(6) NOT NULL,
  `payment_method` varchar(5) NOT NULL,
  `value` decimal(14,4) NOT NULL,
  `currency` varchar(5) NOT NULL,
  `exchange_rate` decimal(10,4) DEFAULT NULL,
  `commentary` varchar(200) DEFAULT NULL,
  `voucher` varchar(50) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_payment`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `payment_file`
--

DROP TABLE IF EXISTS `payment_files`;
CREATE TABLE IF NOT EXISTS `payment_files` (
  `id_payment_file` int(4) NOT NULL,
  `id_payment` int(4) DEFAULT NULL,
  `filename_user` varchar(45) DEFAULT NULL,
  `filename_system` varchar(45) DEFAULT NULL,
  `commentary` varchar(45) DEFAULT NULL,
  `state` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_payment_file`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `payment_sale`
--

DROP TABLE IF EXISTS `payment_sales`;
CREATE TABLE IF NOT EXISTS `payment_sales` (
  `id_payment_sale` int(4) NOT NULL AUTO_INCREMENT,
  `id_payment` int(4) DEFAULT NULL,
  `id_sale` int(4) DEFAULT NULL,
  `id_sale_order` int(4) DEFAULT NULL,
  PRIMARY KEY (`id_payment_sale`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `person`
--

DROP TABLE IF EXISTS `persons`;
CREATE TABLE IF NOT EXISTS `persons` (
  `id_person` int(4) NOT NULL AUTO_INCREMENT,
  `person_type` varchar(5) NOT NULL COMMENT 'tabla: tipo_persona',
  `person_class` varchar(20) NOT NULL COMMENT 'tabla: clase_persona (separado por comas)',
  `internal_code` varchar(15) NOT NULL,
  `ruc` varchar(15) DEFAULT NULL,
  `document_number` varchar(20) DEFAULT NULL,
  `document_type` varchar(5) DEFAULT NULL,
  `names` varchar(100) DEFAULT NULL,
  `tradename` varchar(100) DEFAULT NULL,
  `business_name` varchar(100) DEFAULT NULL,
  `last_name_1` varchar(50) DEFAULT NULL,
  `last_name_2` varchar(50) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `id_ubigeo` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_person`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `person_employee`
--

DROP TABLE IF EXISTS `person_employees`;
CREATE TABLE IF NOT EXISTS `person_employees` (
  `id_person_employee` int(4) NOT NULL AUTO_INCREMENT,
  `id_person` int(4) NOT NULL,
  `description` varchar(50) DEFAULT NULL,
  `names` varchar(100) NOT NULL,
  `last_names` varchar(100) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_person_employee`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `person_local`
--

DROP TABLE IF EXISTS `person_locals`;
CREATE TABLE IF NOT EXISTS `person_locals` (
  `id_person_local` int(4) NOT NULL AUTO_INCREMENT,
  `id_person` int(4) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `address` varchar(500) DEFAULT NULL,
  `id_ubigeo` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_person_local`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `person_phone`
--

DROP TABLE IF EXISTS `person_phones`;
CREATE TABLE IF NOT EXISTS `person_phones` (
  `id_person_phone` int(4) NOT NULL AUTO_INCREMENT,
  `description` varchar(100) DEFAULT NULL,
  `number_type` varchar(5) NOT NULL,
  `number` varchar(20) NOT NULL,
  `country_code` varchar(5) DEFAULT NULL,
  `city_code` varchar(5) DEFAULT NULL,
  `id_person` int(4) DEFAULT NULL,
  `id_person_employee` int(4) DEFAULT NULL,
  `id_person_local` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_person_phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
  `id_product` int(4) NOT NULL AUTO_INCREMENT,
  `internal_code` varchar(20) NOT NULL,
  `short_name` varchar(50) NOT NULL,
  `long_name` varchar(100) NOT NULL,
  `description` varchar(300) DEFAULT NULL,
  `id_brand` int(4) DEFAULT NULL,
  `id_unit` smallint(2) NOT NULL,
  `ids_classification` varchar(20) DEFAULT NULL,
  `id_categorization` int(4) NOT NULL,
  `product_type` varchar(5) DEFAULT NULL,
  `id_image` int(4) DEFAULT NULL,
  `life_time` smallint(2) DEFAULT NULL,
  `id_unit_life_time` smallint(2) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_product`),
  UNIQUE KEY `idx_prod_internal_code` (`internal_code`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_access`
--

DROP TABLE IF EXISTS `product_access`;
CREATE TABLE IF NOT EXISTS `product_access` (
  `id_product` int(4) NOT NULL,
  `id_local` int(4) NOT NULL,
  `allow_view` char(1) DEFAULT NULL,
  `allow_edit` char(1) DEFAULT NULL,
  `allow_delete` char(1) DEFAULT NULL,
  `allow_view_stock` char(1) DEFAULT NULL,
  `allow_view_price` char(1) DEFAULT NULL,
  `allow_buy` char(1) DEFAULT NULL,
  `allow_sell` char(1) DEFAULT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_product`,`id_local`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_lot`
--

DROP TABLE IF EXISTS `product_lots`;
CREATE TABLE IF NOT EXISTS `product_lots` (
  `id_product_lot` int(4) NOT NULL AUTO_INCREMENT,
  `id_product` int(4) NOT NULL,
  `lot_code` varchar(30) DEFAULT NULL,
  `id_unit_quantity` smallint(4) NOT NULL,
  `quantity` decimal(14,4) NOT NULL,
  `id_unit_weight` int(4) DEFAULT NULL,
  `weight` decimal(10,4) DEFAULT NULL,
  `production_date` datetime(6) DEFAULT NULL,
  `buy_date` datetime(6) DEFAULT NULL,
  `expiration_date` datetime(6) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_product_lot`),
  KEY `idx_prod_lot_code` (`lot_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_price`
--

DROP TABLE IF EXISTS `product_prices`;
CREATE TABLE IF NOT EXISTS `product_prices` (
  `id_product_price` int(4) NOT NULL AUTO_INCREMENT,
  `id_product` int(4) NOT NULL,
  `id_local` smallint(2) NOT NULL,
  `price_type` varchar(5) DEFAULT NULL,
  `currency` varchar(5) DEFAULT NULL,
  `price_condition` varchar(10) DEFAULT NULL,
  `price` decimal(14,4) NOT NULL,
  `validity_date_start` datetime(6) NOT NULL,
  `validity_date_end` datetime(6) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_product_price`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_stock`
--

DROP TABLE IF EXISTS `product_stocks`;
CREATE TABLE IF NOT EXISTS `product_stocks` (
  `id_product` int(4) NOT NULL,
  `id_local` smallint(2) NOT NULL,
  `id_warehouse` smallint(2) NOT NULL,
  `date` datetime(6) NOT NULL,
  `stock` decimal(14,4) NOT NULL,
  PRIMARY KEY (`id_product`,`id_local`,`id_warehouse`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_ui`
--

DROP TABLE IF EXISTS `product_uis`;
CREATE TABLE IF NOT EXISTS `product_uis` (
  `id_product_ui` int(4) NOT NULL AUTO_INCREMENT,
  `id_product` int(4) NOT NULL,
  `id_product_lot` int(4) NOT NULL,
  `unique_identifier_code` varchar(50) DEFAULT NULL,
  `serie_number` varchar(50) DEFAULT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_product_ui`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `purchase`
--

DROP TABLE IF EXISTS `purchases`;
CREATE TABLE IF NOT EXISTS `purchases` (
  `id_purchase` int(4) NOT NULL AUTO_INCREMENT,
  `document_type` varchar(5) DEFAULT NULL,
  `serie` varchar(5) DEFAULT NULL,
  `number` varchar(10) DEFAULT NULL,
  `id_supplier` int(4) DEFAULT NULL,
  `ruc_supplier` varchar(15) DEFAULT NULL,
  `supplier_document_type` varchar(5) DEFAULT NULL,
  `supplier_document_number` varchar(20) DEFAULT NULL,
  `supplier_name` varchar(200) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `percentage_igv` decimal(6,4) DEFAULT NULL,
  `total_purchase` decimal(14,4) DEFAULT NULL,
  `application_igv` varchar(5) DEFAULT NULL,
  `currency` varchar(5) DEFAULT NULL,
  `exchange_rate` decimal(10,4) DEFAULT NULL,
  `id_local_buy` int(4) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  `user_creation` smallint(4) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_purchase`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `purchase_detail`
--

DROP TABLE IF EXISTS `purchase_details`;
CREATE TABLE IF NOT EXISTS `purchase_details` (
  `id_purchase_detail` int(4) NOT NULL AUTO_INCREMENT,
  `id_purchase` int(4) DEFAULT NULL,
  `id_product` int(4) DEFAULT NULL,
  `product_description` varchar(400) DEFAULT NULL,
  `id_unit` smallint(2) DEFAULT NULL,
  `quantity` decimal(14,4) DEFAULT NULL,
  `discount` decimal(14,4) DEFAULT NULL,
  `application_discount` varchar(2) DEFAULT NULL COMMENT 'Aplica a: P=Precio sin igv, PV=Precio venta con igv, T=Total sin igv, TV=Total con igv\n',
  `price` decimal(14,4) DEFAULT NULL,
  `price_igv` decimal(14,4) DEFAULT NULL,
  `price_purchase` decimal(14,4) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id_purchase_detail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `purchase_movement_detail`
--

DROP TABLE IF EXISTS `purchase_movement_details`;
CREATE TABLE IF NOT EXISTS `purchase_movement_details` (
  `id_purchase_movement_detail` int(4) NOT NULL AUTO_INCREMENT,
  `id_purchase_detail` int(4) DEFAULT NULL,
  `id_movement_detail` int(4) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  `user_creation` smallint(2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `user_edit` smallint(2) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_purchase_movement_detail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `route`
--

DROP TABLE IF EXISTS `routes`;
CREATE TABLE IF NOT EXISTS `routes` (
  `id_route` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `route_type` varchar(5) NOT NULL,
  `id_vehicle` int(4) DEFAULT NULL,
  `id_employee_driver` int(4) DEFAULT NULL,
  `departure_date` datetime(6) DEFAULT NULL,
  `arrival_date` datetime(6) DEFAULT NULL,
  `number_passengers` tinyint(2) DEFAULT NULL,
  `allow_travel_expenses` char(1) DEFAULT NULL,
  `delivery_duration` smallint(2) DEFAULT NULL,
  `weekday_scheduled` char(1) DEFAULT NULL,
  `time_scheduled` varchar(10) DEFAULT NULL,
  `id_route_base` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_route`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `route_sale`
--

DROP TABLE IF EXISTS `route_sales`;
CREATE TABLE IF NOT EXISTS `route_sales` (
  `id_route_sale` int(4) NOT NULL AUTO_INCREMENT,
  `id_route` int(4) NOT NULL,
  `id_sale` int(4) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id_route_sale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale`
--

DROP TABLE IF EXISTS `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
  `id_sale` int(4) NOT NULL AUTO_INCREMENT,
  `document_type` varchar(5) NOT NULL,
  `serie` varchar(5) DEFAULT NULL,
  `number` varchar(10) NOT NULL,
  `id_customer` int(4) DEFAULT NULL,
  `ruc_customer` varchar(15) DEFAULT NULL,
  `customer_document_type` varchar(5) DEFAULT NULL,
  `customer_document_number` varchar(20) DEFAULT NULL,
  `customer_name` varchar(200) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `percentage_igv` decimal(6,4) DEFAULT NULL,
  `total_sale` decimal(14,4) DEFAULT NULL,
  `application_igv` varchar(5) DEFAULT NULL,
  `currency` varchar(5) DEFAULT NULL,
  `exchange_rate` decimal(10,4) DEFAULT NULL,
  `id_local_sell` int(4) DEFAULT NULL,
  `id_warehouse_sell` int(4) DEFAULT NULL,
  `reserve` char(1) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  `user_creation` smallint(4) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_detail`
--

DROP TABLE IF EXISTS `sale_details`;
CREATE TABLE IF NOT EXISTS `sale_details` (
  `id_sale_detail` int(4) NOT NULL AUTO_INCREMENT,
  `id_sale` int(4) DEFAULT NULL,
  `id_product` int(4) DEFAULT NULL,
  `id_product_ui` int(4) DEFAULT NULL,
  `internal_code` varchar(20) DEFAULT NULL,
  `product_description` varchar(400) DEFAULT NULL,
  `id_unit` smallint(2) DEFAULT NULL,
  `quantity` decimal(14,4) DEFAULT NULL,
  `discount` decimal(14,4) DEFAULT NULL,
  `application_discount` varchar(2) DEFAULT NULL COMMENT 'Aplica a: P=Precio sin igv, PV=Precio venta con igv, T=Total sin igv, TV=Total con igv\n',
  `price` decimal(14,4) DEFAULT NULL,
  `price_igv` decimal(14,4) DEFAULT NULL,
  `price_sale` decimal(14,4) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  `user_creation` smallint(2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `user_edit` smallint(2) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale_detail`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_movement_detail`
--

DROP TABLE IF EXISTS `sale_movement_details`;
CREATE TABLE IF NOT EXISTS `sale_movement_details` (
  `id_sale_movement_detail` int(4) NOT NULL AUTO_INCREMENT,
  `id_sale_detail` int(4) DEFAULT NULL,
  `id_movement_detail` int(4) DEFAULT NULL,
  `id_sale_order_detail` int(4) DEFAULT NULL,
  `id_sale_detail_base` int(4) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  `user_creation` smallint(2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `user_edit` smallint(2) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale_movement_detail`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_order`
--

DROP TABLE IF EXISTS `sale_orders`;
CREATE TABLE IF NOT EXISTS `sale_orders` (
  `id_sale_order` int(4) NOT NULL AUTO_INCREMENT,
  `internal_code` varchar(20) DEFAULT NULL,
  `id_customer` int(4) NOT NULL,
  `date` date DEFAULT NULL,
  `id_local` int(4) DEFAULT NULL,
  `payment_method` varchar(5) NOT NULL COMMENT 'Tabla config = METODO_PAGO',
  `payment_terms` varchar(5) NOT NULL COMMENT 'Tabla config = CONDICION_PAGO',
  `percentage_igv` decimal(6,4) NOT NULL,
  `total_sale` decimal(14,4) NOT NULL,
  `application_igv` varchar(5) NOT NULL,
  `indicator_applied_igv` char(1) DEFAULT NULL COMMENT 'S=Grabada, N=No gravada o exonerada',
  `currency` varchar(5) NOT NULL COMMENT 'TIPO_MONEDA',
  `exchange_rate` decimal(10,4) DEFAULT NULL,
  `commentary` varchar(500) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale_order`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_order_detail`
--

DROP TABLE IF EXISTS `sale_order_details`;
CREATE TABLE IF NOT EXISTS `sale_order_details` (
  `id_sale_order_detail` int(4) NOT NULL AUTO_INCREMENT,
  `id_sale_order` int(4) NOT NULL,
  `id_product` int(4) NOT NULL,
  `id_unit` smallint(2) NOT NULL,
  `quantity_requested` decimal(14,4) NOT NULL COMMENT 'SOLICITADA',
  `quantity_delivered` decimal(14,4) NOT NULL COMMENT 'ENTREGADA',
  `price_sale` decimal(14,4) NOT NULL,
  `price_igv` decimal(14,4) DEFAULT NULL,
  `price_discount` decimal(14,4) DEFAULT NULL,
  `total_sale` decimal(14,4) NOT NULL,
  `commentary` varchar(100) DEFAULT NULL,
  `id_warehouse_reserve` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale_order_detail`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_order_state`
--

DROP TABLE IF EXISTS `sale_order_states`;
CREATE TABLE IF NOT EXISTS `sale_order_states` (
  `id_sale_order_state` int(4) NOT NULL AUTO_INCREMENT,
  `id_sale_order` int(4) NOT NULL,
  `state_sale_order` varchar(5) NOT NULL,
  `current` char(1) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale_order_state`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_schedule`
--

DROP TABLE IF EXISTS `sale_schedules`;
CREATE TABLE IF NOT EXISTS `sale_schedules` (
  `id_sale_schedule` int(4) NOT NULL AUTO_INCREMENT,
  `id_sale` int(4) NOT NULL,
  `fee_number` tinyint(2) NOT NULL,
  `value` decimal(14,4) NOT NULL,
  `date_scheduled` datetime(6) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id_sale_schedule`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_schedule_payment`
--

DROP TABLE IF EXISTS `sale_schedule_payments`;
CREATE TABLE IF NOT EXISTS `sale_schedule_payments` (
  `id_sale_schedule_payment` int(4) NOT NULL AUTO_INCREMENT,
  `id_sale_schedule` int(4) NOT NULL,
  `id_payment` int(4) NOT NULL,
  `value` decimal(14,4) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale_schedule_payment`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sale_state`
--

DROP TABLE IF EXISTS `sale_states`;
CREATE TABLE IF NOT EXISTS `sale_states` (
  `id_sale_state` int(4) NOT NULL AUTO_INCREMENT,
  `id_sale` int(4) NOT NULL,
  `state_sale` varchar(5) DEFAULT NULL,
  `current` char(1) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_sale_state`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ubigeo`
--

DROP TABLE IF EXISTS `ubigeos`;
CREATE TABLE IF NOT EXISTS `ubigeos` (
  `id_ubigeo` int(4) NOT NULL AUTO_INCREMENT,
  `code` varchar(10) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `state` varchar(5) DEFAULT NULL,
  `type` char(1) DEFAULT NULL COMMENT 'D=Departamento; P=Provincia; I=Distrito',
  `id_ubigeo_base` int(4) DEFAULT NULL,
  PRIMARY KEY (`id_ubigeo`)
) ENGINE=InnoDB AUTO_INCREMENT=2161 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `ubigeo`
--

INSERT INTO `ubigeos` (`id_ubigeo`, `code`, `name`, `state`, `type`, `id_ubigeo_base`) VALUES
(1, '01', 'AMAZONAS', 'A', 'D', NULL),
(2, '02', 'ANCASH', 'A', 'D', NULL),
(3, '03', 'APURIMAC', 'A', 'D', NULL),
(4, '04', 'AREQUIPA', 'A', 'D', NULL),
(5, '05', 'AYACUCHO', 'A', 'D', NULL),
(6, '06', 'CAJAMARCA', 'A', 'D', NULL),
(7, '07', 'CALLAO', 'A', 'D', NULL),
(8, '08', 'CUSCO', 'A', 'D', NULL),
(9, '09', 'HUANCAVELICA', 'A', 'D', NULL),
(10, '10', 'HUANUCO', 'A', 'D', NULL),
(11, '11', 'ICA', 'A', 'D', NULL),
(12, '12', 'JUNIN', 'A', 'D', NULL),
(13, '13', 'LA LIBERTAD', 'A', 'D', NULL),
(14, '14', 'LAMBAYEQUE', 'A', 'D', NULL),
(15, '15', 'LIMA', 'A', 'D', NULL),
(16, '16', 'LORETO', 'A', 'D', NULL),
(17, '17', 'MADRE DE DIOS', 'A', 'D', NULL),
(18, '18', 'MOQUEGUA', 'A', 'D', NULL),
(19, '19', 'PASCO', 'A', 'D', NULL),
(20, '20', 'PIURA', 'A', 'D', NULL),
(21, '21', 'PUNO', 'A', 'D', NULL),
(22, '22', 'SAN MARTIN', 'A', 'D', NULL),
(23, '23', 'TACNA', 'A', 'D', NULL),
(24, '24', 'TUMBES', 'A', 'D', NULL),
(25, '25', 'UCAYALI', 'A', 'D', NULL),
(32, '0101', 'CHACHAPOYAS', 'A', 'P', 1),
(33, '0102', 'BAGUA', 'A', 'P', 1),
(34, '0103', 'BONGARA', 'A', 'P', 1),
(35, '0104', 'CONDORCANQUI', 'A', 'P', 1),
(36, '0105', 'LUYA', 'A', 'P', 1),
(37, '0106', 'RODRIGUEZ DE MENDOZA', 'A', 'P', 1),
(38, '0107', 'UTCUBAMBA', 'A', 'P', 1),
(39, '0201', 'HUARAZ', 'A', 'P', 2),
(40, '0202', 'AIJA', 'A', 'P', 2),
(41, '0203', 'ANTONIO RAYMONDI', 'A', 'P', 2),
(42, '0204', 'ASUNCION', 'A', 'P', 2),
(43, '0205', 'BOLOGNESI', 'A', 'P', 2),
(44, '0206', 'CARHUAZ', 'A', 'P', 2),
(45, '0207', 'CARLOS FERMIN FITZCARRALD', 'A', 'P', 2),
(46, '0208', 'CASMA', 'A', 'P', 2),
(47, '0209', 'CORONGO', 'A', 'P', 2),
(48, '0210', 'HUARI', 'A', 'P', 2),
(49, '0211', 'HUARMEY', 'A', 'P', 2),
(50, '0212', 'HUAYLAS', 'A', 'P', 2),
(51, '0213', 'MARISCAL LUZURIAGA', 'A', 'P', 2),
(52, '0214', 'OCROS', 'A', 'P', 2),
(53, '0215', 'PALLASCA', 'A', 'P', 2),
(54, '0216', 'POMABAMBA', 'A', 'P', 2),
(55, '0217', 'RECUAY', 'A', 'P', 2),
(56, '0218', 'SANTA', 'A', 'P', 2),
(57, '0219', 'SIHUAS', 'A', 'P', 2),
(58, '0220', 'YUNGAY', 'A', 'P', 2),
(59, '0301', 'ABANCAY', 'A', 'P', 3),
(60, '0302', 'ANDAHUAYLAS', 'A', 'P', 3),
(61, '0303', 'ANTABAMBA', 'A', 'P', 3),
(62, '0304', 'AYMARAES', 'A', 'P', 3),
(63, '0305', 'COTABAMBAS', 'A', 'P', 3),
(64, '0306', 'CHINCHEROS', 'A', 'P', 3),
(65, '0307', 'GRAU', 'A', 'P', 3),
(66, '0401', 'AREQUIPA', 'A', 'P', 4),
(67, '0402', 'CAMANA', 'A', 'P', 4),
(68, '0403', 'CARAVELI', 'A', 'P', 4),
(69, '0404', 'CASTILLA', 'A', 'P', 4),
(70, '0405', 'CAYLLOMA', 'A', 'P', 4),
(71, '0406', 'CONDESUYOS', 'A', 'P', 4),
(72, '0407', 'ISLAY', 'A', 'P', 4),
(73, '0408', 'LA UNION', 'A', 'P', 4),
(74, '0501', 'HUAMANGA', 'A', 'P', 5),
(75, '0502', 'CANGALLO', 'A', 'P', 5),
(76, '0503', 'HUANCA SANCOS', 'A', 'P', 5),
(77, '0504', 'HUANTA', 'A', 'P', 5),
(78, '0505', 'LA MAR', 'A', 'P', 5),
(79, '0506', 'LUCANAS', 'A', 'P', 5),
(80, '0507', 'PARINACOCHAS', 'A', 'P', 5),
(81, '0508', 'PAUCAR DEL SARA SARA', 'A', 'P', 5),
(82, '0509', 'SUCRE', 'A', 'P', 5),
(83, '0510', 'VICTOR FAJARDO', 'A', 'P', 5),
(84, '0511', 'VILCAS HUAMAN', 'A', 'P', 5),
(85, '0601', 'CAJAMARCA', 'A', 'P', 6),
(86, '0602', 'CAJABAMBA', 'A', 'P', 6),
(87, '0603', 'CELENDIN', 'A', 'P', 6),
(88, '0604', 'CHOTA', 'A', 'P', 6),
(89, '0605', 'CONTUMAZA', 'A', 'P', 6),
(90, '0606', 'CUTERVO', 'A', 'P', 6),
(91, '0607', 'HUALGAYOC', 'A', 'P', 6),
(92, '0608', 'JAEN', 'A', 'P', 6),
(93, '0609', 'SAN IGNACIO', 'A', 'P', 6),
(94, '0610', 'SAN MARCOS', 'A', 'P', 6),
(95, '0611', 'SAN MIGUEL', 'A', 'P', 6),
(96, '0612', 'SAN PABLO', 'A', 'P', 6),
(97, '0613', 'SANTA CRUZ', 'A', 'P', 6),
(98, '0701', 'CALLAO', 'A', 'P', 7),
(99, '0801', 'CUSCO', 'A', 'P', 8),
(100, '0802', 'ACOMAYO', 'A', 'P', 8),
(101, '0803', 'ANTA', 'A', 'P', 8),
(102, '0804', 'CALCA', 'A', 'P', 8),
(103, '0805', 'CANAS', 'A', 'P', 8),
(104, '0806', 'CANCHIS', 'A', 'P', 8),
(105, '0807', 'CHUMBIVILCAS', 'A', 'P', 8),
(106, '0808', 'ESPINAR', 'A', 'P', 8),
(107, '0809', 'LA CONVENCION', 'A', 'P', 8),
(108, '0810', 'PARURO', 'A', 'P', 8),
(109, '0811', 'PAUCARTAMBO', 'A', 'P', 8),
(110, '0812', 'QUISPICANCHI', 'A', 'P', 8),
(111, '0813', 'URUBAMBA', 'A', 'P', 8),
(112, '0901', 'HUANCAVELICA', 'A', 'P', 9),
(113, '0902', 'ACOBAMBA', 'A', 'P', 9),
(114, '0903', 'ANGARAES', 'A', 'P', 9),
(115, '0904', 'CASTROVIRREYNA', 'A', 'P', 9),
(116, '0905', 'CHURCAMPA', 'A', 'P', 9),
(117, '0906', 'HUAYTARA', 'A', 'P', 9),
(118, '0907', 'TAYACAJA', 'A', 'P', 9),
(119, '1001', 'HUANUCO', 'A', 'P', 10),
(120, '1002', 'AMBO', 'A', 'P', 10),
(121, '1003', 'DOS DE MAYO', 'A', 'P', 10),
(122, '1004', 'HUACAYBAMBA', 'A', 'P', 10),
(123, '1005', 'HUAMALIES', 'A', 'P', 10),
(124, '1006', 'LEONCIO PRADO', 'A', 'P', 10),
(125, '1007', 'MARA¥ON', 'A', 'P', 10),
(126, '1008', 'PACHITEA', 'A', 'P', 10),
(127, '1009', 'PUERTO INCA', 'A', 'P', 10),
(128, '1010', 'LAURICOCHA', 'A', 'P', 10),
(129, '1011', 'YAROWILCA', 'A', 'P', 10),
(130, '1101', 'ICA', 'A', 'P', 11),
(131, '1102', 'CHINCHA', 'A', 'P', 11),
(132, '1103', 'NASCA', 'A', 'P', 11),
(133, '1104', 'PALPA', 'A', 'P', 11),
(134, '1105', 'PISCO', 'A', 'P', 11),
(135, '1201', 'HUANCAYO', 'A', 'P', 12),
(136, '1202', 'CONCEPCION', 'A', 'P', 12),
(137, '1203', 'CHANCHAMAYO', 'A', 'P', 12),
(138, '1204', 'JAUJA', 'A', 'P', 12),
(139, '1205', 'JUNIN', 'A', 'P', 12),
(140, '1206', 'SATIPO', 'A', 'P', 12),
(141, '1207', 'TARMA', 'A', 'P', 12),
(142, '1208', 'YAULI', 'A', 'P', 12),
(143, '1209', 'CHUPACA', 'A', 'P', 12),
(144, '1301', 'TRUJILLO', 'A', 'P', 13),
(145, '1302', 'ASCOPE', 'A', 'P', 13),
(146, '1303', 'BOLIVAR', 'A', 'P', 13),
(147, '1304', 'CHEPEN', 'A', 'P', 13),
(148, '1305', 'JULCAN', 'A', 'P', 13),
(149, '1306', 'OTUZCO', 'A', 'P', 13),
(150, '1307', 'PACASMAYO', 'A', 'P', 13),
(151, '1308', 'PATAZ', 'A', 'P', 13),
(152, '1309', 'SANCHEZ CARRION', 'A', 'P', 13),
(153, '1310', 'SANTIAGO DE CHUCO', 'A', 'P', 13),
(154, '1311', 'GRAN CHIMU', 'A', 'P', 13),
(155, '1312', 'VIRU', 'A', 'P', 13),
(156, '1401', 'CHICLAYO', 'A', 'P', 14),
(157, '1402', 'FERRE¥AFE', 'A', 'P', 14),
(158, '1403', 'LAMBAYEQUE', 'A', 'P', 14),
(159, '1501', 'LIMA', 'A', 'P', 15),
(160, '1502', 'BARRANCA', 'A', 'P', 15),
(161, '1503', 'CAJATAMBO', 'A', 'P', 15),
(162, '1504', 'CANTA', 'A', 'P', 15),
(163, '1505', 'CA¥ETE', 'A', 'P', 15),
(164, '1506', 'HUARAL', 'A', 'P', 15),
(165, '1507', 'HUAROCHIRI', 'A', 'P', 15),
(166, '1508', 'HUAURA', 'A', 'P', 15),
(167, '1509', 'OYON', 'A', 'P', 15),
(168, '1510', 'YAUYOS', 'A', 'P', 15),
(169, '1601', 'MAYNAS', 'A', 'P', 16),
(170, '1602', 'ALTO AMAZONAS', 'A', 'P', 16),
(171, '1603', 'LORETO', 'A', 'P', 16),
(172, '1604', 'MARISCAL RAMON CASTILLA', 'A', 'P', 16),
(173, '1605', 'REQUENA', 'A', 'P', 16),
(174, '1606', 'UCAYALI', 'A', 'P', 16),
(175, '1607', 'DATEM DEL MARA¥ON', 'A', 'P', 16),
(176, '1608', 'PUTUMAYO', 'A', 'P', 16),
(177, '1701', 'TAMBOPATA', 'A', 'P', 17),
(178, '1702', 'MANU', 'A', 'P', 17),
(179, '1703', 'TAHUAMANU', 'A', 'P', 17),
(180, '1801', 'MARISCAL NIETO', 'A', 'P', 18),
(181, '1802', 'GENERAL SANCHEZ CERRO', 'A', 'P', 18),
(182, '1803', 'ILO', 'A', 'P', 18),
(183, '1901', 'PASCO', 'A', 'P', 19),
(184, '1902', 'DANIEL ALCIDES CARRION', 'A', 'P', 19),
(185, '1903', 'OXAPAMPA', 'A', 'P', 19),
(186, '2001', 'PIURA', 'A', 'P', 20),
(187, '2002', 'AYABACA', 'A', 'P', 20),
(188, '2003', 'HUANCABAMBA', 'A', 'P', 20),
(189, '2004', 'MORROPON', 'A', 'P', 20),
(190, '2005', 'PAITA', 'A', 'P', 20),
(191, '2006', 'SULLANA', 'A', 'P', 20),
(192, '2007', 'TALARA', 'A', 'P', 20),
(193, '2008', 'SECHURA', 'A', 'P', 20),
(194, '2101', 'PUNO', 'A', 'P', 21),
(195, '2102', 'AZANGARO', 'A', 'P', 21),
(196, '2103', 'CARABAYA', 'A', 'P', 21),
(197, '2104', 'CHUCUITO', 'A', 'P', 21),
(198, '2105', 'EL COLLAO', 'A', 'P', 21),
(199, '2106', 'HUANCANE', 'A', 'P', 21),
(200, '2107', 'LAMPA', 'A', 'P', 21),
(201, '2108', 'MELGAR', 'A', 'P', 21),
(202, '2109', 'MOHO', 'A', 'P', 21),
(203, '2110', 'SAN ANTONIO DE PUTINA', 'A', 'P', 21),
(204, '2111', 'SAN ROMAN', 'A', 'P', 21),
(205, '2112', 'SANDIA', 'A', 'P', 21),
(206, '2113', 'YUNGUYO', 'A', 'P', 21),
(207, '2201', 'MOYOBAMBA', 'A', 'P', 22),
(208, '2202', 'BELLAVISTA', 'A', 'P', 22),
(209, '2203', 'EL DORADO', 'A', 'P', 22),
(210, '2204', 'HUALLAGA', 'A', 'P', 22),
(211, '2205', 'LAMAS', 'A', 'P', 22),
(212, '2206', 'MARISCAL CACERES', 'A', 'P', 22),
(213, '2207', 'PICOTA', 'A', 'P', 22),
(214, '2208', 'RIOJA', 'A', 'P', 22),
(215, '2209', 'SAN MARTIN', 'A', 'P', 22),
(216, '2210', 'TOCACHE', 'A', 'P', 22),
(217, '2301', 'TACNA', 'A', 'P', 23),
(218, '2302', 'CANDARAVE', 'A', 'P', 23),
(219, '2303', 'JORGE BASADRE', 'A', 'P', 23),
(220, '2304', 'TARATA', 'A', 'P', 23),
(221, '2401', 'TUMBES', 'A', 'P', 24),
(222, '2402', 'CONTRALMIRANTE VILLAR', 'A', 'P', 24),
(223, '2403', 'ZARUMILLA', 'A', 'P', 24),
(224, '2501', 'CORONEL PORTILLO', 'A', 'P', 25),
(225, '2502', 'ATALAYA', 'A', 'P', 25),
(226, '2503', 'PADRE ABAD', 'A', 'P', 25),
(227, '2504', 'PURUS', 'A', 'P', 25),
(287, '010101', 'CHACHAPOYAS', 'A', 'I', 32),
(288, '010102', 'ASUNCION', 'A', 'I', 32),
(289, '010103', 'BALSAS', 'A', 'I', 32),
(290, '010104', 'CHETO', 'A', 'I', 32),
(291, '010105', 'CHILIQUIN', 'A', 'I', 32),
(292, '010106', 'CHUQUIBAMBA', 'A', 'I', 32),
(293, '010107', 'GRANADA', 'A', 'I', 32),
(294, '010108', 'HUANCAS', 'A', 'I', 32),
(295, '010109', 'LA JALCA', 'A', 'I', 32),
(296, '010110', 'LEIMEBAMBA', 'A', 'I', 32),
(297, '010111', 'LEVANTO', 'A', 'I', 32),
(298, '010112', 'MAGDALENA', 'A', 'I', 32),
(299, '010113', 'MARISCAL CASTILLA', 'A', 'I', 32),
(300, '010114', 'MOLINOPAMPA', 'A', 'I', 32),
(301, '010115', 'MONTEVIDEO', 'A', 'I', 32),
(302, '010116', 'OLLEROS', 'A', 'I', 32),
(303, '010117', 'QUINJALCA', 'A', 'I', 32),
(304, '010118', 'SAN FRANCISCO DE DAGUAS', 'A', 'I', 32),
(305, '010119', 'SAN ISIDRO DE MAINO', 'A', 'I', 32),
(306, '010120', 'SOLOCO', 'A', 'I', 32),
(307, '010121', 'SONCHE', 'A', 'I', 32),
(308, '010201', 'BAGUA', 'A', 'I', 33),
(309, '010202', 'ARAMANGO', 'A', 'I', 33),
(310, '010203', 'COPALLIN', 'A', 'I', 33),
(311, '010204', 'EL PARCO', 'A', 'I', 33),
(312, '010205', 'IMAZA', 'A', 'I', 33),
(313, '010206', 'LA PECA', 'A', 'I', 33),
(314, '010301', 'JUMBILLA', 'A', 'I', 34),
(315, '010302', 'CHISQUILLA', 'A', 'I', 34),
(316, '010303', 'CHURUJA', 'A', 'I', 34),
(317, '010304', 'COROSHA', 'A', 'I', 34),
(318, '010305', 'CUISPES', 'A', 'I', 34),
(319, '010306', 'FLORIDA', 'A', 'I', 34),
(320, '010307', 'JAZAN', 'A', 'I', 34),
(321, '010308', 'RECTA', 'A', 'I', 34),
(322, '010309', 'SAN CARLOS', 'A', 'I', 34),
(323, '010310', 'SHIPASBAMBA', 'A', 'I', 34),
(324, '010311', 'VALERA', 'A', 'I', 34),
(325, '010312', 'YAMBRASBAMBA', 'A', 'I', 34),
(326, '010401', 'NIEVA', 'A', 'I', 35),
(327, '010402', 'EL CENEPA', 'A', 'I', 35),
(328, '010403', 'RIO SANTIAGO', 'A', 'I', 35),
(329, '010501', 'LAMUD', 'A', 'I', 36),
(330, '010502', 'CAMPORREDONDO', 'A', 'I', 36),
(331, '010503', 'COCABAMBA', 'A', 'I', 36),
(332, '010504', 'COLCAMAR', 'A', 'I', 36),
(333, '010505', 'CONILA', 'A', 'I', 36),
(334, '010506', 'INGUILPATA', 'A', 'I', 36),
(335, '010507', 'LONGUITA', 'A', 'I', 36),
(336, '010508', 'LONYA CHICO', 'A', 'I', 36),
(337, '010509', 'LUYA', 'A', 'I', 36),
(338, '010510', 'LUYA VIEJO', 'A', 'I', 36),
(339, '010511', 'MARIA', 'A', 'I', 36),
(340, '010512', 'OCALLI', 'A', 'I', 36),
(341, '010513', 'OCUMAL', 'A', 'I', 36),
(342, '010514', 'PISUQUIA', 'A', 'I', 36),
(343, '010515', 'PROVIDENCIA', 'A', 'I', 36),
(344, '010516', 'SAN CRISTOBAL', 'A', 'I', 36),
(345, '010517', 'SAN FRANCISCO DEL YESO', 'A', 'I', 36),
(346, '010518', 'SAN JERONIMO', 'A', 'I', 36),
(347, '010519', 'SAN JUAN DE LOPECANCHA', 'A', 'I', 36),
(348, '010520', 'SANTA CATALINA', 'A', 'I', 36),
(349, '010521', 'SANTO TOMAS', 'A', 'I', 36),
(350, '010522', 'TINGO', 'A', 'I', 36),
(351, '010523', 'TRITA', 'A', 'I', 36),
(352, '010601', 'SAN NICOLAS', 'A', 'I', 37),
(353, '010602', 'CHIRIMOTO', 'A', 'I', 37),
(354, '010603', 'COCHAMAL', 'A', 'I', 37),
(355, '010604', 'HUAMBO', 'A', 'I', 37),
(356, '010605', 'LIMABAMBA', 'A', 'I', 37),
(357, '010606', 'LONGAR', 'A', 'I', 37),
(358, '010607', 'MARISCAL BENAVIDES', 'A', 'I', 37),
(359, '010608', 'MILPUC', 'A', 'I', 37),
(360, '010609', 'OMIA', 'A', 'I', 37),
(361, '010610', 'SANTA ROSA', 'A', 'I', 37),
(362, '010611', 'TOTORA', 'A', 'I', 37),
(363, '010612', 'VISTA ALEGRE', 'A', 'I', 37),
(364, '010701', 'BAGUA GRANDE', 'A', 'I', 38),
(365, '010702', 'CAJARURO', 'A', 'I', 38),
(366, '010703', 'CUMBA', 'A', 'I', 38),
(367, '010704', 'EL MILAGRO', 'A', 'I', 38),
(368, '010705', 'JAMALCA', 'A', 'I', 38),
(369, '010706', 'LONYA GRANDE', 'A', 'I', 38),
(370, '010707', 'YAMON', 'A', 'I', 38),
(371, '020101', 'HUARAZ', 'A', 'I', 39),
(372, '020102', 'COCHABAMBA', 'A', 'I', 39),
(373, '020103', 'COLCABAMBA', 'A', 'I', 39),
(374, '020104', 'HUANCHAY', 'A', 'I', 39),
(375, '020105', 'INDEPENDENCIA', 'A', 'I', 39),
(376, '020106', 'JANGAS', 'A', 'I', 39),
(377, '020107', 'LA LIBERTAD', 'A', 'I', 39),
(378, '020108', 'OLLEROS', 'A', 'I', 39),
(379, '020109', 'PAMPAS GRANDE', 'A', 'I', 39),
(380, '020110', 'PARIACOTO', 'A', 'I', 39),
(381, '020111', 'PIRA', 'A', 'I', 39),
(382, '020112', 'TARICA', 'A', 'I', 39),
(383, '020201', 'AIJA', 'A', 'I', 40),
(384, '020202', 'CORIS', 'A', 'I', 40),
(385, '020203', 'HUACLLAN', 'A', 'I', 40),
(386, '020204', 'LA MERCED', 'A', 'I', 40),
(387, '020205', 'SUCCHA', 'A', 'I', 40),
(388, '020301', 'LLAMELLIN', 'A', 'I', 41),
(389, '020302', 'ACZO', 'A', 'I', 41),
(390, '020303', 'CHACCHO', 'A', 'I', 41),
(391, '020304', 'CHINGAS', 'A', 'I', 41),
(392, '020305', 'MIRGAS', 'A', 'I', 41),
(393, '020306', 'SAN JUAN DE RONTOY', 'A', 'I', 41),
(394, '020401', 'CHACAS', 'A', 'I', 42),
(395, '020402', 'ACOCHACA', 'A', 'I', 42),
(396, '020501', 'CHIQUIAN', 'A', 'I', 43),
(397, '020502', 'ABELARDO PARDO LEZAMETA', 'A', 'I', 43),
(398, '020503', 'ANTONIO RAYMONDI', 'A', 'I', 43),
(399, '020504', 'AQUIA', 'A', 'I', 43),
(400, '020505', 'CAJACAY', 'A', 'I', 43),
(401, '020506', 'CANIS', 'A', 'I', 43),
(402, '020507', 'COLQUIOC', 'A', 'I', 43),
(403, '020508', 'HUALLANCA', 'A', 'I', 43),
(404, '020509', 'HUASTA', 'A', 'I', 43),
(405, '020510', 'HUAYLLACAYAN', 'A', 'I', 43),
(406, '020511', 'LA PRIMAVERA', 'A', 'I', 43),
(407, '020512', 'MANGAS', 'A', 'I', 43),
(408, '020513', 'PACLLON', 'A', 'I', 43),
(409, '020514', 'SAN MIGUEL DE CORPANQUI', 'A', 'I', 43),
(410, '020515', 'TICLLOS', 'A', 'I', 43),
(411, '020601', 'CARHUAZ', 'A', 'I', 44),
(412, '020602', 'ACOPAMPA', 'A', 'I', 44),
(413, '020603', 'AMASHCA', 'A', 'I', 44),
(414, '020604', 'ANTA', 'A', 'I', 44),
(415, '020605', 'ATAQUERO', 'A', 'I', 44),
(416, '020606', 'MARCARA', 'A', 'I', 44),
(417, '020607', 'PARIAHUANCA', 'A', 'I', 44),
(418, '020608', 'SAN MIGUEL DE ACO', 'A', 'I', 44),
(419, '020609', 'SHILLA', 'A', 'I', 44),
(420, '020610', 'TINCO', 'A', 'I', 44),
(421, '020611', 'YUNGAR', 'A', 'I', 44),
(422, '020701', 'SAN LUIS', 'A', 'I', 45),
(423, '020702', 'SAN NICOLAS', 'A', 'I', 45),
(424, '020703', 'YAUYA', 'A', 'I', 45),
(425, '020801', 'CASMA', 'A', 'I', 46),
(426, '020802', 'BUENA VISTA ALTA', 'A', 'I', 46),
(427, '020803', 'COMANDANTE NOEL', 'A', 'I', 46),
(428, '020804', 'YAUTAN', 'A', 'I', 46),
(429, '020901', 'CORONGO', 'A', 'I', 47),
(430, '020902', 'ACO', 'A', 'I', 47),
(431, '020903', 'BAMBAS', 'A', 'I', 47),
(432, '020904', 'CUSCA', 'A', 'I', 47),
(433, '020905', 'LA PAMPA', 'A', 'I', 47),
(434, '020906', 'YANAC', 'A', 'I', 47),
(435, '020907', 'YUPAN', 'A', 'I', 47),
(436, '021001', 'HUARI', 'A', 'I', 48),
(437, '021002', 'ANRA', 'A', 'I', 48),
(438, '021003', 'CAJAY', 'A', 'I', 48),
(439, '021004', 'CHAVIN DE HUANTAR', 'A', 'I', 48),
(440, '021005', 'HUACACHI', 'A', 'I', 48),
(441, '021006', 'HUACCHIS', 'A', 'I', 48),
(442, '021007', 'HUACHIS', 'A', 'I', 48),
(443, '021008', 'HUANTAR', 'A', 'I', 48),
(444, '021009', 'MASIN', 'A', 'I', 48),
(445, '021010', 'PAUCAS', 'A', 'I', 48),
(446, '021011', 'PONTO', 'A', 'I', 48),
(447, '021012', 'RAHUAPAMPA', 'A', 'I', 48),
(448, '021013', 'RAPAYAN', 'A', 'I', 48),
(449, '021014', 'SAN MARCOS', 'A', 'I', 48),
(450, '021015', 'SAN PEDRO DE CHANA', 'A', 'I', 48),
(451, '021016', 'UCO', 'A', 'I', 48),
(452, '021101', 'HUARMEY', 'A', 'I', 49),
(453, '021102', 'COCHAPETI', 'A', 'I', 49),
(454, '021103', 'CULEBRAS', 'A', 'I', 49),
(455, '021104', 'HUAYAN', 'A', 'I', 49),
(456, '021105', 'MALVAS', 'A', 'I', 49),
(457, '021201', 'CARAZ', 'A', 'I', 50),
(458, '021202', 'HUALLANCA', 'A', 'I', 50),
(459, '021203', 'HUATA', 'A', 'I', 50),
(460, '021204', 'HUAYLAS', 'A', 'I', 50),
(461, '021205', 'MATO', 'A', 'I', 50),
(462, '021206', 'PAMPAROMAS', 'A', 'I', 50),
(463, '021207', 'PUEBLO LIBRE', 'A', 'I', 50),
(464, '021208', 'SANTA CRUZ', 'A', 'I', 50),
(465, '021209', 'SANTO TORIBIO', 'A', 'I', 50),
(466, '021210', 'YURACMARCA', 'A', 'I', 50),
(467, '021301', 'PISCOBAMBA', 'A', 'I', 51),
(468, '021302', 'CASCA', 'A', 'I', 51),
(469, '021303', 'ELEAZAR GUZMAN BARRON', 'A', 'I', 51),
(470, '021304', 'FIDEL OLIVAS ESCUDERO', 'A', 'I', 51),
(471, '021305', 'LLAMA', 'A', 'I', 51),
(472, '021306', 'LLUMPA', 'A', 'I', 51),
(473, '021307', 'LUCMA', 'A', 'I', 51),
(474, '021308', 'MUSGA', 'A', 'I', 51),
(475, '021401', 'OCROS', 'A', 'I', 52),
(476, '021402', 'ACAS', 'A', 'I', 52),
(477, '021403', 'CAJAMARQUILLA', 'A', 'I', 52),
(478, '021404', 'CARHUAPAMPA', 'A', 'I', 52),
(479, '021405', 'COCHAS', 'A', 'I', 52),
(480, '021406', 'CONGAS', 'A', 'I', 52),
(481, '021407', 'LLIPA', 'A', 'I', 52),
(482, '021408', 'SAN CRISTOBAL DE RAJAN', 'A', 'I', 52),
(483, '021409', 'SAN PEDRO', 'A', 'I', 52),
(484, '021410', 'SANTIAGO DE CHILCAS', 'A', 'I', 52),
(485, '021501', 'CABANA', 'A', 'I', 53),
(486, '021502', 'BOLOGNESI', 'A', 'I', 53),
(487, '021503', 'CONCHUCOS', 'A', 'I', 53),
(488, '021504', 'HUACASCHUQUE', 'A', 'I', 53),
(489, '021505', 'HUANDOVAL', 'A', 'I', 53),
(490, '021506', 'LACABAMBA', 'A', 'I', 53),
(491, '021507', 'LLAPO', 'A', 'I', 53),
(492, '021508', 'PALLASCA', 'A', 'I', 53),
(493, '021509', 'PAMPAS', 'A', 'I', 53),
(494, '021510', 'SANTA ROSA', 'A', 'I', 53),
(495, '021511', 'TAUCA', 'A', 'I', 53),
(496, '021601', 'POMABAMBA', 'A', 'I', 54),
(497, '021602', 'HUAYLLAN', 'A', 'I', 54),
(498, '021603', 'PAROBAMBA', 'A', 'I', 54),
(499, '021604', 'QUINUABAMBA', 'A', 'I', 54),
(500, '021701', 'RECUAY', 'A', 'I', 55),
(501, '021702', 'CATAC', 'A', 'I', 55),
(502, '021703', 'COTAPARACO', 'A', 'I', 55),
(503, '021704', 'HUAYLLAPAMPA', 'A', 'I', 55),
(504, '021705', 'LLACLLIN', 'A', 'I', 55),
(505, '021706', 'MARCA', 'A', 'I', 55),
(506, '021707', 'PAMPAS CHICO', 'A', 'I', 55),
(507, '021708', 'PARARIN', 'A', 'I', 55),
(508, '021709', 'TAPACOCHA', 'A', 'I', 55),
(509, '021710', 'TICAPAMPA', 'A', 'I', 55),
(510, '021801', 'CHIMBOTE', 'A', 'I', 56),
(511, '021802', 'CACERES DEL PERU', 'A', 'I', 56),
(512, '021803', 'COISHCO', 'A', 'I', 56),
(513, '021804', 'MACATE', 'A', 'I', 56),
(514, '021805', 'MORO', 'A', 'I', 56),
(515, '021806', 'NEPE¥A', 'A', 'I', 56),
(516, '021807', 'SAMANCO', 'A', 'I', 56),
(517, '021808', 'SANTA', 'A', 'I', 56),
(518, '021809', 'NUEVO CHIMBOTE', 'A', 'I', 56),
(519, '021901', 'SIHUAS', 'A', 'I', 57),
(520, '021902', 'ACOBAMBA', 'A', 'I', 57),
(521, '021903', 'ALFONSO UGARTE', 'A', 'I', 57),
(522, '021904', 'CASHAPAMPA', 'A', 'I', 57),
(523, '021905', 'CHINGALPO', 'A', 'I', 57),
(524, '021906', 'HUAYLLABAMBA', 'A', 'I', 57),
(525, '021907', 'QUICHES', 'A', 'I', 57),
(526, '021908', 'RAGASH', 'A', 'I', 57),
(527, '021909', 'SAN JUAN', 'A', 'I', 57),
(528, '021910', 'SICSIBAMBA', 'A', 'I', 57),
(529, '022001', 'YUNGAY', 'A', 'I', 58),
(530, '022002', 'CASCAPARA', 'A', 'I', 58),
(531, '022003', 'MANCOS', 'A', 'I', 58),
(532, '022004', 'MATACOTO', 'A', 'I', 58),
(533, '022005', 'QUILLO', 'A', 'I', 58),
(534, '022006', 'RANRAHIRCA', 'A', 'I', 58),
(535, '022007', 'SHUPLUY', 'A', 'I', 58),
(536, '022008', 'YANAMA', 'A', 'I', 58),
(537, '030101', 'ABANCAY', 'A', 'I', 59),
(538, '030102', 'CHACOCHE', 'A', 'I', 59),
(539, '030103', 'CIRCA', 'A', 'I', 59),
(540, '030104', 'CURAHUASI', 'A', 'I', 59),
(541, '030105', 'HUANIPACA', 'A', 'I', 59),
(542, '030106', 'LAMBRAMA', 'A', 'I', 59),
(543, '030107', 'PICHIRHUA', 'A', 'I', 59),
(544, '030108', 'SAN PEDRO DE CACHORA', 'A', 'I', 59),
(545, '030109', 'TAMBURCO', 'A', 'I', 59),
(546, '030201', 'ANDAHUAYLAS', 'A', 'I', 60),
(547, '030202', 'ANDARAPA', 'A', 'I', 60),
(548, '030203', 'CHIARA', 'A', 'I', 60),
(549, '030204', 'HUANCARAMA', 'A', 'I', 60),
(550, '030205', 'HUANCARAY', 'A', 'I', 60),
(551, '030206', 'HUAYANA', 'A', 'I', 60),
(552, '030207', 'KISHUARA', 'A', 'I', 60),
(553, '030208', 'PACOBAMBA', 'A', 'I', 60),
(554, '030209', 'PACUCHA', 'A', 'I', 60),
(555, '030210', 'PAMPACHIRI', 'A', 'I', 60),
(556, '030211', 'POMACOCHA', 'A', 'I', 60),
(557, '030212', 'SAN ANTONIO DE CACHI', 'A', 'I', 60),
(558, '030213', 'SAN JERONIMO', 'A', 'I', 60),
(559, '030214', 'SAN MIGUEL DE CHACCRAMPA', 'A', 'I', 60),
(560, '030215', 'SANTA MARIA DE CHICMO', 'A', 'I', 60),
(561, '030216', 'TALAVERA', 'A', 'I', 60),
(562, '030217', 'TUMAY HUARACA', 'A', 'I', 60),
(563, '030218', 'TURPO', 'A', 'I', 60),
(564, '030219', 'KAQUIABAMBA', 'A', 'I', 60),
(565, '030220', 'JOSE MARIA ARGUEDAS', 'A', 'I', 60),
(566, '030301', 'ANTABAMBA', 'A', 'I', 61),
(567, '030302', 'EL ORO', 'A', 'I', 61),
(568, '030303', 'HUAQUIRCA', 'A', 'I', 61),
(569, '030304', 'JUAN ESPINOZA MEDRANO', 'A', 'I', 61),
(570, '030305', 'OROPESA', 'A', 'I', 61),
(571, '030306', 'PACHACONAS', 'A', 'I', 61),
(572, '030307', 'SABAINO', 'A', 'I', 61),
(573, '030401', 'CHALHUANCA', 'A', 'I', 62),
(574, '030402', 'CAPAYA', 'A', 'I', 62),
(575, '030403', 'CARAYBAMBA', 'A', 'I', 62),
(576, '030404', 'CHAPIMARCA', 'A', 'I', 62),
(577, '030405', 'COLCABAMBA', 'A', 'I', 62),
(578, '030406', 'COTARUSE', 'A', 'I', 62),
(579, '030407', 'IHUAYLLO', 'A', 'I', 62),
(580, '030408', 'JUSTO APU SAHUARAURA', 'A', 'I', 62),
(581, '030409', 'LUCRE', 'A', 'I', 62),
(582, '030410', 'POCOHUANCA', 'A', 'I', 62),
(583, '030411', 'SAN JUAN DE CHAC¥A', 'A', 'I', 62),
(584, '030412', 'SA¥AYCA', 'A', 'I', 62),
(585, '030413', 'SORAYA', 'A', 'I', 62),
(586, '030414', 'TAPAIRIHUA', 'A', 'I', 62),
(587, '030415', 'TINTAY', 'A', 'I', 62),
(588, '030416', 'TORAYA', 'A', 'I', 62),
(589, '030417', 'YANACA', 'A', 'I', 62),
(590, '030501', 'TAMBOBAMBA', 'A', 'I', 63),
(591, '030502', 'COTABAMBAS', 'A', 'I', 63),
(592, '030503', 'COYLLURQUI', 'A', 'I', 63),
(593, '030504', 'HAQUIRA', 'A', 'I', 63),
(594, '030505', 'MARA', 'A', 'I', 63),
(595, '030506', 'CHALLHUAHUACHO', 'A', 'I', 63),
(596, '030601', 'CHINCHEROS', 'A', 'I', 64),
(597, '030602', 'ANCO_HUALLO', 'A', 'I', 64),
(598, '030603', 'COCHARCAS', 'A', 'I', 64),
(599, '030604', 'HUACCANA', 'A', 'I', 64),
(600, '030605', 'OCOBAMBA', 'A', 'I', 64),
(601, '030606', 'ONGOY', 'A', 'I', 64),
(602, '030607', 'URANMARCA', 'A', 'I', 64),
(603, '030608', 'RANRACANCHA', 'A', 'I', 64),
(604, '030609', 'ROCCHACC', 'A', 'I', 64),
(605, '030610', 'EL PORVENIR', 'A', 'I', 64),
(606, '030611', 'LOS CHANKAS', 'A', 'I', 64),
(607, '030701', 'CHUQUIBAMBILLA', 'A', 'I', 65),
(608, '030702', 'CURPAHUASI', 'A', 'I', 65),
(609, '030703', 'GAMARRA', 'A', 'I', 65),
(610, '030704', 'HUAYLLATI', 'A', 'I', 65),
(611, '030705', 'MAMARA', 'A', 'I', 65),
(612, '030706', 'MICAELA BASTIDAS', 'A', 'I', 65),
(613, '030707', 'PATAYPAMPA', 'A', 'I', 65),
(614, '030708', 'PROGRESO', 'A', 'I', 65),
(615, '030709', 'SAN ANTONIO', 'A', 'I', 65),
(616, '030710', 'SANTA ROSA', 'A', 'I', 65),
(617, '030711', 'TURPAY', 'A', 'I', 65),
(618, '030712', 'VILCABAMBA', 'A', 'I', 65),
(619, '030713', 'VIRUNDO', 'A', 'I', 65),
(620, '030714', 'CURASCO', 'A', 'I', 65),
(621, '040101', 'AREQUIPA', 'A', 'I', 66),
(622, '040102', 'ALTO SELVA ALEGRE', 'A', 'I', 66),
(623, '040103', 'CAYMA', 'A', 'I', 66),
(624, '040104', 'CERRO COLORADO', 'A', 'I', 66),
(625, '040105', 'CHARACATO', 'A', 'I', 66),
(626, '040106', 'CHIGUATA', 'A', 'I', 66),
(627, '040107', 'JACOBO HUNTER', 'A', 'I', 66),
(628, '040108', 'LA JOYA', 'A', 'I', 66),
(629, '040109', 'MARIANO MELGAR', 'A', 'I', 66),
(630, '040110', 'MIRAFLORES', 'A', 'I', 66),
(631, '040111', 'MOLLEBAYA', 'A', 'I', 66),
(632, '040112', 'PAUCARPATA', 'A', 'I', 66),
(633, '040113', 'POCSI', 'A', 'I', 66),
(634, '040114', 'POLOBAYA', 'A', 'I', 66),
(635, '040115', 'QUEQUE¥A', 'A', 'I', 66),
(636, '040116', 'SABANDIA', 'A', 'I', 66),
(637, '040117', 'SACHACA', 'A', 'I', 66),
(638, '040118', 'SAN JUAN DE SIGUAS', 'A', 'I', 66),
(639, '040119', 'SAN JUAN DE TARUCANI', 'A', 'I', 66),
(640, '040120', 'SANTA ISABEL DE SIGUAS', 'A', 'I', 66),
(641, '040121', 'SANTA RITA DE SIGUAS', 'A', 'I', 66),
(642, '040122', 'SOCABAYA', 'A', 'I', 66),
(643, '040123', 'TIABAYA', 'A', 'I', 66),
(644, '040124', 'UCHUMAYO', 'A', 'I', 66),
(645, '040125', 'VITOR', 'A', 'I', 66),
(646, '040126', 'YANAHUARA', 'A', 'I', 66),
(647, '040127', 'YARABAMBA', 'A', 'I', 66),
(648, '040128', 'YURA', 'A', 'I', 66),
(649, '040129', 'JOSE LUIS BUSTAMANTE Y RIVERO', 'A', 'I', 66),
(650, '040201', 'CAMANA', 'A', 'I', 67),
(651, '040202', 'JOSE MARIA QUIMPER', 'A', 'I', 67),
(652, '040203', 'MARIANO NICOLAS VALCARCEL', 'A', 'I', 67),
(653, '040204', 'MARISCAL CACERES', 'A', 'I', 67),
(654, '040205', 'NICOLAS DE PIEROLA', 'A', 'I', 67),
(655, '040206', 'OCO¥A', 'A', 'I', 67),
(656, '040207', 'QUILCA', 'A', 'I', 67),
(657, '040208', 'SAMUEL PASTOR', 'A', 'I', 67),
(658, '040301', 'CARAVELI', 'A', 'I', 68),
(659, '040302', 'ACARI', 'A', 'I', 68),
(660, '040303', 'ATICO', 'A', 'I', 68),
(661, '040304', 'ATIQUIPA', 'A', 'I', 68),
(662, '040305', 'BELLA UNION', 'A', 'I', 68),
(663, '040306', 'CAHUACHO', 'A', 'I', 68),
(664, '040307', 'CHALA', 'A', 'I', 68),
(665, '040308', 'CHAPARRA', 'A', 'I', 68),
(666, '040309', 'HUANUHUANU', 'A', 'I', 68),
(667, '040310', 'JAQUI', 'A', 'I', 68),
(668, '040311', 'LOMAS', 'A', 'I', 68),
(669, '040312', 'QUICACHA', 'A', 'I', 68),
(670, '040313', 'YAUCA', 'A', 'I', 68),
(671, '040401', 'APLAO', 'A', 'I', 69),
(672, '040402', 'ANDAGUA', 'A', 'I', 69),
(673, '040403', 'AYO', 'A', 'I', 69),
(674, '040404', 'CHACHAS', 'A', 'I', 69),
(675, '040405', 'CHILCAYMARCA', 'A', 'I', 69),
(676, '040406', 'CHOCO', 'A', 'I', 69),
(677, '040407', 'HUANCARQUI', 'A', 'I', 69),
(678, '040408', 'MACHAGUAY', 'A', 'I', 69),
(679, '040409', 'ORCOPAMPA', 'A', 'I', 69),
(680, '040410', 'PAMPACOLCA', 'A', 'I', 69),
(681, '040411', 'TIPAN', 'A', 'I', 69),
(682, '040412', 'U¥ON', 'A', 'I', 69),
(683, '040413', 'URACA', 'A', 'I', 69),
(684, '040414', 'VIRACO', 'A', 'I', 69),
(685, '040501', 'CHIVAY', 'A', 'I', 70),
(686, '040502', 'ACHOMA', 'A', 'I', 70),
(687, '040503', 'CABANACONDE', 'A', 'I', 70),
(688, '040504', 'CALLALLI', 'A', 'I', 70),
(689, '040505', 'CAYLLOMA', 'A', 'I', 70),
(690, '040506', 'COPORAQUE', 'A', 'I', 70),
(691, '040507', 'HUAMBO', 'A', 'I', 70),
(692, '040508', 'HUANCA', 'A', 'I', 70),
(693, '040509', 'ICHUPAMPA', 'A', 'I', 70),
(694, '040510', 'LARI', 'A', 'I', 70),
(695, '040511', 'LLUTA', 'A', 'I', 70),
(696, '040512', 'MACA', 'A', 'I', 70),
(697, '040513', 'MADRIGAL', 'A', 'I', 70),
(698, '040514', 'SAN ANTONIO DE CHUCA', 'A', 'I', 70),
(699, '040515', 'SIBAYO', 'A', 'I', 70),
(700, '040516', 'TAPAY', 'A', 'I', 70),
(701, '040517', 'TISCO', 'A', 'I', 70),
(702, '040518', 'TUTI', 'A', 'I', 70),
(703, '040519', 'YANQUE', 'A', 'I', 70),
(704, '040520', 'MAJES', 'A', 'I', 70),
(705, '040601', 'CHUQUIBAMBA', 'A', 'I', 71),
(706, '040602', 'ANDARAY', 'A', 'I', 71),
(707, '040603', 'CAYARANI', 'A', 'I', 71),
(708, '040604', 'CHICHAS', 'A', 'I', 71),
(709, '040605', 'IRAY', 'A', 'I', 71),
(710, '040606', 'RIO GRANDE', 'A', 'I', 71),
(711, '040607', 'SALAMANCA', 'A', 'I', 71),
(712, '040608', 'YANAQUIHUA', 'A', 'I', 71),
(713, '040701', 'MOLLENDO', 'A', 'I', 72),
(714, '040702', 'COCACHACRA', 'A', 'I', 72),
(715, '040703', 'DEAN VALDIVIA', 'A', 'I', 72),
(716, '040704', 'ISLAY', 'A', 'I', 72),
(717, '040705', 'MEJIA', 'A', 'I', 72),
(718, '040706', 'PUNTA DE BOMBON', 'A', 'I', 72),
(719, '040801', 'COTAHUASI', 'A', 'I', 73),
(720, '040802', 'ALCA', 'A', 'I', 73),
(721, '040803', 'CHARCANA', 'A', 'I', 73),
(722, '040804', 'HUAYNACOTAS', 'A', 'I', 73),
(723, '040805', 'PAMPAMARCA', 'A', 'I', 73),
(724, '040806', 'PUYCA', 'A', 'I', 73),
(725, '040807', 'QUECHUALLA', 'A', 'I', 73),
(726, '040808', 'SAYLA', 'A', 'I', 73),
(727, '040809', 'TAURIA', 'A', 'I', 73),
(728, '040810', 'TOMEPAMPA', 'A', 'I', 73),
(729, '040811', 'TORO', 'A', 'I', 73),
(730, '050101', 'AYACUCHO', 'A', 'I', 74),
(731, '050102', 'ACOCRO', 'A', 'I', 74),
(732, '050103', 'ACOS VINCHOS', 'A', 'I', 74),
(733, '050104', 'CARMEN ALTO', 'A', 'I', 74),
(734, '050105', 'CHIARA', 'A', 'I', 74),
(735, '050106', 'OCROS', 'A', 'I', 74),
(736, '050107', 'PACAYCASA', 'A', 'I', 74),
(737, '050108', 'QUINUA', 'A', 'I', 74),
(738, '050109', 'SAN JOSE DE TICLLAS', 'A', 'I', 74),
(739, '050110', 'SAN JUAN BAUTISTA', 'A', 'I', 74),
(740, '050111', 'SANTIAGO DE PISCHA', 'A', 'I', 74),
(741, '050112', 'SOCOS', 'A', 'I', 74),
(742, '050113', 'TAMBILLO', 'A', 'I', 74),
(743, '050114', 'VINCHOS', 'A', 'I', 74),
(744, '050115', 'JESUS NAZARENO', 'A', 'I', 74),
(745, '050116', 'ANDRES AVELINO CACERES DORREGARAY', 'A', 'I', 74),
(746, '050201', 'CANGALLO', 'A', 'I', 75),
(747, '050202', 'CHUSCHI', 'A', 'I', 75),
(748, '050203', 'LOS MOROCHUCOS', 'A', 'I', 75),
(749, '050204', 'MARIA PARADO DE BELLIDO', 'A', 'I', 75),
(750, '050205', 'PARAS', 'A', 'I', 75),
(751, '050206', 'TOTOS', 'A', 'I', 75),
(752, '050301', 'SANCOS', 'A', 'I', 76),
(753, '050302', 'CARAPO', 'A', 'I', 76),
(754, '050303', 'SACSAMARCA', 'A', 'I', 76),
(755, '050304', 'SANTIAGO DE LUCANAMARCA', 'A', 'I', 76),
(756, '050401', 'HUANTA', 'A', 'I', 77),
(757, '050402', 'AYAHUANCO', 'A', 'I', 77),
(758, '050403', 'HUAMANGUILLA', 'A', 'I', 77),
(759, '050404', 'IGUAIN', 'A', 'I', 77),
(760, '050405', 'LURICOCHA', 'A', 'I', 77),
(761, '050406', 'SANTILLANA', 'A', 'I', 77),
(762, '050407', 'SIVIA', 'A', 'I', 77),
(763, '050408', 'LLOCHEGUA', 'A', 'I', 77),
(764, '050409', 'CANAYRE', 'A', 'I', 77),
(765, '050410', 'UCHURACCAY', 'A', 'I', 77),
(766, '050411', 'PUCACOLPA', 'A', 'I', 77),
(767, '050412', 'CHACA', 'A', 'I', 77),
(768, '050501', 'SAN MIGUEL', 'A', 'I', 78),
(769, '050502', 'ANCO', 'A', 'I', 78),
(770, '050503', 'AYNA', 'A', 'I', 78),
(771, '050504', 'CHILCAS', 'A', 'I', 78),
(772, '050505', 'CHUNGUI', 'A', 'I', 78),
(773, '050506', 'LUIS CARRANZA', 'A', 'I', 78),
(774, '050507', 'SANTA ROSA', 'A', 'I', 78),
(775, '050508', 'TAMBO', 'A', 'I', 78),
(776, '050509', 'SAMUGARI', 'A', 'I', 78),
(777, '050510', 'ANCHIHUAY', 'A', 'I', 78),
(778, '050511', 'ORONCCOY', 'A', 'I', 78),
(779, '050601', 'PUQUIO', 'A', 'I', 79),
(780, '050602', 'AUCARA', 'A', 'I', 79),
(781, '050603', 'CABANA', 'A', 'I', 79),
(782, '050604', 'CARMEN SALCEDO', 'A', 'I', 79),
(783, '050605', 'CHAVI¥A', 'A', 'I', 79),
(784, '050606', 'CHIPAO', 'A', 'I', 79),
(785, '050607', 'HUAC-HUAS', 'A', 'I', 79),
(786, '050608', 'LARAMATE', 'A', 'I', 79),
(787, '050609', 'LEONCIO PRADO', 'A', 'I', 79),
(788, '050610', 'LLAUTA', 'A', 'I', 79),
(789, '050611', 'LUCANAS', 'A', 'I', 79),
(790, '050612', 'OCA¥A', 'A', 'I', 79),
(791, '050613', 'OTOCA', 'A', 'I', 79),
(792, '050614', 'SAISA', 'A', 'I', 79),
(793, '050615', 'SAN CRISTOBAL', 'A', 'I', 79),
(794, '050616', 'SAN JUAN', 'A', 'I', 79),
(795, '050617', 'SAN PEDRO', 'A', 'I', 79),
(796, '050618', 'SAN PEDRO DE PALCO', 'A', 'I', 79),
(797, '050619', 'SANCOS', 'A', 'I', 79),
(798, '050620', 'SANTA ANA DE HUAYCAHUACHO', 'A', 'I', 79),
(799, '050621', 'SANTA LUCIA', 'A', 'I', 79),
(800, '050701', 'CORACORA', 'A', 'I', 80),
(801, '050702', 'CHUMPI', 'A', 'I', 80),
(802, '050703', 'CORONEL CASTA¥EDA', 'A', 'I', 80),
(803, '050704', 'PACAPAUSA', 'A', 'I', 80),
(804, '050705', 'PULLO', 'A', 'I', 80),
(805, '050706', 'PUYUSCA', 'A', 'I', 80),
(806, '050707', 'SAN FRANCISCO DE RAVACAYCO', 'A', 'I', 80),
(807, '050708', 'UPAHUACHO', 'A', 'I', 80),
(808, '050801', 'PAUSA', 'A', 'I', 81),
(809, '050802', 'COLTA', 'A', 'I', 81),
(810, '050803', 'CORCULLA', 'A', 'I', 81),
(811, '050804', 'LAMPA', 'A', 'I', 81),
(812, '050805', 'MARCABAMBA', 'A', 'I', 81),
(813, '050806', 'OYOLO', 'A', 'I', 81),
(814, '050807', 'PARARCA', 'A', 'I', 81),
(815, '050808', 'SAN JAVIER DE ALPABAMBA', 'A', 'I', 81),
(816, '050809', 'SAN JOSE DE USHUA', 'A', 'I', 81),
(817, '050810', 'SARA SARA', 'A', 'I', 81),
(818, '050901', 'QUEROBAMBA', 'A', 'I', 82),
(819, '050902', 'BELEN', 'A', 'I', 82),
(820, '050903', 'CHALCOS', 'A', 'I', 82),
(821, '050904', 'CHILCAYOC', 'A', 'I', 82),
(822, '050905', 'HUACA¥A', 'A', 'I', 82),
(823, '050906', 'MORCOLLA', 'A', 'I', 82),
(824, '050907', 'PAICO', 'A', 'I', 82),
(825, '050908', 'SAN PEDRO DE LARCAY', 'A', 'I', 82),
(826, '050909', 'SAN SALVADOR DE QUIJE', 'A', 'I', 82),
(827, '050910', 'SANTIAGO DE PAUCARAY', 'A', 'I', 82),
(828, '050911', 'SORAS', 'A', 'I', 82),
(829, '051001', 'HUANCAPI', 'A', 'I', 83),
(830, '051002', 'ALCAMENCA', 'A', 'I', 83),
(831, '051003', 'APONGO', 'A', 'I', 83),
(832, '051004', 'ASQUIPATA', 'A', 'I', 83),
(833, '051005', 'CANARIA', 'A', 'I', 83),
(834, '051006', 'CAYARA', 'A', 'I', 83),
(835, '051007', 'COLCA', 'A', 'I', 83),
(836, '051008', 'HUAMANQUIQUIA', 'A', 'I', 83),
(837, '051009', 'HUANCARAYLLA', 'A', 'I', 83),
(838, '051010', 'HUALLA', 'A', 'I', 83),
(839, '051011', 'SARHUA', 'A', 'I', 83),
(840, '051012', 'VILCANCHOS', 'A', 'I', 83),
(841, '051101', 'VILCAS HUAMAN', 'A', 'I', 84),
(842, '051102', 'ACCOMARCA', 'A', 'I', 84),
(843, '051103', 'CARHUANCA', 'A', 'I', 84),
(844, '051104', 'CONCEPCION', 'A', 'I', 84),
(845, '051105', 'HUAMBALPA', 'A', 'I', 84),
(846, '051106', 'INDEPENDENCIA', 'A', 'I', 84),
(847, '051107', 'SAURAMA', 'A', 'I', 84),
(848, '051108', 'VISCHONGO', 'A', 'I', 84),
(849, '060101', 'CAJAMARCA', 'A', 'I', 85),
(850, '060102', 'ASUNCION', 'A', 'I', 85),
(851, '060103', 'CHETILLA', 'A', 'I', 85),
(852, '060104', 'COSPAN', 'A', 'I', 85),
(853, '060105', 'ENCA¥ADA', 'A', 'I', 85),
(854, '060106', 'JESUS', 'A', 'I', 85),
(855, '060107', 'LLACANORA', 'A', 'I', 85),
(856, '060108', 'LOS BA¥OS DEL INCA', 'A', 'I', 85),
(857, '060109', 'MAGDALENA', 'A', 'I', 85),
(858, '060110', 'MATARA', 'A', 'I', 85),
(859, '060111', 'NAMORA', 'A', 'I', 85),
(860, '060112', 'SAN JUAN', 'A', 'I', 85),
(861, '060201', 'CAJABAMBA', 'A', 'I', 86),
(862, '060202', 'CACHACHI', 'A', 'I', 86),
(863, '060203', 'CONDEBAMBA', 'A', 'I', 86),
(864, '060204', 'SITACOCHA', 'A', 'I', 86),
(865, '060301', 'CELENDIN', 'A', 'I', 87),
(866, '060302', 'CHUMUCH', 'A', 'I', 87),
(867, '060303', 'CORTEGANA', 'A', 'I', 87),
(868, '060304', 'HUASMIN', 'A', 'I', 87),
(869, '060305', 'JORGE CHAVEZ', 'A', 'I', 87),
(870, '060306', 'JOSE GALVEZ', 'A', 'I', 87),
(871, '060307', 'MIGUEL IGLESIAS', 'A', 'I', 87),
(872, '060308', 'OXAMARCA', 'A', 'I', 87),
(873, '060309', 'SOROCHUCO', 'A', 'I', 87),
(874, '060310', 'SUCRE', 'A', 'I', 87),
(875, '060311', 'UTCO', 'A', 'I', 87),
(876, '060312', 'LA LIBERTAD DE PALLAN', 'A', 'I', 87),
(877, '060401', 'CHOTA', 'A', 'I', 88),
(878, '060402', 'ANGUIA', 'A', 'I', 88),
(879, '060403', 'CHADIN', 'A', 'I', 88),
(880, '060404', 'CHIGUIRIP', 'A', 'I', 88),
(881, '060405', 'CHIMBAN', 'A', 'I', 88),
(882, '060406', 'CHOROPAMPA', 'A', 'I', 88),
(883, '060407', 'COCHABAMBA', 'A', 'I', 88),
(884, '060408', 'CONCHAN', 'A', 'I', 88),
(885, '060409', 'HUAMBOS', 'A', 'I', 88),
(886, '060410', 'LAJAS', 'A', 'I', 88),
(887, '060411', 'LLAMA', 'A', 'I', 88),
(888, '060412', 'MIRACOSTA', 'A', 'I', 88),
(889, '060413', 'PACCHA', 'A', 'I', 88),
(890, '060414', 'PION', 'A', 'I', 88),
(891, '060415', 'QUEROCOTO', 'A', 'I', 88),
(892, '060416', 'SAN JUAN DE LICUPIS', 'A', 'I', 88),
(893, '060417', 'TACABAMBA', 'A', 'I', 88),
(894, '060418', 'TOCMOCHE', 'A', 'I', 88),
(895, '060419', 'CHALAMARCA', 'A', 'I', 88),
(896, '060501', 'CONTUMAZA', 'A', 'I', 89),
(897, '060502', 'CHILETE', 'A', 'I', 89),
(898, '060503', 'CUPISNIQUE', 'A', 'I', 89),
(899, '060504', 'GUZMANGO', 'A', 'I', 89),
(900, '060505', 'SAN BENITO', 'A', 'I', 89),
(901, '060506', 'SANTA CRUZ DE TOLED', 'A', 'I', 89),
(902, '060507', 'TANTARICA', 'A', 'I', 89),
(903, '060508', 'YONAN', 'A', 'I', 89),
(904, '060601', 'CUTERVO', 'A', 'I', 90),
(905, '060602', 'CALLAYUC', 'A', 'I', 90),
(906, '060603', 'CHOROS', 'A', 'I', 90),
(907, '060604', 'CUJILLO', 'A', 'I', 90),
(908, '060605', 'LA RAMADA', 'A', 'I', 90),
(909, '060606', 'PIMPINGOS', 'A', 'I', 90),
(910, '060607', 'QUEROCOTILLO', 'A', 'I', 90),
(911, '060608', 'SAN ANDRES DE CUTERVO', 'A', 'I', 90),
(912, '060609', 'SAN JUAN DE CUTERVO', 'A', 'I', 90),
(913, '060610', 'SAN LUIS DE LUCMA', 'A', 'I', 90),
(914, '060611', 'SANTA CRUZ', 'A', 'I', 90),
(915, '060612', 'SANTO DOMINGO DE LA CAPILLA', 'A', 'I', 90),
(916, '060613', 'SANTO TOMAS', 'A', 'I', 90),
(917, '060614', 'SOCOTA', 'A', 'I', 90),
(918, '060615', 'TORIBIO CASANOVA', 'A', 'I', 90),
(919, '060701', 'BAMBAMARCA', 'A', 'I', 91),
(920, '060702', 'CHUGUR', 'A', 'I', 91),
(921, '060703', 'HUALGAYOC', 'A', 'I', 91),
(922, '060801', 'JAEN', 'A', 'I', 92),
(923, '060802', 'BELLAVISTA', 'A', 'I', 92),
(924, '060803', 'CHONTALI', 'A', 'I', 92),
(925, '060804', 'COLASAY', 'A', 'I', 92),
(926, '060805', 'HUABAL', 'A', 'I', 92),
(927, '060806', 'LAS PIRIAS', 'A', 'I', 92),
(928, '060807', 'POMAHUACA', 'A', 'I', 92),
(929, '060808', 'PUCARA', 'A', 'I', 92),
(930, '060809', 'SALLIQUE', 'A', 'I', 92),
(931, '060810', 'SAN FELIPE', 'A', 'I', 92),
(932, '060811', 'SAN JOSE DEL ALTO', 'A', 'I', 92),
(933, '060812', 'SANTA ROSA', 'A', 'I', 92),
(934, '060901', 'SAN IGNACIO', 'A', 'I', 93),
(935, '060902', 'CHIRINOS', 'A', 'I', 93),
(936, '060903', 'HUARANGO', 'A', 'I', 93),
(937, '060904', 'LA COIPA', 'A', 'I', 93),
(938, '060905', 'NAMBALLE', 'A', 'I', 93),
(939, '060906', 'SAN JOSE DE LOURDES', 'A', 'I', 93),
(940, '060907', 'TABACONAS', 'A', 'I', 93),
(941, '061001', 'PEDRO GALVEZ', 'A', 'I', 94),
(942, '061002', 'CHANCAY', 'A', 'I', 94),
(943, '061003', 'EDUARDO VILLANUEVA', 'A', 'I', 94),
(944, '061004', 'GREGORIO PITA', 'A', 'I', 94),
(945, '061005', 'ICHOCAN', 'A', 'I', 94),
(946, '061006', 'JOSE MANUEL QUIROZ', 'A', 'I', 94),
(947, '061007', 'JOSE SABOGAL', 'A', 'I', 94),
(948, '061101', 'SAN MIGUEL', 'A', 'I', 95),
(949, '061102', 'BOLIVAR', 'A', 'I', 95),
(950, '061103', 'CALQUIS', 'A', 'I', 95),
(951, '061104', 'CATILLUC', 'A', 'I', 95),
(952, '061105', 'EL PRADO', 'A', 'I', 95),
(953, '061106', 'LA FLORIDA', 'A', 'I', 95),
(954, '061107', 'LLAPA', 'A', 'I', 95),
(955, '061108', 'NANCHOC', 'A', 'I', 95),
(956, '061109', 'NIEPOS', 'A', 'I', 95),
(957, '061110', 'SAN GREGORIO', 'A', 'I', 95),
(958, '061111', 'SAN SILVESTRE DE COCHAN', 'A', 'I', 95),
(959, '061112', 'TONGOD', 'A', 'I', 95),
(960, '061113', 'UNION AGUA BLANCA', 'A', 'I', 95),
(961, '061201', 'SAN PABLO', 'A', 'I', 96),
(962, '061202', 'SAN BERNARDINO', 'A', 'I', 96),
(963, '061203', 'SAN LUIS', 'A', 'I', 96),
(964, '061204', 'TUMBADEN', 'A', 'I', 96),
(965, '061301', 'SANTA CRUZ', 'A', 'I', 97),
(966, '061302', 'ANDABAMBA', 'A', 'I', 97),
(967, '061303', 'CATACHE', 'A', 'I', 97),
(968, '061304', 'CHANCAYBA¥OS', 'A', 'I', 97),
(969, '061305', 'LA ESPERANZA', 'A', 'I', 97),
(970, '061306', 'NINABAMBA', 'A', 'I', 97),
(971, '061307', 'PULAN', 'A', 'I', 97),
(972, '061308', 'SAUCEPAMPA', 'A', 'I', 97),
(973, '061309', 'SEXI', 'A', 'I', 97),
(974, '061310', 'UTICYACU', 'A', 'I', 97),
(975, '061311', 'YAUYUCAN', 'A', 'I', 97),
(976, '070101', 'CALLAO', 'A', 'I', 98),
(977, '070102', 'BELLAVISTA', 'A', 'I', 98),
(978, '070103', 'CARMEN DE LA LEGUA REYNOSO', 'A', 'I', 98),
(979, '070104', 'LA PERLA', 'A', 'I', 98),
(980, '070105', 'LA PUNTA', 'A', 'I', 98),
(981, '070106', 'VENTANILLA', 'A', 'I', 98),
(982, '070107', 'MI PERU', 'A', 'I', 98),
(983, '080101', 'CUSCO', 'A', 'I', 99),
(984, '080102', 'CCORCA', 'A', 'I', 99),
(985, '080103', 'POROY', 'A', 'I', 99),
(986, '080104', 'SAN JERONIMO', 'A', 'I', 99),
(987, '080105', 'SAN SEBASTIAN', 'A', 'I', 99),
(988, '080106', 'SANTIAGO', 'A', 'I', 99),
(989, '080107', 'SAYLLA', 'A', 'I', 99),
(990, '080108', 'WANCHAQ', 'A', 'I', 99),
(991, '080201', 'ACOMAYO', 'A', 'I', 100),
(992, '080202', 'ACOPIA', 'A', 'I', 100),
(993, '080203', 'ACOS', 'A', 'I', 100),
(994, '080204', 'MOSOC LLACTA', 'A', 'I', 100),
(995, '080205', 'POMACANCHI', 'A', 'I', 100),
(996, '080206', 'RONDOCAN', 'A', 'I', 100),
(997, '080207', 'SANGARARA', 'A', 'I', 100),
(998, '080301', 'ANTA', 'A', 'I', 101),
(999, '080302', 'ANCAHUASI', 'A', 'I', 101),
(1000, '080303', 'CACHIMAYO', 'A', 'I', 101),
(1001, '080304', 'CHINCHAYPUJIO', 'A', 'I', 101),
(1002, '080305', 'HUAROCONDO', 'A', 'I', 101),
(1003, '080306', 'LIMATAMBO', 'A', 'I', 101),
(1004, '080307', 'MOLLEPATA', 'A', 'I', 101),
(1005, '080308', 'PUCYURA', 'A', 'I', 101),
(1006, '080309', 'ZURITE', 'A', 'I', 101),
(1007, '080401', 'CALCA', 'A', 'I', 102),
(1008, '080402', 'COYA', 'A', 'I', 102),
(1009, '080403', 'LAMAY', 'A', 'I', 102),
(1010, '080404', 'LARES', 'A', 'I', 102),
(1011, '080405', 'PISAC', 'A', 'I', 102),
(1012, '080406', 'SAN SALVADOR', 'A', 'I', 102),
(1013, '080407', 'TARAY', 'A', 'I', 102),
(1014, '080408', 'YANATILE', 'A', 'I', 102),
(1015, '080501', 'YANAOCA', 'A', 'I', 103),
(1016, '080502', 'CHECCA', 'A', 'I', 103),
(1017, '080503', 'KUNTURKANKI', 'A', 'I', 103),
(1018, '080504', 'LANGUI', 'A', 'I', 103),
(1019, '080505', 'LAYO', 'A', 'I', 103),
(1020, '080506', 'PAMPAMARCA', 'A', 'I', 103),
(1021, '080507', 'QUEHUE', 'A', 'I', 103),
(1022, '080508', 'TUPAC AMARU', 'A', 'I', 103),
(1023, '080601', 'SICUANI', 'A', 'I', 104),
(1024, '080602', 'CHECACUPE', 'A', 'I', 104),
(1025, '080603', 'COMBAPATA', 'A', 'I', 104),
(1026, '080604', 'MARANGANI', 'A', 'I', 104),
(1027, '080605', 'PITUMARCA', 'A', 'I', 104),
(1028, '080606', 'SAN PABLO', 'A', 'I', 104),
(1029, '080607', 'SAN PEDRO', 'A', 'I', 104),
(1030, '080608', 'TINTA', 'A', 'I', 104),
(1031, '080701', 'SANTO TOMAS', 'A', 'I', 105),
(1032, '080702', 'CAPACMARCA', 'A', 'I', 105),
(1033, '080703', 'CHAMACA', 'A', 'I', 105),
(1034, '080704', 'COLQUEMARCA', 'A', 'I', 105),
(1035, '080705', 'LIVITACA', 'A', 'I', 105),
(1036, '080706', 'LLUSCO', 'A', 'I', 105),
(1037, '080707', 'QUI¥OTA', 'A', 'I', 105),
(1038, '080708', 'VELILLE', 'A', 'I', 105),
(1039, '080801', 'ESPINAR', 'A', 'I', 106),
(1040, '080802', 'CONDOROMA', 'A', 'I', 106),
(1041, '080803', 'COPORAQUE', 'A', 'I', 106),
(1042, '080804', 'OCORURO', 'A', 'I', 106),
(1043, '080805', 'PALLPATA', 'A', 'I', 106),
(1044, '080806', 'PICHIGUA', 'A', 'I', 106),
(1045, '080807', 'SUYCKUTAMBO', 'A', 'I', 106),
(1046, '080808', 'ALTO PICHIGUA', 'A', 'I', 106),
(1047, '080901', 'SANTA ANA', 'A', 'I', 107),
(1048, '080902', 'ECHARATE', 'A', 'I', 107),
(1049, '080903', 'HUAYOPATA', 'A', 'I', 107),
(1050, '080904', 'MARANURA', 'A', 'I', 107),
(1051, '080905', 'OCOBAMBA', 'A', 'I', 107),
(1052, '080906', 'QUELLOUNO', 'A', 'I', 107),
(1053, '080907', 'KIMBIRI', 'A', 'I', 107),
(1054, '080908', 'SANTA TERESA', 'A', 'I', 107),
(1055, '080909', 'VILCABAMBA', 'A', 'I', 107),
(1056, '080910', 'PICHARI', 'A', 'I', 107),
(1057, '080911', 'INKAWASI', 'A', 'I', 107),
(1058, '080912', 'VILLA VIRGEN', 'A', 'I', 107),
(1059, '080913', 'VILLA KINTIARINA', 'A', 'I', 107),
(1060, '080914', 'MEGANTONI', 'A', 'I', 107),
(1061, '081001', 'PARURO', 'A', 'I', 108),
(1062, '081002', 'ACCHA', 'A', 'I', 108),
(1063, '081003', 'CCAPI', 'A', 'I', 108),
(1064, '081004', 'COLCHA', 'A', 'I', 108),
(1065, '081005', 'HUANOQUITE', 'A', 'I', 108),
(1066, '081006', 'OMACHA', 'A', 'I', 108),
(1067, '081007', 'PACCARITAMBO', 'A', 'I', 108),
(1068, '081008', 'PILLPINTO', 'A', 'I', 108),
(1069, '081009', 'YAURISQUE', 'A', 'I', 108),
(1070, '081101', 'PAUCARTAMBO', 'A', 'I', 109),
(1071, '081102', 'CAICAY', 'A', 'I', 109),
(1072, '081103', 'CHALLABAMBA', 'A', 'I', 109),
(1073, '081104', 'COLQUEPATA', 'A', 'I', 109),
(1074, '081105', 'HUANCARANI', 'A', 'I', 109),
(1075, '081106', 'KOS¥IPATA', 'A', 'I', 109),
(1076, '081201', 'URCOS', 'A', 'I', 110),
(1077, '081202', 'ANDAHUAYLILLAS', 'A', 'I', 110),
(1078, '081203', 'CAMANTI', 'A', 'I', 110),
(1079, '081204', 'CCARHUAYO', 'A', 'I', 110),
(1080, '081205', 'CCATCA', 'A', 'I', 110),
(1081, '081206', 'CUSIPATA', 'A', 'I', 110),
(1082, '081207', 'HUARO', 'A', 'I', 110),
(1083, '081208', 'LUCRE', 'A', 'I', 110),
(1084, '081209', 'MARCAPATA', 'A', 'I', 110),
(1085, '081210', 'OCONGATE', 'A', 'I', 110),
(1086, '081211', 'OROPESA', 'A', 'I', 110),
(1087, '081212', 'QUIQUIJANA', 'A', 'I', 110),
(1088, '081301', 'URUBAMBA', 'A', 'I', 111),
(1089, '081302', 'CHINCHERO', 'A', 'I', 111),
(1090, '081303', 'HUAYLLABAMBA', 'A', 'I', 111),
(1091, '081304', 'MACHUPICCHU', 'A', 'I', 111),
(1092, '081305', 'MARAS', 'A', 'I', 111),
(1093, '081306', 'OLLANTAYTAMBO', 'A', 'I', 111),
(1094, '081307', 'YUCAY', 'A', 'I', 111),
(1095, '090101', 'HUANCAVELICA', 'A', 'I', 112),
(1096, '090102', 'ACOBAMBILLA', 'A', 'I', 112),
(1097, '090103', 'ACORIA', 'A', 'I', 112),
(1098, '090104', 'CONAYCA', 'A', 'I', 112),
(1099, '090105', 'CUENCA', 'A', 'I', 112),
(1100, '090106', 'HUACHOCOLPA', 'A', 'I', 112),
(1101, '090107', 'HUAYLLAHUARA', 'A', 'I', 112),
(1102, '090108', 'IZCUCHACA', 'A', 'I', 112),
(1103, '090109', 'LARIA', 'A', 'I', 112),
(1104, '090110', 'MANTA', 'A', 'I', 112),
(1105, '090111', 'MARISCAL CACERES', 'A', 'I', 112),
(1106, '090112', 'MOYA', 'A', 'I', 112),
(1107, '090113', 'NUEVO OCCORO', 'A', 'I', 112),
(1108, '090114', 'PALCA', 'A', 'I', 112),
(1109, '090115', 'PILCHACA', 'A', 'I', 112),
(1110, '090116', 'VILCA', 'A', 'I', 112),
(1111, '090117', 'YAULI', 'A', 'I', 112),
(1112, '090118', 'ASCENSION', 'A', 'I', 112),
(1113, '090119', 'HUANDO', 'A', 'I', 112),
(1114, '090201', 'ACOBAMBA', 'A', 'I', 113),
(1115, '090202', 'ANDABAMBA', 'A', 'I', 113),
(1116, '090203', 'ANTA', 'A', 'I', 113),
(1117, '090204', 'CAJA', 'A', 'I', 113),
(1118, '090205', 'MARCAS', 'A', 'I', 113),
(1119, '090206', 'PAUCARA', 'A', 'I', 113),
(1120, '090207', 'POMACOCHA', 'A', 'I', 113),
(1121, '090208', 'ROSARIO', 'A', 'I', 113),
(1122, '090301', 'LIRCAY', 'A', 'I', 114),
(1123, '090302', 'ANCHONGA', 'A', 'I', 114),
(1124, '090303', 'CALLANMARCA', 'A', 'I', 114),
(1125, '090304', 'CCOCHACCASA', 'A', 'I', 114),
(1126, '090305', 'CHINCHO', 'A', 'I', 114),
(1127, '090306', 'CONGALLA', 'A', 'I', 114),
(1128, '090307', 'HUANCA-HUANCA', 'A', 'I', 114),
(1129, '090308', 'HUAYLLAY GRANDE', 'A', 'I', 114),
(1130, '090309', 'JULCAMARCA', 'A', 'I', 114),
(1131, '090310', 'SAN ANTONIO DE ANTAPARCO', 'A', 'I', 114),
(1132, '090311', 'SANTO TOMAS DE PATA', 'A', 'I', 114),
(1133, '090312', 'SECCLLA', 'A', 'I', 114),
(1134, '090401', 'CASTROVIRREYNA', 'A', 'I', 115),
(1135, '090402', 'ARMA', 'A', 'I', 115),
(1136, '090403', 'AURAHUA', 'A', 'I', 115),
(1137, '090404', 'CAPILLAS', 'A', 'I', 115),
(1138, '090405', 'CHUPAMARCA', 'A', 'I', 115),
(1139, '090406', 'COCAS', 'A', 'I', 115),
(1140, '090407', 'HUACHOS', 'A', 'I', 115),
(1141, '090408', 'HUAMATAMBO', 'A', 'I', 115),
(1142, '090409', 'MOLLEPAMPA', 'A', 'I', 115),
(1143, '090410', 'SAN JUAN', 'A', 'I', 115),
(1144, '090411', 'SANTA ANA', 'A', 'I', 115),
(1145, '090412', 'TANTARA', 'A', 'I', 115),
(1146, '090413', 'TICRAPO', 'A', 'I', 115),
(1147, '090501', 'CHURCAMPA', 'A', 'I', 116),
(1148, '090502', 'ANCO', 'A', 'I', 116),
(1149, '090503', 'CHINCHIHUASI', 'A', 'I', 116),
(1150, '090504', 'EL CARMEN', 'A', 'I', 116),
(1151, '090505', 'LA MERCED', 'A', 'I', 116),
(1152, '090506', 'LOCROJA', 'A', 'I', 116),
(1153, '090507', 'PAUCARBAMBA', 'A', 'I', 116),
(1154, '090508', 'SAN MIGUEL DE MAYOCC', 'A', 'I', 116),
(1155, '090509', 'SAN PEDRO DE CORIS', 'A', 'I', 116),
(1156, '090510', 'PACHAMARCA', 'A', 'I', 116),
(1157, '090511', 'COSME', 'A', 'I', 116),
(1158, '090601', 'HUAYTARA', 'A', 'I', 117),
(1159, '090602', 'AYAVI', 'A', 'I', 117),
(1160, '090603', 'CORDOVA', 'A', 'I', 117),
(1161, '090604', 'HUAYACUNDO ARMA', 'A', 'I', 117),
(1162, '090605', 'LARAMARCA', 'A', 'I', 117),
(1163, '090606', 'OCOYO', 'A', 'I', 117),
(1164, '090607', 'PILPICHACA', 'A', 'I', 117),
(1165, '090608', 'QUERCO', 'A', 'I', 117),
(1166, '090609', 'QUITO-ARMA', 'A', 'I', 117),
(1167, '090610', 'SAN ANTONIO DE CUSICANCHA', 'A', 'I', 117),
(1168, '090611', 'SAN FRANCISCO DE SANGAYAICO', 'A', 'I', 117),
(1169, '090612', 'SAN ISIDRO', 'A', 'I', 117),
(1170, '090613', 'SANTIAGO DE CHOCORVOS', 'A', 'I', 117),
(1171, '090614', 'SANTIAGO DE QUIRAHUARA', 'A', 'I', 117),
(1172, '090615', 'SANTO DOMINGO DE CAPILLAS', 'A', 'I', 117),
(1173, '090616', 'TAMBO', 'A', 'I', 117),
(1174, '090701', 'PAMPAS', 'A', 'I', 118),
(1175, '090702', 'ACOSTAMBO', 'A', 'I', 118),
(1176, '090703', 'ACRAQUIA', 'A', 'I', 118),
(1177, '090704', 'AHUAYCHA', 'A', 'I', 118),
(1178, '090705', 'COLCABAMBA', 'A', 'I', 118),
(1179, '090706', 'DANIEL HERNANDEZ', 'A', 'I', 118),
(1180, '090707', 'HUACHOCOLPA', 'A', 'I', 118),
(1181, '090709', 'HUARIBAMBA', 'A', 'I', 118),
(1182, '090710', '¥AHUIMPUQUIO', 'A', 'I', 118),
(1183, '090711', 'PAZOS', 'A', 'I', 118),
(1184, '090713', 'QUISHUAR', 'A', 'I', 118),
(1185, '090714', 'SALCABAMBA', 'A', 'I', 118),
(1186, '090715', 'SALCAHUASI', 'A', 'I', 118),
(1187, '090716', 'SAN MARCOS DE ROCCHAC', 'A', 'I', 118),
(1188, '090717', 'SURCUBAMBA', 'A', 'I', 118),
(1189, '090718', 'TINTAY PUNCU', 'A', 'I', 118),
(1190, '090719', 'QUICHUAS', 'A', 'I', 118),
(1191, '090720', 'ANDAYMARCA', 'A', 'I', 118),
(1192, '090721', 'ROBLE', 'A', 'I', 118),
(1193, '090722', 'PICHOS', 'A', 'I', 118),
(1194, '090723', 'SANTIAGO DE TUCUMA', 'A', 'I', 118),
(1195, '100101', 'HUANUCO', 'A', 'I', 119),
(1196, '100102', 'AMARILIS', 'A', 'I', 119),
(1197, '100103', 'CHINCHAO', 'A', 'I', 119),
(1198, '100104', 'CHURUBAMBA', 'A', 'I', 119),
(1199, '100105', 'MARGOS', 'A', 'I', 119),
(1200, '100106', 'QUISQUI (KICHKI)', 'A', 'I', 119),
(1201, '100107', 'SAN FRANCISCO DE CAYRAN', 'A', 'I', 119),
(1202, '100108', 'SAN PEDRO DE CHAULAN', 'A', 'I', 119),
(1203, '100109', 'SANTA MARIA DEL VALLE', 'A', 'I', 119),
(1204, '100110', 'YARUMAYO', 'A', 'I', 119),
(1205, '100111', 'PILLCO MARCA', 'A', 'I', 119),
(1206, '100112', 'YACUS', 'A', 'I', 119),
(1207, '100113', 'SAN PABLO DE PILLAO', 'A', 'I', 119),
(1208, '100201', 'AMBO', 'A', 'I', 120),
(1209, '100202', 'CAYNA', 'A', 'I', 120),
(1210, '100203', 'COLPAS', 'A', 'I', 120),
(1211, '100204', 'CONCHAMARCA', 'A', 'I', 120),
(1212, '100205', 'HUACAR', 'A', 'I', 120),
(1213, '100206', 'SAN FRANCISCO', 'A', 'I', 120),
(1214, '100207', 'SAN RAFAEL', 'A', 'I', 120),
(1215, '100208', 'TOMAY KICHWA', 'A', 'I', 120),
(1216, '100301', 'LA UNION', 'A', 'I', 121),
(1217, '100307', 'CHUQUIS', 'A', 'I', 121),
(1218, '100311', 'MARIAS', 'A', 'I', 121),
(1219, '100313', 'PACHAS', 'A', 'I', 121),
(1220, '100316', 'QUIVILLA', 'A', 'I', 121),
(1221, '100317', 'RIPAN', 'A', 'I', 121),
(1222, '100321', 'SHUNQUI', 'A', 'I', 121),
(1223, '100322', 'SILLAPATA', 'A', 'I', 121),
(1224, '100323', 'YANAS', 'A', 'I', 121),
(1225, '100401', 'HUACAYBAMBA', 'A', 'I', 122),
(1226, '100402', 'CANCHABAMBA', 'A', 'I', 122),
(1227, '100403', 'COCHABAMBA', 'A', 'I', 122),
(1228, '100404', 'PINRA', 'A', 'I', 122),
(1229, '100501', 'LLATA', 'A', 'I', 123),
(1230, '100502', 'ARANCAY', 'A', 'I', 123),
(1231, '100503', 'CHAVIN DE PARIARCA', 'A', 'I', 123),
(1232, '100504', 'JACAS GRANDE', 'A', 'I', 123),
(1233, '100505', 'JIRCAN', 'A', 'I', 123),
(1234, '100506', 'MIRAFLORES', 'A', 'I', 123),
(1235, '100507', 'MONZON', 'A', 'I', 123),
(1236, '100508', 'PUNCHAO', 'A', 'I', 123),
(1237, '100509', 'PU¥OS', 'A', 'I', 123),
(1238, '100510', 'SINGA', 'A', 'I', 123),
(1239, '100511', 'TANTAMAYO', 'A', 'I', 123),
(1240, '100601', 'RUPA-RUPA', 'A', 'I', 124),
(1241, '100602', 'DANIEL ALOMIA ROBLES', 'A', 'I', 124),
(1242, '100603', 'HERMILIO VALDIZAN', 'A', 'I', 124),
(1243, '100604', 'JOSE CRESPO Y CASTILLO', 'A', 'I', 124),
(1244, '100605', 'LUYANDO', 'A', 'I', 124),
(1245, '100606', 'MARIANO DAMASO BERAUN', 'A', 'I', 124),
(1246, '100607', 'PUCAYACU', 'A', 'I', 124),
(1247, '100608', 'CASTILLO GRANDE', 'A', 'I', 124),
(1248, '100609', 'PUEBLO NUEVO', 'A', 'I', 124),
(1249, '100610', 'SANTO DOMINGO DE ANDIA', 'A', 'I', 124),
(1250, '100701', 'HUACRACHUCO', 'A', 'I', 125),
(1251, '100702', 'CHOLON', 'A', 'I', 125),
(1252, '100703', 'SAN BUENAVENTURA', 'A', 'I', 125),
(1253, '100704', 'LA MORADA', 'A', 'I', 125),
(1254, '100705', 'SANTA ROSA DE ALTO YANAJANCA', 'A', 'I', 125);
INSERT INTO `ubigeos` (`id_ubigeo`, `code`, `name`, `state`, `type`, `id_ubigeo_base`) VALUES
(1255, '100801', 'PANAO', 'A', 'I', 126),
(1256, '100802', 'CHAGLLA', 'A', 'I', 126),
(1257, '100803', 'MOLINO', 'A', 'I', 126),
(1258, '100804', 'UMARI', 'A', 'I', 126),
(1259, '100901', 'PUERTO INCA', 'A', 'I', 127),
(1260, '100902', 'CODO DEL POZUZO', 'A', 'I', 127),
(1261, '100903', 'HONORIA', 'A', 'I', 127),
(1262, '100904', 'TOURNAVISTA', 'A', 'I', 127),
(1263, '100905', 'YUYAPICHIS', 'A', 'I', 127),
(1264, '101001', 'JESUS', 'A', 'I', 128),
(1265, '101002', 'BA¥OS', 'A', 'I', 128),
(1266, '101003', 'JIVIA', 'A', 'I', 128),
(1267, '101004', 'QUEROPALCA', 'A', 'I', 128),
(1268, '101005', 'RONDOS', 'A', 'I', 128),
(1269, '101006', 'SAN FRANCISCO DE ASIS', 'A', 'I', 128),
(1270, '101007', 'SAN MIGUEL DE CAURI', 'A', 'I', 128),
(1271, '101101', 'CHAVINILLO', 'A', 'I', 129),
(1272, '101102', 'CAHUAC', 'A', 'I', 129),
(1273, '101103', 'CHACABAMBA', 'A', 'I', 129),
(1274, '101104', 'APARICIO POMARES', 'A', 'I', 129),
(1275, '101105', 'JACAS CHICO', 'A', 'I', 129),
(1276, '101106', 'OBAS', 'A', 'I', 129),
(1277, '101107', 'PAMPAMARCA', 'A', 'I', 129),
(1278, '101108', 'CHORAS', 'A', 'I', 129),
(1279, '110101', 'ICA', 'A', 'I', 130),
(1280, '110102', 'LA TINGUI¥A', 'A', 'I', 130),
(1281, '110103', 'LOS AQUIJES', 'A', 'I', 130),
(1282, '110104', 'OCUCAJE', 'A', 'I', 130),
(1283, '110105', 'PACHACUTEC', 'A', 'I', 130),
(1284, '110106', 'PARCONA', 'A', 'I', 130),
(1285, '110107', 'PUEBLO NUEVO', 'A', 'I', 130),
(1286, '110108', 'SALAS', 'A', 'I', 130),
(1287, '110109', 'SAN JOSE DE LOS MOLINOS', 'A', 'I', 130),
(1288, '110110', 'SAN JUAN BAUTISTA', 'A', 'I', 130),
(1289, '110111', 'SANTIAGO', 'A', 'I', 130),
(1290, '110112', 'SUBTANJALLA', 'A', 'I', 130),
(1291, '110113', 'TATE', 'A', 'I', 130),
(1292, '110114', 'YAUCA DEL ROSARIO', 'A', 'I', 130),
(1293, '110201', 'CHINCHA ALTA', 'A', 'I', 131),
(1294, '110202', 'ALTO LARAN', 'A', 'I', 131),
(1295, '110203', 'CHAVIN', 'A', 'I', 131),
(1296, '110204', 'CHINCHA BAJA', 'A', 'I', 131),
(1297, '110205', 'EL CARMEN', 'A', 'I', 131),
(1298, '110206', 'GROCIO PRADO', 'A', 'I', 131),
(1299, '110207', 'PUEBLO NUEVO', 'A', 'I', 131),
(1300, '110208', 'SAN JUAN DE YANAC', 'A', 'I', 131),
(1301, '110209', 'SAN PEDRO DE HUACARPANA', 'A', 'I', 131),
(1302, '110210', 'SUNAMPE', 'A', 'I', 131),
(1303, '110211', 'TAMBO DE MORA', 'A', 'I', 131),
(1304, '110301', 'NASCA', 'A', 'I', 132),
(1305, '110302', 'CHANGUILLO', 'A', 'I', 132),
(1306, '110303', 'EL INGENIO', 'A', 'I', 132),
(1307, '110304', 'MARCONA', 'A', 'I', 132),
(1308, '110305', 'VISTA ALEGRE', 'A', 'I', 132),
(1309, '110401', 'PALPA', 'A', 'I', 133),
(1310, '110402', 'LLIPATA', 'A', 'I', 133),
(1311, '110403', 'RIO GRANDE', 'A', 'I', 133),
(1312, '110404', 'SANTA CRUZ', 'A', 'I', 133),
(1313, '110405', 'TIBILLO', 'A', 'I', 133),
(1314, '110501', 'PISCO', 'A', 'I', 134),
(1315, '110502', 'HUANCANO', 'A', 'I', 134),
(1316, '110503', 'HUMAY', 'A', 'I', 134),
(1317, '110504', 'INDEPENDENCIA', 'A', 'I', 134),
(1318, '110505', 'PARACAS', 'A', 'I', 134),
(1319, '110506', 'SAN ANDRES', 'A', 'I', 134),
(1320, '110507', 'SAN CLEMENTE', 'A', 'I', 134),
(1321, '110508', 'TUPAC AMARU INCA', 'A', 'I', 134),
(1322, '120101', 'HUANCAYO', 'A', 'I', 135),
(1323, '120104', 'CARHUACALLANGA', 'A', 'I', 135),
(1324, '120105', 'CHACAPAMPA', 'A', 'I', 135),
(1325, '120106', 'CHICCHE', 'A', 'I', 135),
(1326, '120107', 'CHILCA', 'A', 'I', 135),
(1327, '120108', 'CHONGOS ALTO', 'A', 'I', 135),
(1328, '120111', 'CHUPURO', 'A', 'I', 135),
(1329, '120112', 'COLCA', 'A', 'I', 135),
(1330, '120113', 'CULLHUAS', 'A', 'I', 135),
(1331, '120114', 'EL TAMBO', 'A', 'I', 135),
(1332, '120116', 'HUACRAPUQUIO', 'A', 'I', 135),
(1333, '120117', 'HUALHUAS', 'A', 'I', 135),
(1334, '120119', 'HUANCAN', 'A', 'I', 135),
(1335, '120120', 'HUASICANCHA', 'A', 'I', 135),
(1336, '120121', 'HUAYUCACHI', 'A', 'I', 135),
(1337, '120122', 'INGENIO', 'A', 'I', 135),
(1338, '120124', 'PARIAHUANCA', 'A', 'I', 135),
(1339, '120125', 'PILCOMAYO', 'A', 'I', 135),
(1340, '120126', 'PUCARA', 'A', 'I', 135),
(1341, '120127', 'QUICHUAY', 'A', 'I', 135),
(1342, '120128', 'QUILCAS', 'A', 'I', 135),
(1343, '120129', 'SAN AGUSTIN', 'A', 'I', 135),
(1344, '120130', 'SAN JERONIMO DE TUNAN', 'A', 'I', 135),
(1345, '120132', 'SA¥O', 'A', 'I', 135),
(1346, '120133', 'SAPALLANGA', 'A', 'I', 135),
(1347, '120134', 'SICAYA', 'A', 'I', 135),
(1348, '120135', 'SANTO DOMINGO DE ACOBAMBA', 'A', 'I', 135),
(1349, '120136', 'VIQUES', 'A', 'I', 135),
(1350, '120201', 'CONCEPCION', 'A', 'I', 136),
(1351, '120202', 'ACO', 'A', 'I', 136),
(1352, '120203', 'ANDAMARCA', 'A', 'I', 136),
(1353, '120204', 'CHAMBARA', 'A', 'I', 136),
(1354, '120205', 'COCHAS', 'A', 'I', 136),
(1355, '120206', 'COMAS', 'A', 'I', 136),
(1356, '120207', 'HEROINAS TOLEDO', 'A', 'I', 136),
(1357, '120208', 'MANZANARES', 'A', 'I', 136),
(1358, '120209', 'MARISCAL CASTILLA', 'A', 'I', 136),
(1359, '120210', 'MATAHUASI', 'A', 'I', 136),
(1360, '120211', 'MITO', 'A', 'I', 136),
(1361, '120212', 'NUEVE DE JULIO', 'A', 'I', 136),
(1362, '120213', 'ORCOTUNA', 'A', 'I', 136),
(1363, '120214', 'SAN JOSE DE QUERO', 'A', 'I', 136),
(1364, '120215', 'SANTA ROSA DE OCOPA', 'A', 'I', 136),
(1365, '120301', 'CHANCHAMAYO', 'A', 'I', 137),
(1366, '120302', 'PERENE', 'A', 'I', 137),
(1367, '120303', 'PICHANAQUI', 'A', 'I', 137),
(1368, '120304', 'SAN LUIS DE SHUARO', 'A', 'I', 137),
(1369, '120305', 'SAN RAMON', 'A', 'I', 137),
(1370, '120306', 'VITOC', 'A', 'I', 137),
(1371, '120401', 'JAUJA', 'A', 'I', 138),
(1372, '120402', 'ACOLLA', 'A', 'I', 138),
(1373, '120403', 'APATA', 'A', 'I', 138),
(1374, '120404', 'ATAURA', 'A', 'I', 138),
(1375, '120405', 'CANCHAYLLO', 'A', 'I', 138),
(1376, '120406', 'CURICACA', 'A', 'I', 138),
(1377, '120407', 'EL MANTARO', 'A', 'I', 138),
(1378, '120408', 'HUAMALI', 'A', 'I', 138),
(1379, '120409', 'HUARIPAMPA', 'A', 'I', 138),
(1380, '120410', 'HUERTAS', 'A', 'I', 138),
(1381, '120411', 'JANJAILLO', 'A', 'I', 138),
(1382, '120412', 'JULCAN', 'A', 'I', 138),
(1383, '120413', 'LEONOR ORDO¥EZ', 'A', 'I', 138),
(1384, '120414', 'LLOCLLAPAMPA', 'A', 'I', 138),
(1385, '120415', 'MARCO', 'A', 'I', 138),
(1386, '120416', 'MASMA', 'A', 'I', 138),
(1387, '120417', 'MASMA CHICCHE', 'A', 'I', 138),
(1388, '120418', 'MOLINOS', 'A', 'I', 138),
(1389, '120419', 'MONOBAMBA', 'A', 'I', 138),
(1390, '120420', 'MUQUI', 'A', 'I', 138),
(1391, '120421', 'MUQUIYAUYO', 'A', 'I', 138),
(1392, '120422', 'PACA', 'A', 'I', 138),
(1393, '120423', 'PACCHA', 'A', 'I', 138),
(1394, '120424', 'PANCAN', 'A', 'I', 138),
(1395, '120425', 'PARCO', 'A', 'I', 138),
(1396, '120426', 'POMACANCHA', 'A', 'I', 138),
(1397, '120427', 'RICRAN', 'A', 'I', 138),
(1398, '120428', 'SAN LORENZO', 'A', 'I', 138),
(1399, '120429', 'SAN PEDRO DE CHUNAN', 'A', 'I', 138),
(1400, '120430', 'SAUSA', 'A', 'I', 138),
(1401, '120431', 'SINCOS', 'A', 'I', 138),
(1402, '120432', 'TUNAN MARCA', 'A', 'I', 138),
(1403, '120433', 'YAULI', 'A', 'I', 138),
(1404, '120434', 'YAUYOS', 'A', 'I', 138),
(1405, '120501', 'JUNIN', 'A', 'I', 139),
(1406, '120502', 'CARHUAMAYO', 'A', 'I', 139),
(1407, '120503', 'ONDORES', 'A', 'I', 139),
(1408, '120504', 'ULCUMAYO', 'A', 'I', 139),
(1409, '120601', 'SATIPO', 'A', 'I', 140),
(1410, '120602', 'COVIRIALI', 'A', 'I', 140),
(1411, '120603', 'LLAYLLA', 'A', 'I', 140),
(1412, '120604', 'MAZAMARI', 'A', 'I', 140),
(1413, '120605', 'PAMPA HERMOSA', 'A', 'I', 140),
(1414, '120606', 'PANGOA', 'A', 'I', 140),
(1415, '120607', 'RIO NEGRO', 'A', 'I', 140),
(1416, '120608', 'RIO TAMBO', 'A', 'I', 140),
(1417, '120609', 'VIZCATAN DEL ENE', 'A', 'I', 140),
(1418, '120701', 'TARMA', 'A', 'I', 141),
(1419, '120702', 'ACOBAMBA', 'A', 'I', 141),
(1420, '120703', 'HUARICOLCA', 'A', 'I', 141),
(1421, '120704', 'HUASAHUASI', 'A', 'I', 141),
(1422, '120705', 'LA UNION', 'A', 'I', 141),
(1423, '120706', 'PALCA', 'A', 'I', 141),
(1424, '120707', 'PALCAMAYO', 'A', 'I', 141),
(1425, '120708', 'SAN PEDRO DE CAJAS', 'A', 'I', 141),
(1426, '120709', 'TAPO', 'A', 'I', 141),
(1427, '120801', 'LA OROYA', 'A', 'I', 142),
(1428, '120802', 'CHACAPALPA', 'A', 'I', 142),
(1429, '120803', 'HUAY-HUAY', 'A', 'I', 142),
(1430, '120804', 'MARCAPOMACOCHA', 'A', 'I', 142),
(1431, '120805', 'MOROCOCHA', 'A', 'I', 142),
(1432, '120806', 'PACCHA', 'A', 'I', 142),
(1433, '120807', 'SANTA BARBARA DE CARHUACAYAN', 'A', 'I', 142),
(1434, '120808', 'SANTA ROSA DE SACCO', 'A', 'I', 142),
(1435, '120809', 'SUITUCANCHA', 'A', 'I', 142),
(1436, '120810', 'YAULI', 'A', 'I', 142),
(1437, '120901', 'CHUPACA', 'A', 'I', 143),
(1438, '120902', 'AHUAC', 'A', 'I', 143),
(1439, '120903', 'CHONGOS BAJO', 'A', 'I', 143),
(1440, '120904', 'HUACHAC', 'A', 'I', 143),
(1441, '120905', 'HUAMANCACA CHICO', 'A', 'I', 143),
(1442, '120906', 'SAN JUAN DE ISCOS', 'A', 'I', 143),
(1443, '120907', 'SAN JUAN DE JARPA', 'A', 'I', 143),
(1444, '120908', 'TRES DE DICIEMBRE', 'A', 'I', 143),
(1445, '120909', 'YANACANCHA', 'A', 'I', 143),
(1446, '130101', 'TRUJILLO', 'A', 'I', 144),
(1447, '130102', 'EL PORVENIR', 'A', 'I', 144),
(1448, '130103', 'FLORENCIA DE MORA', 'A', 'I', 144),
(1449, '130104', 'HUANCHACO', 'A', 'I', 144),
(1450, '130105', 'LA ESPERANZA', 'A', 'I', 144),
(1451, '130106', 'LAREDO', 'A', 'I', 144),
(1452, '130107', 'MOCHE', 'A', 'I', 144),
(1453, '130108', 'POROTO', 'A', 'I', 144),
(1454, '130109', 'SALAVERRY', 'A', 'I', 144),
(1455, '130110', 'SIMBAL', 'A', 'I', 144),
(1456, '130111', 'VICTOR LARCO HERRERA', 'A', 'I', 144),
(1457, '130201', 'ASCOPE', 'A', 'I', 145),
(1458, '130202', 'CHICAMA', 'A', 'I', 145),
(1459, '130203', 'CHOCOPE', 'A', 'I', 145),
(1460, '130204', 'MAGDALENA DE CAO', 'A', 'I', 145),
(1461, '130205', 'PAIJAN', 'A', 'I', 145),
(1462, '130206', 'RAZURI', 'A', 'I', 145),
(1463, '130207', 'SANTIAGO DE CAO', 'A', 'I', 145),
(1464, '130208', 'CASA GRANDE', 'A', 'I', 145),
(1465, '130301', 'BOLIVAR', 'A', 'I', 146),
(1466, '130302', 'BAMBAMARCA', 'A', 'I', 146),
(1467, '130303', 'CONDORMARCA', 'A', 'I', 146),
(1468, '130304', 'LONGOTEA', 'A', 'I', 146),
(1469, '130305', 'UCHUMARCA', 'A', 'I', 146),
(1470, '130306', 'UCUNCHA', 'A', 'I', 146),
(1471, '130401', 'CHEPEN', 'A', 'I', 147),
(1472, '130402', 'PACANGA', 'A', 'I', 147),
(1473, '130403', 'PUEBLO NUEVO', 'A', 'I', 147),
(1474, '130501', 'JULCAN', 'A', 'I', 148),
(1475, '130502', 'CALAMARCA', 'A', 'I', 148),
(1476, '130503', 'CARABAMBA', 'A', 'I', 148),
(1477, '130504', 'HUASO', 'A', 'I', 148),
(1478, '130601', 'OTUZCO', 'A', 'I', 149),
(1479, '130602', 'AGALLPAMPA', 'A', 'I', 149),
(1480, '130604', 'CHARAT', 'A', 'I', 149),
(1481, '130605', 'HUARANCHAL', 'A', 'I', 149),
(1482, '130606', 'LA CUESTA', 'A', 'I', 149),
(1483, '130608', 'MACHE', 'A', 'I', 149),
(1484, '130610', 'PARANDAY', 'A', 'I', 149),
(1485, '130611', 'SALPO', 'A', 'I', 149),
(1486, '130613', 'SINSICAP', 'A', 'I', 149),
(1487, '130614', 'USQUIL', 'A', 'I', 149),
(1488, '130701', 'SAN PEDRO DE LLOC', 'A', 'I', 150),
(1489, '130702', 'GUADALUPE', 'A', 'I', 150),
(1490, '130703', 'JEQUETEPEQUE', 'A', 'I', 150),
(1491, '130704', 'PACASMAYO', 'A', 'I', 150),
(1492, '130705', 'SAN JOSE', 'A', 'I', 150),
(1493, '130801', 'TAYABAMBA', 'A', 'I', 151),
(1494, '130802', 'BULDIBUYO', 'A', 'I', 151),
(1495, '130803', 'CHILLIA', 'A', 'I', 151),
(1496, '130804', 'HUANCASPATA', 'A', 'I', 151),
(1497, '130805', 'HUAYLILLAS', 'A', 'I', 151),
(1498, '130806', 'HUAYO', 'A', 'I', 151),
(1499, '130807', 'ONGON', 'A', 'I', 151),
(1500, '130808', 'PARCOY', 'A', 'I', 151),
(1501, '130809', 'PATAZ', 'A', 'I', 151),
(1502, '130810', 'PIAS', 'A', 'I', 151),
(1503, '130811', 'SANTIAGO DE CHALLAS', 'A', 'I', 151),
(1504, '130812', 'TAURIJA', 'A', 'I', 151),
(1505, '130813', 'URPAY', 'A', 'I', 151),
(1506, '130901', 'HUAMACHUCO', 'A', 'I', 152),
(1507, '130902', 'CHUGAY', 'A', 'I', 152),
(1508, '130903', 'COCHORCO', 'A', 'I', 152),
(1509, '130904', 'CURGOS', 'A', 'I', 152),
(1510, '130905', 'MARCABAL', 'A', 'I', 152),
(1511, '130906', 'SANAGORAN', 'A', 'I', 152),
(1512, '130907', 'SARIN', 'A', 'I', 152),
(1513, '130908', 'SARTIMBAMBA', 'A', 'I', 152),
(1514, '131001', 'SANTIAGO DE CHUCO', 'A', 'I', 153),
(1515, '131002', 'ANGASMARCA', 'A', 'I', 153),
(1516, '131003', 'CACHICADAN', 'A', 'I', 153),
(1517, '131004', 'MOLLEBAMBA', 'A', 'I', 153),
(1518, '131005', 'MOLLEPATA', 'A', 'I', 153),
(1519, '131006', 'QUIRUVILCA', 'A', 'I', 153),
(1520, '131007', 'SANTA CRUZ DE CHUCA', 'A', 'I', 153),
(1521, '131008', 'SITABAMBA', 'A', 'I', 153),
(1522, '131101', 'CASCAS', 'A', 'I', 154),
(1523, '131102', 'LUCMA', 'A', 'I', 154),
(1524, '131103', 'MARMOT', 'A', 'I', 154),
(1525, '131104', 'SAYAPULLO', 'A', 'I', 154),
(1526, '131201', 'VIRU', 'A', 'I', 155),
(1527, '131202', 'CHAO', 'A', 'I', 155),
(1528, '131203', 'GUADALUPITO', 'A', 'I', 155),
(1529, '140101', 'CHICLAYO', 'A', 'I', 156),
(1530, '140102', 'CHONGOYAPE', 'A', 'I', 156),
(1531, '140103', 'ETEN', 'A', 'I', 156),
(1532, '140104', 'ETEN PUERTO', 'A', 'I', 156),
(1533, '140105', 'JOSE LEONARDO ORTIZ', 'A', 'I', 156),
(1534, '140106', 'LA VICTORIA', 'A', 'I', 156),
(1535, '140107', 'LAGUNAS', 'A', 'I', 156),
(1536, '140108', 'MONSEFU', 'A', 'I', 156),
(1537, '140109', 'NUEVA ARICA', 'A', 'I', 156),
(1538, '140110', 'OYOTUN', 'A', 'I', 156),
(1539, '140111', 'PICSI', 'A', 'I', 156),
(1540, '140112', 'PIMENTEL', 'A', 'I', 156),
(1541, '140113', 'REQUE', 'A', 'I', 156),
(1542, '140114', 'SANTA ROSA', 'A', 'I', 156),
(1543, '140115', 'SA¥A', 'A', 'I', 156),
(1544, '140116', 'CAYALTI', 'A', 'I', 156),
(1545, '140117', 'PATAPO', 'A', 'I', 156),
(1546, '140118', 'POMALCA', 'A', 'I', 156),
(1547, '140119', 'PUCALA', 'A', 'I', 156),
(1548, '140120', 'TUMAN', 'A', 'I', 156),
(1549, '140201', 'FERRE¥AFE', 'A', 'I', 157),
(1550, '140202', 'CA¥ARIS', 'A', 'I', 157),
(1551, '140203', 'INCAHUASI', 'A', 'I', 157),
(1552, '140204', 'MANUEL ANTONIO MESONES MURO', 'A', 'I', 157),
(1553, '140205', 'PITIPO', 'A', 'I', 157),
(1554, '140206', 'PUEBLO NUEVO', 'A', 'I', 157),
(1555, '140301', 'LAMBAYEQUE', 'A', 'I', 158),
(1556, '140302', 'CHOCHOPE', 'A', 'I', 158),
(1557, '140303', 'ILLIMO', 'A', 'I', 158),
(1558, '140304', 'JAYANCA', 'A', 'I', 158),
(1559, '140305', 'MOCHUMI', 'A', 'I', 158),
(1560, '140306', 'MORROPE', 'A', 'I', 158),
(1561, '140307', 'MOTUPE', 'A', 'I', 158),
(1562, '140308', 'OLMOS', 'A', 'I', 158),
(1563, '140309', 'PACORA', 'A', 'I', 158),
(1564, '140310', 'SALAS', 'A', 'I', 158),
(1565, '140311', 'SAN JOSE', 'A', 'I', 158),
(1566, '140312', 'TUCUME', 'A', 'I', 158),
(1567, '150101', 'LIMA', 'A', 'I', 159),
(1568, '150102', 'ANCON', 'A', 'I', 159),
(1569, '150103', 'ATE', 'A', 'I', 159),
(1570, '150104', 'BARRANCO', 'A', 'I', 159),
(1571, '150105', 'BRE¥A', 'A', 'I', 159),
(1572, '150106', 'CARABAYLLO', 'A', 'I', 159),
(1573, '150107', 'CHACLACAYO', 'A', 'I', 159),
(1574, '150108', 'CHORRILLOS', 'A', 'I', 159),
(1575, '150109', 'CIENEGUILLA', 'A', 'I', 159),
(1576, '150110', 'COMAS', 'A', 'I', 159),
(1577, '150111', 'EL AGUSTINO', 'A', 'I', 159),
(1578, '150112', 'INDEPENDENCIA', 'A', 'I', 159),
(1579, '150113', 'JESUS MARIA', 'A', 'I', 159),
(1580, '150114', 'LA MOLINA', 'A', 'I', 159),
(1581, '150115', 'LA VICTORIA', 'A', 'I', 159),
(1582, '150116', 'LINCE', 'A', 'I', 159),
(1583, '150117', 'LOS OLIVOS', 'A', 'I', 159),
(1584, '150118', 'LURIGANCHO', 'A', 'I', 159),
(1585, '150119', 'LURIN', 'A', 'I', 159),
(1586, '150120', 'MAGDALENA DEL MAR', 'A', 'I', 159),
(1587, '150121', 'PUEBLO LIBRE', 'A', 'I', 159),
(1588, '150122', 'MIRAFLORES', 'A', 'I', 159),
(1589, '150123', 'PACHACAMAC', 'A', 'I', 159),
(1590, '150124', 'PUCUSANA', 'A', 'I', 159),
(1591, '150125', 'PUENTE PIEDRA', 'A', 'I', 159),
(1592, '150126', 'PUNTA HERMOSA', 'A', 'I', 159),
(1593, '150127', 'PUNTA NEGRA', 'A', 'I', 159),
(1594, '150128', 'RIMAC', 'A', 'I', 159),
(1595, '150129', 'SAN BARTOLO', 'A', 'I', 159),
(1596, '150130', 'SAN BORJA', 'A', 'I', 159),
(1597, '150131', 'SAN ISIDRO', 'A', 'I', 159),
(1598, '150132', 'SAN JUAN DE LURIGANCHO', 'A', 'I', 159),
(1599, '150133', 'SAN JUAN DE MIRAFLORES', 'A', 'I', 159),
(1600, '150134', 'SAN LUIS', 'A', 'I', 159),
(1601, '150135', 'SAN MARTIN DE PORRES', 'A', 'I', 159),
(1602, '150136', 'SAN MIGUEL', 'A', 'I', 159),
(1603, '150137', 'SANTA ANITA', 'A', 'I', 159),
(1604, '150138', 'SANTA MARIA DEL MAR', 'A', 'I', 159),
(1605, '150139', 'SANTA ROSA', 'A', 'I', 159),
(1606, '150140', 'SANTIAGO DE SURCO', 'A', 'I', 159),
(1607, '150141', 'SURQUILLO', 'A', 'I', 159),
(1608, '150142', 'VILLA EL SALVADOR', 'A', 'I', 159),
(1609, '150143', 'VILLA MARIA DEL TRIUNFO', 'A', 'I', 159),
(1610, '150201', 'BARRANCA', 'A', 'I', 160),
(1611, '150202', 'PARAMONGA', 'A', 'I', 160),
(1612, '150203', 'PATIVILCA', 'A', 'I', 160),
(1613, '150204', 'SUPE', 'A', 'I', 160),
(1614, '150205', 'SUPE PUERTO', 'A', 'I', 160),
(1615, '150301', 'CAJATAMBO', 'A', 'I', 161),
(1616, '150302', 'COPA', 'A', 'I', 161),
(1617, '150303', 'GORGOR', 'A', 'I', 161),
(1618, '150304', 'HUANCAPON', 'A', 'I', 161),
(1619, '150305', 'MANAS', 'A', 'I', 161),
(1620, '150401', 'CANTA', 'A', 'I', 162),
(1621, '150402', 'ARAHUAY', 'A', 'I', 162),
(1622, '150403', 'HUAMANTANGA', 'A', 'I', 162),
(1623, '150404', 'HUAROS', 'A', 'I', 162),
(1624, '150405', 'LACHAQUI', 'A', 'I', 162),
(1625, '150406', 'SAN BUENAVENTURA', 'A', 'I', 162),
(1626, '150407', 'SANTA ROSA DE QUIVES', 'A', 'I', 162),
(1627, '150501', 'SAN VICENTE DE CA¥ETE', 'A', 'I', 163),
(1628, '150502', 'ASIA', 'A', 'I', 163),
(1629, '150503', 'CALANGO', 'A', 'I', 163),
(1630, '150504', 'CERRO AZUL', 'A', 'I', 163),
(1631, '150505', 'CHILCA', 'A', 'I', 163),
(1632, '150506', 'COAYLLO', 'A', 'I', 163),
(1633, '150507', 'IMPERIAL', 'A', 'I', 163),
(1634, '150508', 'LUNAHUANA', 'A', 'I', 163),
(1635, '150509', 'MALA', 'A', 'I', 163),
(1636, '150510', 'NUEVO IMPERIAL', 'A', 'I', 163),
(1637, '150511', 'PACARAN', 'A', 'I', 163),
(1638, '150512', 'QUILMANA', 'A', 'I', 163),
(1639, '150513', 'SAN ANTONIO', 'A', 'I', 163),
(1640, '150514', 'SAN LUIS', 'A', 'I', 163),
(1641, '150515', 'SANTA CRUZ DE FLORES', 'A', 'I', 163),
(1642, '150516', 'ZU¥IGA', 'A', 'I', 163),
(1643, '150601', 'HUARAL', 'A', 'I', 164),
(1644, '150602', 'ATAVILLOS ALTO', 'A', 'I', 164),
(1645, '150603', 'ATAVILLOS BAJO', 'A', 'I', 164),
(1646, '150604', 'AUCALLAMA', 'A', 'I', 164),
(1647, '150605', 'CHANCAY', 'A', 'I', 164),
(1648, '150606', 'IHUARI', 'A', 'I', 164),
(1649, '150607', 'LAMPIAN', 'A', 'I', 164),
(1650, '150608', 'PACARAOS', 'A', 'I', 164),
(1651, '150609', 'SAN MIGUEL DE ACOS', 'A', 'I', 164),
(1652, '150610', 'SANTA CRUZ DE ANDAMARCA', 'A', 'I', 164),
(1653, '150611', 'SUMBILCA', 'A', 'I', 164),
(1654, '150612', 'VEINTISIETE DE NOVIEMBRE', 'A', 'I', 164),
(1655, '150701', 'MATUCANA', 'A', 'I', 165),
(1656, '150702', 'ANTIOQUIA', 'A', 'I', 165),
(1657, '150703', 'CALLAHUANCA', 'A', 'I', 165),
(1658, '150704', 'CARAMPOMA', 'A', 'I', 165),
(1659, '150705', 'CHICLA', 'A', 'I', 165),
(1660, '150706', 'CUENCA', 'A', 'I', 165),
(1661, '150707', 'HUACHUPAMPA', 'A', 'I', 165),
(1662, '150708', 'HUANZA', 'A', 'I', 165),
(1663, '150709', 'HUAROCHIRI', 'A', 'I', 165),
(1664, '150710', 'LAHUAYTAMBO', 'A', 'I', 165),
(1665, '150711', 'LANGA', 'A', 'I', 165),
(1666, '150712', 'SAN PEDRO DE LARAOS', 'A', 'I', 165),
(1667, '150713', 'MARIATANA', 'A', 'I', 165),
(1668, '150714', 'RICARDO PALMA', 'A', 'I', 165),
(1669, '150715', 'SAN ANDRES DE TUPICOCHA', 'A', 'I', 165),
(1670, '150716', 'SAN ANTONIO', 'A', 'I', 165),
(1671, '150717', 'SAN BARTOLOME', 'A', 'I', 165),
(1672, '150718', 'SAN DAMIAN', 'A', 'I', 165),
(1673, '150719', 'SAN JUAN DE IRIS', 'A', 'I', 165),
(1674, '150720', 'SAN JUAN DE TANTARANCHE', 'A', 'I', 165),
(1675, '150721', 'SAN LORENZO DE QUINTI', 'A', 'I', 165),
(1676, '150722', 'SAN MATEO', 'A', 'I', 165),
(1677, '150723', 'SAN MATEO DE OTAO', 'A', 'I', 165),
(1678, '150724', 'SAN PEDRO DE CASTA', 'A', 'I', 165),
(1679, '150725', 'SAN PEDRO DE HUANCAYRE', 'A', 'I', 165),
(1680, '150726', 'SANGALLAYA', 'A', 'I', 165),
(1681, '150727', 'SANTA CRUZ DE COCACHACRA', 'A', 'I', 165),
(1682, '150728', 'SANTA EULALIA', 'A', 'I', 165),
(1683, '150729', 'SANTIAGO DE ANCHUCAYA', 'A', 'I', 165),
(1684, '150730', 'SANTIAGO DE TUNA', 'A', 'I', 165),
(1685, '150731', 'SANTO DOMINGO DE LOS OLLEROS', 'A', 'I', 165),
(1686, '150732', 'SURCO', 'A', 'I', 165),
(1687, '150801', 'HUACHO', 'A', 'I', 166),
(1688, '150802', 'AMBAR', 'A', 'I', 166),
(1689, '150803', 'CALETA DE CARQUIN', 'A', 'I', 166),
(1690, '150804', 'CHECRAS', 'A', 'I', 166),
(1691, '150805', 'HUALMAY', 'A', 'I', 166),
(1692, '150806', 'HUAURA', 'A', 'I', 166),
(1693, '150807', 'LEONCIO PRADO', 'A', 'I', 166),
(1694, '150808', 'PACCHO', 'A', 'I', 166),
(1695, '150809', 'SANTA LEONOR', 'A', 'I', 166),
(1696, '150810', 'SANTA MARIA', 'A', 'I', 166),
(1697, '150811', 'SAYAN', 'A', 'I', 166),
(1698, '150812', 'VEGUETA', 'A', 'I', 166),
(1699, '150901', 'OYON', 'A', 'I', 167),
(1700, '150902', 'ANDAJES', 'A', 'I', 167),
(1701, '150903', 'CAUJUL', 'A', 'I', 167),
(1702, '150904', 'COCHAMARCA', 'A', 'I', 167),
(1703, '150905', 'NAVAN', 'A', 'I', 167),
(1704, '150906', 'PACHANGARA', 'A', 'I', 167),
(1705, '151001', 'YAUYOS', 'A', 'I', 168),
(1706, '151002', 'ALIS', 'A', 'I', 168),
(1707, '151003', 'ALLAUCA', 'A', 'I', 168),
(1708, '151004', 'AYAVIRI', 'A', 'I', 168),
(1709, '151005', 'AZANGARO', 'A', 'I', 168),
(1710, '151006', 'CACRA', 'A', 'I', 168),
(1711, '151007', 'CARANIA', 'A', 'I', 168),
(1712, '151008', 'CATAHUASI', 'A', 'I', 168),
(1713, '151009', 'CHOCOS', 'A', 'I', 168),
(1714, '151010', 'COCHAS', 'A', 'I', 168),
(1715, '151011', 'COLONIA', 'A', 'I', 168),
(1716, '151012', 'HONGOS', 'A', 'I', 168),
(1717, '151013', 'HUAMPARA', 'A', 'I', 168),
(1718, '151014', 'HUANCAYA', 'A', 'I', 168),
(1719, '151015', 'HUANGASCAR', 'A', 'I', 168),
(1720, '151016', 'HUANTAN', 'A', 'I', 168),
(1721, '151017', 'HUA¥EC', 'A', 'I', 168),
(1722, '151018', 'LARAOS', 'A', 'I', 168),
(1723, '151019', 'LINCHA', 'A', 'I', 168),
(1724, '151020', 'MADEAN', 'A', 'I', 168),
(1725, '151021', 'MIRAFLORES', 'A', 'I', 168),
(1726, '151022', 'OMAS', 'A', 'I', 168),
(1727, '151023', 'PUTINZA', 'A', 'I', 168),
(1728, '151024', 'QUINCHES', 'A', 'I', 168),
(1729, '151025', 'QUINOCAY', 'A', 'I', 168),
(1730, '151026', 'SAN JOAQUIN', 'A', 'I', 168),
(1731, '151027', 'SAN PEDRO DE PILAS', 'A', 'I', 168),
(1732, '151028', 'TANTA', 'A', 'I', 168),
(1733, '151029', 'TAURIPAMPA', 'A', 'I', 168),
(1734, '151030', 'TOMAS', 'A', 'I', 168),
(1735, '151031', 'TUPE', 'A', 'I', 168),
(1736, '151032', 'VI¥AC', 'A', 'I', 168),
(1737, '151033', 'VITIS', 'A', 'I', 168),
(1738, '160101', 'IQUITOS', 'A', 'I', 169),
(1739, '160102', 'ALTO NANAY', 'A', 'I', 169),
(1740, '160103', 'FERNANDO LORES', 'A', 'I', 169),
(1741, '160104', 'INDIANA', 'A', 'I', 169),
(1742, '160105', 'LAS AMAZONAS', 'A', 'I', 169),
(1743, '160106', 'MAZAN', 'A', 'I', 169),
(1744, '160107', 'NAPO', 'A', 'I', 169),
(1745, '160108', 'PUNCHANA', 'A', 'I', 169),
(1746, '160110', 'TORRES CAUSANA', 'A', 'I', 169),
(1747, '160112', 'BELEN', 'A', 'I', 169),
(1748, '160113', 'SAN JUAN BAUTISTA', 'A', 'I', 169),
(1749, '160201', 'YURIMAGUAS', 'A', 'I', 170),
(1750, '160202', 'BALSAPUERTO', 'A', 'I', 170),
(1751, '160205', 'JEBEROS', 'A', 'I', 170),
(1752, '160206', 'LAGUNAS', 'A', 'I', 170),
(1753, '160210', 'SANTA CRUZ', 'A', 'I', 170),
(1754, '160211', 'TENIENTE CESAR LOPEZ ROJAS', 'A', 'I', 170),
(1755, '160301', 'NAUTA', 'A', 'I', 171),
(1756, '160302', 'PARINARI', 'A', 'I', 171),
(1757, '160303', 'TIGRE', 'A', 'I', 171),
(1758, '160304', 'TROMPETEROS', 'A', 'I', 171),
(1759, '160305', 'URARINAS', 'A', 'I', 171),
(1760, '160401', 'RAMON CASTILLA', 'A', 'I', 172),
(1761, '160402', 'PEBAS', 'A', 'I', 172),
(1762, '160403', 'YAVARI', 'A', 'I', 172),
(1763, '160404', 'SAN PABLO', 'A', 'I', 172),
(1764, '160501', 'REQUENA', 'A', 'I', 173),
(1765, '160502', 'ALTO TAPICHE', 'A', 'I', 173),
(1766, '160503', 'CAPELO', 'A', 'I', 173),
(1767, '160504', 'EMILIO SAN MARTIN', 'A', 'I', 173),
(1768, '160505', 'MAQUIA', 'A', 'I', 173),
(1769, '160506', 'PUINAHUA', 'A', 'I', 173),
(1770, '160507', 'SAQUENA', 'A', 'I', 173),
(1771, '160508', 'SOPLIN', 'A', 'I', 173),
(1772, '160509', 'TAPICHE', 'A', 'I', 173),
(1773, '160510', 'JENARO HERRERA', 'A', 'I', 173),
(1774, '160511', 'YAQUERANA', 'A', 'I', 173),
(1775, '160601', 'CONTAMANA', 'A', 'I', 174),
(1776, '160602', 'INAHUAYA', 'A', 'I', 174),
(1777, '160603', 'PADRE MARQUEZ', 'A', 'I', 174),
(1778, '160604', 'PAMPA HERMOSA', 'A', 'I', 174),
(1779, '160605', 'SARAYACU', 'A', 'I', 174),
(1780, '160606', 'VARGAS GUERRA', 'A', 'I', 174),
(1781, '160701', 'BARRANCA', 'A', 'I', 175),
(1782, '160702', 'CAHUAPANAS', 'A', 'I', 175),
(1783, '160703', 'MANSERICHE', 'A', 'I', 175),
(1784, '160704', 'MORONA', 'A', 'I', 175),
(1785, '160705', 'PASTAZA', 'A', 'I', 175),
(1786, '160706', 'ANDOAS', 'A', 'I', 175),
(1787, '160801', 'PUTUMAYO', 'A', 'I', 176),
(1788, '160802', 'ROSA PANDURO', 'A', 'I', 176),
(1789, '160803', 'TENIENTE MANUEL CLAVERO', 'A', 'I', 176),
(1790, '160804', 'YAGUAS', 'A', 'I', 176),
(1791, '170101', 'TAMBOPATA', 'A', 'I', 177),
(1792, '170102', 'INAMBARI', 'A', 'I', 177),
(1793, '170103', 'LAS PIEDRAS', 'A', 'I', 177),
(1794, '170104', 'LABERINTO', 'A', 'I', 177),
(1795, '170201', 'MANU', 'A', 'I', 178),
(1796, '170202', 'FITZCARRALD', 'A', 'I', 178),
(1797, '170203', 'MADRE DE DIOS', 'A', 'I', 178),
(1798, '170204', 'HUEPETUHE', 'A', 'I', 178),
(1799, '170301', 'I¥APARI', 'A', 'I', 179),
(1800, '170302', 'IBERIA', 'A', 'I', 179),
(1801, '170303', 'TAHUAMANU', 'A', 'I', 179),
(1802, '180101', 'MOQUEGUA', 'A', 'I', 180),
(1803, '180102', 'CARUMAS', 'A', 'I', 180),
(1804, '180103', 'CUCHUMBAYA', 'A', 'I', 180),
(1805, '180104', 'SAMEGUA', 'A', 'I', 180),
(1806, '180105', 'SAN CRISTOBAL', 'A', 'I', 180),
(1807, '180106', 'TORATA', 'A', 'I', 180),
(1808, '180201', 'OMATE', 'A', 'I', 181),
(1809, '180202', 'CHOJATA', 'A', 'I', 181),
(1810, '180203', 'COALAQUE', 'A', 'I', 181),
(1811, '180204', 'ICHU¥A', 'A', 'I', 181),
(1812, '180205', 'LA CAPILLA', 'A', 'I', 181),
(1813, '180206', 'LLOQUE', 'A', 'I', 181),
(1814, '180207', 'MATALAQUE', 'A', 'I', 181),
(1815, '180208', 'PUQUINA', 'A', 'I', 181),
(1816, '180209', 'QUINISTAQUILLAS', 'A', 'I', 181),
(1817, '180210', 'UBINAS', 'A', 'I', 181),
(1818, '180211', 'YUNGA', 'A', 'I', 181),
(1819, '180301', 'ILO', 'A', 'I', 182),
(1820, '180302', 'EL ALGARROBAL', 'A', 'I', 182),
(1821, '180303', 'PACOCHA', 'A', 'I', 182),
(1822, '190101', 'CHAUPIMARCA', 'A', 'I', 183),
(1823, '190102', 'HUACHON', 'A', 'I', 183),
(1824, '190103', 'HUARIACA', 'A', 'I', 183),
(1825, '190104', 'HUAYLLAY', 'A', 'I', 183),
(1826, '190105', 'NINACACA', 'A', 'I', 183),
(1827, '190106', 'PALLANCHACRA', 'A', 'I', 183),
(1828, '190107', 'PAUCARTAMBO', 'A', 'I', 183),
(1829, '190108', 'SAN FRANCISCO DE ASIS DE YARUSYACAN', 'A', 'I', 183),
(1830, '190109', 'SIMON BOLIVAR', 'A', 'I', 183),
(1831, '190110', 'TICLACAYAN', 'A', 'I', 183),
(1832, '190111', 'TINYAHUARCO', 'A', 'I', 183),
(1833, '190112', 'VICCO', 'A', 'I', 183),
(1834, '190113', 'YANACANCHA', 'A', 'I', 183),
(1835, '190201', 'YANAHUANCA', 'A', 'I', 184),
(1836, '190202', 'CHACAYAN', 'A', 'I', 184),
(1837, '190203', 'GOYLLARISQUIZGA', 'A', 'I', 184),
(1838, '190204', 'PAUCAR', 'A', 'I', 184),
(1839, '190205', 'SAN PEDRO DE PILLAO', 'A', 'I', 184),
(1840, '190206', 'SANTA ANA DE TUSI', 'A', 'I', 184),
(1841, '190207', 'TAPUC', 'A', 'I', 184),
(1842, '190208', 'VILCABAMBA', 'A', 'I', 184),
(1843, '190301', 'OXAPAMPA', 'A', 'I', 185),
(1844, '190302', 'CHONTABAMBA', 'A', 'I', 185),
(1845, '190303', 'HUANCABAMBA', 'A', 'I', 185),
(1846, '190304', 'PALCAZU', 'A', 'I', 185),
(1847, '190305', 'POZUZO', 'A', 'I', 185),
(1848, '190306', 'PUERTO BERMUDEZ', 'A', 'I', 185),
(1849, '190307', 'VILLA RICA', 'A', 'I', 185),
(1850, '190308', 'CONSTITUCION', 'A', 'I', 185),
(1851, '200101', 'PIURA', 'A', 'I', 186),
(1852, '200104', 'CASTILLA', 'A', 'I', 186),
(1853, '200105', 'CATACAOS', 'A', 'I', 186),
(1854, '200107', 'CURA MORI', 'A', 'I', 186),
(1855, '200108', 'EL TALLAN', 'A', 'I', 186),
(1856, '200109', 'LA ARENA', 'A', 'I', 186),
(1857, '200110', 'LA UNION', 'A', 'I', 186),
(1858, '200111', 'LAS LOMAS', 'A', 'I', 186),
(1859, '200114', 'TAMBO GRANDE', 'A', 'I', 186),
(1860, '200115', 'VEINTISEIS DE OCTUBRE', 'A', 'I', 186),
(1861, '200201', 'AYABACA', 'A', 'I', 187),
(1862, '200202', 'FRIAS', 'A', 'I', 187),
(1863, '200203', 'JILILI', 'A', 'I', 187),
(1864, '200204', 'LAGUNAS', 'A', 'I', 187),
(1865, '200205', 'MONTERO', 'A', 'I', 187),
(1866, '200206', 'PACAIPAMPA', 'A', 'I', 187),
(1867, '200207', 'PAIMAS', 'A', 'I', 187),
(1868, '200208', 'SAPILLICA', 'A', 'I', 187),
(1869, '200209', 'SICCHEZ', 'A', 'I', 187),
(1870, '200210', 'SUYO', 'A', 'I', 187),
(1871, '200301', 'HUANCABAMBA', 'A', 'I', 188),
(1872, '200302', 'CANCHAQUE', 'A', 'I', 188),
(1873, '200303', 'EL CARMEN DE LA FRONTERA', 'A', 'I', 188),
(1874, '200304', 'HUARMACA', 'A', 'I', 188),
(1875, '200305', 'LALAQUIZ', 'A', 'I', 188),
(1876, '200306', 'SAN MIGUEL DE EL FAIQUE', 'A', 'I', 188),
(1877, '200307', 'SONDOR', 'A', 'I', 188),
(1878, '200308', 'SONDORILLO', 'A', 'I', 188),
(1879, '200401', 'CHULUCANAS', 'A', 'I', 189),
(1880, '200402', 'BUENOS AIRES', 'A', 'I', 189),
(1881, '200403', 'CHALACO', 'A', 'I', 189),
(1882, '200404', 'LA MATANZA', 'A', 'I', 189),
(1883, '200405', 'MORROPON', 'A', 'I', 189),
(1884, '200406', 'SALITRAL', 'A', 'I', 189),
(1885, '200407', 'SAN JUAN DE BIGOTE', 'A', 'I', 189),
(1886, '200408', 'SANTA CATALINA DE MOSSA', 'A', 'I', 189),
(1887, '200409', 'SANTO DOMINGO', 'A', 'I', 189),
(1888, '200410', 'YAMANGO', 'A', 'I', 189),
(1889, '200501', 'PAITA', 'A', 'I', 190),
(1890, '200502', 'AMOTAPE', 'A', 'I', 190),
(1891, '200503', 'ARENAL', 'A', 'I', 190),
(1892, '200504', 'COLAN', 'A', 'I', 190),
(1893, '200505', 'LA HUACA', 'A', 'I', 190),
(1894, '200506', 'TAMARINDO', 'A', 'I', 190),
(1895, '200507', 'VICHAYAL', 'A', 'I', 190),
(1896, '200601', 'SULLANA', 'A', 'I', 191),
(1897, '200602', 'BELLAVISTA', 'A', 'I', 191),
(1898, '200603', 'IGNACIO ESCUDERO', 'A', 'I', 191),
(1899, '200604', 'LANCONES', 'A', 'I', 191),
(1900, '200605', 'MARCAVELICA', 'A', 'I', 191),
(1901, '200606', 'MIGUEL CHECA', 'A', 'I', 191),
(1902, '200607', 'QUERECOTILLO', 'A', 'I', 191),
(1903, '200608', 'SALITRAL', 'A', 'I', 191),
(1904, '200701', 'PARI¥AS', 'A', 'I', 192),
(1905, '200702', 'EL ALTO', 'A', 'I', 192),
(1906, '200703', 'LA BREA', 'A', 'I', 192),
(1907, '200704', 'LOBITOS', 'A', 'I', 192),
(1908, '200705', 'LOS ORGANOS', 'A', 'I', 192),
(1909, '200706', 'MANCORA', 'A', 'I', 192),
(1910, '200801', 'SECHURA', 'A', 'I', 193),
(1911, '200802', 'BELLAVISTA DE LA UNION', 'A', 'I', 193),
(1912, '200803', 'BERNAL', 'A', 'I', 193),
(1913, '200804', 'CRISTO NOS VALGA', 'A', 'I', 193),
(1914, '200805', 'VICE', 'A', 'I', 193),
(1915, '200806', 'RINCONADA LLICUAR', 'A', 'I', 193),
(1916, '210101', 'PUNO', 'A', 'I', 194),
(1917, '210102', 'ACORA', 'A', 'I', 194),
(1918, '210103', 'AMANTANI', 'A', 'I', 194),
(1919, '210104', 'ATUNCOLLA', 'A', 'I', 194),
(1920, '210105', 'CAPACHICA', 'A', 'I', 194),
(1921, '210106', 'CHUCUITO', 'A', 'I', 194),
(1922, '210107', 'COATA', 'A', 'I', 194),
(1923, '210108', 'HUATA', 'A', 'I', 194),
(1924, '210109', 'MA¥AZO', 'A', 'I', 194),
(1925, '210110', 'PAUCARCOLLA', 'A', 'I', 194),
(1926, '210111', 'PICHACANI', 'A', 'I', 194),
(1927, '210112', 'PLATERIA', 'A', 'I', 194),
(1928, '210113', 'SAN ANTONIO', 'A', 'I', 194),
(1929, '210114', 'TIQUILLACA', 'A', 'I', 194),
(1930, '210115', 'VILQUE', 'A', 'I', 194),
(1931, '210201', 'AZANGARO', 'A', 'I', 195),
(1932, '210202', 'ACHAYA', 'A', 'I', 195),
(1933, '210203', 'ARAPA', 'A', 'I', 195),
(1934, '210204', 'ASILLO', 'A', 'I', 195),
(1935, '210205', 'CAMINACA', 'A', 'I', 195),
(1936, '210206', 'CHUPA', 'A', 'I', 195),
(1937, '210207', 'JOSE DOMINGO CHOQUEHUANCA', 'A', 'I', 195),
(1938, '210208', 'MU¥ANI', 'A', 'I', 195),
(1939, '210209', 'POTONI', 'A', 'I', 195),
(1940, '210210', 'SAMAN', 'A', 'I', 195),
(1941, '210211', 'SAN ANTON', 'A', 'I', 195),
(1942, '210212', 'SAN JOSE', 'A', 'I', 195),
(1943, '210213', 'SAN JUAN DE SALINAS', 'A', 'I', 195),
(1944, '210214', 'SANTIAGO DE PUPUJA', 'A', 'I', 195),
(1945, '210215', 'TIRAPATA', 'A', 'I', 195),
(1946, '210301', 'MACUSANI', 'A', 'I', 196),
(1947, '210302', 'AJOYANI', 'A', 'I', 196),
(1948, '210303', 'AYAPATA', 'A', 'I', 196),
(1949, '210304', 'COASA', 'A', 'I', 196),
(1950, '210305', 'CORANI', 'A', 'I', 196),
(1951, '210306', 'CRUCERO', 'A', 'I', 196),
(1952, '210307', 'ITUATA', 'A', 'I', 196),
(1953, '210308', 'OLLACHEA', 'A', 'I', 196),
(1954, '210309', 'SAN GABAN', 'A', 'I', 196),
(1955, '210310', 'USICAYOS', 'A', 'I', 196),
(1956, '210401', 'JULI', 'A', 'I', 197),
(1957, '210402', 'DESAGUADERO', 'A', 'I', 197),
(1958, '210403', 'HUACULLANI', 'A', 'I', 197),
(1959, '210404', 'KELLUYO', 'A', 'I', 197),
(1960, '210405', 'PISACOMA', 'A', 'I', 197),
(1961, '210406', 'POMATA', 'A', 'I', 197),
(1962, '210407', 'ZEPITA', 'A', 'I', 197),
(1963, '210501', 'ILAVE', 'A', 'I', 198),
(1964, '210502', 'CAPAZO', 'A', 'I', 198),
(1965, '210503', 'PILCUYO', 'A', 'I', 198),
(1966, '210504', 'SANTA ROSA', 'A', 'I', 198),
(1967, '210505', 'CONDURIRI', 'A', 'I', 198),
(1968, '210601', 'HUANCANE', 'A', 'I', 199),
(1969, '210602', 'COJATA', 'A', 'I', 199),
(1970, '210603', 'HUATASANI', 'A', 'I', 199),
(1971, '210604', 'INCHUPALLA', 'A', 'I', 199),
(1972, '210605', 'PUSI', 'A', 'I', 199),
(1973, '210606', 'ROSASPATA', 'A', 'I', 199),
(1974, '210607', 'TARACO', 'A', 'I', 199),
(1975, '210608', 'VILQUE CHICO', 'A', 'I', 199),
(1976, '210701', 'LAMPA', 'A', 'I', 200),
(1977, '210702', 'CABANILLA', 'A', 'I', 200),
(1978, '210703', 'CALAPUJA', 'A', 'I', 200),
(1979, '210704', 'NICASIO', 'A', 'I', 200),
(1980, '210705', 'OCUVIRI', 'A', 'I', 200),
(1981, '210706', 'PALCA', 'A', 'I', 200),
(1982, '210707', 'PARATIA', 'A', 'I', 200),
(1983, '210708', 'PUCARA', 'A', 'I', 200),
(1984, '210709', 'SANTA LUCIA', 'A', 'I', 200),
(1985, '210710', 'VILAVILA', 'A', 'I', 200),
(1986, '210801', 'AYAVIRI', 'A', 'I', 201),
(1987, '210802', 'ANTAUTA', 'A', 'I', 201),
(1988, '210803', 'CUPI', 'A', 'I', 201),
(1989, '210804', 'LLALLI', 'A', 'I', 201),
(1990, '210805', 'MACARI', 'A', 'I', 201),
(1991, '210806', 'NU¥OA', 'A', 'I', 201),
(1992, '210807', 'ORURILLO', 'A', 'I', 201),
(1993, '210808', 'SANTA ROSA', 'A', 'I', 201),
(1994, '210809', 'UMACHIRI', 'A', 'I', 201),
(1995, '210901', 'MOHO', 'A', 'I', 202),
(1996, '210902', 'CONIMA', 'A', 'I', 202),
(1997, '210903', 'HUAYRAPATA', 'A', 'I', 202),
(1998, '210904', 'TILALI', 'A', 'I', 202),
(1999, '211001', 'PUTINA', 'A', 'I', 203),
(2000, '211002', 'ANANEA', 'A', 'I', 203),
(2001, '211003', 'PEDRO VILCA APAZA', 'A', 'I', 203),
(2002, '211004', 'QUILCAPUNCU', 'A', 'I', 203),
(2003, '211005', 'SINA', 'A', 'I', 203),
(2004, '211101', 'JULIACA', 'A', 'I', 204),
(2005, '211102', 'CABANA', 'A', 'I', 204),
(2006, '211103', 'CABANILLAS', 'A', 'I', 204),
(2007, '211104', 'CARACOTO', 'A', 'I', 204),
(2008, '211105', 'SAN MIGUEL', 'A', 'I', 204),
(2009, '211201', 'SANDIA', 'A', 'I', 205),
(2010, '211202', 'CUYOCUYO', 'A', 'I', 205),
(2011, '211203', 'LIMBANI', 'A', 'I', 205),
(2012, '211204', 'PATAMBUCO', 'A', 'I', 205),
(2013, '211205', 'PHARA', 'A', 'I', 205),
(2014, '211206', 'QUIACA', 'A', 'I', 205),
(2015, '211207', 'SAN JUAN DEL ORO', 'A', 'I', 205),
(2016, '211208', 'YANAHUAYA', 'A', 'I', 205),
(2017, '211209', 'ALTO INAMBARI', 'A', 'I', 205),
(2018, '211210', 'SAN PEDRO DE PUTINA PUNCO', 'A', 'I', 205),
(2019, '211301', 'YUNGUYO', 'A', 'I', 206),
(2020, '211302', 'ANAPIA', 'A', 'I', 206),
(2021, '211303', 'COPANI', 'A', 'I', 206),
(2022, '211304', 'CUTURAPI', 'A', 'I', 206),
(2023, '211305', 'OLLARAYA', 'A', 'I', 206),
(2024, '211306', 'TINICACHI', 'A', 'I', 206),
(2025, '211307', 'UNICACHI', 'A', 'I', 206),
(2026, '220101', 'MOYOBAMBA', 'A', 'I', 207),
(2027, '220102', 'CALZADA', 'A', 'I', 207),
(2028, '220103', 'HABANA', 'A', 'I', 207),
(2029, '220104', 'JEPELACIO', 'A', 'I', 207),
(2030, '220105', 'SORITOR', 'A', 'I', 207),
(2031, '220106', 'YANTALO', 'A', 'I', 207),
(2032, '220201', 'BELLAVISTA', 'A', 'I', 208),
(2033, '220202', 'ALTO BIAVO', 'A', 'I', 208),
(2034, '220203', 'BAJO BIAVO', 'A', 'I', 208),
(2035, '220204', 'HUALLAGA', 'A', 'I', 208),
(2036, '220205', 'SAN PABLO', 'A', 'I', 208),
(2037, '220206', 'SAN RAFAEL', 'A', 'I', 208),
(2038, '220301', 'SAN JOSE DE SISA', 'A', 'I', 209),
(2039, '220302', 'AGUA BLANCA', 'A', 'I', 209),
(2040, '220303', 'SAN MARTIN', 'A', 'I', 209),
(2041, '220304', 'SANTA ROSA', 'A', 'I', 209),
(2042, '220305', 'SHATOJA', 'A', 'I', 209),
(2043, '220401', 'SAPOSOA', 'A', 'I', 210),
(2044, '220402', 'ALTO SAPOSOA', 'A', 'I', 210),
(2045, '220403', 'EL ESLABON', 'A', 'I', 210),
(2046, '220404', 'PISCOYACU', 'A', 'I', 210),
(2047, '220405', 'SACANCHE', 'A', 'I', 210),
(2048, '220406', 'TINGO DE SAPOSOA', 'A', 'I', 210),
(2049, '220501', 'LAMAS', 'A', 'I', 211),
(2050, '220502', 'ALONSO DE ALVARADO', 'A', 'I', 211),
(2051, '220503', 'BARRANQUITA', 'A', 'I', 211),
(2052, '220504', 'CAYNARACHI', 'A', 'I', 211),
(2053, '220505', 'CU¥UMBUQUI', 'A', 'I', 211),
(2054, '220506', 'PINTO RECODO', 'A', 'I', 211),
(2055, '220507', 'RUMISAPA', 'A', 'I', 211),
(2056, '220508', 'SAN ROQUE DE CUMBAZA', 'A', 'I', 211),
(2057, '220509', 'SHANAO', 'A', 'I', 211),
(2058, '220510', 'TABALOSOS', 'A', 'I', 211),
(2059, '220511', 'ZAPATERO', 'A', 'I', 211),
(2060, '220601', 'JUANJUI', 'A', 'I', 212),
(2061, '220602', 'CAMPANILLA', 'A', 'I', 212),
(2062, '220603', 'HUICUNGO', 'A', 'I', 212),
(2063, '220604', 'PACHIZA', 'A', 'I', 212),
(2064, '220605', 'PAJARILLO', 'A', 'I', 212),
(2065, '220701', 'PICOTA', 'A', 'I', 213),
(2066, '220702', 'BUENOS AIRES', 'A', 'I', 213),
(2067, '220703', 'CASPISAPA', 'A', 'I', 213),
(2068, '220704', 'PILLUANA', 'A', 'I', 213),
(2069, '220705', 'PUCACACA', 'A', 'I', 213),
(2070, '220706', 'SAN CRISTOBAL', 'A', 'I', 213),
(2071, '220707', 'SAN HILARION', 'A', 'I', 213),
(2072, '220708', 'SHAMBOYACU', 'A', 'I', 213),
(2073, '220709', 'TINGO DE PONASA', 'A', 'I', 213),
(2074, '220710', 'TRES UNIDOS', 'A', 'I', 213),
(2075, '220801', 'RIOJA', 'A', 'I', 214),
(2076, '220802', 'AWAJUN', 'A', 'I', 214),
(2077, '220803', 'ELIAS SOPLIN VARGAS', 'A', 'I', 214),
(2078, '220804', 'NUEVA CAJAMARCA', 'A', 'I', 214),
(2079, '220805', 'PARDO MIGUEL', 'A', 'I', 214),
(2080, '220806', 'POSIC', 'A', 'I', 214),
(2081, '220807', 'SAN FERNANDO', 'A', 'I', 214),
(2082, '220808', 'YORONGOS', 'A', 'I', 214),
(2083, '220809', 'YURACYACU', 'A', 'I', 214),
(2084, '220901', 'TARAPOTO', 'A', 'I', 215),
(2085, '220902', 'ALBERTO LEVEAU', 'A', 'I', 215),
(2086, '220903', 'CACATACHI', 'A', 'I', 215),
(2087, '220904', 'CHAZUTA', 'A', 'I', 215),
(2088, '220905', 'CHIPURANA', 'A', 'I', 215),
(2089, '220906', 'EL PORVENIR', 'A', 'I', 215),
(2090, '220907', 'HUIMBAYOC', 'A', 'I', 215),
(2091, '220908', 'JUAN GUERRA', 'A', 'I', 215),
(2092, '220909', 'LA BANDA DE SHILCAYO', 'A', 'I', 215),
(2093, '220910', 'MORALES', 'A', 'I', 215),
(2094, '220911', 'PAPAPLAYA', 'A', 'I', 215),
(2095, '220912', 'SAN ANTONIO', 'A', 'I', 215),
(2096, '220913', 'SAUCE', 'A', 'I', 215),
(2097, '220914', 'SHAPAJA', 'A', 'I', 215),
(2098, '221001', 'TOCACHE', 'A', 'I', 216),
(2099, '221002', 'NUEVO PROGRESO', 'A', 'I', 216),
(2100, '221003', 'POLVORA', 'A', 'I', 216),
(2101, '221004', 'SHUNTE', 'A', 'I', 216),
(2102, '221005', 'UCHIZA', 'A', 'I', 216),
(2103, '230101', 'TACNA', 'A', 'I', 217),
(2104, '230102', 'ALTO DE LA ALIANZA', 'A', 'I', 217),
(2105, '230103', 'CALANA', 'A', 'I', 217),
(2106, '230104', 'CIUDAD NUEVA', 'A', 'I', 217),
(2107, '230105', 'INCLAN', 'A', 'I', 217),
(2108, '230106', 'PACHIA', 'A', 'I', 217),
(2109, '230107', 'PALCA', 'A', 'I', 217),
(2110, '230108', 'POCOLLAY', 'A', 'I', 217),
(2111, '230109', 'SAMA', 'A', 'I', 217),
(2112, '230110', 'CORONEL GREGORIO ALBARRACIN LANCHIPA', 'A', 'I', 217),
(2113, '230111', 'LA YARADA LOS PALOS', 'A', 'I', 217),
(2114, '230201', 'CANDARAVE', 'A', 'I', 218),
(2115, '230202', 'CAIRANI', 'A', 'I', 218),
(2116, '230203', 'CAMILACA', 'A', 'I', 218),
(2117, '230204', 'CURIBAYA', 'A', 'I', 218),
(2118, '230205', 'HUANUARA', 'A', 'I', 218),
(2119, '230206', 'QUILAHUANI', 'A', 'I', 218),
(2120, '230301', 'LOCUMBA', 'A', 'I', 219),
(2121, '230302', 'ILABAYA', 'A', 'I', 219),
(2122, '230303', 'ITE', 'A', 'I', 219),
(2123, '230401', 'TARATA', 'A', 'I', 220),
(2124, '230402', 'HEROES ALBARRACIN', 'A', 'I', 220),
(2125, '230403', 'ESTIQUE', 'A', 'I', 220),
(2126, '230404', 'ESTIQUE-PAMPA', 'A', 'I', 220),
(2127, '230405', 'SITAJARA', 'A', 'I', 220),
(2128, '230406', 'SUSAPAYA', 'A', 'I', 220),
(2129, '230407', 'TARUCACHI', 'A', 'I', 220),
(2130, '230408', 'TICACO', 'A', 'I', 220),
(2131, '240101', 'TUMBES', 'A', 'I', 221),
(2132, '240102', 'CORRALES', 'A', 'I', 221),
(2133, '240103', 'LA CRUZ', 'A', 'I', 221),
(2134, '240104', 'PAMPAS DE HOSPITAL', 'A', 'I', 221),
(2135, '240105', 'SAN JACINTO', 'A', 'I', 221),
(2136, '240106', 'SAN JUAN DE LA VIRGEN', 'A', 'I', 221),
(2137, '240201', 'ZORRITOS', 'A', 'I', 222),
(2138, '240202', 'CASITAS', 'A', 'I', 222),
(2139, '240203', 'CANOAS DE PUNTA SAL', 'A', 'I', 222),
(2140, '240301', 'ZARUMILLA', 'A', 'I', 223),
(2141, '240302', 'AGUAS VERDES', 'A', 'I', 223),
(2142, '240303', 'MATAPALO', 'A', 'I', 223),
(2143, '240304', 'PAPAYAL', 'A', 'I', 223),
(2144, '250101', 'CALLERIA', 'A', 'I', 224),
(2145, '250102', 'CAMPOVERDE', 'A', 'I', 224),
(2146, '250103', 'IPARIA', 'A', 'I', 224),
(2147, '250104', 'MASISEA', 'A', 'I', 224),
(2148, '250105', 'YARINACOCHA', 'A', 'I', 224),
(2149, '250106', 'NUEVA REQUENA', 'A', 'I', 224),
(2150, '250107', 'MANANTAY', 'A', 'I', 224),
(2151, '250201', 'RAYMONDI', 'A', 'I', 225),
(2152, '250202', 'SEPAHUA', 'A', 'I', 225),
(2153, '250203', 'TAHUANIA', 'A', 'I', 225),
(2154, '250204', 'YURUA', 'A', 'I', 225),
(2155, '250301', 'PADRE ABAD', 'A', 'I', 226),
(2156, '250302', 'IRAZOLA', 'A', 'I', 226),
(2157, '250303', 'CURIMANA', 'A', 'I', 226),
(2158, '250304', 'NESHUYA', 'A', 'I', 226),
(2159, '250305', 'ALEXANDER VON HUMBOLDT', 'A', 'I', 226),
(2160, '250401', 'PURUS', 'A', 'I', 227);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unit`
--

DROP TABLE IF EXISTS `units`;
CREATE TABLE IF NOT EXISTS `units` (
  `id_unit` smallint(2) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `abbreviation` varchar(10) NOT NULL,
  `type` varchar(5) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_unit`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unit_conversion`
--

DROP TABLE IF EXISTS `unit_conversions`;
CREATE TABLE IF NOT EXISTS `unit_conversions` (
  `id_unit_conversion` smallint(2) NOT NULL AUTO_INCREMENT,
  `id_unit_higher` smallint(2) NOT NULL,
  `id_unit_smaller` smallint(2) NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_unit_conversion`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehicle`
--

DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id_vehicle` int(4) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL,
  `license_plate` varchar(10) NOT NULL,
  `id_employee_driver_assigned` int(4) DEFAULT NULL,
  `internal_code` varchar(20) NOT NULL,
  `type_vehicle` varchar(5) NOT NULL,
  `passenger_capacity` tinyint(2) DEFAULT NULL,
  `load_capacity_kg` smallint(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_vehicle`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `warehouse`
--

DROP TABLE IF EXISTS `warehouses`;
CREATE TABLE IF NOT EXISTS `warehouses` (
  `id_warehouse` smallint(2) NOT NULL AUTO_INCREMENT,
  `short_name` varchar(20) NOT NULL,
  `long_name` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `id_local` int(4) NOT NULL,
  `id_responsible_employee` int(4) DEFAULT NULL,
  `state` varchar(5) NOT NULL,
  `user_creation` smallint(4) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_edit` smallint(4) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id_warehouse`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;