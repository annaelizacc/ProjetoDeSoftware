-- =====================================================================
-- Script SQL - Sistema de Gerenciamento de Eventos
-- Compatível com MySQL 8+
-- Gerado a partir das Models SQLAlchemy (Etapa 3) do projeto.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS eventos_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE eventos_db;

-- ---------------------------------------------------------------------
-- Evento
-- ---------------------------------------------------------------------
CREATE TABLE evento (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    local VARCHAR(150) NOT NULL,
    data  DATE NOT NULL,
    nome  VARCHAR(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- PlantaBaixa (1:1 com Evento)
-- ---------------------------------------------------------------------
CREATE TABLE planta_baixa (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    mapa      VARCHAR(255) NOT NULL,
    evento_id INT NOT NULL UNIQUE,
    CONSTRAINT fk_planta_baixa_evento
        FOREIGN KEY (evento_id) REFERENCES evento(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Rota (N:1 com PlantaBaixa)
-- ---------------------------------------------------------------------
CREATE TABLE rota (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    origem          VARCHAR(150) NOT NULL,
    destino         VARCHAR(150) NOT NULL,
    planta_baixa_id INT NOT NULL,
    CONSTRAINT fk_rota_planta_baixa
        FOREIGN KEY (planta_baixa_id) REFERENCES planta_baixa(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Patrocinador (N:1 com Evento)
-- ---------------------------------------------------------------------
CREATE TABLE patrocinador (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(150) NOT NULL,
    logo      VARCHAR(255),
    descricao VARCHAR(500),
    evento_id INT NOT NULL,
    CONSTRAINT fk_patrocinador_evento
        FOREIGN KEY (evento_id) REFERENCES evento(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Palestrante
-- ---------------------------------------------------------------------
CREATE TABLE palestrante (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(150) NOT NULL,
    biografia TEXT,
    empresa   VARCHAR(150),
    foto      VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Palestra (N:1 com Evento)
-- ---------------------------------------------------------------------
CREATE TABLE palestra (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    titulo            VARCHAR(150) NOT NULL,
    tema              VARCHAR(150),
    descricao         TEXT,
    horario           DATETIME NOT NULL,
    vagas_disponiveis INT NOT NULL DEFAULT 0,
    evento_id         INT NOT NULL,
    CONSTRAINT fk_palestra_evento
        FOREIGN KEY (evento_id) REFERENCES evento(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- palestra_palestrante (tabela associativa N:N)
-- ---------------------------------------------------------------------
CREATE TABLE palestra_palestrante (
    palestra_id    INT NOT NULL,
    palestrante_id INT NOT NULL,
    PRIMARY KEY (palestra_id, palestrante_id),
    CONSTRAINT fk_pp_palestra
        FOREIGN KEY (palestra_id) REFERENCES palestra(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pp_palestrante
        FOREIGN KEY (palestrante_id) REFERENCES palestrante(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Usuario (superclasse; Organizador usa Single Table Inheritance
-- através da coluna discriminadora "tipo")
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(150) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    senha       VARCHAR(255) NOT NULL,
    modo_escuro BOOLEAN DEFAULT FALSE,
    tipo        VARCHAR(20) NOT NULL DEFAULT 'usuario'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Comunicado (N:1 com Usuario/Organizador)
-- ---------------------------------------------------------------------
CREATE TABLE comunicado (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    titulo         VARCHAR(150) NOT NULL,
    mensagem       TEXT NOT NULL,
    data_envio     DATETIME DEFAULT CURRENT_TIMESTAMP,
    organizador_id INT NOT NULL,
    CONSTRAINT fk_comunicado_organizador
        FOREIGN KEY (organizador_id) REFERENCES usuario(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Notificacao (N:1 com Usuario)
-- ---------------------------------------------------------------------
CREATE TABLE notificacao (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    mensagem   VARCHAR(255) NOT NULL,
    data_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_id INT NOT NULL,
    CONSTRAINT fk_notificacao_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Inscricao (N:1 com Usuario, N:1 com Palestra)
-- ---------------------------------------------------------------------
CREATE TABLE inscricao (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    status         VARCHAR(20) NOT NULL DEFAULT 'pendente',
    data_inscricao DATE DEFAULT (CURRENT_DATE),
    usuario_id     INT NOT NULL,
    palestra_id    INT NOT NULL,
    CONSTRAINT uq_inscricao_usuario_palestra UNIQUE (usuario_id, palestra_id),
    CONSTRAINT fk_inscricao_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_inscricao_palestra
        FOREIGN KEY (palestra_id) REFERENCES palestra(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Favorito (N:1 com Usuario, N:1 com Palestra)
-- ---------------------------------------------------------------------
CREATE TABLE favorito (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    data_favoritacao DATE DEFAULT (CURRENT_DATE),
    usuario_id       INT NOT NULL,
    palestra_id      INT NOT NULL,
    CONSTRAINT uq_favorito_usuario_palestra UNIQUE (usuario_id, palestra_id),
    CONSTRAINT fk_favorito_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_favorito_palestra
        FOREIGN KEY (palestra_id) REFERENCES palestra(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Feedback (N:1 com Usuario, N:1 com Palestra)
-- ---------------------------------------------------------------------
CREATE TABLE feedback (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    comentario  TEXT NOT NULL,
    data        DATE DEFAULT (CURRENT_DATE),
    usuario_id  INT NOT NULL,
    palestra_id INT NOT NULL,
    CONSTRAINT fk_feedback_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_feedback_palestra
        FOREIGN KEY (palestra_id) REFERENCES palestra(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Avaliacao (N:1 com Usuario, N:1 com Palestra)
-- ---------------------------------------------------------------------
CREATE TABLE avaliacao (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    estrelas    INT NOT NULL,
    usuario_id  INT NOT NULL,
    palestra_id INT NOT NULL,
    CONSTRAINT uq_avaliacao_usuario_palestra UNIQUE (usuario_id, palestra_id),
    CONSTRAINT chk_avaliacao_estrelas CHECK (estrelas BETWEEN 1 AND 5),
    CONSTRAINT fk_avaliacao_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_avaliacao_palestra
        FOREIGN KEY (palestra_id) REFERENCES palestra(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
