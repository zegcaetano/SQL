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