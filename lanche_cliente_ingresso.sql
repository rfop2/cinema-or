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