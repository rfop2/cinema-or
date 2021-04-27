CREATE OR REPLACE TYPE tp_funcionario UNDER tp_pessoa (
    CarteiraTrabalho VARCHAR2(30),
    Salario NUMBER(10),
    MEMBER PROCEDURE setSalario (s NUMBER)
) FINAL;
/
CREATE OR REPLACE TYPE BODY tp_funcionario AS 
FINAL MEMBER PROCEDURE setSalario(s NUMBER) IS
BEGIN
    salario:=s;
END;
END;
/

ALTER TYPE tp_funcionario ADD ATTRIBUTE (carteiratrabalho_supervisor VARCHAR2(30)) CASCADE;

CREATE TABLE tb_funcionario OF tp_funcionario(CarteiraTrabalho PRIMARY KEY);

INSERT INTO tb_funcionario VALUES ('87456867456', 'Jaqueline Medeiros', 'jaquelinemedeiros@gmail.com', va_fones(tp_fones('31007805'),tp_fones('30067825'),tp_fones('32222805')), 83684462000100, 3000, NULL );

INSERT INTO tb_funcionario VALUES ('87748567456', 'Roberta Medeiros', 'robertamedeiros@gmail.com', va_fones(tp_fones('31397805'),tp_fones('33367825'),tp_fones('36697805')), 94667164000110, 1045, 83684462000100 );

SELECT * FROM TABLE(SELECT a.lista_telefones FROM tb_funcionario a WHERE a.CPF = 87748567456);
