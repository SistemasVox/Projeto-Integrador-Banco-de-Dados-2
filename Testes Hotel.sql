SELECT F_PAGAMENTO();


SELECT SUBSTRING(((RAND() * 3) + 1), 1, 1);


select * from pagamento;

select codigoDoApartamentoDoHospede('313.236.527-01');
SELECT valor_Nota('313.236.527-01');

SELECT pagamento FROM Pagamento WHERE ID = 0;

select format(1000000000, 2, 'de_DE'); -- No format, fazemos usado do locale, passando como valor o Alemão.
-- http://paposql.blogspot.com/2011/12/funcao-para-formatar-moeda-em-reais-no.html