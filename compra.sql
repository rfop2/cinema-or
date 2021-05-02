CREATE OR REPLACE TYPE tp_compra AS OBJECT(
	  id INT,
		valor FLOAT,
		cliente REF tp_cliente,
		lanche tp_lanche,
		ingresso tp_ingresso,
		ORDER MEMBER FUNCTION comparaValor (V tp_compra) RETURN INTEGER
)FINAL;
/

CREATE OR REPLACE TYPE BODY tp_compra IS
ORDER MEMBER FUNCTION comparaValor (V tp_compra)
RETURN INTEGER IS
BEGIN
RETURN SELF.valor - V.valor;
END;
END;
/

#Uso de SCOPE IS, deixa junto de tp_compra

CREATE TABLE tb_compra OF tp_compra(id PRIMARY KEY, cliente SCOPE IS tb_cliente);

DROP TABLE tb_compra PURGE;

CREATE TABLE tb_compra OF tp_compra(id PRIMARY KEY, cliente WITH ROWID REFERENCES tb_cliente);

INSERT INTO tb_compra VALUES (
1 , 
89.90,
tp_cliente(SELECT REF(a) FROM tb_cliente a WHERE a.Cpf=14557874569),
tp_lanche(1, 'Combo 1', 49.90),
tp_ingresso('B3', (SELECT REF(e) FROM tb_cinema e WHERE e.Identificador = 1), tp_sessao(TO_DATE('01/03/2020 14:02:44', 'dd/mm/yyyy hh24:mi:ss'),1))
);

DECLARE
mb tp_compra;
m number;
BEGIN
SELECT VALUE(p) INTO mb FROM tb_compra p
WHERE p.id = '1';
SELECT d.comparaValor(mb) into m FROM tb_compra d WHERE
d.id = '2';
IF m > 0 THEN DBMS_OUTPUT.PUT_LINE('Compra de ID '
||'1' || ' foi maior que o valor da compra de ID '
||TO_CHAR(mb.id) ); END IF;
IF m = 0 THEN DBMS_OUTPUT.PUT_LINE('Valor da compra de ID '
||'1' || ' foi igual ao valor da compra de ID '
||TO_CHAR(mb.cpf) ); END IF;
IF m < 0 THEN DBMS_OUTPUT.PUT_LINE('Valor da compra de ID '
||'1' || ' foi menor que o valor da compra de ID  '
||TO_CHAR(mb.cpf) );END IF;
END;
/