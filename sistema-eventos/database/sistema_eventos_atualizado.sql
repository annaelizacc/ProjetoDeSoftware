-- =====================================================================
-- BANCO DE DADOS: Sistema de Gerenciamento de Eventos
-- Gerado a partir do Diagrama Entidade-Relacionamento (Chen)
-- Compatível com MySQL / MariaDB
-- =====================================================================

DROP DATABASE IF EXISTS sistema_eventos;
CREATE DATABASE sistema_eventos
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sistema_eventos;

-- =====================================================================
-- 1. TABELA: usuario
-- Entidade base do sistema. Todo participante, palestrante ou
-- organizador é primeiro um usuário cadastrado.
-- =====================================================================
CREATE TABLE usuario (
    id_usuario      INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(150)    NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    senha           VARCHAR(255)    NOT NULL,
    tipo_usuario    VARCHAR(50)     NOT NULL
) ENGINE=InnoDB;

-- =====================================================================
-- 2. TABELA: evento
-- Entidade central que representa cada evento cadastrado.
-- =====================================================================
CREATE TABLE evento (
    id_evento       INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(150)    NOT NULL,
    descricao       TEXT,
    data_inicio     DATE            NOT NULL,
    data_fim        DATE            NOT NULL,
    local           VARCHAR(200)
) ENGINE=InnoDB;

-- =====================================================================
-- 3. TABELA: restaurante
-- Restaurantes que podem estar associados a um ou mais eventos.
-- =====================================================================
CREATE TABLE restaurante (
    id_restaurante  INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(150)    NOT NULL,
    avaliacao       DECIMAL(2,1),
    distancia       DECIMAL(6,2),
    categoria       VARCHAR(80),
    endereco        VARCHAR(200)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. TABELA: palestra
-- Palestras pertencem a um evento (relacionamento "pertence").
-- =====================================================================
CREATE TABLE palestra (
    id_palestra     INT AUTO_INCREMENT PRIMARY KEY,
    titulo          VARCHAR(200)    NOT NULL,
    resumo          TEXT,
    tema            VARCHAR(120),
    sala            VARCHAR(60),
    horario_inicio  DATETIME,
    horario_fim     DATETIME,
    id_evento       INT             NOT NULL,
    CONSTRAINT fk_palestra_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- Extensão mínima para a regra de inscrição com controle automático de vagas.
-- Os valores existentes continuam válidos; a atualização abaixo recalcula o
-- saldo considerando as participações que já estão no banco.
ALTER TABLE palestra
    ADD COLUMN vagas_total INT NOT NULL DEFAULT 50,
    ADD COLUMN vagas_disponiveis INT NOT NULL DEFAULT 50;

-- =====================================================================
-- 5. TABELA: organizador
-- Especialização de usuario (todo organizador é um usuário).
-- =====================================================================
CREATE TABLE organizador (
    id_organizador  INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT             NOT NULL UNIQUE,
    nivel_acesso    VARCHAR(50)     NOT NULL,
    CONSTRAINT fk_organizador_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 6. TABELA: participacao
-- Entidade associativa (relacionamento "participa") entre
-- usuario e palestra, com cardinalidade N:N.
-- =====================================================================
CREATE TABLE participacao (
    id_participacao INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT             NOT NULL,
    id_palestra     INT             NOT NULL,
    CONSTRAINT fk_participacao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_participacao_palestra
        FOREIGN KEY (id_palestra) REFERENCES palestra(id_palestra)
        ON DELETE CASCADE,
    UNIQUE KEY uk_participacao (id_usuario, id_palestra)
) ENGINE=InnoDB;

-- =====================================================================
-- 7. TABELA: comentario
-- Comentários que um usuário faz sobre uma palestra.
-- =====================================================================
CREATE TABLE comentario (
    id_comentario   INT AUTO_INCREMENT PRIMARY KEY,
    texto           TEXT            NOT NULL,
    nota            DECIMAL(3,1),
    data            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario      INT             NOT NULL,
    id_palestra     INT             NOT NULL,
    CONSTRAINT fk_comentario_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_comentario_palestra
        FOREIGN KEY (id_palestra) REFERENCES palestra(id_palestra)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 8. TABELA: notificacao
-- Notificações recebidas ("recebe") por um usuário, referentes
-- a uma palestra específica.
-- =====================================================================
CREATE TABLE notificacao (
    id_notificacao  INT AUTO_INCREMENT PRIMARY KEY,
    mensagem        TEXT            NOT NULL,
    data_envio      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_notificacao VARCHAR(50),
    id_usuario      INT             NOT NULL,
    id_palestra     INT             NOT NULL,
    CONSTRAINT fk_notificacao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_notificacao_palestra
        FOREIGN KEY (id_palestra) REFERENCES palestra(id_palestra)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 9. TABELA: planta_baixa
-- Mapa/planta baixa que pertence a um evento.
-- =====================================================================
CREATE TABLE planta_baixa (
    id_planta       INT AUTO_INCREMENT PRIMARY KEY,
    imagem_mapa     VARCHAR(255),
    descricao       TEXT,
    id_evento       INT             NOT NULL,
    CONSTRAINT fk_planta_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 10. TABELA: localizacao
-- Locais que pertencem a um evento.
-- =====================================================================
CREATE TABLE localizacao (
    id_localizacao  INT AUTO_INCREMENT PRIMARY KEY,
    nome_local      VARCHAR(150)    NOT NULL,
    descricao       TEXT,
    id_evento       INT             NOT NULL,
    CONSTRAINT fk_localizacao_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 11. TABELA: restaurante_evento
-- Tabela de junção para o relacionamento N:N "associado"
-- entre restaurante e evento (cardinalidade (0,n)-(0,n) no diagrama).
-- =====================================================================
CREATE TABLE restaurante_evento (
    id_restaurante  INT NOT NULL,
    id_evento       INT NOT NULL,
    PRIMARY KEY (id_restaurante, id_evento),
    CONSTRAINT fk_assoc_restaurante
        FOREIGN KEY (id_restaurante) REFERENCES restaurante(id_restaurante)
        ON DELETE CASCADE,
    CONSTRAINT fk_assoc_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- A tabela oficial não possuía favoritos. A restrição UNIQUE impede que o
-- mesmo usuário favorite a mesma palestra duas vezes.
CREATE TABLE favorito (
    id_favorito      INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario       INT NOT NULL,
    id_palestra      INT NOT NULL,
    data_favoritacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_favorito_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_favorito_palestra
        FOREIGN KEY (id_palestra) REFERENCES palestra(id_palestra)
        ON DELETE CASCADE,
    UNIQUE KEY uk_favorito_usuario_palestra (id_usuario, id_palestra)
) ENGINE=InnoDB;

-- =====================================================================
-- DADOS FICTÍCIOS PARA DEMONSTRAÇÃO
-- =====================================================================

INSERT INTO usuario (nome, email, senha, tipo_usuario) VALUES
('Ana Silva',    'ana.silva@email.com',    'hash123', 'participante'),
('Bruno Costa',  'bruno.costa@email.com',  'hash456', 'organizador'),
('Carla Souza',  'carla.souza@email.com',  'hash789', 'palestrante');

INSERT INTO evento (nome, descricao, data_inicio, data_fim, local) VALUES
('Semana de Tecnologia', 'Evento acadêmico sobre inovação e TI', '2026-09-10', '2026-09-12', 'Centro de Convenções UFMG'),
('Feira de Ciências',    'Exposição de projetos escolares',      '2026-10-05', '2026-10-06', 'Ginásio Municipal');

INSERT INTO restaurante (nome, avaliacao, distancia, categoria, endereco) VALUES
('Sabor Mineiro',   4.5, 0.80, 'Comida Mineira', 'Rua das Flores, 100'),
('Cantina Italiana',4.2, 1.20, 'Italiana',       'Av. Central, 250');

INSERT INTO restaurante_evento (id_restaurante, id_evento) VALUES
(1, 1),
(2, 1);

INSERT INTO palestra (titulo, resumo, tema, sala, horario_inicio, horario_fim, id_evento) VALUES
('Introdução à Inteligência Artificial', 'Panorama geral sobre IA', 'Tecnologia', 'Sala A1', '2026-09-10 09:00:00', '2026-09-10 10:30:00', 1),
('Banco de Dados na Prática',            'Modelagem e consultas SQL', 'Tecnologia', 'Sala A2', '2026-09-10 11:00:00', '2026-09-10 12:30:00', 1);

INSERT INTO organizador (id_usuario, nivel_acesso) VALUES
(2, 'administrador');

INSERT INTO participacao (id_usuario, id_palestra) VALUES
(1, 1),
(1, 2);

-- Mantém o contador coerente com os dados fictícios oficiais.
UPDATE palestra p
LEFT JOIN (
    SELECT id_palestra, COUNT(*) AS total_inscritos
    FROM participacao
    GROUP BY id_palestra
) i ON i.id_palestra = p.id_palestra
SET p.vagas_disponiveis = GREATEST(
    p.vagas_total - COALESCE(i.total_inscritos, 0), 0
);

INSERT INTO comentario (texto, nota, id_usuario, id_palestra) VALUES
('Palestra muito esclarecedora!', 9.5, 1, 1);

INSERT INTO notificacao (mensagem, tipo_notificacao, id_usuario, id_palestra) VALUES
('A palestra "Introdução à Inteligência Artificial" começa em 30 minutos.', 'lembrete', 1, 1);

INSERT INTO planta_baixa (imagem_mapa, descricao, id_evento) VALUES
('/mapas/semana_tecnologia.png', 'Mapa do centro de convenções', 1);

INSERT INTO localizacao (nome_local, descricao, id_evento) VALUES
('Auditório Principal', 'Local das palestras principais', 1);
