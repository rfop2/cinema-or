CREATE OR REPLACE TYPE tp_fones AS OBJECT(
    numero VARCHAR2(14)
)FINAL;
/

CREATE OR REPLACE TYPE VA_FONES AS VARRAY(4) OF tp_fones;
/

#Adição de uma função, e portanto um body em tp_pessoa
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