CREATE OR REPLACE TYPE tp_fones AS OBJECT(
    numero VARCHAR2(14)
)FINAL;
/

CREATE OR REPLACE TYPE VA_FONES AS VARRAY(4) OF tp_fones;
/

CREATE OR REPLACE TYPE tp_pessoa AS OBJECT(
	Cpf INT,
	Nome VARCHAR2(30),
	Email  VARCHAR2(30),
	lista_telefones VA_FONES,
	MEMBER FUNCTION documentoOficial RETURN NUMBER
)NOT FINAL NOT INSTANTIABLE;
/

CREATE OR REPLACE TYPE BODY tp_pessoa AS
MEMBER FUNCTION documentoOficial RETURN INTEGER IS
BEGIN
	RETURN SELF.CarteiraTrabalho;
END;
END;
/


#CINEMA QUE FUNCIONA
CREATE OR REPLACE TYPE tp_endereco AS OBJECT(
    Cep VARCHAR2(9),
    Estado VARCHAR2(30),
    Cidade VARCHAR2(30),
    Bairro VARCHAR2(30),
    Rua VARCHAR2(100),
    Numero INT
)FINAL;
/
CREATE OR REPLACE TYPE tp_sala AS OBJECT(
		num_sala INT,
    num_lugares INT
)FINAL;
/
CREATE OR REPLACE TYPE va_salas AS VARRAY(15) OF tp_sala;
/
CREATE OR REPLACE TYPE tp_sessao AS OBJECT (
		dia_hora DATE,
		sala INT
)FINAL;
/
CREATE TYPE tp_nt_sessao AS TABLE OF tp_sessao;
/
CREATE OR REPLACE TYPE tp_filme AS OBJECT (
		codigo INT ,
		classificacao VARCHAR2(30),
		genero VARCHAR2(30),
		titulo VARCHAR2(30),
    sessoes tp_nt_sessao
)FINAL;
/
CREATE TYPE tp_nt_filme AS TABLE OF tp_filme ;
/
CREATE OR REPLACE TYPE tp_cinema AS OBJECT(
	Identificador INT,
	endereco tp_endereco,
	lista_salas va_salas ,
  filmes tp_nt_filme
)FINAL;
/
CREATE TABLE tb_cinema OF tp_cinema(Identificador PRIMARY KEY)NESTED TABLE filmes STORE AS st_filmes (NESTED TABLE sessoes STORE AS st_sessao);
INSERT INTO tb_cinema VALUES (
1 , 
tp_endereco('51110-160','Pernambuco', 'Recife', 'Pina', 'Av. República do Líbano', 251) ,
va_salas(tp_sala(1,30),tp_sala(2,30),tp_sala(3,45)) ,
tp_nt_filme(tp_filme(1,'livre','ação','Superman',tp_nt_sessao(tp_sessao(TO_DATE('01/02/2020 14:02:44', 'dd/mm/yyyy hh24:mi:ss'),1),tp_sessao(TO_DATE('01/02/2020 18:02:44', 'dd/mm/yyyy hh24:mi:ss'),1) )))
);
SELECT * FROM TABLE (SELECT c.filmes FROM tb_cinema c WHERE c.identificador = 1);
SELECT * FROM TABLE (SELECT b.sessoes FROM TABLE (SELECT c.filmes FROM tb_cinema c WHERE c.identificador = 1)  b WHERE b.codigo = 1);

CREATE OR REPLACE TYPE tp_lanche AS OBJECT(
    Identificador INT,
    Descricao VARCHAR2(30),
    Preco FLOAT
)FINAL;
/

CREATE OR REPLACE TYPE tp_cliente UNDER tp_pessoa (
    Pontos_fidelidade INT
) FINAL;
/

CREATE TABLE tb_cliente OF tp_cliente(Cpf PRIMARY KEY);

INSERT INTO tb_cliente VALUES (tp_cliente('14557874569', 'Maria da Silva', 'mariadasilva@gmail.com', va_fones(tp_fones('33597895'),tp_fones('33597825'),tp_fones('33597805')) , '15'));

CREATE OR REPLACE TYPE tp_ingresso AS OBJECT (
    NumeroCadeira VARCHAR2(3),
    Cinema REF tp_cinema,
    Sessao tp_sessao,
    MAP MEMBER FUNCTION get_cinema RETURN INT
) FINAL;
/

CREATE OR REPLACE TYPE BODY tp_ingresso AS
FINAL MEMBER FUNCTION get_cinema IS
BEGIN
    RETURN SELF.cinema;
END;
END;
/

#Overriding member function em tp_funcionario
CREATE OR REPLACE TYPE tp_funcionario UNDER tp_pessoa (
    CarteiraTrabalho VARCHAR2(30),
    Salario NUMBER(10),
    MEMBER PROCEDURE setSalario (s NUMBER),
		OVERRIDING MEMBER FUNCTION documentoOficial RETURN NUMBER
) FINAL;
/
CREATE OR REPLACE TYPE BODY tp_funcionario AS 
FINAL MEMBER PROCEDURE setSalario(s NUMBER) IS
BEGIN
    salario:=s;
END;
MEMBER FUNCTION documentoOficial RETURN INTEGER IS
BEGIN
	RETURN SELF.CarteiraTrabalho;
END;
END;
/

ALTER TYPE tp_funcionario ADD ATTRIBUTE (carteiratrabalho_supervisor VARCHAR2(30)) CASCADE;

CREATE TABLE tb_funcionario OF tp_funcionario(CarteiraTrabalho PRIMARY KEY);

INSERT INTO tb_funcionario VALUES ('87456867456', 'Jaqueline Medeiros', 'jaquelinemedeiros@gmail.com', va_fones(tp_fones('31007805'),tp_fones('30067825'),tp_fones('32222805')), 83684462000100, 3000, NULL );

INSERT INTO tb_funcionario VALUES ('87748567456', 'Roberta Medeiros', 'robertamedeiros@gmail.com', va_fones(tp_fones('31397805'),tp_fones('33367825'),tp_fones('36697805')), 94667164000110, 1045, 83684462000100 );

SELECT * FROM TABLE(SELECT a.lista_telefones FROM tb_funcionario a WHERE a.CPF = 87748567456);


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