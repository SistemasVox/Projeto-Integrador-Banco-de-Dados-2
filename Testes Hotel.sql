SELECT F_PAGAMENTO();


SELECT SUBSTRING(((RAND() * 3) + 1), 1, 1);


SELECT* FROM pagamento;
SELECT LENGTH(CURRENT_DATE());
SELECT CURRENT_DATE() - INTERVAL (FLOOR((RAND() * 30))) DAY;
SELECT RANDDATA();

SELECT CODIGODOAPARTAMENTODOHOSPEDE('313.236.527-01');
SELECT valor_Nota('313.236.527-01');

SELECT DISTINCT Nome_produto from Ser_Diversos sd, Solicitacao_Servico ss, produtos p where ss.Cod_servico = sd.Cod_servico and sd.Cod_produto = p.Cod_produto and sd.Cod_servico = 1;

SELECT pagamento FROM Pagamento WHERE ID = 0;

SELECT FORMAT(1000000000, 2, 'de_DE'); -- No format, fazemos usado do locale, passando como valor o Alemão.
-- http://paposql.blogspot.com/2011/12/funcao-para-formatar-moeda-em-reais-no.html

SELECT randDataConsumo('375.407.454-79');