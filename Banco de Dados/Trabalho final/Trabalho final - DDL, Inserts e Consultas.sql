CREATE DATABASE IF NOT EXISTS PetShop;
USE PetShop;

CREATE TABLE IF NOT EXISTS Cliente (
    id 		 INT PRIMARY KEY AUTO_INCREMENT,
	email    VARCHAR(70) UNIQUE,
    senha    VARCHAR(255) NOT NULL,
    cpf      VARCHAR(11) NOT NULL UNIQUE,
    nome     VARCHAR(70) NOT NULL,
    endereco VARCHAR(70) NOT NULL,
    telefone VARCHAR(11) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Pet (
	id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(30) NOT NULL,
    raca VARCHAR(20) NOT NULL,
    dono_id INT NOT NULL,
    FOREIGN KEY (dono_id) REFERENCES Cliente (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Funcionario (
	id INT PRIMARY KEY AUTO_INCREMENT,
	ctps INT NOT NULL UNIQUE,
    nome VARCHAR(70) NOT NULL,
    admissao DATE NOT NULL,
    demissao DATE NULL,
    salario DECIMAL (6, 2),
    funcao ENUM("vendedor", "cuidador", "motorista", "banhista", "tosador")
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Reserva (
	entrada DATETIME NOT NULL,
    saida DATETIME NOT NULL,
    pet_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    cliente_id INT NOT NULL,
        
    FOREIGN KEY (pet_id) REFERENCES Pet (id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionario (id),
    FOREIGN KEY (cliente_id) REFERENCES Cliente (id),
    PRIMARY KEY (entrada, pet_id) -- O mesmo pet não pode ter mais de uma entrada no mesmo horário.
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Banho (
	horario DATETIME NOT NULL,
    pet_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    valor DECIMAL(5,2),
    
    PRIMARY KEY (horario, pet_id), -- O mesmo pet não pode ter dois banhos marcados no mesmo horário.
    FOREIGN KEY (pet_id) REFERENCES Pet (id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionario (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Produto (
	cod INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(70) NOT NULL,
    valor DECIMAL(6,2) NOT NULL,
    unidade ENUM ("m", "un", "g", "kg")
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Estoque (
	cod_produto INT NOT NULL,
    quantidade FLOAT NOT NULL,
    validade DATE NOT NULL,
      
    PRIMARY KEY (cod_produto, validade),
    FOREIGN KEY (cod_produto) REFERENCES Produto (cod)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Pedido (
	numero INT PRIMARY KEY AUTO_INCREMENT,
    data_pedido DATETIME NOT NULL,
    cliente_id INT NOT NULL,
    funcionario_id INT NOT NULL,

    FOREIGN KEY (cliente_id) REFERENCES Cliente (id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionario (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS ProdutosPedido (
    num_pedido INT NOT NULL,
    cod_produto INT NOT NULL,
    quantidade INT,
    
    PRIMARY KEY (num_pedido, cod_produto),
    FOREIGN KEY (num_pedido) REFERENCES Pedido (numero),
    FOREIGN KEY (cod_produto) REFERENCES Produto (cod)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Veterinario (
	crmv INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(70) NOT NULL,
    admissao DATE NOT NULL,
    demissao DATE,
    salario DECIMAL (6, 2)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Consulta (
	crmv_vet INT NOT NULL,
    pet_id INT NOT NULL,
    data_consulta DATETIME NOT NULL,
    valor DECIMAL (6, 2),
    
    PRIMARY KEY (crmv_vet, pet_id, data_consulta),
    FOREIGN KEY (crmv_vet) REFERENCES Veterinario (crmv),
    FOREIGN KEY (pet_id) REFERENCES Pet (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Vacina (
	nome VARCHAR(100),
	lote INT NOT NULL,
    estoque INT NOT NULL,
    validade DATE NOT NULL,
    
    PRIMARY KEY (nome, lote)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS Vacinacao (
	pet_id INT NOT NULL,
    crmv_vet INT NOT NULL,
    nome_vacina VARCHAR(100) NOT NULL,
    lote_vacina INT NOT NULL,
    data_vacinacao DATETIME NOT NULL,
    
    PRIMARY KEY (pet_id, crmv_vet, nome_vacina, lote_vacina),
    FOREIGN KEY (crmv_vet) REFERENCES Veterinario (crmv),
    FOREIGN KEY (nome_vacina, lote_vacina) REFERENCES Vacina (nome, lote)
) ENGINE = InnoDB;

-- Views

CREATE VIEW VEstoque (Código, Descrição, Unidade, Quantidade, Validade) AS
	SELECT  
		P.cod, P.descricao, P.unidade, E.quantidade, E.validade
    FROM Produto P JOIN Estoque E ON P.cod = E.cod_produto;

CREATE VIEW VProdutosPedido (`Cliente` , `Pedido` , `Descrição`, `Quantidade`, `Funcionário`) AS
	SELECT C.nome, Pe.numero as Pedido, P.descricao, PP.quantidade, F.nome FROM Cliente C
		JOIN Pedido Pe ON Pe.cliente_id = C.id
		JOIN ProdutosPedido PP ON PP.num_pedido = Pe.numero
		JOIN Produto P ON P.cod = PP.cod_produto
        JOIN Funcionario F ON F.id = Pe.funcionario_id;


CREATE VIEW VReservas (`Pet`, `Dono`, `Entrada`, `Saída`, `Funcionário`) AS
	SELECT P.nome as Pet, C.nome as Cliente, R.entrada, R.saida, F.nome as Funcionário FROM Reserva R
		JOIN Pet P ON P.id = R.pet_id
		JOIN Cliente C ON C.id = R.cliente_id
		JOIN Funcionario F ON F.id = R.funcionario_id;

CREATE VIEW VConsultas (`Pet`, `Raça`, `Dono`, `Veterinário`, `Data`, `Valor`) AS
	SELECT P.nome, P.raca, Cli.nome, V.nome, Co.data_consulta, Co.valor FROM Consulta Co
		JOIN Veterinario V ON V.crmv = Co.crmv_vet
		JOIN Pet P ON P.id = Co.pet_id
		JOIN Cliente Cli ON Cli.id = P.dono_id;

CREATE VIEW VVacinacao (`Pet`, `Raça`, `Dono`, `Veterinário`, `Vacina`, `Lote da vacina`, `Data da vacinação`) AS
	SELECT P.nome, P.raca, C.nome, Vet.nome, Vac.nome, Vac.lote, V.data_vacinacao FROM Vacinacao V
		JOIN Pet P ON P.id = V.pet_id
		JOIN Cliente C ON C.id = P.dono_id
		JOIN Veterinario Vet ON Vet.crmv = V.crmv_vet
		JOIN Vacina Vac ON Vac.nome = V.nome_vacina;
        
CREATE VIEW VPedidos (`Número`, `Cliente`, `Total`, `Data do pedido`, `Vendedor`) AS
SELECT Pe.numero, C.nome as Cliente, SUM(PP.quantidade * P.valor), Pe.data_pedido, F.nome FROM Cliente C
    JOIN Pedido Pe ON Pe.cliente_id = C.id
    JOIN ProdutosPedido PP ON Pe.numero = PP.num_pedido
    JOIN Produto P ON P.cod = PP.cod_produto
    JOIN Funcionario F ON F.id = Pe.funcionario_id
    GROUP BY C.nome;
        
-- Procedures

DELIMITER $

/*
	Adiciona cliente
    Verifica se o email é válido.
    Verifica se há o mesmo email cadastrado.
    Verifica se há o mesmo CPF cadastrado.
*/ 
CREATE PROCEDURE `ADDCLIENTE`(IN email VARCHAR(70), IN senha VARCHAR(255), IN cpf VARCHAR(11), IN nome VARCHAR(70), IN endereco VARCHAR(70), IN telefone VARCHAR(11))
BEGIN

    IF email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Email inválido.";
	ELSEIF EXISTS (SELECT * FROM Cliente C WHERE C.email = email) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Email já cadastrado.";
	ELSEIF EXISTS (SELECT * FROM Cliente C WHERE C.cpf = cpf) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "CPF já utilizado.";
	ELSE
		INSERT INTO Cliente (email, senha, cpf, nome, endereco, telefone) VALUES (email, SHA(senha), cpf, nome, endereco, telefone);
    END IF;
    
END$

/*
	Adiciona pet.
    Verifica se o cliente existe.
    Verifica se o pet já está cadastrado.
*/
CREATE PROCEDURE `ADDPET`(IN nome VARCHAR(30), IN raca VARCHAR(20), IN cliente_cpf VARCHAR(11))
BEGIN
	
    DECLARE dono_id INT;
    
    SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf INTO dono_id;
    
    IF NOT EXISTS (SELECT * FROM Cliente C WHERE C.id = dono_id) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Usuário inválido.";
	END IF;
    
    IF EXISTS (SELECT * FROM Pet P WHERE P.nome = nome AND P.raca = raca AND P.dono_id = dono_id) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Pet já cadastrado.";
	ELSE
		INSERT INTO Pet (nome, raca, dono_id) VALUES (nome, raca, dono_id);
	END IF;

END$

-- Adiciona funcionário. Verifica se a CTPS já foi cadastrada.
CREATE PROCEDURE `ADDFUNC`(IN ctps INT, IN nome VARCHAR(70), IN admissao DATE, IN salario DECIMAL(6, 2), IN funcao ENUM("vendedor", "cuidador", "motorista", "banhista", "tosador"))
BEGIN

	IF EXISTS (SELECT * FROM Funcionario F WHERE F.ctps = ctps) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Carteira de trabalho já cadastrada para outro funcionário";
    ELSE
		INSERT INTO Funcionario (ctps, nome, admissao, salario, funcao) VALUES (ctps, nome, admissao, salario, funcao);
    END IF;
    
END$

/*
	Adiciona pedido. Verifica se a data que o pedido está sendo feito é maior ou igual a atual.
	Verifica se o funcionário na operação é um vendedor.
*/
CREATE PROCEDURE `ADDPEDIDO`(IN data_pedido DATETIME, IN cliente_cpf VARCHAR(11), IN funcionario_ctps INT)
BEGIN

	DECLARE cliente_id INT;
    DECLARE funcionario_id INT;
    
    SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf
    INTO cliente_id;
    
    SELECT F.id FROM Funcionario F WHERE F.ctps = funcionario_ctps
    INTO funcionario_id;
    
    IF data_pedido >= CURRENT_TIMESTAMP THEN
		IF EXISTS (SELECT F.id FROM Funcionario F WHERE F.id = funcionario_id AND funcao = "vendedor") THEN
			INSERT INTO Pedido (data_pedido, cliente_id, funcionario_id)
			VALUES (data_pedido, cliente_id, funcionario_id);
		ELSE
			SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Funcionário não é um vendedor.";
		END IF;
	ELSE
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Data do pedido inválida";
    END IF;
    
END$

/*
	Vincula o produto ao pedido.
    Verifica se existe o pedido e o produto informado.
    Altera o estoque do produto.
*/
CREATE PROCEDURE `ADDPROD2PEDIDO`(IN num_pedido INT, IN cod_produto INT, IN quantidade FLOAT)
BEGIN

	IF EXISTS (SELECT * FROM Pedido P WHERE P.numero = num_pedido) AND EXISTS (SELECT * FROM Produto P WHERE P.cod = cod_produto) THEN
		INSERT INTO ProdutosPedido (num_pedido, cod_produto, quantidade) VALUES (num_pedido, cod_produto, quantidade);
        UPDATE Estoque E SET E.quantidade = E.quantidade - quantidade WHERE E.cod_produto = cod_produto AND E.quantidade > 0 ORDER BY E.validade ASC LIMIT 1;
	ELSE
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Número do pedido ou código do produto inválidos.";
	END IF;
    
END$

/*
	Adiciona um produto.
    Verifica se a validade é anterior à data atual.
	Caso o produto não exista, ele é criado e seu estoque é alterado. Se já existe, seu estoque é alterado de acordo com a data de validade.
*/
CREATE PROCEDURE `ADDPRODUTO`(IN descricao VARCHAR(70), IN valor DECIMAL(6, 2), IN unidade ENUM ("m", "un", "g", "kg"), IN quantidade FLOAT, IN validade DATE)
BEGIN

	DECLARE ProdCod INT;
    
    IF validade < CURRENT_DATE() THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Data de validade inválida";
	END IF;

    IF NOT EXISTS (SELECT * FROM Produto P WHERE P.descricao = descricao) THEN
		INSERT INTO Produto (descricao, valor, unidade) VALUES (descricao, valor, unidade);
        SELECT P.cod FROM Produto P WHERE P.descricao = descricao ORDER BY cod DESC LIMIT 1
		INTO ProdCod;
        
        INSERT INTO Estoque (cod_produto, quantidade, validade) VALUES (ProdCod, quantidade, validade);
	ELSEIF EXISTS (SELECT * FROM Produto P WHERE P.descricao = descricao) THEN
		SELECT P.cod FROM Produto P WHERE P.descricao = descricao ORDER BY cod DESC LIMIT 1
		INTO ProdCod;
        
        INSERT INTO Estoque (cod_produto, quantidade, validade) VALUES (ProdCod, quantidade, validade);
	ELSE
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Erro durante criação do produto";
	END IF;

END$

/*
	Faz uma reserva.
    Verifica se o funcionário vinculado é um cuidador.
    Verifica se já existe uma reserva cadastrada para o pet no mesmo período.
*/
CREATE PROCEDURE `MKRESERVA`(IN entrada DATETIME, IN saida DATETIME, IN pet_nome VARCHAR(30), IN funcionario_ctps INT, IN cliente_cpf VARCHAR(11))
BEGIN
	
    DECLARE funcionario_id INT;
    DECLARE cliente_id INT;
    DECLARE pet_id INT;
    
    SELECT F.id FROM Funcionario F WHERE F.ctps = funcionario_ctps
    INTO funcionario_id;
    
    SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf
    INTO cliente_id;
    
    SELECT P.id FROM Pet P WHERE P.nome = pet_nome AND P.dono_id = cliente_id
    INTO pet_id;
    
    IF NOT EXISTS (SELECT * FROM Funcionario F WHERE F.id = funcionario_id AND F.funcao = "cuidador") THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "O funcionário vinculado não exerce a função de cuidador";
	END IF;
    
    IF NOT EXISTS (SELECT * FROM Reserva R WHERE R.pet_id = pet_id AND R.saida > entrada) THEN
		INSERT INTO Reserva (entrada, saida, pet_id, funcionario_id, cliente_id) VALUES
        (entrada, saida, pet_id, funcionario_id, cliente_id);
	ELSE
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Já existe uma reserva cadastrada para esse período.";
    END IF;
    
END$

/*
	Faz um registro de banho.
    Verifica se o funcionário é um "banhista".
    Verifica se o valor da operação é menor que 0.
    Verifica se existem todos os dados informados sobre pet, cliente e funcionário, e então faz o registro.
*/
CREATE PROCEDURE `MKBANHO`(IN horario DATETIME, IN pet_nome VARCHAR(30), IN cliente_cpf VARCHAR(11), IN funcionario_ctps INT, IN valor DECIMAL (5,2))
BEGIN

	DECLARE pet_id INT;
    DECLARE cliente_id INT;
    DECLARE funcionario_id INT;
    
    SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf
    INTO cliente_id;
    
    SELECT P.id FROM Pet P WHERE P.nome = pet_nome AND P.dono_id = cliente_id
    INTO pet_id;
    
    IF NOT EXISTS (SELECT * FROM Funcionario F WHERE F.ctps = funcionario_ctps AND F.funcao = "banhista") THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Funcionário não é apto para essa operação.";
    ELSE
		SELECT F.id FROM Funcionario F WHERE F.ctps = funcionario_ctps AND F.funcao = "banhista"
        INTO funcionario_id;
    END IF;
    
    IF valor < 0 THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "O valor não pode ser menor que 0.";
	END IF;
    
	IF EXISTS (SELECT * FROM Pet P WHERE P.id = pet_id) AND EXISTS (SELECT * FROM Cliente C WHERE C.id = cliente_id) AND EXISTS (SELECT * FROM Funcionario F WHERE F.id = funcionario_id) THEN
		INSERT INTO Banho VALUES (horario, pet_id, funcionario_id, valor);
	END IF;
    
END$

/*
	Faz o registro de uma consulta.
    Verifica se o pet existe.
    Verifica se o valor da operação é menor ou igual a 0.
    Se a informada for maior que a atual, gera o registro.
*/
CREATE PROCEDURE `MKCONSULTA`(IN crmv_vet INT, IN pet_nome VARCHAR(30), IN cliente_cpf VARCHAR(11), IN data_consulta DATETIME, IN valor DECIMAL (6,2))
BEGIN

	DECLARE pet_id INT;
    
    IF NOT EXISTS (SELECT P.id FROM Pet P WHERE P.dono_id = (SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf) AND P.nome = pet_nome) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "O pet não existe.";
	ELSE
		SELECT P.id FROM Pet P WHERE P.dono_id = (SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf) AND P.nome = pet_nome
        INTO pet_id;
	END IF;
	
	IF valor <= 0 THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "O valor deve ser maior que 0";
    END IF;
    
    IF data_consulta > CURRENT_TIMESTAMP THEN
		INSERT INTO Consulta (crmv_vet, pet_id, data_consulta, valor) VALUES (crmv_vet, pet_id, data_consulta, valor);
    ELSE
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Data inválida";
	END IF;

END$

-- Verifica se o salário informado é menor que 0. Cria o veterinário.
CREATE PROCEDURE `ADDVETERINARIO`(IN crmv INT, IN nome VARCHAR(70), IN admissao DATE, IN salario DECIMAL (6,2))
BEGIN
	
    IF salario <= 0 THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "O salário deve ser maior que 0";
    END IF;
	
	INSERT INTO Veterinario (crmv, nome, admissao, salario) VALUES (crmv, nome, admissao, salario);
    
END$


CREATE PROCEDURE `ADDVACINA`(IN nome VARCHAR(100), IN lote INT, IN quantidade INT, IN validade DATE)
BEGIN

	IF quantidade < 0 THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Quantidade inválida.";
    END IF;

	IF validade > CURRENT_TIMESTAMP THEN
		IF NOT EXISTS (SELECT * FROM Vacina V WHERE V.nome = nome AND V.lote = lote) THEN
			INSERT INTO Vacina (nome, lote, estoque, validade) VALUES (nome, lote, quantidade, validade);
		ELSE 
			UPDATE Vacina V SET V.estoque = V.estoque + quantidade WHERE V.nome = nome AND V.lote = lote AND V.validade = validade;
        END IF;
	END IF;

END$

CREATE PROCEDURE `MKVACINACAO`(IN pet_nome VARCHAR(30), IN cliente_cpf VARCHAR(11), IN crmv_vet INT, IN nome_vacina VARCHAR(100), IN lote_vacina INT, IN data_vacinacao DATETIME)
BEGIN
	DECLARE pet_id INT;
    
    IF NOT EXISTS (SELECT P.id FROM Pet P WHERE P.dono_id = (SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf) AND P.nome = pet_nome) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "O pet não existe.";
	ELSE
		SELECT P.id FROM Pet P WHERE P.dono_id = (SELECT C.id FROM Cliente C WHERE C.cpf = cliente_cpf) AND P.nome = pet_nome
        INTO pet_id;
	END IF;

	IF data_vacinacao > (SELECT V.validade FROM Vacina V WHERE V.nome = nome_vacina AND V.lote = lote_vacina) THEN
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "O lote da vacina está vencido!";
	ELSEIF data_vacinacao > CURRENT_TIMESTAMP THEN
		INSERT INTO Vacinacao (pet_id, crmv_vet, nome_vacina, lote_vacina, data_vacinacao) VALUES (pet_id, crmv_vet, nome_vacina, lote_vacina, data_vacinacao);
        UPDATE Vacina V SET V.estoque = V.estoque - 1 WHERE V.nome = nome_vacina AND V.lote = lote_vacina;
	END IF;
END$

DELIMITER ;	

USE PetShop;

CALL ADDCLIENTE('walter.white@breakingbad.com', 'password123', '12345678901', 'Walter White', '308 Negra Arroyo Lane', '5551234567');
CALL ADDCLIENTE('jesse.pinkman@breakingbad.com', 'password123', '12345678902', 'Jesse Pinkman', '9809 Margo Street', '5551234568');
CALL ADDCLIENTE('saul.goodman@breakingbad.com', 'password123', '12345678903', 'Saul Goodman', '1600 Pennsylvania Avenue', '5551234569');
CALL ADDCLIENTE('hank.schrader@breakingbad.com', 'password123', '12345678904', 'Hank Schrader', '4900 Candelaria Road', '5551234570');
CALL ADDCLIENTE('skyler.white@breakingbad.com', 'password123', '12345678905', 'Skyler White', '308 Negra Arroyo Lane', '5551234571');
CALL ADDCLIENTE('gus.fring@breakingbad.com', 'password123', '12345678906', 'Gus Fring', 'Los Pollos Hermanos', '5551234572');
CALL ADDCLIENTE('mike.ehrmantraut@breakingbad.com', 'password123', '12345678907', 'Mike Ehrmantraut', '3828 Piermont Drive', '5551234573');
CALL ADDCLIENTE('marie.schrader@breakingbad.com', 'password123', '12345678908', 'Marie Schrader', '4900 Candelaria Road', '5551234574');
CALL ADDCLIENTE('lydia.rodartequayle@breakingbad.com', 'password123', '12345678909', 'Lydia Rodarte-Quayle', '50 2nd Street', '5551234575');
CALL ADDCLIENTE('todd.alquist@breakingbad.com', 'password123', '12345678910', 'Todd Alquist', '312 Maple Street', '5551234576');
CALL ADDCLIENTE('rick.grimes@walkingdead.com', 'password123', '22345678901', 'Rick Grimes', 'King County', '5552234567');
CALL ADDCLIENTE('daryl.dixon@walkingdead.com', 'password123', '22345678902', 'Daryl Dixon', 'Woodbury', '5552234568');
CALL ADDCLIENTE('michonne@walkingdead.com', 'password123', '22345678903', 'Michonne', 'Alexandria', '5552234569');
CALL ADDCLIENTE('carl.grimes@walkingdead.com', 'password123', '22345678904', 'Carl Grimes', 'King County', '5552234570');
CALL ADDCLIENTE('carol.peletier@walkingdead.com', 'password123', '22345678905', 'Carol Peletier', 'Alexandria', '5552234571');
CALL ADDCLIENTE('maggie.greene@walkingdead.com', 'password123', '22345678906', 'Maggie Greene', 'Hilltop', '5552234572');
CALL ADDCLIENTE('glenn.rhee@walkingdead.com', 'password123', '22345678907', 'Glenn Rhee', 'Hilltop', '5552234573');
CALL ADDCLIENTE('negan@walkingdead.com', 'password123', '22345678908', 'Negan', 'Sanctuary', '5552234574');
CALL ADDCLIENTE('sasha.williams@walkingdead.com', 'password123', '22345678909', 'Sasha Williams', 'Alexandria', '5552234575');
CALL ADDCLIENTE('rosita.espinosa@walkingdead.com', 'password123', '22345678910', 'Rosita Espinosa', 'Alexandria', '5552234576');
CALL ADDCLIENTE('jon.snow@got.com', 'password123', '32345678901', 'Jon Snow', 'Winterfell', '5553234567');
CALL ADDCLIENTE('daenerys.targaryen@got.com', 'password123', '32345678902', 'Daenerys Targaryen', 'Dragonstone', '5553234568');
CALL ADDCLIENTE('tyrion.lannister@got.com', 'password123', '32345678903', 'Tyrion Lannister', 'Casterly Rock', '5553234569');
CALL ADDCLIENTE('cersei.lannister@got.com', 'password123', '32345678904', 'Cersei Lannister', 'Red Keep', '5553234570');
CALL ADDCLIENTE('arya.stark@got.com', 'password123', '32345678905', 'Arya Stark', 'Winterfell', '5553234571');
CALL ADDCLIENTE('tony.soprano@sopranos.com', 'password123', '42345678901', 'Tony Soprano', 'North Caldwell, NJ', '5554234567');
CALL ADDCLIENTE('carmela.soprano@sopranos.com', 'password123', '42345678902', 'Carmela Soprano', 'North Caldwell, NJ', '5554234568');
CALL ADDCLIENTE('christopher.moltisanti@sopranos.com', 'password123', '42345678903', 'Christopher Moltisanti', 'North Caldwell, NJ', '5554234569');
CALL ADDCLIENTE('paulie.gualtieri@sopranos.com', 'password123', '42345678904', 'Paulie Gualtieri', 'North Caldwell, NJ', '5554234570');
CALL ADDCLIENTE('silvio.dante@sopranos.com', 'password123', '42345678905', 'Silvio Dante', 'North Caldwell, NJ', '5554234571');
CALL ADDCLIENTE('dr.jennifer.melfi@sopranos.com', 'password123', '42345678906', 'Dr. Jennifer Melfi', 'North Caldwell, NJ', '5554234572');
CALL ADDCLIENTE('junior.soprano@sopranos.com', 'password123', '42345678907', 'Junior Soprano', 'North Caldwell, NJ', '5554234573');
CALL ADDCLIENTE('janice.soprano@sopranos.com', 'password123', '42345678908', 'Janice Soprano', 'North Caldwell, NJ', '5554234574');
CALL ADDCLIENTE('meadow.soprano@sopranos.com', 'password123', '42345678909', 'Meadow Soprano', 'North Caldwell, NJ', '5554234575');
CALL ADDCLIENTE('anthony.soprano.jr@sopranos.com', 'password123', '42345678910', 'Anthony Soprano Jr.', 'North Caldwell, NJ', '5554234576');
CALL ADDCLIENTE('sheldon.cooper@bigbangtheory.com', 'password123', '52345678901', 'Sheldon Cooper', 'Pasadena, CA', '5555234567');
CALL ADDCLIENTE('leonard.hofstadter@bigbangtheory.com', 'password123', '52345678902', 'Leonard Hofstadter', 'Pasadena, CA', '5555234568');
CALL ADDCLIENTE('penny@bigbangtheory.com', 'password123', '52345678903', 'Penny', 'Pasadena, CA', '5555234569');
CALL ADDCLIENTE('howard.wolowitz@bigbangtheory.com', 'password123', '52345678904', 'Howard Wolowitz', 'Pasadena, CA', '5555234570');
CALL ADDCLIENTE('raj.koothrappali@bigbangtheory.com', 'password123', '52345678905', 'Raj Koothrappali', 'Pasadena, CA', '5555234571');
CALL ADDCLIENTE('bernadette.rostenkowski@bigbangtheory.com', 'password123', '52345678906', 'Bernadette Rostenkowski', 'Pasadena, CA', '5555234572');
CALL ADDCLIENTE('amy.farrahfowler@bigbangtheory.com', 'password123', '52345678907', 'Amy Farrah Fowler', 'Pasadena, CA', '5555234573');
CALL ADDCLIENTE('stuart.bloom@bigbangtheory.com', 'password123', '52345678908', 'Stuart Bloom', 'Pasadena, CA', '5555234574');
CALL ADDCLIENTE('leslie.winkle@bigbangtheory.com', 'password123', '52345678909', 'Leslie Winkle', 'Pasadena, CA', '5555234575');
CALL ADDCLIENTE('barry.kripke@bigbangtheory.com', 'password123', '52345678910', 'Barry Kripke', 'Pasadena, CA', '5555234576');
CALL ADDCLIENTE('ross.geller@friends.com', 'password123', '62345678901', 'Ross Geller', 'New York, NY', '5556234567');
CALL ADDCLIENTE('rachel.green@friends.com', 'password123', '62345678902', 'Rachel Green', 'New York, NY', '5556234568');
CALL ADDCLIENTE('monica.geller@friends.com', 'password123', '62345678903', 'Monica Geller', 'New York, NY', '5556234569');
CALL ADDCLIENTE('chandler.bing@friends.com', 'password123', '62345678904', 'Chandler Bing', 'New York, NY', '5556234570');
CALL ADDCLIENTE('joey.tribbiani@friends.com', 'password123', '62345678905', 'Joey Tribbiani', 'New York, NY', '5556234571');
CALL ADDCLIENTE('phoebe.buffay@friends.com', 'password123', '62345678906', 'Phoebe Buffay', 'New York, NY', '5556234572');
CALL ADDCLIENTE('dexter.morgan@dexter.com', 'password123', '72345678901', 'Dexter Morgan', 'Miami, FL', '5557234567');
CALL ADDCLIENTE('debra.morgan@dexter.com', 'password123', '72345678902', 'Debra Morgan', 'Miami, FL', '5557234568');
CALL ADDCLIENTE('rita.bennett@dexter.com', 'password123', '72345678903', 'Rita Bennett', 'Miami, FL', '5557234569');
CALL ADDCLIENTE('harrison.morgan@dexter.com', 'password123', '72345678904', 'Harrison Morgan', 'Miami, FL', '5557234570');
CALL ADDCLIENTE('hannah.mckay@dexter.com', 'password123', '72345678905', 'Hannah McKay', 'Miami, FL', '5557234571');
CALL ADDCLIENTE('vincent.masuka@dexter.com', 'password123', '72345678906', 'Vincent Masuka', 'Miami, FL', '5557234572');
CALL ADDCLIENTE('angel.batista@dexter.com', 'password123', '72345678907', 'Angel Batista', 'Miami, FL', '5557234573');
CALL ADDCLIENTE('maria.laguerta@dexter.com', 'password123', '72345678908', 'Maria LaGuerta', 'Miami, FL', '5557234574');
CALL ADDCLIENTE('harry.morgan@dexter.com', 'password123', '72345678909', 'Harry Morgan', 'Miami, FL', '5557234575');
CALL ADDCLIENTE('joseph.quinn@dexter.com', 'password123', '72345678910', 'Joseph Quinn', 'Miami, FL', '5557234576');
CALL ADDCLIENTE('michael.scott@theoffice.com', 'password123', '82345678901', 'Michael Scott', 'Scranton, PA', '5558234567');
CALL ADDCLIENTE('jim.halpert@theoffice.com', 'password123', '82345678902', 'Jim Halpert', 'Scranton, PA', '5558234568');
CALL ADDCLIENTE('pam.beesly@theoffice.com', 'password123', '82345678903', 'Pam Beesly', 'Scranton, PA', '5558234569');
CALL ADDCLIENTE('dwight.schrute@theoffice.com', 'password123', '82345678904', 'Dwight Schrute', 'Scranton, PA', '5558234570');
CALL ADDCLIENTE('andy.bernard@theoffice.com', 'password123', '82345678905', 'Andy Bernard', 'Scranton, PA', '5558234571');
CALL ADDCLIENTE('angela.martin@theoffice.com', 'password123', '82345678906', 'Angela Martin', 'Scranton, PA', '5558234572');
CALL ADDCLIENTE('kevin.malone@theoffice.com', 'password123', '82345678907', 'Kevin Malone', 'Scranton, PA', '5558234573');
CALL ADDCLIENTE('oscar.martinez@theoffice.com', 'password123', '82345678908', 'Oscar Martinez', 'Scranton, PA', '5558234574');
CALL ADDCLIENTE('toby.flenderson@theoffice.com', 'password123', '82345678909', 'Toby Flenderson', 'Scranton, PA', '5558234575');
CALL ADDCLIENTE('stanley.hudson@theoffice.com', 'password123', '82345678910', 'Stanley Hudson', 'Scranton, PA', '5558234576');
CALL ADDCLIENTE('walter.skinner@xfiles.com', 'password123', '92345678901', 'Walter Skinner', 'Washington, DC', '5559234567');
CALL ADDCLIENTE('fox.mulder@xfiles.com', 'password123', '92345678902', 'Fox Mulder', 'Washington, DC', '5559234568');
CALL ADDCLIENTE('dana.scully@xfiles.com', 'password123', '92345678903', 'Dana Scully', 'Washington, DC', '5559234569');
CALL ADDCLIENTE('john.doggett@xfiles.com', 'password123', '92345678904', 'John Doggett', 'Washington, DC', '5559234570');
CALL ADDCLIENTE('monica.reyes@xfiles.com', 'password123', '92345678905', 'Monica Reyes', 'Washington, DC', '5559234571');
CALL ADDCLIENTE('alex.krycek@xfiles.com', 'password123', '92345678906', 'Alex Krycek', 'Washington, DC', '5559234572');
CALL ADDCLIENTE('smoking.man@xfiles.com', 'password123', '92345678907', 'Cigarette Smoking Man', 'Washington, DC', '5559234573');
CALL ADDCLIENTE('alvin.kersch@xfiles.com', 'password123', '92345678908', 'Alvin Kersch', 'Washington, DC', '5559234574');
CALL ADDCLIENTE('brad.follmer@xfiles.com', 'password123', '92345678909', 'Brad Follmer', 'Washington, DC', '5559234575');
CALL ADDCLIENTE('jeffrey.spender@xfiles.com', 'password123', '92345678910', 'Jeffrey Spender', 'Washington, DC', '5559234576');

CALL ADDPET('Buddy', 'Golden Retriever', '12345678901'); -- Walter White
CALL ADDPET('Max', 'Beagle', '12345678902'); -- Jesse Pinkman
CALL ADDPET('Bella', 'Bulldog', '12345678903'); -- Saul Goodman
CALL ADDPET('Lucy', 'Poodle', '12345678904'); -- Hank Schrader
CALL ADDPET('Charlie', 'Labrador', '12345678905'); -- Skyler White
CALL ADDPET('Molly', 'Shih Tzu', '12345678906'); -- Gus Fring
CALL ADDPET('Daisy', 'Pug', '12345678907'); -- Mike Ehrmantraut
CALL ADDPET('Bailey', 'Cocker Spaniel', '12345678908'); -- Marie Schrader
CALL ADDPET('Sadie', 'Boxer', '12345678909'); -- Lydia Rodarte-Quayle
CALL ADDPET('Rocky', 'Dachshund', '12345678910'); -- Todd Alquist
CALL ADDPET('Duke', 'Great Dane', '22345678901'); -- Rick Grimes
CALL ADDPET('Roxy', 'Husky', '22345678902'); -- Daryl Dixon
CALL ADDPET('Jack', 'German Shepherd', '22345678903'); -- Michonne
CALL ADDPET('Zoey', 'Yorkshire Terrier', '22345678904'); -- Carl Grimes
CALL ADDPET('Chloe', 'Border Collie', '22345678905'); -- Carol Peletier
CALL ADDPET('Cooper', 'Pit Bull', '22345678906'); -- Maggie Greene
CALL ADDPET('Sophie', 'Dalmatian', '22345678907'); -- Glenn Rhee
CALL ADDPET('Tucker', 'Chihuahua', '22345678908'); -- Negan
CALL ADDPET('Riley', 'Rottweiler', '22345678909'); -- Sasha Williams
CALL ADDPET('Harley', 'Bichon Frise', '22345678910'); -- Rosita Espinosa
CALL ADDPET('Buster', 'Saint Bernard', '32345678901'); -- Jon Snow
CALL ADDPET('Ziggy', 'Akita', '32345678902'); -- Daenerys Targaryen
CALL ADDPET('Ollie', 'Cavalier King Charles Spaniel', '32345678903'); -- Tyrion Lannister
CALL ADDPET('Lola', 'Chow Chow', '32345678904'); -- Cersei Lannister
CALL ADDPET('Murphy', 'Schnauzer', '32345678905'); -- Arya Stark
CALL ADDPET('Finn', 'Samoyed', '42345678901'); -- Tony Soprano
CALL ADDPET('Luna', 'Whippet', '42345678902'); -- Carmela Soprano
CALL ADDPET('Simba', 'Bengal Cat', '42345678903'); -- Christopher Moltisanti
CALL ADDPET('Milo', 'Maine Coon', '42345678904'); -- Paulie Gualtieri
CALL ADDPET('Nala', 'Persian Cat', '42345678905'); -- Silvio Dante
CALL ADDPET('Coco', 'Ragdoll Cat', '42345678906'); -- Dr. Jennifer Melfi
CALL ADDPET('Shadow', 'Sphynx Cat', '42345678907'); -- Junior Soprano
CALL ADDPET('Loki', 'Scottish Fold', '42345678908'); -- Janice Soprano
CALL ADDPET('Oscar', 'British Shorthair', '42345678909'); -- Meadow Soprano
CALL ADDPET('Leo', 'Siamese Cat', '42345678910'); -- Anthony Soprano Jr.
CALL ADDPET('Ruby', 'Beagle', '52345678901'); -- Sheldon Cooper
CALL ADDPET('Scout', 'Collie', '52345678902'); -- Leonard Hofstadter
CALL ADDPET('Bear', 'Bernese Mountain Dog', '52345678903'); -- Penny
CALL ADDPET('Piper', 'Corgi', '52345678904'); -- Howard Wolowitz
CALL ADDPET('Ranger', 'Vizsla', '52345678905'); -- Raj Koothrappali
CALL ADDPET('Maggie', 'Newfoundland', '52345678906'); -- Bernadette Rostenkowski
CALL ADDPET('Diesel', 'Mastiff', '52345678907'); -- Amy Farrah Fowler
CALL ADDPET('Chase', 'American Bulldog', '52345678908'); -- Stuart Bloom
CALL ADDPET('Jasper', 'Australian Shepherd', '52345678909'); -- Leslie Winkle
CALL ADDPET('Axel', 'English Setter', '52345678910'); -- Barry Kripke
CALL ADDPET('Zeus', 'Doberman', '62345678901'); -- Ross Geller
CALL ADDPET('Daisy', 'French Bulldog', '62345678902'); -- Rachel Green
CALL ADDPET('Juno', 'Greyhound', '62345678903'); -- Monica Geller
CALL ADDPET('Blu', 'Weimaraner', '62345678904'); -- Chandler Bing
CALL ADDPET('Moose', 'Pomeranian', '62345678905'); -- Joey Tribbiani
CALL ADDPET('Ginger', 'Papillon', '62345678906'); -- Phoebe Buffay
CALL ADDPET('Tiger', 'Maine Coon', '72345678901'); -- Dexter Morgan
CALL ADDPET('Lily', 'Bengal Cat', '72345678902'); -- Debra Morgan
CALL ADDPET('Oreo', 'Persian Cat', '72345678903'); -- Rita Bennett
CALL ADDPET('Felix', 'Ragdoll Cat', '72345678904'); -- Harrison Morgan
CALL ADDPET('Chester', 'Sphynx Cat', '72345678905'); -- Hannah McKay
CALL ADDPET('Boots', 'Scottish Fold', '72345678906'); -- Vincent Masuka
CALL ADDPET('Mittens', 'British Shorthair', '72345678907'); -- Angel Batista
CALL ADDPET('Zorro', 'Siamese Cat', '72345678908'); -- Maria LaGuerta
CALL ADDPET('Simba', 'Bengal Cat', '72345678909'); -- Harry Morgan
CALL ADDPET('Whiskers', 'Maine Coon', '72345678910'); -- Joseph Quinn
CALL ADDPET('Bella', 'Beagle', '82345678901'); -- Michael Scott
CALL ADDPET('Lucy', 'Labrador', '82345678902'); -- Jim Halpert
CALL ADDPET('Milo', 'Bulldog', '82345678903'); -- Pam Beesly
CALL ADDPET('Bailey', 'Golden Retriever', '82345678904'); -- Dwight Schrute
CALL ADDPET('Daisy', 'Poodle', '82345678905'); -- Andy Bernard
CALL ADDPET('Rocky', 'Rottweiler', '82345678906'); -- Angela Martin
CALL ADDPET('Sophie', 'Boxer', '82345678907'); -- Kevin Malone
CALL ADDPET('Chloe', 'Shih Tzu', '82345678908'); -- Oscar Martinez
CALL ADDPET('Buster', 'Dachshund', '82345678909'); -- Toby Flenderson
CALL ADDPET('Nala', 'Chihuahua', '82345678910'); -- Stanley Hudson
CALL ADDPET('Thor', 'Great Dane', '92345678901'); -- Walter Skinner
CALL ADDPET('Athena', 'Husky', '92345678902'); -- Fox Mulder
CALL ADDPET('Apollo', 'German Shepherd', '92345678903'); -- Dana Scully
CALL ADDPET('Hermes', 'Border Collie', '92345678904'); -- John Doggett
CALL ADDPET('Artemis', 'Dalmatian', '92345678905'); -- Monica Reyes
CALL ADDPET('Ares', 'Rottweiler', '92345678906'); -- Alex Krycek
CALL ADDPET('Zephyr', 'Akita', '92345678907'); -- Cigarette Smoking Man
CALL ADDPET('Echo', 'Cavalier King Charles Spaniel', '92345678908'); -- Alvin Kersch
CALL ADDPET('Iris', 'Chow Chow', '92345678909'); -- Brad Follmer
CALL ADDPET('Atlas', 'Saint Bernard', '92345678910'); -- Jeffrey Spender
CALL ADDPET('Rex', 'Poodle', '12345678901'); -- Walter White
CALL ADDPET('Bella', 'Boxer', '12345678902'); -- Jesse Pinkman
CALL ADDPET('Luna', 'Siamese Cat', '12345678903'); -- Saul Goodman
CALL ADDPET('Charlie', 'Beagle', '12345678904'); -- Hank Schrader
CALL ADDPET('Molly', 'Golden Retriever', '12345678905'); -- Skyler White
CALL ADDPET('Buddy', 'Bulldog', '12345678906'); -- Gus Fring
CALL ADDPET('Max', 'Rottweiler', '12345678907'); -- Mike Ehrmantraut
CALL ADDPET('Rocky', 'Maine Coon', '12345678908'); -- Marie Schrader
CALL ADDPET('Jack', 'Labrador', '12345678909'); -- Lydia Rodarte-Quayle
CALL ADDPET('Oscar', 'Shih Tzu', '12345678910'); -- Todd Alquist
CALL ADDPET('Sam', 'Pomeranian', '22345678901'); -- Rick Grimes
CALL ADDPET('Toby', 'Dalmatian', '22345678902'); -- Daryl Dixon
CALL ADDPET('Coco', 'Yorkshire Terrier', '22345678903'); -- Michonne
CALL ADDPET('Sasha', 'Dachshund', '22345678904'); -- Carl Grimes
CALL ADDPET('Gizmo', 'Persian Cat', '22345678905'); -- Carol Peletier

CALL ADDFUNC(101, 'Homer Simpson', '2023-01-15', 3000.00, 'vendedor');
CALL ADDFUNC(102, 'Marge Simpson', '2023-02-20', 3200.00, 'cuidador');
CALL ADDFUNC(103, 'Bart Simpson', '2023-03-25', 2800.00, 'motorista');
CALL ADDFUNC(104, 'Lisa Simpson', '2023-04-30', 3500.00, 'banhista');
CALL ADDFUNC(105, 'Maggie Simpson', '2023-05-05', 2900.00, 'tosador');
CALL ADDFUNC(106, 'Peter Griffin', '2023-01-10', 3100.00, 'vendedor');
CALL ADDFUNC(107, 'Lois Griffin', '2023-02-15', 3300.00, 'cuidador');
CALL ADDFUNC(108, 'Stewie Griffin', '2023-03-20', 2700.00, 'motorista');
CALL ADDFUNC(109, 'Brian Griffin', '2023-04-25', 3600.00, 'banhista');
CALL ADDFUNC(110, 'Meg Griffin', '2023-05-30', 3000.00, 'tosador');
CALL ADDFUNC(111, 'Fred Flintstone', '2023-01-05', 3100.00, 'vendedor');
CALL ADDFUNC(112, 'Wilma Flintstone', '2023-02-10', 3200.00, 'cuidador');
CALL ADDFUNC(113, 'Barney Rubble', '2023-03-15', 3000.00, 'motorista');
CALL ADDFUNC(114, 'Betty Rubble', '2023-04-20', 3300.00, 'banhista');
CALL ADDFUNC(115, 'Bam-Bam Rubble', '2023-05-25', 2800.00, 'tosador');
CALL ADDFUNC(116, 'Scooby-Doo', '2023-01-12', 3400.00, 'vendedor');
CALL ADDFUNC(117, 'Shaggy Rogers', '2023-02-17', 3000.00, 'cuidador');
CALL ADDFUNC(118, 'Fred Jones', '2023-03-22', 3600.00, 'motorista');
CALL ADDFUNC(119, 'Daphne Blake', '2023-04-27', 3300.00, 'banhista');
CALL ADDFUNC(120, 'Velma Dinkley', '2023-05-02', 3100.00, 'tosador');
CALL ADDFUNC(121, 'Mickey Mouse', '2023-01-18', 3500.00, 'vendedor');
CALL ADDFUNC(122, 'Minnie Mouse', '2023-02-23', 3200.00, 'cuidador');
CALL ADDFUNC(123, 'Donald Duck', '2023-03-28', 3100.00, 'motorista');
CALL ADDFUNC(124, 'Daisy Duck', '2023-04-03', 3400.00, 'banhista');
CALL ADDFUNC(125, 'Goofy', '2023-05-08', 3000.00, 'tosador');
CALL ADDFUNC(126, 'SpongeBob SquarePants', '2023-06-12', 3300.00, 'vendedor');
CALL ADDFUNC(127, 'Patrick Star', '2023-07-17', 3200.00, 'cuidador');
CALL ADDFUNC(128, 'Squidward Tentacles', '2023-08-22', 3100.00, 'motorista');
CALL ADDFUNC(129, 'Sandy Cheeks', '2023-09-27', 3400.00, 'banhista');
CALL ADDFUNC(130, 'Mr. Krabs', '2023-10-02', 3000.00, 'tosador');
CALL ADDFUNC(131, 'Homer Simpson', '2023-11-07', 3500.00, 'vendedor');
CALL ADDFUNC(132, 'Marge Simpson', '2023-12-12', 3300.00, 'cuidador');
CALL ADDFUNC(133, 'Bart Simpson', '2023-01-17', 3200.00, 'motorista');
CALL ADDFUNC(134, 'Lisa Simpson', '2023-02-22', 3100.00, 'banhista');
CALL ADDFUNC(135, 'Maggie Simpson', '2023-03-27', 3400.00, 'tosador');

CALL MKRESERVA('2024-07-01 10:00:00', '2024-07-06 15:00:00', 'Buddy', 132, '12345678901'); 
CALL MKRESERVA('2024-07-02 11:00:00', '2024-07-07 14:00:00', 'Rex', 102, '12345678901'); 
CALL MKRESERVA('2024-07-03 12:00:00', '2024-07-08 13:00:00', 'Max', 132, '12345678902'); 
CALL MKRESERVA('2024-07-04 13:00:00', '2024-07-09 12:00:00', 'Bella', 102, '12345678902'); 
CALL MKRESERVA('2024-07-05 14:00:00', '2024-07-10 11:00:00', 'Bella', 107, '12345678903'); 
CALL MKRESERVA('2024-07-06 15:00:00', '2024-07-11 10:00:00', 'Luna', 112, '12345678903'); 
CALL MKRESERVA('2024-07-07 16:00:00', '2024-07-12 09:00:00', 'Lucy', 117, '12345678904'); 
CALL MKRESERVA('2024-07-08 17:00:00', '2024-07-13 08:00:00', 'Charlie', 122, '12345678904'); 
CALL MKRESERVA('2024-07-09 18:00:00', '2024-07-14 07:00:00', 'Charlie', 127, '12345678905'); 
CALL MKRESERVA('2024-07-10 19:00:00', '2024-07-15 06:00:00', 'Molly', 132, '12345678905'); 
CALL MKRESERVA('2024-07-11 20:00:00', '2024-07-16 05:00:00', 'Molly', 102, '12345678906'); 
CALL MKRESERVA('2024-07-12 21:00:00', '2024-07-17 04:00:00', 'Buddy', 107, '12345678906'); 
CALL MKRESERVA('2024-07-13 22:00:00', '2024-07-18 03:00:00', 'Daisy', 112, '12345678907'); 
CALL MKRESERVA('2024-07-14 23:00:00', '2024-07-19 02:00:00', 'Max', 117, '12345678907'); 
CALL MKRESERVA('2024-07-15 00:00:00', '2024-07-20 01:00:00', 'Bailey', 122, '12345678908'); 
CALL MKRESERVA('2024-07-16 01:00:00', '2024-07-21 00:00:00', 'Rocky', 127, '12345678908'); 
CALL MKRESERVA('2024-07-17 02:00:00', '2024-07-22 23:00:00', 'Sadie', 132, '12345678909'); 
CALL MKRESERVA('2024-07-18 03:00:00', '2024-07-23 22:00:00', 'Jack', 102, '12345678909'); 
CALL MKRESERVA('2024-07-19 04:00:00', '2024-07-24 21:00:00', 'Rocky', 107, '12345678910'); 
CALL MKRESERVA('2024-07-20 05:00:00', '2024-07-25 20:00:00', 'Oscar', 112, '12345678910'); 
CALL MKRESERVA('2024-07-21 06:00:00', '2024-07-26 19:00:00', 'Duke', 117, '22345678901'); 
CALL MKRESERVA('2024-07-22 07:00:00', '2024-07-27 18:00:00', 'Sam', 122, '22345678901'); 
CALL MKRESERVA('2024-07-23 08:00:00', '2024-07-28 17:00:00', 'Roxy', 127, '22345678902'); 
CALL MKRESERVA('2024-07-24 09:00:00', '2024-07-29 16:00:00', 'Toby', 132, '22345678902'); 
CALL MKRESERVA('2024-07-25 10:00:00', '2024-07-30 15:00:00', 'Buddy', 102, '12345678901');
CALL MKRESERVA('2024-07-26 11:00:00', '2024-07-31 14:00:00', 'Rex', 107, '12345678901');
CALL MKRESERVA('2024-07-27 12:00:00', '2024-08-01 13:00:00', 'Max', 112, '12345678902');
CALL MKRESERVA('2024-07-28 13:00:00', '2024-08-02 12:00:00', 'Bella', 117, '12345678902');
CALL MKRESERVA('2024-07-29 14:00:00', '2024-08-03 11:00:00', 'Bella', 122, '12345678903');
CALL MKRESERVA('2024-07-30 15:00:00', '2024-08-04 10:00:00', 'Luna', 127, '12345678903');
CALL MKRESERVA('2024-07-31 16:00:00', '2024-08-05 09:00:00', 'Lucy', 132, '12345678904');
CALL MKRESERVA('2024-08-01 17:00:00', '2024-08-06 08:00:00', 'Charlie', 102, '12345678904');
CALL MKRESERVA('2024-08-02 18:00:00', '2024-08-07 07:00:00', 'Charlie', 107, '12345678905');
CALL MKRESERVA('2024-08-03 19:00:00', '2024-08-08 06:00:00', 'Molly', 112, '12345678905');
CALL MKRESERVA('2024-08-04 20:00:00', '2024-08-09 05:00:00', 'Molly', 117, '12345678906');
CALL MKRESERVA('2024-08-05 21:00:00', '2024-08-10 04:00:00', 'Buddy', 122, '12345678906');
CALL MKRESERVA('2024-08-06 22:00:00', '2024-08-11 03:00:00', 'Daisy', 127, '12345678907');
CALL MKRESERVA('2024-08-07 23:00:00', '2024-08-12 02:00:00', 'Max', 132, '12345678907');
CALL MKRESERVA('2024-08-08 00:00:00', '2024-08-13 01:00:00', 'Bailey', 102, '12345678908');
CALL MKRESERVA('2024-08-09 01:00:00', '2024-08-14 00:00:00', 'Rocky', 107, '12345678908');
CALL MKRESERVA('2024-08-10 02:00:00', '2024-08-15 23:00:00', 'Sadie', 112, '12345678909');
CALL MKRESERVA('2024-08-11 03:00:00', '2024-08-16 22:00:00', 'Jack', 117, '12345678909');
CALL MKRESERVA('2024-08-12 04:00:00', '2024-08-17 21:00:00', 'Rocky', 122, '12345678910');
CALL MKRESERVA('2024-08-13 05:00:00', '2024-08-18 20:00:00', 'Oscar', 127, '12345678910');
CALL MKRESERVA('2024-08-14 06:00:00', '2024-08-19 19:00:00', 'Duke', 132, '22345678901');
CALL MKRESERVA('2024-08-15 07:00:00', '2024-08-20 18:00:00', 'Sam', 102, '22345678901');
CALL MKRESERVA('2024-08-16 08:00:00', '2024-08-21 17:00:00', 'Roxy', 107, '22345678902');
CALL MKRESERVA('2024-08-17 09:00:00', '2024-08-22 16:00:00', 'Toby', 112, '22345678902');
CALL MKRESERVA('2024-08-18 10:00:00', '2024-08-23 15:00:00', 'Buddy', 102, '12345678901');
CALL MKRESERVA('2024-08-19 11:00:00', '2024-08-24 14:00:00', 'Rex', 107, '12345678901');
CALL MKRESERVA('2024-08-20 12:00:00', '2024-08-25 13:00:00', 'Max', 112, '12345678902');
CALL MKRESERVA('2024-08-21 13:00:00', '2024-08-26 12:00:00', 'Bella', 117, '12345678902');
CALL MKRESERVA('2024-08-22 14:00:00', '2024-08-27 11:00:00', 'Bella', 122, '12345678903');
CALL MKRESERVA('2024-08-23 15:00:00', '2024-08-28 10:00:00', 'Luna', 127, '12345678903');
CALL MKRESERVA('2024-08-24 16:00:00', '2024-08-29 09:00:00', 'Lucy', 132, '12345678904');
CALL MKRESERVA('2024-08-25 17:00:00', '2024-08-30 08:00:00', 'Charlie', 102, '12345678904');
CALL MKRESERVA('2024-08-26 18:00:00', '2024-08-31 07:00:00', 'Charlie', 107, '12345678905');
CALL MKRESERVA('2024-08-27 19:00:00', '2024-09-01 06:00:00', 'Molly', 112, '12345678905');
CALL MKRESERVA('2024-08-28 20:00:00', '2024-09-02 05:00:00', 'Molly', 117, '12345678906');
CALL MKRESERVA('2024-08-29 21:00:00', '2024-09-03 04:00:00', 'Buddy', 122, '12345678906');
CALL MKRESERVA('2024-08-30 22:00:00', '2024-09-04 03:00:00', 'Daisy', 127, '12345678907');
CALL MKRESERVA('2024-08-31 23:00:00', '2024-09-05 02:00:00', 'Max', 132, '12345678907');
CALL MKRESERVA('2024-09-01 00:00:00', '2024-09-06 01:00:00', 'Bailey', 102, '12345678908');
CALL MKRESERVA('2024-09-02 01:00:00', '2024-09-07 00:00:00', 'Rocky', 107, '12345678908');
CALL MKRESERVA('2024-09-03 02:00:00', '2024-09-08 23:00:00', 'Sadie', 112, '12345678909');
CALL MKRESERVA('2024-09-04 03:00:00', '2024-09-09 22:00:00', 'Jack', 117, '12345678909');
CALL MKRESERVA('2024-09-05 04:00:00', '2024-09-10 21:00:00', 'Rocky', 122, '12345678910');
CALL MKRESERVA('2024-09-06 05:00:00', '2024-09-11 20:00:00', 'Oscar', 127, '12345678910');
CALL MKRESERVA('2024-09-07 06:00:00', '2024-09-12 19:00:00', 'Duke', 132, '22345678901');
CALL MKRESERVA('2024-09-08 07:00:00', '2024-09-13 18:00:00', 'Sam', 102, '22345678901');
CALL MKRESERVA('2024-09-09 08:00:00', '2024-09-14 17:00:00', 'Roxy', 107, '22345678902');
CALL MKRESERVA('2024-09-10 09:00:00', '2024-09-15 16:00:00', 'Toby', 112, '22345678902');

CALL ADDPEDIDO('2024-08-18 10:00:00', '12345678901', 101);
CALL ADDPEDIDO('2024-08-19 11:00:00', '12345678901', 106);
CALL ADDPEDIDO('2024-08-20 12:00:00', '12345678902', 111);
CALL ADDPEDIDO('2024-08-21 13:00:00', '12345678902', 116);
CALL ADDPEDIDO('2024-08-22 14:00:00', '12345678903', 121);
CALL ADDPEDIDO('2024-08-23 15:00:00', '12345678903', 126);
CALL ADDPEDIDO('2024-08-24 16:00:00', '12345678904', 131);
CALL ADDPEDIDO('2024-08-25 17:00:00', '12345678904', 101);
CALL ADDPEDIDO('2024-08-26 18:00:00', '22345678901', 106);
CALL ADDPEDIDO('2024-08-27 19:00:00', '22345678901', 111);
CALL ADDPEDIDO('2024-08-28 20:00:00', '22345678902', 116);
CALL ADDPEDIDO('2024-08-29 21:00:00', '22345678902', 121);
CALL ADDPEDIDO('2024-08-30 22:00:00', '22345678903', 126);
CALL ADDPEDIDO('2024-08-31 23:00:00', '22345678903', 131);
CALL ADDPEDIDO('2024-09-01 00:00:00', '32345678901', 101);
CALL ADDPEDIDO('2024-09-02 01:00:00', '32345678901', 106);
CALL ADDPEDIDO('2024-09-03 02:00:00', '32345678902', 111);
CALL ADDPEDIDO('2024-09-04 03:00:00', '32345678902', 116);
CALL ADDPEDIDO('2024-09-05 04:00:00', '32345678903', 121);
CALL ADDPEDIDO('2024-09-06 05:00:00', '32345678903', 126);
CALL ADDPEDIDO('2024-09-07 06:00:00', '42345678901', 131);
CALL ADDPEDIDO('2024-09-08 07:00:00', '42345678901', 101);
CALL ADDPEDIDO('2024-09-09 08:00:00', '42345678902', 106);
CALL ADDPEDIDO('2024-09-10 09:00:00', '42345678902', 111);
CALL ADDPEDIDO('2024-09-11 10:00:00', '42345678903', 116);
CALL ADDPEDIDO('2024-09-12 11:00:00', '42345678903', 121);
CALL ADDPEDIDO('2024-09-13 12:00:00', '52345678901', 126);
CALL ADDPEDIDO('2024-09-14 13:00:00', '52345678901', 131);
CALL ADDPEDIDO('2024-09-15 14:00:00', '52345678902', 101);
CALL ADDPEDIDO('2024-09-16 15:00:00', '52345678902', 106);
CALL ADDPEDIDO('2024-09-17 16:00:00', '52345678903', 111);
CALL ADDPEDIDO('2024-09-18 17:00:00', '52345678903', 116);
CALL ADDPEDIDO('2024-09-19 18:00:00', '62345678901', 121);
CALL ADDPEDIDO('2024-09-20 19:00:00', '62345678901', 126);
CALL ADDPEDIDO('2024-09-21 20:00:00', '62345678902', 131);
CALL ADDPEDIDO('2024-09-22 21:00:00', '62345678902', 101);
CALL ADDPEDIDO('2024-09-23 22:00:00', '62345678903', 106);
CALL ADDPEDIDO('2024-09-24 23:00:00', '62345678903', 111);
CALL ADDPEDIDO('2024-09-25 00:00:00', '72345678901', 116);
CALL ADDPEDIDO('2024-09-26 01:00:00', '72345678901', 121);
CALL ADDPEDIDO('2024-09-27 02:00:00', '72345678902', 126);
CALL ADDPEDIDO('2024-09-28 03:00:00', '72345678902', 131);
CALL ADDPEDIDO('2024-09-29 04:00:00', '72345678903', 101);
CALL ADDPEDIDO('2024-09-30 05:00:00', '72345678903', 106);
CALL ADDPEDIDO('2024-10-01 06:00:00', '82345678901', 111);
CALL ADDPEDIDO('2024-10-02 07:00:00', '82345678901', 116);
CALL ADDPEDIDO('2024-10-03 08:00:00', '82345678902', 121);
CALL ADDPEDIDO('2024-10-04 09:00:00', '82345678902', 126);

CALL ADDPRODUTO('Ração para cães adulto', 50.00, 'kg', 100, '2024-08-01');
CALL ADDPRODUTO('Ração para cães filhote', 60.00, 'kg', 80, '2024-08-02');
CALL ADDPRODUTO('Ração para gatos adulto', 40.00, 'kg', 120, '2024-08-03');
CALL ADDPRODUTO('Areia sanitária para gatos', 20.00, 'kg', 150, '2024-08-04');
CALL ADDPRODUTO('Coleira para cães', 30.00, 'un', 200, '2024-08-05');
CALL ADDPRODUTO('Coleira para gatos', 25.00, 'un', 180, '2024-08-06');
CALL ADDPRODUTO('Brinquedo para cães', 15.00, 'un', 220, '2024-08-07');
CALL ADDPRODUTO('Brinquedo para gatos', 12.00, 'un', 250, '2024-08-08');
CALL ADDPRODUTO('Petisco para cães', 10.00, 'kg', 300, '2024-08-09');
CALL ADDPRODUTO('Petisco para gatos', 8.00, 'kg', 280, '2024-08-10');
CALL ADDPRODUTO('Shampoo para cães', 25.00, 'm', 180, '2024-08-11');
CALL ADDPRODUTO('Shampoo para gatos', 20.00, 'm', 160, '2024-08-12');
CALL ADDPRODUTO('Condicionador para cães', 20.00, 'm', 200, '2024-08-13');
CALL ADDPRODUTO('Condicionador para gatos', 15.00, 'm', 220, '2024-08-14');
CALL ADDPRODUTO('Tapete higiênico para cães', 35.00, 'un', 150, '2024-08-15');
CALL ADDPRODUTO('Tapete higiênico para gatos', 30.00, 'un', 140, '2024-08-16');
CALL ADDPRODUTO('Areia para hamster', 18.00, 'kg', 200, '2024-08-17');
CALL ADDPRODUTO('Ração para pássaros', 12.00, 'kg', 250, '2024-08-18');
CALL ADDPRODUTO('Brinquedo para pássaros', 8.00, 'un', 280, '2024-08-19');
CALL ADDPRODUTO('Gaiola para coelhos', 45.00, 'un', 180, '2024-08-20');
CALL ADDPRODUTO('Gaiola para pássaros', 40.00, 'un', 200, '2024-08-21');
CALL ADDPRODUTO('Vitamina para peixes', 20.00, 'un', 300, '2024-08-22');
CALL ADDPRODUTO('Aquário', 120.00, 'un', 150, '2024-08-23');
CALL ADDPRODUTO('Filtro para aquário', 30.00, 'un', 200, '2024-08-24');
CALL ADDPRODUTO('Ração para tartarugas', 25.00, 'kg', 180, '2024-08-25');
CALL ADDPRODUTO('Cama para cães pequenos', 40.00, 'un', 150, '2024-08-26');
CALL ADDPRODUTO('Cama para cães grandes', 60.00, 'un', 120, '2024-08-27');
CALL ADDPRODUTO('Comedouro para pássaros', 15.00, 'un', 200, '2024-08-28');
CALL ADDPRODUTO('Bebedouro para pássaros', 12.00, 'un', 220, '2024-08-29');
CALL ADDPRODUTO('Escova para cães', 18.00, 'un', 250, '2024-08-30');
CALL ADDPRODUTO('Escova para gatos', 15.00, 'un', 280, '2024-08-31');
CALL ADDPRODUTO('Guia para cães', 30.00, 'un', 180, '2024-09-01');
CALL ADDPRODUTO('Guia para gatos', 25.00, 'un', 200, '2024-09-02');
CALL ADDPRODUTO('Bolsa de transporte para cães', 50.00, 'un', 150, '2024-09-03');
CALL ADDPRODUTO('Bolsa de transporte para gatos', 45.00, 'un', 160, '2024-09-04');
CALL ADDPRODUTO('Coleira antipulgas para cães', 35.00, 'un', 200, '2024-09-05');
CALL ADDPRODUTO('Coleira antipulgas para gatos', 30.00, 'un', 220, '2024-09-06');
CALL ADDPRODUTO('Ração para peixes', 10.00, 'kg', 300, '2024-09-07');
CALL ADDPRODUTO('Alimentador automático para peixes', 40.00, 'un', 180, '2024-09-08');
CALL ADDPRODUTO('Sementes para pássaros', 8.00, 'kg', 250, '2024-09-09');
CALL ADDPRODUTO('Brinquedo para hamster', 12.00, 'un', 280, '2024-09-10');
CALL ADDPRODUTO('Caixa de transporte para cães', 55.00, 'un', 150, '2024-09-11');
CALL ADDPRODUTO('Caixa de transporte para gatos', 50.00, 'un', 160, '2024-09-12');
CALL ADDPRODUTO('Casinha para pássaros', 30.00, 'un', 200, '2024-09-13');
CALL ADDPRODUTO('Casinha para coelhos', 40.00, 'un', 220, '2024-09-14');
CALL ADDPRODUTO('Sisal para gatos', 20.00, 'm', 300, '2024-09-15');
CALL ADDPRODUTO('Comedouro para hamster', 10.00, 'un', 180, '2024-09-16');
CALL ADDPRODUTO('Bebedouro para hamster', 8.00, 'un', 200, '2024-09-17');
CALL ADDPRODUTO('Areia sanitária para gatos', 20.00, 'kg', 250, '2024-09-18');
CALL ADDPRODUTO('Cama para coelhos', 35.00, 'un', 180, '2024-09-19');
CALL ADDPRODUTO('Comedouro para pássaros', 12.00, 'un', 200, '2024-09-20');
CALL ADDPRODUTO('Bebedouro para pássaros', 10.00, 'un', 220, '2024-09-21');
CALL ADDPRODUTO('Brinquedo para cães', 15.00, 'un', 300, '2024-09-22');
CALL ADDPRODUTO('Brinquedo para gatos', 12.00, 'un', 280, '2024-09-23');
CALL ADDPRODUTO('Ração para pássaros', 8.00, 'kg', 200, '2024-09-24');
CALL ADDPRODUTO('Ração para peixes tropicais', 10.00, 'kg', 250, '2024-09-25');
CALL ADDPRODUTO('Ração para peixes de água doce', 12.00, 'kg', 220, '2024-09-26');
CALL ADDPRODUTO('Ração para peixes de água salgada', 15.00, 'kg', 200, '2024-09-27');
CALL ADDPRODUTO('Alimento para hamster', 10.00, 'kg', 280, '2024-09-28');
CALL ADDPRODUTO('Ração para pássaros canários', 8.00, 'kg', 220, '2024-09-29');
CALL ADDPRODUTO('Areia para pássaros', 15.00, 'kg', 200, '2024-09-30');
CALL ADDPRODUTO('Cama para pássaros', 18.00, 'un', 180, '2024-10-01');
CALL ADDPRODUTO('Casinha para hamster', 20.00, 'un', 250, '2024-10-02');
CALL ADDPRODUTO('Bebedouro para coelhos', 12.00, 'un', 220, '2024-10-03');
CALL ADDPRODUTO('Comedouro para coelhos', 10.00, 'un', 200, '2024-10-04');
CALL ADDPRODUTO('Casinha para cães pequenos', 50.00, 'un', 150, '2024-10-05');
CALL ADDPRODUTO('Casinha para cães grandes', 70.00, 'un', 120, '2024-10-06');
CALL ADDPRODUTO('Comedouro para gatos', 18.00, 'un', 180, '2024-10-07');
CALL ADDPRODUTO('Bebedouro para gatos', 15.00, 'un', 200, '2024-10-08');
CALL ADDPRODUTO('Coleira para pássaros', 10.00, 'un', 250, '2024-10-09');
CALL ADDPRODUTO('Coleira para coelhos', 12.00, 'un', 220, '2024-10-10');

CALL ADDPROD2PEDIDO(1, 1, 5);
CALL ADDPROD2PEDIDO(2, 2, 3);
CALL ADDPROD2PEDIDO(3, 3, 2);
CALL ADDPROD2PEDIDO(4, 4, 4);
CALL ADDPROD2PEDIDO(5, 5, 1);
CALL ADDPROD2PEDIDO(6, 6, 2);
CALL ADDPROD2PEDIDO(7, 7, 3);
CALL ADDPROD2PEDIDO(8, 8, 5);
CALL ADDPROD2PEDIDO(9, 9, 4);
CALL ADDPROD2PEDIDO(10, 10, 2);
CALL ADDPROD2PEDIDO(11, 11, 3);
CALL ADDPROD2PEDIDO(12, 12, 1);
CALL ADDPROD2PEDIDO(13, 13, 2);
CALL ADDPROD2PEDIDO(14, 14, 3);
CALL ADDPROD2PEDIDO(15, 15, 4);
CALL ADDPROD2PEDIDO(16, 16, 5);
CALL ADDPROD2PEDIDO(17, 17, 1);
CALL ADDPROD2PEDIDO(18, 18, 2);
CALL ADDPROD2PEDIDO(19, 19, 3);
CALL ADDPROD2PEDIDO(20, 20, 4);
CALL ADDPROD2PEDIDO(21, 21, 5);
CALL ADDPROD2PEDIDO(22, 22, 1);
CALL ADDPROD2PEDIDO(23, 23, 2);
CALL ADDPROD2PEDIDO(24, 24, 3);
CALL ADDPROD2PEDIDO(25, 25, 4);
CALL ADDPROD2PEDIDO(26, 26, 5);
CALL ADDPROD2PEDIDO(27, 27, 3);
CALL ADDPROD2PEDIDO(28, 28, 2);
CALL ADDPROD2PEDIDO(29, 29, 4);
CALL ADDPROD2PEDIDO(30, 30, 1);
CALL ADDPROD2PEDIDO(31, 31, 2);
CALL ADDPROD2PEDIDO(32, 32, 3);
CALL ADDPROD2PEDIDO(33, 33, 5);
CALL ADDPROD2PEDIDO(34, 34, 4);
CALL ADDPROD2PEDIDO(35, 35, 2);
CALL ADDPROD2PEDIDO(36, 36, 3);
CALL ADDPROD2PEDIDO(37, 37, 1);
CALL ADDPROD2PEDIDO(38, 38, 2);
CALL ADDPROD2PEDIDO(39, 39, 3);
CALL ADDPROD2PEDIDO(40, 40, 4);
CALL ADDPROD2PEDIDO(41, 41, 5);
CALL ADDPROD2PEDIDO(42, 42, 1);
CALL ADDPROD2PEDIDO(43, 43, 2);
CALL ADDPROD2PEDIDO(44, 44, 3);
CALL ADDPROD2PEDIDO(45, 45, 4);
CALL ADDPROD2PEDIDO(46, 46, 5);
CALL ADDPROD2PEDIDO(47, 47, 1);
CALL ADDPROD2PEDIDO(48, 48, 2);
CALL ADDPROD2PEDIDO(1, 49, 3);
CALL ADDPROD2PEDIDO(2, 50, 4);
CALL ADDPROD2PEDIDO(3, 51, 2);
CALL ADDPROD2PEDIDO(4, 52, 3);
CALL ADDPROD2PEDIDO(5, 53, 5);
CALL ADDPROD2PEDIDO(6, 54, 1);
CALL ADDPROD2PEDIDO(7, 55, 2);
CALL ADDPROD2PEDIDO(8, 56, 3);
CALL ADDPROD2PEDIDO(9, 57, 4);
CALL ADDPROD2PEDIDO(10, 58, 5);
CALL ADDPROD2PEDIDO(11, 59, 1);
CALL ADDPROD2PEDIDO(12, 60, 2);
CALL ADDPROD2PEDIDO(13, 61, 3);
CALL ADDPROD2PEDIDO(14, 62, 4);
CALL ADDPROD2PEDIDO(15, 63, 5);
CALL ADDPROD2PEDIDO(16, 64, 1);
CALL ADDPROD2PEDIDO(17, 65, 2);
CALL ADDPROD2PEDIDO(18, 48, 3);
CALL ADDPROD2PEDIDO(19, 49, 4);
CALL ADDPROD2PEDIDO(20, 50, 5);
CALL ADDPROD2PEDIDO(21, 51, 1);
CALL ADDPROD2PEDIDO(22, 52, 2);
CALL ADDPROD2PEDIDO(23, 53, 3);
CALL ADDPROD2PEDIDO(24, 54, 4);
CALL ADDPROD2PEDIDO(25, 55, 5);
CALL ADDPROD2PEDIDO(26, 56, 1);
CALL ADDPROD2PEDIDO(27, 57, 2);
CALL ADDPROD2PEDIDO(28, 58, 3);
CALL ADDPROD2PEDIDO(29, 59, 4);
CALL ADDPROD2PEDIDO(30, 60, 5);
CALL ADDPROD2PEDIDO(31, 61, 1);
CALL ADDPROD2PEDIDO(32, 62, 2);
CALL ADDPROD2PEDIDO(33, 63, 3);
CALL ADDPROD2PEDIDO(34, 64, 4);
CALL ADDPROD2PEDIDO(35, 65, 5);
CALL ADDPROD2PEDIDO(36, 48, 1);
CALL ADDPROD2PEDIDO(37, 49, 2);
CALL ADDPROD2PEDIDO(38, 50, 3);
CALL ADDPROD2PEDIDO(39, 51, 4);
CALL ADDPROD2PEDIDO(40, 52, 5);
CALL ADDPROD2PEDIDO(41, 53, 1);
CALL ADDPROD2PEDIDO(42, 54, 2);
CALL ADDPROD2PEDIDO(43, 55, 3);
CALL ADDPROD2PEDIDO(44, 56, 4);
CALL ADDPROD2PEDIDO(45, 57, 5);
CALL ADDPROD2PEDIDO(46, 58, 1);
CALL ADDPROD2PEDIDO(47, 59, 2);
CALL ADDPROD2PEDIDO(48, 60, 3);

CALL MKBANHO('2024-07-01 10:00:00', 'Buddy', '12345678901', 104, 50.00);
CALL MKBANHO('2024-07-02 11:30:00', 'Rex', '12345678901', 109, 45.00);
CALL MKBANHO('2024-07-03 09:45:00', 'Max', '12345678902', 114, 55.00);
CALL MKBANHO('2024-07-04 14:00:00', 'Bella', '12345678902', 119, 60.00);
CALL MKBANHO('2024-07-05 13:15:00', 'Bella', '12345678903', 124, 65.00);
CALL MKBANHO('2024-07-06 12:30:00', 'Luna', '12345678903', 129, 70.00);
CALL MKBANHO('2024-07-07 10:45:00', 'Lucy', '12345678904', 134, 75.00);
CALL MKBANHO('2024-07-08 10:00:00', 'Charlie', '12345678904', 104, 80.00);
CALL MKBANHO('2024-07-09 11:30:00', 'Charlie', '12345678905', 109, 85.00);
CALL MKBANHO('2024-07-10 09:45:00', 'Molly', '12345678905', 114, 90.00);
CALL MKBANHO('2024-07-11 14:00:00', 'Molly', '12345678906', 119, 95.00);
CALL MKBANHO('2024-07-12 13:15:00', 'Buddy', '12345678906', 124, 100.00);
CALL MKBANHO('2024-07-13 12:30:00', 'Daisy', '12345678907', 129, 105.00);
CALL MKBANHO('2024-07-14 10:45:00', 'Max', '12345678907', 134, 110.00);
CALL MKBANHO('2024-07-15 10:00:00', 'Bailey', '12345678908', 104, 115.00);
CALL MKBANHO('2024-07-16 11:30:00', 'Rocky', '12345678908', 109, 120.00);
CALL MKBANHO('2024-07-17 09:45:00', 'Sadie', '12345678909', 114, 125.00);
CALL MKBANHO('2024-07-18 14:00:00', 'Jack', '12345678909', 119, 130.00);
CALL MKBANHO('2024-07-19 13:15:00', 'Rocky', '12345678910', 124, 135.00);
CALL MKBANHO('2024-07-20 12:30:00', 'Oscar', '12345678910', 129, 140.00);
CALL MKBANHO('2024-07-21 10:45:00', 'Duke', '22345678901', 134, 145.00);
CALL MKBANHO('2024-07-22 10:00:00', 'Sam', '22345678901', 104, 150.00);
CALL MKBANHO('2024-07-23 11:30:00', 'Roxy', '22345678902', 109, 155.00);
CALL MKBANHO('2024-07-24 09:45:00', 'Toby', '22345678902', 114, 160.00);
CALL MKBANHO('2024-07-25 14:00:00', 'Jack', '22345678903', 119, 165.00);
CALL MKBANHO('2024-07-26 13:15:00', 'Coco', '22345678903', 124, 170.00);
CALL MKBANHO('2024-07-27 12:30:00', 'Zoey', '22345678904', 129, 175.00);
CALL MKBANHO('2024-07-28 10:45:00', 'Sasha', '22345678904', 134, 180.00);
CALL MKBANHO('2024-07-29 10:00:00', 'Chloe', '22345678905', 104, 185.00);
CALL MKBANHO('2024-07-30 11:30:00', 'Gizmo', '22345678905', 109, 190.00);
CALL MKBANHO('2024-07-31 09:45:00', 'Cooper', '22345678906', 114, 195.00);
CALL MKBANHO('2024-08-01 14:00:00', 'Sophie', '22345678907', 119, 200.00);
CALL MKBANHO('2024-08-02 13:15:00', 'Tucker', '22345678908', 124, 205.00);
CALL MKBANHO('2024-08-03 12:30:00', 'Riley', '22345678909', 129, 210.00);
CALL MKBANHO('2024-08-04 10:45:00', 'Harley', '22345678910', 134, 215.00);
CALL MKBANHO('2024-08-05 10:00:00', 'Buster', '32345678901', 104, 220.00);
CALL MKBANHO('2024-08-06 11:30:00', 'Ziggy', '32345678902', 109, 225.00);
CALL MKBANHO('2024-08-07 09:45:00', 'Ollie', '32345678903', 114, 230.00);
CALL MKBANHO('2024-08-08 14:00:00', 'Lola', '32345678904', 119, 235.00);
CALL MKBANHO('2024-08-09 13:15:00', 'Murphy', '32345678905', 124, 240.00);
CALL MKBANHO('2024-08-10 12:30:00', 'Finn', '42345678901', 129, 245.00);
CALL MKBANHO('2024-08-11 10:45:00', 'Luna', '42345678902', 134, 250.00);
CALL MKBANHO('2024-08-12 10:00:00', 'Simba', '42345678903', 104, 255.00);
CALL MKBANHO('2024-08-13 11:30:00', 'Milo', '42345678904', 109, 260.00);
CALL MKBANHO('2024-08-14 09:45:00', 'Nala', '42345678905', 114, 265.00);
CALL MKBANHO('2024-08-15 14:00:00', 'Coco', '42345678906', 119, 270.00);
CALL MKBANHO('2024-08-16 13:15:00', 'Shadow', '42345678907', 124, 275.00);

CALL ADDVETERINARIO(123456, 'Wesley Safadão', '2023-05-15', 7500.00);
CALL ADDVETERINARIO(234567, 'Solange Almeida', '2023-06-20', 6800.00);
CALL ADDVETERINARIO(345678, 'Xand Avião', '2023-07-25', 7100.00);
CALL ADDVETERINARIO(456789, 'Simone Mendes', '2023-08-30', 7200.00);
CALL ADDVETERINARIO(567890, 'Dorgival Dantas', '2023-09-05', 7300.00);
CALL ADDVETERINARIO(678901, 'Márcia Fellipe', '2023-10-10', 7400.00);
CALL ADDVETERINARIO(789012, 'Avine Vinny', '2023-11-15', 7600.00);
CALL ADDVETERINARIO(890123, 'Fagner Paz', '2023-12-20', 7700.00);
CALL ADDVETERINARIO(901234, 'Alcymar Monteiro', '2024-01-25', 7800.00);
CALL ADDVETERINARIO(102345, 'Ranniery Gomes', '2024-02-29', 7900.00);

CALL MKCONSULTA(102345, 'Buddy', '12345678901', '2024-07-01 08:00:00', 100.00);
CALL MKCONSULTA(123456, 'Rex', '12345678901', '2024-07-02 09:00:00', 120.00);
CALL MKCONSULTA(234567, 'Max', '12345678902', '2024-07-03 10:00:00', 150.00);
CALL MKCONSULTA(345678, 'Bella', '12345678902', '2024-07-04 11:00:00', 80.00);
CALL MKCONSULTA(456789, 'Bella', '12345678903', '2024-07-05 12:00:00', 90.00);
CALL MKCONSULTA(567890, 'Luna', '12345678903', '2024-07-06 13:00:00', 110.00);
CALL MKCONSULTA(678901, 'Lucy', '12345678904', '2024-07-07 14:00:00', 70.00);
CALL MKCONSULTA(789012, 'Charlie', '12345678904', '2024-07-08 15:00:00', 130.00);
CALL MKCONSULTA(890123, 'Charlie', '12345678905', '2024-07-09 16:00:00', 100.00);
CALL MKCONSULTA(901234, 'Molly', '12345678905', '2024-07-10 17:00:00', 140.00);
CALL MKCONSULTA(102345, 'Molly', '12345678906', '2024-07-11 18:00:00', 160.00);
CALL MKCONSULTA(123456, 'Buddy', '12345678906', '2024-07-12 19:00:00', 90.00);
CALL MKCONSULTA(234567, 'Daisy', '12345678907', '2024-07-13 20:00:00', 120.00);
CALL MKCONSULTA(345678, 'Max', '12345678907', '2024-07-14 08:00:00', 100.00);
CALL MKCONSULTA(456789, 'Bailey', '12345678908', '2024-07-15 09:00:00', 110.00);
CALL MKCONSULTA(567890, 'Rocky', '12345678908', '2024-07-16 10:00:00', 130.00);
CALL MKCONSULTA(678901, 'Sadie', '12345678909', '2024-07-17 11:00:00', 80.00);
CALL MKCONSULTA(789012, 'Jack', '12345678909', '2024-07-18 12:00:00', 90.00);
CALL MKCONSULTA(890123, 'Rocky', '12345678910', '2024-07-19 13:00:00', 100.00);
CALL MKCONSULTA(901234, 'Oscar', '12345678910', '2024-07-20 14:00:00', 120.00);
CALL MKCONSULTA(102345, 'Duke', '22345678901', '2024-07-21 15:00:00', 150.00);
CALL MKCONSULTA(123456, 'Sam', '22345678901', '2024-07-22 16:00:00', 130.00);
CALL MKCONSULTA(234567, 'Roxy', '22345678902', '2024-07-23 17:00:00', 100.00);
CALL MKCONSULTA(345678, 'Toby', '22345678902', '2024-07-24 18:00:00', 110.00);
CALL MKCONSULTA(456789, 'Jack', '22345678903', '2024-07-25 08:00:00', 120.00);
CALL MKCONSULTA(567890, 'Coco', '22345678903', '2024-07-26 09:00:00', 90.00);
CALL MKCONSULTA(678901, 'Zoey', '22345678904', '2024-07-27 10:00:00', 110.00);
CALL MKCONSULTA(789012, 'Sasha', '22345678904', '2024-07-28 11:00:00', 100.00);
CALL MKCONSULTA(890123, 'Chloe', '22345678905', '2024-07-29 12:00:00', 130.00);
CALL MKCONSULTA(901234, 'Gizmo', '22345678905', '2024-07-30 13:00:00', 120.00);
CALL MKCONSULTA(102345, 'Cooper', '22345678906', '2024-07-31 14:00:00', 140.00);
CALL MKCONSULTA(123456, 'Sophie', '22345678907', '2024-08-01 15:00:00', 110.00);
CALL MKCONSULTA(234567, 'Tucker', '22345678908', '2024-08-02 16:00:00', 100.00);
CALL MKCONSULTA(345678, 'Riley', '22345678909', '2024-08-03 17:00:00', 120.00);
CALL MKCONSULTA(456789, 'Harley', '22345678910', '2024-08-04 18:00:00', 130.00);
CALL MKCONSULTA(567890, 'Buster', '32345678901', '2024-08-05 19:00:00', 140.00);
CALL MKCONSULTA(678901, 'Ziggy', '32345678902', '2024-08-06 20:00:00', 110.00);
CALL MKCONSULTA(789012, 'Ollie', '32345678903', '2024-08-07 08:00:00', 120.00);
CALL MKCONSULTA(890123, 'Lola', '32345678904', '2024-08-08 09:00:00', 100.00);
CALL MKCONSULTA(901234, 'Murphy', '32345678905', '2024-08-09 10:00:00', 110.00);
CALL MKCONSULTA(102345, 'Finn', '42345678901', '2024-08-10 11:00:00', 130.00);
CALL MKCONSULTA(123456, 'Luna', '42345678902', '2024-08-11 12:00:00', 90.00);
CALL MKCONSULTA(234567, 'Simba', '42345678903', '2024-08-12 13:00:00', 100.00);
CALL MKCONSULTA(345678, 'Milo', '42345678904', '2024-08-13 14:00:00', 120.00);
CALL MKCONSULTA(456789, 'Nala', '42345678905', '2024-08-14 15:00:00', 110.00);
CALL MKCONSULTA(567890, 'Coco', '42345678906', '2024-08-15 16:00:00', 100.00);
CALL MKCONSULTA(678901, 'Shadow', '42345678907', '2024-08-16 17:00:00', 120.00);
CALL MKCONSULTA(789012, 'Loki', '42345678908', '2024-08-17 18:00:00', 130.00);

CALL ADDVACINA('Vanguard Plus 5/CV-L', 1234, 100, '2027-06-01');
CALL ADDVACINA('Rabies Vaccine', 5678, 120, '2027-12-01');
CALL ADDVACINA('Canine Spectra 10', 9876, 80, '2027-11-01');
CALL ADDVACINA('Bordetella bronchiseptica', 5432, 90, '2027-10-01');
CALL ADDVACINA('Fel-O-Vax Lv-K IV + Calicivax', 7890, 110, '2027-09-01');
CALL ADDVACINA('Leptospira bacterin', 4321, 70, '2027-08-01');
CALL ADDVACINA('Duramune Max PC', 8765, 100, '2027-07-01');
CALL ADDVACINA('Feline Focus 5', 2109, 120, '2027-06-01');
CALL ADDVACINA('Distemper + Parvo + Lepto + Adenovirus Type 2 + Parainfluenza + Coronavirus', 6543, 80, '2027-05-01');
CALL ADDVACINA('Nobivac Puppy DP', 3210, 90, '2027-04-01');
CALL ADDVACINA('Vanguard HTLP 5/CV', 4567, 110, '2027-03-01');
CALL ADDVACINA('Canine Influenza Vaccine H3N2-H3N8', 8901, 70, '2027-02-01');
CALL ADDVACINA('Feline Leukemia Vaccine', 1357, 100, '2027-01-01');
CALL ADDVACINA('Nobivac Feline 1-HCPCh', 2468, 120, '2026-12-01');
CALL ADDVACINA('Rabies Vaccine', 9753, 80, '2026-11-01');
CALL ADDVACINA('Lyme Vaccine', 6543, 90, '2026-10-01');
CALL ADDVACINA('Nobivac Canine Flu Bivalent', 3214, 110, '2026-09-01');
CALL ADDVACINA('Rabies Vaccine', 8754, 70, '2026-08-01');
CALL ADDVACINA('Canine Distemper + Adenovirus Type 2 + Parainfluenza + Parvovirus Vaccine', 9876, 100, '2026-07-01');
CALL ADDVACINA('Nobivac Intra-Trac 3', 5432, 120, '2026-06-01');
CALL ADDVACINA('Canine Spectra 10', 2143, 80, '2026-05-01');
CALL ADDVACINA('Nobivac Puppy DP', 6789, 90, '2026-04-01');
CALL ADDVACINA('Canine Distemper + Adenovirus Type 2 + Parainfluenza + Parvovirus Vaccine', 1010, 110, '2026-03-01');
CALL ADDVACINA('Feline Rhinotracheitis-Calici-Panleukopenia Vaccine', 2020, 70, '2026-02-01');

CALL MKVACINACAO('Buddy', '12345678901', 102345, 'Vanguard Plus 5/CV-L', 1234, '2025-06-01');
CALL MKVACINACAO('Rex', '12345678901', 123456, 'Rabies Vaccine', 5678, '2025-12-01');
CALL MKVACINACAO('Max', '12345678902', 234567, 'Canine Spectra 10', 9876, '2025-11-01');
CALL MKVACINACAO('Bella', '12345678902', 345678, 'Bordetella bronchiseptica', 5432, '2025-10-01');
CALL MKVACINACAO('Bella', '12345678903', 456789, 'Fel-O-Vax Lv-K IV + Calicivax', 7890, '2025-09-01');
CALL MKVACINACAO('Luna', '12345678903', 567890, 'Leptospira bacterin', 4321, '2025-08-01');
CALL MKVACINACAO('Lucy', '12345678904', 678901, 'Duramune Max PC', 8765, '2025-07-01');
CALL MKVACINACAO('Charlie', '12345678904', 789012, 'Feline Focus 5', 2109, '2025-06-01');
CALL MKVACINACAO('Charlie', '12345678905', 890123, 'Distemper + Parvo + Lepto + Adenovirus Type 2 + Parainfluenza + Coronavirus', 6543, '2025-05-01');
CALL MKVACINACAO('Molly', '12345678905', 901234, 'Nobivac Puppy DP', 3210, '2025-04-01');
CALL MKVACINACAO('Molly', '12345678906', 102345, 'Vanguard HTLP 5/CV', 4567, '2025-03-01');
CALL MKVACINACAO('Buddy', '12345678906', 123456, 'Canine Influenza Vaccine H3N2-H3N8', 8901, '2025-02-01');
CALL MKVACINACAO('Daisy', '12345678907', 234567, 'Feline Leukemia Vaccine', 1357, '2025-01-01');
CALL MKVACINACAO('Max', '12345678907', 345678, 'Feline Rhinotracheitis-Calici-Panleukopenia Vaccine', 2020, '2025-12-01');
CALL MKVACINACAO('Bailey', '12345678908', 456789, 'Leptospira bacterin', 4321, '2025-11-01');
CALL MKVACINACAO('Rocky', '12345678908', 567890, 'Lyme Vaccine', 6543, '2025-10-01');
CALL MKVACINACAO('Sadie', '12345678909', 678901, 'Nobivac Canine Flu Bivalent', 3214, '2025-09-01');
CALL MKVACINACAO('Jack', '12345678909', 789012, 'Rabies Vaccine', 8754, '2025-08-01');
CALL MKVACINACAO('Rocky', '12345678910', 890123, 'Rabies Vaccine', 9753, '2025-07-01');
CALL MKVACINACAO('Oscar', '12345678910', 901234, 'Nobivac Intra-Trac 3', 5432, '2025-06-01');
CALL MKVACINACAO('Duke', '22345678901', 102345, 'Canine Spectra 10', 2143, '2025-05-01');
CALL MKVACINACAO('Sam', '22345678901', 123456, 'Nobivac Puppy DP', 6789, '2025-04-01');
CALL MKVACINACAO('Roxy', '22345678902', 234567, 'Canine Distemper + Adenovirus Type 2 + Parainfluenza + Parvovirus Vaccine', 1010, '2025-03-01');
CALL MKVACINACAO('Toby', '22345678902', 345678, 'Canine Distemper + Adenovirus Type 2 + Parainfluenza + Parvovirus Vaccine', 9876, '2025-02-01');
CALL MKVACINACAO('Jack', '22345678903', 456789, 'Canine Influenza Vaccine H3N2-H3N8', 8901, '2025-01-01');

-- Seleciona o nome do pet que não tomou nenhuma vacina, e o nome do dono
SELECT P.nome, C.nome AS Pet FROM Pet P 
JOIN 
	Cliente C ON P.dono_id = C.id 
WHERE P.id NOT IN (
	SELECT Va.pet_id FROM Vacinacao Va
);

-- Seleciona o nome do pet que tem uma reserva, uma vacinação e um banho registrados, e o nome do dono
SELECT P.nome, C.nome FROM Pet P 
JOIN Cliente C ON C.id = P.dono_id
WHERE P.id IN (
	SELECT R.pet_id FROM Reserva R
) AND P.id IN (
	SELECT V.pet_id FROM Vacinacao V
) AND P.id IN (
	SELECT B.pet_id FROM Banho B
);

-- Seleciona a média dos totais dos pedidos
SELECT CONCAT("R$", AVG(Total)) AS `Média de totais dos produtos` FROM VPedidos;

SELECT AVG(`Total gasto`) AS `Média de totais dos pedidos` FROM (
		SELECT SUM(PP2.quantidade * P2.valor) as `Total gasto` FROM Cliente C2
        JOIN Pedido Pe2 ON Pe2.cliente_id = C2.id
        JOIN ProdutosPedido PP2 ON PP2.num_pedido = Pe2.numero
        JOIN Produto P2 ON P2.cod = PP2.cod_produto
        GROUP BY C2.nome
    ) as `Média de gastos`;
		
-- Seleciona o nome do cliente e o total gasto por ele, caso o total gasto tenha sido acima da média.
SELECT Cliente, Total AS `Total gasto` FROM (
	SELECT Cliente, Total FROM VPedidos
) AS `Total gasto por cliente` WHERE Total > (
	SELECT AVG(Total) FROM VPedidos
);

SELECT Cliente, `Total gasto` AS `Total gasto` FROM (
	SELECT C.nome as Cliente, SUM(PP.quantidade * P.valor) as `Total gasto` FROM Cliente C
    JOIN Pedido Pe ON Pe.cliente_id = C.id
    JOIN ProdutosPedido PP ON Pe.numero = PP.num_pedido
    JOIN Produto P ON P.cod = PP.cod_produto
    GROUP BY C.nome
) as `Total gasto por cliente` WHERE `Total gasto` > (
	SELECT AVG(`Total gasto`) FROM (
		SELECT SUM(PP2.quantidade * P2.valor) as `Total gasto` FROM Cliente C2
        JOIN Pedido Pe2 ON Pe2.cliente_id = C2.id
        JOIN ProdutosPedido PP2 ON PP2.num_pedido = Pe2.numero
        JOIN Produto P2 ON P2.cod = PP2.cod_produto
        GROUP BY C2.nome
    ) as `Média de gastos`
);

-- Seleciona a média de salários dos funcionários que tiveram mais de 5 reservas
SELECT AVG(F.salario) AS `Média de salários`
FROM Funcionario F
WHERE F.funcao = 'cuidador'
AND F.id IN (
    SELECT R.funcionario_id FROM Reserva R
    GROUP BY R.funcionario_id HAVING COUNT(R.entrada) > 5
);

-- Seleciona a descrição do produto, a quantidade em estoque e a data de validade de produtos que vencerão nos próximos 2 meses.
SELECT P.descricao, E.quantidade, E.validade FROM Produto P
JOIN Estoque E ON E.cod_produto = P.cod
WHERE E.validade BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 MONTH);