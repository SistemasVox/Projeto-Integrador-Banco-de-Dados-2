-- -----------------------------------------------------------------------------
--                            INFORMAÇÕES:                                   --
--                                                                           --
-- Nome: Marcelo José Vieira.                                                --
-- Período: 7º Período Licenciatura em Computação.                           --
-- Matéria: Banco de Dados 2.                                                --
-- Contato: dj.marcelo.2009@gmail.com                                        --
-- -----------------------------------------------------------------------------
-- https://format-sql.com https://sqlformat.org
-- http://www.4devs.com.br/gerador_de_pessoas

/* Descrição:
Um microempresário resolveu construir um hotel em um local de alta chance de crescimento em Uberlândia,
não perdendo tempo com a modernidade ele quis optar por deixar seu sistema de gerenciamento totalmente digital,
para isso contratou os serviços do Desenvolvedor Marcelo Vieira, Marcelo Vieira agora tem a missão de criar
o banco de dados totalmente funcional de um hotel, no seu banco de dados, deve ter cadastro dos Clientes,
para cada Hospede deve ser cadastrado as seguintes informações: Código do Hospede, Nome, CPF, Data de Entrada, Data de Saída e sua Nota Fiscal.
Ao realizar uma Reserva deve constar as seguintes informações: Código da Reserva, Tempo Hospedagem, CPF do Hospede e Código do Apartamento.
Cada Apartamento deve ter as informações: Código do Apartamento e seu Tipo de Apartamento (Casal, Solteiro, Suíte, Presidencial).
Nos seus Serviços Diversos deve constar: Código do Serviço, Tipo do Serviço (Lanche, Refeição Completa, Bebida) e Descrição do Serviço.
No quesito Produtos deve-se ter: Código do Produto, Nome do Produto, Descrição do Produto e claro o Preço.
Por último a Conta deve ter: Número da nota Fiscal, Valor total e Tipo de pagamento (Crédito, Débito ou Dinheiro).
*/
-- -----------------------------------------------------------------------------
--                  SCRIPT DE CRIAÇÃO DA BASE DE DADOS.                      --
-- -----------------------------------------------------------------------------

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
--     Manutenção     --
desc Hospede;
DROP TABLE Hospede;
--  ----------------  --

CREATE TABLE Apartamentos (
    Cod_apartamento INT NOT NULL AUTO_INCREMENT,
    Tipo_apartamento ENUM('Casal', 'Solteiro', 'Suíte', 'Presidencial'),
    PRIMARY KEY (Cod_apartamento) -- Chave Primária.
);
--     Manutenção     --
desc Apartamentos;
DROP TABLE Apartamentos;
--  ----------------  --

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
--     Manutenção     --
desc Reserva;
DROP TABLE Reserva;
--  ----------------  --

CREATE TABLE Produtos (
    Cod_produto INT NOT NULL,
    Nome_produto VARCHAR(25) NOT NULL,
    Desc_produto VARCHAR(100) NOT NULL,
    Preco NUMERIC(10 , 2 ) NOT NULL,
    PRIMARY KEY (Cod_produto)
);
--     Manutenção     --
desc Produtos;
DROP TABLE Produtos;
--  ----------------  --

CREATE TABLE Ser_Diversos (
    Cod_produto INT NOT NULL,
    Cod_servico INT NOT NULL,
    Tipo_servico ENUM('Lanche', 'Refeição Completa', 'Bebida'),
    Desc_servico VARCHAR(25) NOT NULL,
    PRIMARY KEY (Cod_servico),
    FOREIGN KEY (Cod_produto)
        REFERENCES Produtos (Cod_produto)
); 
--     Manutenção     --
desc Ser_Diversos;
DROP TABLE Ser_Diversos;
--  ----------------  --

CREATE TABLE Solicitacao_Servico (
    data_Solicitacao DATE NOT NULL,
    CPF VARCHAR(14) NOT NULL,
    Cod_servico INT NOT NULL,
    Cod_apartamento INT NOT NULL,
    FOREIGN KEY (CPF)
        REFERENCES Hospede (CPF),
    FOREIGN KEY (Cod_Servico)
        REFERENCES Ser_Diversos (Cod_servico),
    FOREIGN KEY (Cod_apartamento)
        REFERENCES Apartamentos (Cod_apartamento)
);
--     Manutenção     --
desc Solicitacao_Servico;
DROP TABLE Solicitacao_Servico;
--  ----------------  --

CREATE TABLE Conta (
    CPF VARCHAR(14) NOT NULL UNIQUE,
    Num_nota_Fiscal INT NOT NULL AUTO_INCREMENT,
    Valor_total NUMERIC(10 , 2 ) DEFAULT 0,
    Tipo_pagamento ENUM('Crédito', 'Débito', 'Dinheiro'),
    Data_pagamento DATE NOT NULL,
    PRIMARY KEY (Num_nota_Fiscal),
    FOREIGN KEY (CPF)
        REFERENCES Hospede (CPF)
);
--     Manutenção     --
desc Conta;
DROP TABLE Conta;
--  ----------------  --

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

-- G) Calcular Valor da Nota Fiscal 
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
-- -----------------------------------------------------------------------------
--            FIM DAS FUNÇÕES PARA AJUDAR NO PREENCHIMENTO                   --
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--                     INSERÇÃO DE DADOS NAS TABELAS                         --
-- -----------------------------------------------------------------------------

/*4) Efetuar a carga de dados nas tabelas simulando dados reais. De 5 a 10 
registros por tabela. 
*/

-- ---------------------------------------------------
--                     HOSPEDE                     --
-- ---------------------------------------------------
SELECT * FROM Hospede;
desc Hospede;
DELETE FROM Hospede;

INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Carolina Martins Silva', '375.407.454-79', '2018-10-01', '2018-10-02','F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Kai Martins Ferreira', '849.525.773-41', '2018-10-01', '2018-10-05','M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Aline Azevedo Souza', '122.184.355-94', '2018-10-01', '2018-10-10','F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Giovanna Costa Cunha', '514.536.980-86', '2018-10-01', '2018-10-09','F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Isabella Pinto Sousa', '313.236.527-01', '2018-10-01', '2018-10-09','F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Estevan Barros Sousa', '926.148.594-43', '2018-10-03', '2018-10-31','M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Carla Oliveira Ferreira', '363.071.433-12', '2018-10-01', '2018-10-25','F', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Douglas Cunha Rodrigues', '606.883.985-02', '2018-10-01', '2018-10-12','M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Nicolash Santos Oliveira', '651.304.169-45', '2018-10-01', '2018-10-7','M', telefone(), numNotaFiscal());
INSERT INTO Hospede (Nome_hospede, CPF, Data_entrada, Data_saida, Sexo, telCliente, Num_nota_Fiscal)
Values ('Paulo Castro Correia', '969.045.586-95', '2018-10-01', '2018-10-02','M', telefone(), numNotaFiscal());
/* *********************************************************************************** */

-- ---------------------------------------------------
--                   APARTAMENTO                   --
-- ---------------------------------------------------
SELECT * FROM Apartamentos;
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
--                     RESERVA                     --
-- ---------------------------------------------------
SELECT * FROM Reserva;
TRUNCATE TABLE Reserva;
desc Reserva;

INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('375.407.454-79'), current_date(), '375.407.454-79', 1);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('849.525.773-41'), current_date(), '849.525.773-41', 2);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('122.184.355-94'), current_date(), '122.184.355-94', 3);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('514.536.980-86'), current_date(), '514.536.980-86', 4);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('313.236.527-01'), current_date(), '313.236.527-01', 4);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('926.148.594-43'), current_date(), '926.148.594-43', 1);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('363.071.433-12'), current_date(), '363.071.433-12', 3);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('606.883.985-02'), current_date(), '606.883.985-02', 2);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('651.304.169-45'), current_date(), '651.304.169-45', 2);
INSERT INTO Reserva (Tempo_Hospedagem, Data_reserva, CPF, Cod_apartamento)
VALUES(tempoDeHospedagem('969.045.586-95'), current_date(), '969.045.586-95', 1);
-- Apagar todas linhas da Tabela --
TRUNCATE TABLE Reserva; -- TODAS as LINHAS da Tabela.
DELETE FROM Reserva WHERE Cod_reserva = 0; -- Especificamente a Reserva de Nº 0.
-- ----------------------------- --
/* ************************************************** */

-- ---------------------------------------------------
--                    Produtos                     --
-- ---------------------------------------------------
SELECT * FROM Produtos;
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
SELECT * FROM Ser_Diversos;
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
--                     Conta                       --
-- ---------------------------------------------------
SELECT * FROM Conta;
TRUNCATE TABLE Conta;
desc Conta;

SELECT * FROM hospede;

SELECT * FROM Conta;
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
SELECT * FROM Solicitacao_Servico;

-- Adicionando o Campo 'ID' na Tabela Solicitacao_Servico --
-- ALTER TABLE Solicitacao_Servico ADD ID int;
-- *************************************************************** --
TRUNCATE TABLE Solicitacao_Servico; -- Apagar todas as linhas da tabela.
-- UPDATE Solicitacao_Servico SET CPF = '375.407.454-79', Cod_servico = 1 WHERE ID = 1;

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
/* ************************************************** */

-- -----------------------------------------------------------------------------
--                FIM DA INSERÇÃO DE DADOS NAS TABELAS                       --
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--                            CONSULTAS                                      --
-- -----------------------------------------------------------------------------

-- A) Consultar todos os nomes e data de entrada das mulheres hospedadas no Hotel (OPERADOR LIKE, GROUP BY)
		SELECT Nome_hospede, Data_entrada FROM HOSPEDE WHERE Sexo = 'F';
		SELECT COUNT(*) FROM HOSPEDE WHERE Sexo LIKE '%F%' GROUP BY Sexo;

-- B) E quantos homens? (OPERADOR LIKE, GROUP BY)
		SELECT Nome_hospede, Data_entrada FROM HOSPEDE WHERE Sexo = 'M';
		SELECT COUNT(*) FROM HOSPEDE WHERE Sexo LIKE '%M%' GROUP BY Sexo;
        
-- BB) E qual a porcentagem de mulheres e relação com a quantidade de homens hospedados? (Junção com ela Própria)
		SELECT (SELECT ((SELECT COUNT(*) FROM HOSPEDE WHERE Sexo LIKE '%F%') * 100) ) / (SELECT COUNT(*) FROM HOSPEDE WHERE Sexo LIKE '%M%') as Porcentagem;

-- C) Quais Hóspedes vieram na inauguração? (OPERADOR LIKE)
		SELECT Nome_hospede FROM HOSPEDE WHERE Data_entrada LIKE '2018-10-01';

-- D) Consultar quantidade de Hóspedes pelo tipo de apartamentos. (GROUP BY e COUNT)
		SELECT Tipo_apartamento, COUNT(*) from HOSPEDE h, RESERVA r, APARTAMENTOS ap
		WHERE h.CPF = r.CPF and ap.Cod_apartamento = r.Cod_apartamento GROUP BY Tipo_apartamento; 

-- E) Consultar quantidade de Hóspedes pelo tipo de apartamentos, que tenha mais de 2 Hóspedes. (GROUP BY, COUNT e HAVING)
		SELECT Tipo_apartamento, COUNT(*) as qtd from HOSPEDE h, RESERVA r, APARTAMENTOS ap
		WHERE h.CPF = r.CPF and ap.Cod_apartamento = r.Cod_apartamento GROUP BY Tipo_apartamento HAVING qtd > 2; 

-- F) Quais estão hospedados até a PRIMEIRA QUINZENA de Outubro? (OPERADOR BETWEEN)
		SELECT Nome_hospede, Data_entrada, Data_saida FROM HOSPEDE WHERE Data_saida BETWEEN '2018-10-01' AND '2018-10-15';

-- F) Quais Delivery são oferecidos pelo Hotel?(JUNÇÃO DE TABELA).
		SELECT Tipo_servico, Desc_produto FROM Ser_Diversos s, Produtos p WHERE s.Cod_servico = p.Cod_produto;
        
-- G) Quais hóspedes estão hospedados no quarto de casal e quais serviços já foram pedidos? (JUNÇÃO DE TABELA).
		SELECT Nome_hospede, Desc_servico, Desc_produto FROM HOSPEDE h, Solicitacao_Servico ss, Ser_Diversos sd, Produtos p, Apartamentos a, Reserva r
		WHERE h.CPF = ss.CPF AND sd.Cod_servico = ss.Cod_servico AND p.Cod_produto = sd.Cod_servico
		AND Tipo_apartamento = 'Casal' AND a.Cod_apartamento = r.Cod_apartamento AND r.CPF = h.CPF;

-- H) Quais hóspedes estão hospedados no quarto de Presidencial e quais serviços já foram pedidos? (JUNÇÃO DE TABELA).
		SELECT Nome_hospede, Desc_servico, Desc_produto FROM HOSPEDE h, Solicitacao_Servico ss, Ser_Diversos sd, Produtos p, Apartamentos a, Reserva r
		WHERE h.CPF = ss.CPF AND sd.Cod_servico = ss.Cod_servico AND p.Cod_produto = sd.Cod_servico
		AND Tipo_apartamento = 'Presidencial' AND a.Cod_apartamento = r.Cod_apartamento AND r.CPF = h.CPF;

-- I) Quais hóspedes pediram almoço ou jantar? E Ordene por Ordem Alfabética. (OPERADOR OR, ORDER BY e UNION)
		SELECT Nome_hospede, Desc_servico FROM HOSPEDE h, Solicitacao_Servico ss, Ser_Diversos sd
		WHERE h.CPF = ss.CPF AND sd.Cod_servico = ss.Cod_servico
		AND Desc_servico = 'Jantar' -- Só Jantar.
		OR h.CPF = ss.CPF
		AND sd.Cod_servico = ss.Cod_servico AND Desc_servico = 'Almoço' ORDER BY Nome_hospede; -- Só Almoço.
        
        -- UNION
        SELECT Nome_hospede, Desc_servico FROM HOSPEDE h, Solicitacao_Servico ss, Ser_Diversos sd
		WHERE h.CPF = ss.CPF AND sd.Cod_servico = ss.Cod_servico
		AND Desc_servico = 'Jantar'
        UNION
        SELECT Nome_hospede, Desc_servico FROM HOSPEDE h, Solicitacao_Servico ss, Ser_Diversos sd
		WHERE h.CPF = ss.CPF AND sd.Cod_servico = ss.Cod_servico
		AND Desc_servico = 'Almoço' ORDER BY Nome_hospede;
        
        
 -- II) Quais hospedes estão hospedados nos quartos Solteiro e Casado, Casado e Presidencial. (UNION)
		-- Solteiro e Casado
		SELECT Nome_hospede, Tipo_apartamento from HOSPEDE h, RESERVA r, APARTAMENTOS ap
		WHERE h.CPF = r.CPF and ap.Cod_apartamento = r.Cod_apartamento and Tipo_apartamento = 'Casal'
        UNION
		SELECT Nome_hospede, Tipo_apartamento from HOSPEDE h, RESERVA r, APARTAMENTOS ap
		WHERE h.CPF = r.CPF and ap.Cod_apartamento = r.Cod_apartamento and Tipo_apartamento = 'Solteiro';  
        
		-- Casado e Presidencial
		SELECT Nome_hospede, Tipo_apartamento from HOSPEDE h, RESERVA r, APARTAMENTOS ap
		WHERE h.CPF = r.CPF and ap.Cod_apartamento = r.Cod_apartamento and Tipo_apartamento = 'Casal'
        UNION
		SELECT Nome_hospede, Tipo_apartamento from HOSPEDE h, RESERVA r, APARTAMENTOS ap
		WHERE h.CPF = r.CPF and ap.Cod_apartamento = r.Cod_apartamento and Tipo_apartamento = 'Presidencial'; 
        
-- J) Verifique se algum Valor total da Nota Fiscal está Nulo. (UPDATE e IS NULL)
		SELECT * FROM conta WHERE Valor_total IS NULL;
	-- a) Caso esteja tudo certo atribua um Valor nulo alguém.
		UPDATE conta SET Valor_total = null WHERE Num_nota_Fiscal = 4;
	-- b) Verifique se há um Valor nulo novamente.
		SELECT * FROM conta WHERE Valor_total IS NULL;
	-- c) Corrija o Valor nulo.
		UPDATE conta SET Valor_total = 54 WHERE Num_nota_Fiscal = 4;
	-- d) Verifique se há um Valor nulo novamente.
		SELECT * FROM conta WHERE Valor_total IS NULL;

-- K) Liste quais Notas Fiscais tem Valores: (OPERADORRES <> )
	-- a) Total menor que R$ 100.
		SELECT * FROM conta WHERE Valor_total < 100;
	-- b) Total maior que R$ 100.
		SELECT * FROM conta WHERE Valor_total > 100;
	-- c) Total maior que R$ 1000.
		SELECT * FROM conta WHERE Valor_total > 1000;
	-- d) Liste todos os hospedes com seus nomes Tipo de Apartamento e valores de suas contas.
		SELECT Nome_hospede, Tipo_apartamento, Valor_total FROM HOSPEDE h, Apartamentos a, Conta c, Reserva r
		WHERE h.CPF = r.CPF AND a.Cod_apartamento = r.Cod_apartamento AND c.Num_nota_Fiscal = r.Cod_reserva;
	-- e) Liste todos os hospedes com seus nomes Tipo de Apartamento e valores de suas contas acima de R$ 1000.00
		SELECT Nome_hospede, Tipo_apartamento, Valor_total FROM HOSPEDE h, Apartamentos a, Conta c, Reserva r
		WHERE h.CPF = r.CPF AND a.Cod_apartamento = r.Cod_apartamento AND c.Num_nota_Fiscal = r.Cod_reserva
		AND c.Valor_total > 1000;
        
-- -------------------          
SET autocommit = 0; --
-- -------------------  
START TRANSACTION;         
savepoint inserindo_Marcelo;
-- L) Liste o nome de hóspedes que esteja hospedado, mas seu nome não esteja na reserva. (Controle de Transação)
		SELECT Nome_hospede FROM HOSPEDE WHERE CPF NOT IN (SELECT CPF FROM Reserva);
	-- a) Adicione um Hóspede sem fazer reserva do mesmo.
		INSERT INTO Hospede (Nome_hospede, CPF)
		Values ('Marcelo', '665.754.474-87');
	-- b) Faça o teste novamente.
		SELECT Nome_hospede FROM HOSPEDE WHERE CPF NOT IN (SELECT CPF FROM Reserva);
	-- c) Exclua esse Hóspede.
		-- DELETE FROM HOSPEDE WHERE Nome_hospede = 'Marcelo';
        rollback to inserindo_Marcelo;
	-- d) Faça o teste novamente.
		SELECT Nome_hospede FROM HOSPEDE WHERE CPF NOT IN (SELECT CPF FROM Reserva);
	-- e) Salve as modificações.
		commit;
-- -------------------     
SET autocommit = 1; -- 
-- ------------------- 
CREATE TABLE Pagamento (
    ID INT AUTO_INCREMENT,
    pagamento VARCHAR(8) NOT NULL,
    PRIMARY KEY (ID)
);
INSERT INTO Pagamento (pagamento) values ('Dinheiro');
INSERT INTO Pagamento (pagamento) values ('Débito');
INSERT INTO Pagamento (pagamento) values ('Crédito');


-- ------------------------------------------------------------------------
--                   Criação dos Funções no SGBD                        --
-- ------------------------------------------------------------------------

-- ------------------------------------------------------------------------
--                Fim Criação dos Funções no SGBD                       --
-- ------------------------------------------------------------------------

-- ------------------------------------------------------------------------------
--                   Criação dos Procedimentos no SGBD                        --
-- ------------------------------------------------------------------------------
select Nome_hospede, Tipo_apartamento as Ap, Nome_produto, Desc_produto, sum(Preco) total
from hospede h, apartamentos ap, reserva re,  produtos pro, solicitacao_servico soli, ser_diversos ser
where soli.CPF = re.CPF and soli.Cod_servico = ser.Cod_servico and soli.Cod_apartamento = ap.Cod_apartamento and
ser.Cod_produto = pro.Cod_produto and
re.CPF = h.CPF and re.Cod_apartamento = ap.Cod_apartamento group by Nome_hospede
;
-- ------------------------------------------------------------------------------
--                 Fim Criação dos Procedimentos no SGBD                      --
-- ------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
--                            FIM DO CÓDIGO                                  --
-- ----------------------------------------------------------------------------