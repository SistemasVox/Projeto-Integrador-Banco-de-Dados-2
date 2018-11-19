DROP database Hotel;
CREATE database Hotel;
USE Hotel;

CREATE TABLE Hospede (
    Nome_hospede VARCHAR(256) NOT NULL,
    CPF VARCHAR(14) NOT NULL UNIQUE,
    sexo ENUM('F', 'M'),
    telCliente VARCHAR(15) NOT NULL,
    Data_entrada DATE NOT NULL,
    Data_saida DATE,
    Num_nota_Fiscal INT NOT NULL UNIQUE,
    PRIMARY KEY (CPF)
);

CREATE TABLE Apartamentos (
    Cod_apartamento INT NOT NULL AUTO_INCREMENT,
    Tipo_apartamento ENUM('Casal', 'Solteiro', 'Suíte', 'Presidencial'),
    PRIMARY KEY (Cod_apartamento) -- Chave Primária.
);

CREATE TABLE valorDiariasAptos (
    Cod_apartamento INT NOT NULL,
    valor_Apto NUMERIC(10 , 2 ),
    FOREIGN KEY (Cod_apartamento)
        REFERENCES Apartamentos (Cod_apartamento)
);

CREATE TABLE Reserva (
    Cod_reserva INT NOT NULL AUTO_INCREMENT,
    Tempo_Hospedagem INT(3) NOT NULL,
    Data_reserva DATE NOT NULL,
    CPF VARCHAR(14) NOT NULL,
    Cod_apartamento INT NOT NULL,
    FOREIGN KEY (CPF)
        REFERENCES Hospede (CPF)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Cod_apartamento)
        REFERENCES Apartamentos (Cod_apartamento)
        ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (Cod_reserva)
);

CREATE TABLE Produtos (
    Cod_produto INT NOT NULL,
    Nome_produto VARCHAR(25) NOT NULL,
    Desc_produto VARCHAR(100) NOT NULL,
    Preco NUMERIC(10 , 2 ) NOT NULL,
    PRIMARY KEY (Cod_produto)
);

CREATE TABLE Ser_Diversos (
    Cod_produto INT NOT NULL,
    Cod_servico INT NOT NULL,
    Tipo_servico ENUM('Lanche', 'Refeição Completa', 'Bebida'),
    Desc_servico VARCHAR(25) NOT NULL,
    PRIMARY KEY (Cod_servico),
    FOREIGN KEY (Cod_produto)
        REFERENCES Produtos (Cod_produto)
); 

CREATE TABLE Solicitacao_Servico (
    data_Solicitacao DATE NOT NULL,
    CPF VARCHAR(14) NOT NULL,
    Cod_servico INT NOT NULL,
    Cod_apartamento INT NOT NULL,
    FOREIGN KEY (CPF)
        REFERENCES Hospede (CPF)
        ON DELETE CASCADE,
    FOREIGN KEY (Cod_Servico)
        REFERENCES Ser_Diversos (Cod_servico),
    FOREIGN KEY (Cod_apartamento)
        REFERENCES Apartamentos (Cod_apartamento)
);

CREATE TABLE Conta (
    CPF VARCHAR(14) NOT NULL UNIQUE,
    Num_nota_Fiscal INT NOT NULL AUTO_INCREMENT,
    Valor_total NUMERIC(10 , 2 ) DEFAULT 0,
    Tipo_pagamento ENUM('Crédito', 'Débito', 'Dinheiro'),
    Data_pagamento DATE NOT NULL,
    PRIMARY KEY (Num_nota_Fiscal),
    FOREIGN KEY (CPF)
        REFERENCES Hospede (CPF)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Pagamento (
    ID INT AUTO_INCREMENT,
    pagamento VARCHAR(8) NOT NULL,
    PRIMARY KEY (ID)
);
-- -----------------------------------------------------------------------------
--                 FUNÇÕES PARA AJUDAR NO PREENCHIMENTO                      --
-- -----------------------------------------------------------------------------
-- A) NÚMERO TELEFONE RANDOMICO
DELIMITER $
CREATE FUNCTION telefone() RETURNS VARCHAR(15)
BEGIN
	DECLARE telCliente VARCHAR(15);
	set telCliente = CONCAT ( '(', inteiro(), inteiro(), ') 9', inteiro() , inteiro(), inteiro(), inteiro(),
    '-' , inteiro(), inteiro(), inteiro(), inteiro());
    
    RETURN telCliente;
	
END $
DELIMITER ;

-- B) NÚMERO RANDOMICO INTEIRO 
DELIMITER $
CREATE FUNCTION inteiro() RETURNS VARCHAR(1)
BEGIN
    RETURN SUBSTRING(RAND()*10, 1, 1);
END $
DELIMITER ;

-- C) NÚMERO NOTA FISCAL 
DELIMITER $
CREATE FUNCTION numNotaFiscal() RETURNS int
BEGIN
	DECLARE ultimoNum INT DEFAULT 0;
    select max(Num_nota_Fiscal) from hospede into ultimoNum;
    
    if(ultimoNum IS NULL) THEN
    SET ultimoNum = 0;
    END IF;  
    RETURN (ultimoNum + 1);
END $
DELIMITER ;

-- D) TEMPO DE HOSPEDAGEM.
DELIMITER $
CREATE FUNCTION tempoDeHospedagem(var_CPF varchar(14)) RETURNS int
BEGIN
	DECLARE tempoHosp INT DEFAULT 0;
    select DATEDIFF(Data_saida, Data_entrada) FROM hospede WHERE CPF = var_CPF into tempoHosp;    
    if(tempoHosp IS NULL) THEN
    SET tempoHosp = 0;
    END IF;  
    RETURN (tempoHosp);
END $
DELIMITER ;

-- E) Código do Apartamento 
DELIMITER $
CREATE FUNCTION codigoDoApartamentoDoHospede(var_CPF varchar(14)) RETURNS int
BEGIN
	DECLARE codigo INT DEFAULT 0;
    SELECT ap.Cod_apartamento from HOSPEDE h, RESERVA r, APARTAMENTOS ap
 WHERE h.CPF = var_CPF and r.CPF =  var_CPF and ap.Cod_apartamento = r.Cod_apartamento into codigo;    
    RETURN (codigo);
END $
DELIMITER ;

-- F) Calcular Valor da Nota Fiscal 
DELIMITER $
CREATE FUNCTION valorTotal(var_CPF varchar(14)) RETURNS int
BEGIN
	DECLARE total INT DEFAULT 0;
    SELECT RAND() * 5000 into total;    
    RETURN (total);
END $
DELIMITER ;

-- G) Gerar Tipo de Pagamento da Nota Fiscal 
DELIMITER $
CREATE FUNCTION f_pagamento() RETURNS VARCHAR(8)
BEGIN
	DECLARE var_id INT DEFAULT 0;
    DECLARE var_pagamento VARCHAR(8);    
    
    WHILE (var_id != 1 && var_id != 2 && var_id != 3 )  DO
		SELECT SUBSTRING(((RAND() * 3) + 1), 1, 1) into var_id;
	END WHILE;
	SET  var_pagamento = (SELECT pagamento FROM Pagamento WHERE ID = var_id);
    
    RETURN (var_pagamento);
END $
DELIMITER ;

-- H) Retornar Valor da Nota Fiscal 
DELIMITER $
CREATE FUNCTION valor_Nota(var_CPF varchar(14)) RETURNS int
BEGIN   
    RETURN (SELECT Valor_total FROM conta WHERE CPF = var_CPF);
END $
DELIMITER ;

-- I) Retornar uma Data entre 2018-10-01 a -30 Dias.
DELIMITER $
CREATE FUNCTION randData() RETURNS date
BEGIN   
    RETURN (SELECT '2018-10-01' + INTERVAL (FLOOR((RAND() * 30) + 1)) DAY);
END $
DELIMITER ;

-- J) Retornar uma Data entre hoje a -30 Dias.
DELIMITER $
CREATE FUNCTION dataReserva(var_CPF varchar(14)) RETURNS date
BEGIN   
    RETURN (SELECT Data_entrada from hospede where CPF = var_CPF);
END $
DELIMITER ;
-- -----------------------------------------------------------------------------
--            FIM DAS FUNÇÕES PARA AJUDAR NO PREENCHIMENTO                   --
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--                     INSERÇÃO DE DADOS NAS TABELAS                         --
-- -----------------------------------------------------------------------------
-- ---------------------------------------------------
--                     HOSPEDE                     --
-- ---------------------------------------------------
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Carolina Martins Silva', '375.407.454-79', '2018-10-01', randData(),'F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Kai Martins Ferreira', '849.525.773-41', '2018-10-01', randData(),'M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Aline Azevedo Souza', '122.184.355-94', '2018-10-01', randData(),'F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Giovanna Costa Cunha', '514.536.980-86', '2018-10-01', randData(),'F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Isabella Pinto Sousa', '313.236.527-01', '2018-10-01', randData(),'F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Estevan Barros Sousa', '926.148.594-43', '2018-10-03', randData(),'M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Carla Oliveira Ferreira', '363.071.433-12', '2018-10-01', randData(),'F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Douglas Cunha Rodrigues', '606.883.985-02', '2018-10-01', randData(),'M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Nicolash Santos Oliveira', '651.304.169-45', '2018-10-01', randData(),'M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Paulo Castro Correia', '969.045.586-95', '2018-10-01', randData(),'M', telefone(), numNotaFiscal());
/* *********************************************************************************** */

-- ---------------------------------------------------
--                   APARTAMENTO                   --
-- ---------------------------------------------------
INSERT INTO Apartamentos (Cod_apartamento, Tipo_apartamento)
Values (1, 'Casal');
INSERT INTO Apartamentos (Cod_apartamento, Tipo_apartamento)
Values (2, 'Solteiro');
INSERT INTO Apartamentos (Cod_apartamento, Tipo_apartamento)
Values (3, 'Suite');
INSERT INTO Apartamentos (Cod_apartamento, Tipo_apartamento)
Values (4, 'Presidencial');
/* ************************************************** */

-- ---------------------------------------------------
--                APARTAMENTO VALOR                --
-- ---------------------------------------------------
INSERT INTO valorDiariasAptos (Cod_apartamento, valor_Apto)
Values (1, 249.90);
INSERT INTO valorDiariasAptos (Cod_apartamento, valor_Apto)
Values (2, 149.90);
INSERT INTO valorDiariasAptos (Cod_apartamento, valor_Apto)
Values (3, 499.90);
INSERT INTO valorDiariasAptos (Cod_apartamento, valor_Apto)
Values (4, 999.90);
/* ************************************************** */

-- ---------------------------------------------------
--                     RESERVA                     --
-- ---------------------------------------------------
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('375.407.454-79'), dataReserva('375.407.454-79'), '375.407.454-79', 1);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('849.525.773-41'), dataReserva('849.525.773-41'), '849.525.773-41', 2);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('122.184.355-94'), dataReserva('122.184.355-94'), '122.184.355-94', 3);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('514.536.980-86'), dataReserva('514.536.980-86'), '514.536.980-86', 4);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('313.236.527-01'), dataReserva('313.236.527-01'), '313.236.527-01', 4);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('926.148.594-43'), dataReserva('926.148.594-43'), '926.148.594-43', 1);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('363.071.433-12'), dataReserva('363.071.433-12'), '363.071.433-12', 3);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('606.883.985-02'), dataReserva('606.883.985-02'), '606.883.985-02', 2);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('651.304.169-45'), dataReserva('651.304.169-45'), '651.304.169-45', 2);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('969.045.586-95'), dataReserva('969.045.586-95'), '969.045.586-95', 1);
-- ----------------------------- --
/* ************************************************** */

-- ---------------------------------------------------
--                    Produtos                     --
-- ---------------------------------------------------
INSERT INTO Produtos (Cod_produto, Nome_produto, Desc_produto, Preco)
Values (1, 'Hambúrguer', 'X-BACON', 12);
INSERT INTO Produtos (Cod_produto, Nome_produto, Desc_produto, Preco)
Values (2, 'Torta', 'Morango com Chocolate', 13);
INSERT INTO Produtos (Cod_produto, Nome_produto, Desc_produto, Preco)
Values (3, 'Almoço', 'Almoço', 10);
INSERT INTO Produtos (Cod_produto, Nome_produto, Desc_produto, Preco)
Values (4, 'Jantar', 'Janta', 20);
INSERT INTO Produtos (Cod_produto, Nome_produto, Desc_produto, Preco)
Values (5, 'Coca-Cola', 'Refrigerante 3.3L', 6);
INSERT INTO Produtos (Cod_produto, Nome_produto, Desc_produto, Preco)
Values (6, 'Vinho', 'Tinto 1L', 32);
/* ************************************************** */

-- ---------------------------------------------------
--                  Ser_Diversos                   --
-- ---------------------------------------------------
INSERT INTO Ser_Diversos (Cod_servico, Tipo_servico, Desc_servico, Cod_produto)
Values (1,'Lanche', 'Café da Manhã', 1);
INSERT INTO Ser_Diversos (Cod_servico, Tipo_servico, Desc_servico, Cod_produto)
Values (2,'Lanche', 'Café da Tarde', 2);
INSERT INTO Ser_Diversos (Cod_servico, Tipo_servico, Desc_servico, Cod_produto)
Values (3,'Refeição Completa', 'Almoço', 3);
INSERT INTO Ser_Diversos (Cod_servico, Tipo_servico, Desc_servico, Cod_produto)
Values (4,'Refeição Completa', 'Jantar', 4);
INSERT INTO Ser_Diversos (Cod_servico, Tipo_servico, Desc_servico, Cod_produto)
Values (5,'Bebida', 'Refrigerante', 5);
INSERT INTO Ser_Diversos (Cod_servico, Tipo_servico, Desc_servico, Cod_produto)
Values (6,'Bebida', 'Alcoólico', 6);
/* ************************************************** */
-- ---------------------------------------------------
--                   Pagamento                     --
-- ---------------------------------------------------
INSERT INTO Pagamento (pagamento) values ('Dinheiro');
INSERT INTO Pagamento (pagamento) values ('Débito');
INSERT INTO Pagamento (pagamento) values ('Crédito');

/* ************************************************** */

-- ---------------------------------------------------
--                     Conta                       --
-- ---------------------------------------------------
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('375.407.454-79',  current_date(), F_PAGAMENTO(), valorTotal('375.407.454-79'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('849.525.773-41',  current_date(), F_PAGAMENTO(), valorTotal('849.525.773-41'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('122.184.355-94',  current_date(), F_PAGAMENTO(), valorTotal('122.184.355-94'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('514.536.980-86',  current_date(), F_PAGAMENTO(), valorTotal('514.536.980-86'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('313.236.527-01',  current_date(), F_PAGAMENTO(), valorTotal('313.236.527-01'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('926.148.594-43',  current_date(), F_PAGAMENTO(), valorTotal('926.148.594-43'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('363.071.433-12',  current_date(), F_PAGAMENTO(), valorTotal('363.071.433-12'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('606.883.985-02',  current_date(), F_PAGAMENTO(), valorTotal('606.883.985-02'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('651.304.169-45',  current_date(), F_PAGAMENTO(), valorTotal('651.304.169-45'));
INSERT INTO Conta (CPF, Data_pagamento, Tipo_pagamento, Valor_total)
Values ('969.045.586-95',  current_date(), F_PAGAMENTO(), valorTotal('969.045.586-95'));
/* ************************************************** */
-- ---------------------------------------------------
--             Solicitação de Serviço              --
-- ---------------------------------------------------
-- Carolina Martins Silva Quarto Casal
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '375.407.454-79', 1, codigoDoApartamentoDoHospede('375.407.454-79'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '375.407.454-79', 2, codigoDoApartamentoDoHospede('375.407.454-79'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '375.407.454-79', 3, codigoDoApartamentoDoHospede('375.407.454-79'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '375.407.454-79', 4, codigoDoApartamentoDoHospede('375.407.454-79'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '375.407.454-79', 5, codigoDoApartamentoDoHospede('375.407.454-79'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '375.407.454-79', 6, codigoDoApartamentoDoHospede('375.407.454-79'));
-- Kai Martins Ferreira Quarto Solteiro
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '849.525.773-41', 1, codigoDoApartamentoDoHospede('849.525.773-41'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '849.525.773-41', 4, codigoDoApartamentoDoHospede('849.525.773-41'));
-- Estevan Barros Sousa Quarto Casal
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '926.148.594-43', 1, codigoDoApartamentoDoHospede('926.148.594-43'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '926.148.594-43', 6, codigoDoApartamentoDoHospede('926.148.594-43'));
-- Aline Azevedo Souza Quarto Suite
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '122.184.355-94', 4, codigoDoApartamentoDoHospede('122.184.355-94'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '122.184.355-94', 6, codigoDoApartamentoDoHospede('122.184.355-94'));
-- Giovanna Costa Cunha Quarto Presidencial
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '514.536.980-86', 1, codigoDoApartamentoDoHospede('514.536.980-86'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '514.536.980-86', 2, codigoDoApartamentoDoHospede('514.536.980-86'));
INSERT INTO Solicitacao_Servico (data_Solicitacao, CPF, Cod_servico, Cod_apartamento)
Values (current_date(), '514.536.980-86', 6, codigoDoApartamentoDoHospede('514.536.980-86'));