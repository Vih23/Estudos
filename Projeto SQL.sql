CREATE TABLE Autores (
    ID_Autor SERIAL PRIMARY KEY,
    Nome VARCHAR(100),
    Nacionalidade VARCHAR(100)
);

CREATE TABLE Livros (
    ID_Livro SERIAL PRIMARY KEY,
    Titulo VARCHAR(200),
    Ano_Publicacao INTEGER,
    Etario ENUM('Infantil', 'Juvenil', 'Adulto'),
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
    CONSTRAINT chk_livro_nao_emprestado_novamente CHECK (
        NOT EXISTS (
            SELECT 1
            FROM Emprestimos e2
            WHERE e2.ID_Exemplar = Emprestimos.ID_Exemplar
              AND e2.Status = 'Ativo'
              AND e2.ID_Emprestimo != Emprestimos.ID_Emprestimo
        )
    ),
    CONSTRAINT chk_livro_etario CHECK (
        NOT EXISTS (
            SELECT 1
            FROM Livros
            WHERE Livros.ID_Livro = Emprestimos.ID_Livro
              AND Livros.Etario = 'Adulto'
        ) OR (
            EXISTS (
                SELECT 1
                FROM Membros
                WHERE Membros.ID_Membro = Emprestimos.ID_Membro
                  AND Membros.Idade >= 18
            )
        )
    )
);
