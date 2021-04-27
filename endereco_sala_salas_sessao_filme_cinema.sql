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
