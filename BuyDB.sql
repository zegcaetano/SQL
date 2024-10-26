DROP DATABASE IF EXISTS BuyDB;
CREATE DATABASE BuyDB;
USE BuyDB;

DROP USER IF EXISTS CLIENTE;
CREATE USER CLIENTE
IDENTIFIED BY 'Password123!';

GRANT SELECT, INSERT, UPDATE ON TABLE Product TO CLIENTE;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE `Order` TO CLIENTE;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE OrderedItem TO CLIENTE;
GRANT SELECT, INSERT, UPDATE ON TABLE Recommendation TO CLIENTE;
GRANT SELECT, INSERT, UPDATE ON TABLE Electronic TO CLIENTE;
GRANT SELECT, INSERT, UPDATE ON TABLE Author TO CLIENTE;
GRANT SELECT, INSERT, UPDATE ON TABLE Book TO CLIENTE;
GRANT SELECT, INSERT, UPDATE ON TABLE BookAuthor TO CLIENTE;
GRANT EXECUTE ON PROCEDURE CriarEncomenda TO CLIENTE;
GRANT EXECUTE ON PROCEDURE CalcularTotal TO CLIENTE;
GRANT EXECUTE ON PROCEDURE AdicionarProduto TO CLIENTE;


DROP USER IF EXISTS OPERATOR;
CREATE USER OPERATOR
IDENTIFIED BY 'oP3r4t0r!?';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON *.* TO OPERATOR;

DROP USER IF EXISTS ADMIN_BUYDB;
CREATE USER ADMIN_BUYDB
IDENTIFIED BY '4Dm1N!%';
GRANT ALL PRIVILEGES ON *.* TO ADMIN_BUYDB WITH GRANT OPTION;

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

INSERT INTO Operator (firstname, surname, email, password) 
VALUES
('Rui', 'Pereira', 'rui.pereira@email.com', 'P3r31r4!Rui'),
('Cláudia', 'Santos', 'claudia.santos@email.com', '5porting$Claudia'),
('Mário', 'Almeida', 'mario.almeida@email.com', '#MariobEnF1c4'),
('Joana', 'Nunes', 'joana.nunes@email.com', 'Tit4nic?Joana'),
('Pedro', 'Cruz', 'pedro.cruz@email.com', 'H4rry%Pedro');
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

/*
TESTE DO CLIENT:

INSERT INTO `Client`(firstname, surname, email, `password`, address, zip_code, city, phone_number, birthdate)
VALUES (
	"André",
    "Ferreira",
    "andre.fl.ferreira.95@gmail.com",
    "Password123!",
    "dsafdsagfda",
    1234,
    "Lisboa",
    "987654321asd",
    '1995-05-21'
);

select * from `Client`;
*/



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

INSERT INTO Client (firstname, surname, email, password, address, zip_code, city, phone_number, birthdate) 
VALUES
('Sara', 'Oliveira', 'sara.oliveira@email.com', 'SenhaFortaleza3!', 'Rua da Liberdade, 15', 1000, 'Lisboa', '912345678', '1990-02-15'),
('Tiago', 'Ferreira', 'tiago.ferreira@email.com', 'SenhaForte?456', 'Avenida dos Descobrimentos, 45', 2000, 'Porto', '913456789', '1985-03-22'),
('Ana', 'Lima', 'ana.lima@email.com', 'Ana%12345', 'Travessa da Alegria, 30', 3000, 'Coimbra', '914567890', '1992-04-10'),
('Nuno', 'Carvalho', 'nuno.carvalho@email.com', 'Nuno$Senha1', 'Rua do Sol, 12', 4000, 'Braga', '915678901', '1988-05-30'),
('Marta', 'Gonçalves', 'marta.goncalves@email.com', 'Marta#Segura4', 'Estrada das Flores, 5', 5000, 'Aveiro', '916789012', '1995-06-25');
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
    
INSERT INTO Product (id, quantity, price, vat, score, product_image, active, reason) VALUES
('E001', 20, 299.99, 23, 5, 'https://example.com/img/headphones.jpg', TRUE, NULL),
('E002', 15, 699.00, 23, 4, 'https://example.com/img/smartphone.jpg', TRUE, NULL),
('E003', 30, 1299.00, 23, 5, 'https://example.com/img/laptop.jpg', TRUE, NULL),
('E004', 25, 899.50, 23, 4, 'https://example.com/img/tablet.jpg', TRUE, NULL),
('E005', 10, 1499.99, 23, 5, 'https://example.com/img/tv.jpg', TRUE, NULL),
('B001', 100, 19.90, 6, 4, 'https://example.com/img/book1.jpg', TRUE, NULL),
('B002', 50, 29.90, 6, 5, 'https://example.com/img/book2.jpg', TRUE, NULL),
('B003', 80, 39.90, 6, 5, 'https://example.com/img/book3.jpg', TRUE, NULL),
('B004', 70, 24.90, 6, 3, 'https://example.com/img/book4.jpg', TRUE, NULL),
('B005', 90, 34.90, 6, 4, 'https://example.com/img/book5.jpg', TRUE, NULL);
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

INSERT INTO `Order` (date_time, delivery_method, status, payment_card_number, payment_card_name, payment_card_expiration, client_id) 
VALUES
('2024-01-15 10:30:00', 'regular', 'open', 1234567890123456, 'Ana Silva', '2026-12-31', 1),
('2024-02-20 14:45:00', 'urgent', 'processing', 2345678901234567, 'Pedro Gomes', '2025-05-30', 2),
('2024-03-10 09:15:00', 'regular', 'closed', 3456789012345678, 'Joana Santos', '2025-11-15', 3),
('2024-04-05 16:00:00', 'urgent', 'pending', 4567890123456789, 'Cláudia Pereira', '2027-01-01', 4),
('2024-05-25 11:00:00', 'regular', 'canceled', 5678901234567890, 'Mário Almeida', '2025-08-20', 5),
('2024-06-30 12:00:00', 'regular', 'open', 6789012345678901, 'Rui Ferreira', '2026-02-14', 1),
('2024-07-18 15:30:00', 'urgent', 'processing', 7890123456789012, 'Sofia Nunes', '2025-12-25', 2),
('2024-08-22 10:10:00', 'regular', 'closed', 8901234567890123, 'Carlos Costa', '2026-09-30', 3),
('2024-09-05 08:45:00', 'urgent', 'pending', 9012345678901234, 'Ana Sousa', '2025-04-01', 4),
('2024-10-15 13:00:00', 'regular', 'canceled', 0123456789012345, 'Fernando Alves', '2027-03-15', 5);
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

INSERT INTO OrderedItem (order_id, product_id, quantity, price, vat_amount) 
VALUES
(1, 'E001', 2, 299.99, 69.00),
(2, 'E002', 1, 699.00, 161.77),
(3, 'B001', 5, 19.90, 0.30),
(4, 'E004', 3, 899.50, 207.36),
(5, 'B005', 2, 34.90, 4.19),
(1, 'E003', 1, 1299.00, 299.77),
(2, 'B002', 3, 29.90, 5.09),
(3, 'B003', 4, 39.90, 6.60),
(4, 'E005', 1, 1499.99, 344.50),
(5, 'B004', 2, 24.90, 3.13);
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

INSERT INTO Recommendation (product_id, client_id, reason, start_date) VALUES
('E001', 1, 'Produto excelente para ouvir música.', '2023-08-01'),
('E002', 2, 'Melhor smartphone do mercado.', '2023-08-05'),
('B001', 3, 'Ótima leitura para quem ama aventura.', '2023-08-10'),
('E003', 4, 'Ideal para trabalho remoto.', '2023-08-15'),
('B005', 5, 'Um romance envolvente e cativante.', '2023-08-20');
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

INSERT INTO Electronic (product_id, serial_number, brand, model, spec_tec, type) 
VALUES
('E001', 9876543210, 'Sony', 'WH-1000XM4', 'Cancelamento de ruído, Bluetooth', 'consumível'),
('E002', 6543210987, 'Samsung', 'Galaxy S21', 'Tela 6.2", Câmera Tripla', 'consumível'),
('E003', 3210987654, 'Apple', 'MacBook Pro', 'M1, 13", 256GB', 'consumível'),
('E004', 1234567890, 'Huawei', 'MatePad Pro', '10.8", 6GB RAM', 'consumível'),
('E005', 2468013579, 'LG', 'OLED 55"', '4K UHD, HDR', 'consumível');
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
 
INSERT INTO Book (product_id, isbn13, title, genre, publisher, publication_date) 
VALUES
('B001', '978-3-16-148410-0', 'A Magia da Leitura', 'Educação', 'Editora Lê', '2015-05-01'),
('B002', '978-1-4028-9462-6', 'O Mundo das Ideias', 'Filosofia', 'Editora do Pensamento', '2018-06-15'),
('B003', '978-0-201-53082-8', 'Histórias de Vida', 'Biografia', 'Editora Vida', '2020-03-10'),
('B004', '978-0-06-239503-3', 'Segredos da Natureza', 'Ciências', 'Editora Verde', '2019-09-20'),
('B005', '978-0-345-39180-8', 'Receitas de Família', 'Culinária', 'Editora Gourmet', '2021-12-25');
 -- ---------------------------------------------------------------------
DROP TABLE IF EXISTS Author; 
CREATE TABLE Author (
	ID				INT PRIMARY KEY AUTO_INCREMENT,
    `name`			VARCHAR(100) COMMENT "Author's literary/pseudo name, for which he is known",
	fullname		VARCHAR(100) COMMENT "Author's real full name",
    birthdate		DATE NOT NULL
    );

INSERT INTO Author (name, fullname, birthdate) 
VALUES
('José Saramago', 'José de Sousa Saramago', '1922-11-16'),
('Eça de Queirós', 'José Maria de Eça de Queirós', '1845-11-25'),
('Agustina Bessa-Luís', 'Agustina Bessa-Luís', '1922-04-15'),
('Fernando Pessoa', 'Fernando António Nogueira Pessoa', '1888-06-13'),
('Lídia Jorge', 'Lídia Ferreira Jorge', '1946-06-18');
-- ----------------------------------------------------------------------
DROP TABLE IF EXISTS BookAuthor;
CREATE TABLE BookAuthor (
	id				INT PRIMARY KEY AUTO_INCREMENT,
	product_id		VARCHAR(10),
    author_id		INT,
    FOREIGN KEY (product_id) REFERENCES Book (product_id),
    FOREIGN KEY (author_id) REFERENCES Author (ID)
    );

INSERT INTO BookAuthor (product_id, author_id) VALUES
('B001', 1),  
('B002', 2),  
('B003', 3),  
('B004', 4),  
('B005', 5);  
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







