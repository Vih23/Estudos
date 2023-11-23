--IDEIA E ESCOPO DO PROJETO

--Banco de dados de biblioteca que permite consultar detalhes dos livros, efetuar empréstimos


--CONSTRAINTS 

-- Livros já emprestados não podem ser emprestados;
-- Livros +18 não podem ser emprestados para menores (boolean);
-- Livros que não foram emprestados em até 90 dias serão excluídos (trigger);






CREATE TABLE Autores (
ID_Autor SERIAL PRIMARY KEY,
Nome VARCHAR(100),
Nacionalidade VARCHAR(100)	
);


CREATE TABLE Livros (
ID_Livro SERIAL PRIMARY KEY,
Titulo VARCHAR(100),
Ano_Publicacao INTEGER,
Genero VARCHAR(30),
Etario VARCHAR(30),
ID_Autor INT REFERENCES Autores(ID_Autor)
);


CREATE TABLE Exemplares (
ID_Exemplar SERIAL PRIMARY KEY,
ID_Livro INT REFERENCES Livros(ID_Livro),
Status ENUM('Disponível', 'Emprestado', 'Manutenção')
);


CREATE TABLE Membros (
    ID_Membro SERIAL PRIMARY KEY,
    Nome VARCHAR(100),
    Idade INTEGER,
    PRIMARY KEY (ID_Membro)
);


CREATE TABLE Emprestimos (
ID_Emprestimo SERIAL PRIMARY KEY,
ID_Exemplar INT REFERENCES Exemplares(ID_Exemplar),
ID_Membro INT REFERENCES Membros(ID_Membro),
Data_Emprestimo DATE,
Data_Devolucao DATE,
Status ENUM('Ativo', 'Devolvido'),

CONSTRAINT chk_livro_nao_emprestar_novamente CHECK (
	NOT EXISTS (
	   SELECT 1
	   FROM Emprestimos e2
	   WHERE e2.ID_Exemplar = Emprestimos.ID_Exemplar
	     AND e2.Status = 'Ativo'
	     AND e2.ID_Emprestimo != Emprestimo.ID_Emprestimo
       )
),

CONSTRAINT chk_livros_etario CHECK(
	NOT EXISTS (
	SELECT 1
	FROM Livros
	WHERE Livros.ID_Livro = Emprestimos.ID_Livro
	   AND Livros.Etario = 'Adulto'
) OR (
     EXISTS (
	SELECT 1
	FROM Membros
	WHERE Membros.ID_Membro = Emprestimo.ID_Membro
	   AND Membros.Idade >= 18
     )	
   )
 )
);


CREATE OR REPLACE FUNCTION ExcluirLivrosNaoEmprestados()
RETURNS VOID AS $$
BEGIN
    DELETE FROM Biblioteca
    WHERE Status = 'Devolvido' AND Data_Devolucao <= CURRENT_DATE - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;




INSERT INTO Autores (Nome, Nacionalidade) 
VALUES 
('Jane Austen', 'Inglês'),
('Lewis Carrell', 'Inglês'),
('Antonie de Saint-Exupéry', 'Francês'),
('Paulo Coelho', 'Brasileiro'),
('José Saramago', 'Brasileiro'),
('Chuck Palahniuk', 'Norte-Americano'),
('Stephen Chbosky', 'Norte-Americano'),
('Erika Leonard James', 'Norte-Americano'),
('Gillian Flynn', 'Norte-Americano'),
('Carla Madeira', 'Brasileiro'),
('Edmundo Barreiros', 'Brasileiro');


INSERT INTO Livros (Titulo, Ano_Publicacao, Etario, ID_Autor)
VALUES 
('Orgulho e Preconceito', 1813, 'Juvenil', 1234),
('Persuasão', 1817, 'Juvenil', 1324),
('Alice no País das Maravilhas', 1865, 'Infantil', 1423),
('O Pequeno Príncipe', 1943, 'Infantil', 2134),
('Diário de um Mago', 1987, 'Juvenil', 2341),
('O Alquimista', 1988, 'Juvenil', 2031),
('Brida', 1990, 'Juvenil', 3124),
('Ensaio Sobre a Cegueira', 1995, 'Juvenil', 3241),
('Clube da Luta', 1996, 'Juvenil', 3412),
('As Vantagens de Ser Invisível', 1999, 4321),
('Cinquenta Tons de Cinza', 2011, 'Adulto', 4230),
('Garota Exemplar', 2012, 'Adulto', 4301),
('Tudo é Rio', 2014, 'Adulto', 1432),
('A Principe Cativo', 2023, 'Adulto', 2432);


INSERT INTO Exemplares (ID_Livro, Status)
VALUES 
(1, 'Disponível'),
(2, 'Disponível'),
(3, 'Disponível'),
(4, 'Disponível'),
(5, 'Disponível'),
(6, 'Disponível'),
(7, 'Disponível'),
(8, 'Disponível'),
(9, 'Disponível'),
(10, 'Disponível'),
(11, 'Disponível'),
(12, 'Disponível'),
(13, 'Disponível'),
(14, 'Disponível');


INSERT INTO Membros (Nome, Idade)
VALUES 
('João', 21),
('Maria', 55);


INSERT INTO Emprestimos (ID_Exemplar, ID_Membro, Data_Emprestimo, Data_Devolucao, Status)
VALUES 
(10, 3, '2021-03-06', 'Devolvido'),
(1, 5, '2022-10-30', 'Devolvido');





