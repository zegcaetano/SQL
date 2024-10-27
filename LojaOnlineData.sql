USE BuyDB;

INSERT INTO Operator (firstname, surname, email, `password`) 
VALUES
('Rui', 'Pereira', 'rui.pereira@email.com', 'P3r31r4!Rui'),
('Cláudia', 'Santos', 'claudia.santos@email.com', '5porting$Claudia'),
('Mário', 'Almeida', 'mario.almeida@email.com', '#MariobEnF1c4'),
('Joana', 'Nunes', 'joana.nunes@email.com', 'Tit4nic?Joana'),
('Pedro', 'Cruz', 'pedro.cruz@email.com', 'H4rry%Pedro');

INSERT INTO `Client` (firstname, surname, email, `password`, address, zip_code, city, phone_number, birthdate) 
VALUES
('Sara', 'Oliveira', 'sara.oliveira@email.com', 'SenhaFortaleza3!', 'Rua da Liberdade, 15', 1000, 'Lisboa', '912345678', '1990-02-15'),
('Tiago', 'Ferreira', 'tiago.ferreira@email.com', 'SenhaForte?456', 'Avenida dos Descobrimentos, 45', 2000, 'Porto', '913456789', '1985-03-22'),
('Ana', 'Lima', 'ana.lima@email.com', 'Ana%12345', 'Travessa da Alegria, 30', 3000, 'Coimbra', '914567890', '1992-04-10'),
('Nuno', 'Carvalho', 'nuno.carvalho@email.com', 'Nuno$Senha1', 'Rua do Sol, 12', 4000, 'Braga', '915678901', '1988-05-30'),
('Marta', 'Gonçalves', 'marta.goncalves@email.com', 'Marta#Segura4', 'Estrada das Flores, 5', 5000, 'Aveiro', '916789012', '1995-06-25');

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

INSERT INTO Recommendation (product_id, client_id, reason, start_date) VALUES
('E001', 1, 'Produto excelente para ouvir música.', '2023-08-01'),
('E002', 2, 'Melhor smartphone do mercado.', '2023-08-05'),
('B001', 3, 'Ótima leitura para quem ama aventura.', '2023-08-10'),
('E003', 4, 'Ideal para trabalho remoto.', '2023-08-15'),
('B005', 5, 'Um romance envolvente e cativante.', '2023-08-20');

INSERT INTO Electronic (product_id, serial_number, brand, model, spec_tec, type) 
VALUES
('E001', 9876543210, 'Sony', 'WH-1000XM4', 'Cancelamento de ruído, Bluetooth', 'consumível'),
('E002', 6543210987, 'Samsung', 'Galaxy S21', 'Tela 6.2", Câmera Tripla', 'consumível'),
('E003', 3210987654, 'Apple', 'MacBook Pro', 'M1, 13", 256GB', 'consumível'),
('E004', 1234567890, 'Huawei', 'MatePad Pro', '10.8", 6GB RAM', 'consumível'),
('E005', 2468013579, 'LG', 'OLED 55"', '4K UHD, HDR', 'consumível');

INSERT INTO Book (product_id, isbn13, title, genre, publisher, publication_date) 
VALUES
('B001', '978-3-16-148410-0', 'A Magia da Leitura', 'Educação', 'Editora Lê', '2015-05-01'),
('B002', '978-1-4028-9462-6', 'O Mundo das Ideias', 'Filosofia', 'Editora do Pensamento', '2018-06-15'),
('B003', '978-0-201-53082-8', 'Histórias de Vida', 'Biografia', 'Editora Vida', '2020-03-10'),
('B004', '978-0-06-239503-3', 'Segredos da Natureza', 'Ciências', 'Editora Verde', '2019-09-20'),
('B005', '978-0-345-39180-8', 'Receitas de Família', 'Culinária', 'Editora Gourmet', '2021-12-25');

INSERT INTO Author (name, fullname, birthdate) 
VALUES
('José Saramago', 'José de Sousa Saramago', '1922-11-16'),
('Eça de Queirós', 'José Maria de Eça de Queirós', '1845-11-25'),
('Agustina Bessa-Luís', 'Agustina Bessa-Luís', '1922-04-15'),
('Fernando Pessoa', 'Fernando António Nogueira Pessoa', '1888-06-13'),
('Lídia Jorge', 'Lídia Ferreira Jorge', '1946-06-18');

INSERT INTO BookAuthor (product_id, author_id) VALUES
('B001', 1),  
('B002', 2),  
('B003', 3),  
('B004', 4),  
('B005', 5);  