DROP DATABASE IF EXISTS BuyDB;
CREATE DATABASE BuyDB;
USE BuyDB;

-- --------------------------------------------------
DROP TABLE IF EXISTS Operator;
CREATE TABLE Operator (
	id				INTEGER PRIMARY KEY AUTO_INCREMENT,
    firstname		VARCHAR (250) NOT NULL,
	surname			VARCHAR (250) NOT NULL,
	email			VARCHAR (50) UNIQUE NOT NULL,
	`password`  	CHAR (64) NOT NULL
);
DROP FUNCTION IF EXISTS verify_password;
DELIMITER //

CREATE FUNCTION verify_password (password CHAR(64))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE password_valid BOOLEAN;

    IF CHAR_LENGTH(`password`) < 6 OR CHAR_LENGTH(`password`) > 50 
    OR NOT `password` REGEXP '[0-9]' 
    OR NOT `password` REGEXP '[a-z]' 
    OR NOT `password` REGEXP '[A-Z]' 
    OR NOT `password` REGEXP '[!$#?%]' 
    THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END//

CREATE TRIGGER validate_email_operator
BEFORE INSERT ON Operator
FOR EACH ROW
BEGIN
DECLARE email_invalid_operator CONDITION FOR SQLSTATE '45000';
    IF NEW.email NOT RLIKE "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?" THEN
        SIGNAL email_invalid_operator
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;
END //

CREATE TRIGGER validate_password_operator
BEFORE INSERT ON Operator
FOR EACH ROW
BEGIN
    DECLARE password_valid_operator BOOLEAN;
    DECLARE password_invalid_operator CONDITION FOR SQLSTATE '45001';

	IF NOT verify_password(NEW.`password`) THEN
        SIGNAL password_invalid_operator
        SET MESSAGE_TEXT = 'Password must contain at least one digit, one lowercase letter, one uppercase letter, and one special symbol (!, $, #, ?, %)';
    END IF;

    SET NEW.`password` = SHA2(NEW.`password`, 256);
END//
DELIMITER ;

-- ----------------------------------------------
DROP TABLE IF EXISTS `Client`;
CREATE TABLE `Client` (
	id				INTEGER PRIMARY KEY AUTO_INCREMENT,
    firstname		VARCHAR (250) NOT NULL,
	surname			VARCHAR (250) NOT NULL,
	email			VARCHAR (50) UNIQUE NOT NULL,
	`password`  	CHAR (64) NOT NULL,
	address			VARCHAR (100) NOT NULL,
	zip_code		SMALLINT NOT NULL,
    city			VARCHAR (30) NOT NULL,
    country			VARCHAR (30) NOT NULL DEFAULT 'Portugal',
    phone_number	VARCHAR (15),
    last_login 		TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    birthdate		DATE NOT NULL
);

DELIMITER //
DROP TRIGGER IF EXISTS validate_email_client//
CREATE TRIGGER validate_email_client
BEFORE INSERT ON `Client`
FOR EACH ROW
BEGIN
DECLARE email_invalid CONDITION FOR SQLSTATE '45002';
    IF NEW.Email NOT RLIKE "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?" THEN
        SIGNAL email_invalid
        SET MESSAGE_TEXT = 'Invalid email format';
    END IF;
END //

DROP TRIGGER IF EXISTS validate_password_client//
CREATE TRIGGER validate_password_client
BEFORE INSERT ON `Client`
FOR EACH ROW
BEGIN
    DECLARE password_invalid_client CONDITION FOR SQLSTATE '45003';

    IF NOT verify_password(NEW.`password`) THEN
        SIGNAL password_invalid_client
        SET MESSAGE_TEXT = 'Password must contain at least one digit, one lowercase letter, one uppercase letter, and one special symbol (!, $, #, ?, %)';
    END IF;

    SET NEW.`password` = SHA2(NEW.`password`, 256);
END//

DROP TRIGGER IF EXISTS validate_phone_number_client//
CREATE TRIGGER validate_phone_number_client
BEFORE INSERT ON `Client`
FOR EACH ROW
BEGIN
	DECLARE phone_number_invalid_client CONDITION FOR SQLSTATE '45004';
    DECLARE phone_number_valid_client BOOLEAN;
    
    IF CHAR_LENGTH(NEW.phone_number) < 6 OR CHAR_LENGTH(NEW.phone_number) > 15 THEN
        SIGNAL phone_number_invalid_client
        SET MESSAGE_TEXT = 'Phone number must be at least 6 to 15 digits long';
    END IF;
    
    SET phone_number_valid_client = NEW.phone_number REGEXP '[0-9]';
    
    IF NOT phone_number_valid_client THEN
        SIGNAL phone_number_invalid_client
        SET MESSAGE_TEXT = 'Phone number must be at least 6 to 15 digits long';
	END IF;
END//
DELIMITER ;
-- ----------------------------------------------------
DROP TABLE IF EXISTS Product;
CREATE TABLE Product (
	id				VARCHAR(10) PRIMARY KEY,
    quantity		INT UNSIGNED NOT NULL,
	price			DECIMAL(6,2) UNSIGNED NOT NULL,
    vat				FLOAT NOT NULL CHECK (vat BETWEEN 0 AND 100),
	score			SMALLINT CHECK (score BETWEEN 1 AND 5),
    product_image	VARCHAR(500),
    `active`		BOOL NOT NULL DEFAULT TRUE,
    reason			VARCHAR(500) COMMENT "Motivo de inatividade"
    );

    -- ------------------------------------------------------
DROP TABLE IF EXISTS `Order`;
CREATE TABLE `Order` (
	id 							INTEGER PRIMARY KEY AUTO_INCREMENT,
    date_time 					DATETIME DEFAULT (CURRENT_DATE()),
    delivery_method 			VARCHAR(10) DEFAULT 'regular' CHECK (delivery_method IN ('regular', 'urgent')),
    `status` 					VARCHAR(10) DEFAULT 'open' CHECK (`status` IN ('open', 'processing', 'pending', 'closed', 'canceled')),
    payment_card_number 		LONG,
    payment_card_name 			VARCHAR (20) NOT NULL,
    payment_card_expiration 	DATE NOT NULL,
    client_id 					INT,
    
    FOREIGN KEY (client_id) REFERENCES `Client`(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------------
DROP TABLE IF EXISTS OrderedItem;
CREATE TABLE OrderedItem (
	id 							INTEGER PRIMARY KEY AUTO_INCREMENT,
    order_id 					INT,
    product_id 					VARCHAR(10),
    quantity 					INT UNSIGNED NOT NULL,
    price 						INT UNSIGNED NOT NULL,
    vat_amount 					DECIMAL(10,2) UNSIGNED NOT NULL,
    
    FOREIGN KEY (order_id) REFERENCES `Order`(id) ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(id) ON UPDATE CASCADE
);
-- ------------------------------------------------------------------------
DROP TABLE IF EXISTS Recommendation;
CREATE TABLE Recommendation(
	id 				INT PRIMARY KEY AUTO_INCREMENT,
    product_id 		VARCHAR(10),
    client_id 		INT,
    reason 			VARCHAR (500),
    start_date 		DATE,
    
    FOREIGN KEY (client_id) REFERENCES `Client`(id) ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(id) ON UPDATE CASCADE
);
-- ----------------------------------------------------------------------
DROP TABLE IF EXISTS Electronic;
CREATE TABLE Electronic (
	product_id			VARCHAR(10) PRIMARY KEY,
    serial_number		BIGINT UNIQUE NOT NULL,
    brand				VARCHAR(20) NOT NULL,
    model				VARCHAR(20) NOT NULL,
    spec_tec			TEXT,
    `type`				VARCHAR(10) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Product (id)
    );
-- -----------------------------------------------------------  
DROP TABLE IF EXISTS Book;
CREATE TABLE Book (
	product_id			VARCHAR(10) PRIMARY KEY,
	isbn13				VARCHAR(20) NOT NULL UNIQUE,
    title				VARCHAR(50) NOT NULL,
    genre				VARCHAR(50) NOT NULL,
    publisher			VARCHAR(100) NOT NULL,
    publication_date	DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Product (id)
    );
DROP TRIGGER IF EXISTS validate_isbn13;
DELIMITER //

CREATE TRIGGER validate_isbn13
BEFORE INSERT ON Book
FOR EACH ROW
	BEGIN
		IF NEW.isbn13 REGEXP '^-|-$' THEN
			SIGNAL SQLSTATE '45005'
            SET MESSAGE_TEXT = 'ISBN13 cannot start or end with a hyphen';
		END IF;
        
        IF NOT NEW.isbn13 REGEXP '^[A-Z0-9-]+$' THEN
			SIGNAL SQLSTATE '45006' 
            SET MESSAGE_TEXT = 'ISBN13 can only contain uppercase letters, digits, and hyphens';
		END IF;
        
        IF LENGTH(REPLACE(NEW.isbn13, '-', '')) <> 13 THEN
			SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'ISBN13 must have exactly 13 characters after removing hyphens';
		END IF;
	END//

DELIMITER ; 

 -- ---------------------------------------------------------------------
DROP TABLE IF EXISTS Author; 
CREATE TABLE Author (
	ID				INT PRIMARY KEY AUTO_INCREMENT,
    `name`			VARCHAR(100) COMMENT "Author's literary/pseudo name, for which he is known",
	fullname		VARCHAR(100) COMMENT "Author's real full name",
    birthdate		DATE NOT NULL
    );

-- ----------------------------------------------------------------------
DROP TABLE IF EXISTS BookAuthor;
CREATE TABLE BookAuthor (
	id				INT PRIMARY KEY AUTO_INCREMENT,
	product_id		VARCHAR(10),
    author_id		INT,
    FOREIGN KEY (product_id) REFERENCES Book (product_id),
    FOREIGN KEY (author_id) REFERENCES Author (ID)
    );
-- -----------------------------------------------------------------------
-- 1.
DELIMITER //
DROP PROCEDURE IF EXISTS ProdutoPorTipo//
CREATE PROCEDURE ProdutoPorTipo (IN Product VARCHAR(50))
BEGIN
    IF Product = "Book" THEN
    SELECT Product.id, Book.product_id, "Book" AS Product_Type, price, score, product_image, `active` FROM Product
    JOIN Book
    ON Product.id = Book.product_id;
    
    ELSEIF Product = "Electronic" THEN
    SELECT Product.id, Electronic.product_id, "Electronic" AS Product_Type, price, score, product_image, `active` FROM Product
    JOIN Electronic
    ON Product.id = Electronic.product_id;
    
    ELSE
    SELECT Product.id, Book.product_id, Electronic.product_id, price, score, product_image, `active`,
		CASE 
		   WHEN Book.product_id IS NOT NULL THEN 'Book' 
		   WHEN Electronic.product_id IS NOT NULL THEN 'Electronic' 
		   ELSE 'Unknown'
	   END AS product_type
	FROM Product
    JOIN Book
    ON Product.id = Book.product_id
    JOIN Electronic
    ON Product.id = Electronic.product_id;
	END IF;
END//

-- 2.
DROP PROCEDURE IF EXISTS EncomendasDiarias//

CREATE PROCEDURE EncomendasDiarias(IN `data` DATE)
BEGIN
    SELECT 		*
    FROM 		`Order`
    WHERE DATE(date_time) = `data`;
END//

-- 3.
DROP PROCEDURE IF EXISTS EncomendasAnuais//
CREATE PROCEDURE EncomendasAnuais (IN `Client` INT, `Year` YEAR)
BEGIN
    SELECT `Client`.id, CONCAT(firstname, " ", surname) AS Fullname, `status`, delivery_method, date_time
    FROM `Client`
    JOIN `Order`
    ON `CLient`.id = `Order`.id
    WHERE YEAR(date_time) = `Year`
    AND `Client` = `Client`.id;
END//

-- 4.
DROP PROCEDURE IF EXISTS CriarEncomenda//

CREATE PROCEDURE CriarEncomenda(
    IN ID_Cliente INT,
    IN Metodo VARCHAR(10),
    IN Nr_Cartao BIGINT,
    IN Nome_Cartao VARCHAR(20),
    IN Data_Validade DATE
)
BEGIN
    INSERT INTO `Order` (
        client_id,
        delivery_method,
        payment_card_number,
        payment_card_name,
        payment_card_expiration,
        `status`,
        date_time
    ) VALUES (
        ID_Cliente,
        Metodo,
        Nr_Cartao,
        Nome_Cartao,
        Data_Validade,
        'open',  
        NOW()    
    );
END//

-- 5.
DROP PROCEDURE IF EXISTS CalcularTotal//
CREATE PROCEDURE CalcularTotal (IN `Order` INT)
BEGIN
    SELECT `Order`.id, OrderedItem.order_id, OrderedItem.quantity, Product.price, Product.vat, (OrderedItem.quantity * Product.price) * (Product.vat / 100) AS FinalPrice
    FROM `Order`
    JOIN OrderedItem
    ON OrderedItem.order_id = `Order`.id
    JOIN Product
    ON Product.id = OrderedItem.product_id
    WHERE `Order` = `Order`.id;
END//

-- 6.
DROP PROCEDURE IF EXISTS AdicionarProduto//

CREATE PROCEDURE AdicionarProduto(
    IN encomenda_id INT,
    IN produto_id VARCHAR(10),
    IN quantidade INT
)
BEGIN
    DECLARE preco_produto DECIMAL(5,2);
    DECLARE iva_produto FLOAT;
    DECLARE quantidade_produto INT;
    DECLARE preço_total DECIMAL(10,2);
    DECLARE valor_iva DECIMAL(10,2);

    IF NOT EXISTS (SELECT 1 FROM `Order` WHERE id = encomenda_id) THEN
        SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'Ordern not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Product WHERE id = produto_id) THEN
        SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'Product not found';
    END IF;

    SELECT price, vat, quantity INTO preco_produto, iva_produto, quantidade_produto
    FROM Product
    WHERE id = produto_id;

    IF quantidade_produto < quantidade THEN
        SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'Not enough quantity in stock';
    END IF;

    SET preco_total = preco_produto * quantidade;
    SET valor_iva = preco_total * (iva_produto / 100);

    INSERT INTO OrderedItem (order_id, product_id, quantity, price, vat_amount)
    VALUES (encomenda_id, produto_id, quantidade, preco_total, valor_iva);

    UPDATE Product
    SET quantity = quantity - quantidade
    WHERE id = produto_id;
END//

-- 7.
DROP PROCEDURE IF EXISTS CriarLivro//
DELIMITER //
CREATE PROCEDURE CriarLivro(
	IN p_id 				VARCHAR(10),
    IN p_quantidade 		INT UNSIGNED,
    IN p_preco 				DECIMAL(5,2) UNSIGNED,
    IN p_iva 				FLOAT,
    IN p_classificacao 		SMALLINT,
    IN p_imagem_produto 	VARCHAR(500),
    IN p_ativo 				BOOL,
    IN p_motivo 			VARCHAR(500),
	IN b_isbn13				VARCHAR(20),
    IN b_titulo				VARCHAR(50),
    IN b_genero				VARCHAR(50),
    IN b_editora			VARCHAR(100),
    IN b_data_publicacao	DATE
)
BEGIN
    DECLARE produto_existe BOOLEAN;
    SET produto_existe = (SELECT COUNT(*) > 0 FROM Product WHERE id = p_id);

    IF produto_existe THEN
        SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'Product already exists in table Product';
    ELSE
        INSERT INTO Product (id, quantity, price, vat, score, product_image, `active`, reason)
        VALUES (p_id, p_quantidade, p_preco, p_iva, p_classificacao, p_imagem_produto, p_ativo, p_motivo);

        INSERT INTO Book (product_id, isbn13, title, genre, publisher, publication_date)
        VALUES (p_id, b_isbn13, b_titulo, b_genero, b_editora, b_data_publicacao);
    END IF;
END//

-- 8.
DROP PROCEDURE IF EXISTS CriarConsumivelElec//
CREATE PROCEDURE CriarConsumivelElec(
    IN p_id VARCHAR(10),
    IN p_quantidade INT UNSIGNED,
    IN p_preco DECIMAL(5,2) UNSIGNED,
    IN p_iva FLOAT,
    IN p_classificacao SMALLINT,
    IN p_imagem_produto VARCHAR(500),
    IN p_ativo BOOL,
    IN p_motivo VARCHAR(500),
    IN e_numero_serie BIGINT,
    IN e_marca VARCHAR(20),
    IN e_modelo VARCHAR(20),
    IN e_especificacoes_tecnicas TEXT,
    IN e_tipo VARCHAR(10)
)
BEGIN
    DECLARE produto_existe BOOLEAN;
    SET produto_existe = (SELECT COUNT(*) > 0 FROM Product WHERE id = p_id);

    IF produto_existe THEN
        SIGNAL SQLSTATE '45012' SET MESSAGE_TEXT = 'Product already exists in table Product';
    ELSE
        INSERT INTO Product (id, quantity, price, vat, score, product_image, `active`, reason)
        VALUES (p_id, p_quantidade, p_preco, p_iva, p_classificacao, p_imagem_produto, p_ativo, p_motivo);

        INSERT INTO Electronic (product_id, serial_number, brand, model, spec_tec, `type`)
        VALUES (p_id, e_numero_serie, e_marca, e_modelo, e_especificacoes_tecnicas, e_tipo);
    END IF;
END//
DELIMITER ;







