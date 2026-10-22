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
-- Entidade base do sistema. Todo participante ou organizador é primeiro
-- um usuário cadastrado. Palestrantes não são usuários: ficam na tabela
-- `palestrante` (F19/D01).
--
-- Preparo para a F18 (Entrar com Google), ainda não implementada:
-- - `senha` aceita vazio, porque quem entra pelo Google não tem senha
--   no sistema (o login por e-mail e senha recusa esses usuários);
-- - `google_id` guarda o identificador da conta Google, para reconhecer
--   a mesma pessoa nos próximos logins.
-- =====================================================================
CREATE TABLE usuario (
    id_usuario      INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(150)    NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    senha           VARCHAR(255),
    tipo_usuario    VARCHAR(50)     NOT NULL,
    google_id       VARCHAR(255)    UNIQUE
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
-- 4. TABELA: palestrante (F19/D01, usada na F05)
-- Quem apresenta as palestras. Não é um usuário do app: tem só os dados
-- mostrados na tela de informações do palestrante.
-- =====================================================================
CREATE TABLE palestrante (
    id_palestrante  INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(150)    NOT NULL,
    foto            VARCHAR(255),
    descricao       TEXT,
    rede_social     VARCHAR(255)
) ENGINE=InnoDB;

-- =====================================================================
-- 5. TABELA: localizacao
-- Locais que pertencem a um evento (auditórios, salas, estandes).
-- Fica antes de `palestra` porque cada palestra aponta para o local
-- onde acontece (F19/D01, usada na F04).
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
-- 6. TABELA: palestra
-- Palestras pertencem a um evento (relacionamento "pertence").
-- O texto livre `sala` foi trocado por `id_localizacao` (F19/D01): o
-- local passa a ser um registro de `localizacao`, que a tela de rotas
-- (F04) consegue usar. Palestrante e local são opcionais e, se forem
-- apagados, a palestra continua existindo (ON DELETE SET NULL).
-- =====================================================================
CREATE TABLE palestra (
    id_palestra     INT AUTO_INCREMENT PRIMARY KEY,
    titulo          VARCHAR(200)    NOT NULL,
    resumo          TEXT,
    tema            VARCHAR(120),
    horario_inicio  DATETIME,
    horario_fim     DATETIME,
    id_evento       INT             NOT NULL,
    id_localizacao  INT,
    id_palestrante  INT,
    CONSTRAINT fk_palestra_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE,
    CONSTRAINT fk_palestra_localizacao
        FOREIGN KEY (id_localizacao) REFERENCES localizacao(id_localizacao)
        ON DELETE SET NULL,
    CONSTRAINT fk_palestra_palestrante
        FOREIGN KEY (id_palestrante) REFERENCES palestrante(id_palestrante)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- Extensão mínima para a regra de inscrição com controle automático de vagas.
-- Os valores existentes continuam válidos; a atualização abaixo recalcula o
-- saldo considerando as participações que já estão no banco.
ALTER TABLE palestra
    ADD COLUMN vagas_total INT NOT NULL DEFAULT 50,
    ADD COLUMN vagas_disponiveis INT NOT NULL DEFAULT 50;

-- =====================================================================
-- 7. TABELA: organizador
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
-- 8. TABELA: participacao
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
-- 9. TABELA: avaliacao (F19/D01, usada na F06 e na F07)
-- Avaliação que um usuário faz sobre uma palestra: estrelas de 1 a 5 e
-- um comentário opcional. Substitui a antiga tabela `comentario`, para
-- não guardar o mesmo dado em dois lugares (na tela "Avaliar", estrelas
-- e comentário são enviados juntos).
-- A chave única impede que a mesma pessoa avalie a mesma palestra mais
-- de uma vez e distorça a média.
-- =====================================================================
CREATE TABLE avaliacao (
    id_avaliacao    INT AUTO_INCREMENT PRIMARY KEY,
    nota_estrelas   TINYINT         NOT NULL,
    comentario      TEXT,
    data            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario      INT             NOT NULL,
    id_palestra     INT             NOT NULL,
    CONSTRAINT ck_avaliacao_estrelas
        CHECK (nota_estrelas BETWEEN 1 AND 5),
    CONSTRAINT fk_avaliacao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_avaliacao_palestra
        FOREIGN KEY (id_palestra) REFERENCES palestra(id_palestra)
        ON DELETE CASCADE,
    UNIQUE KEY uk_avaliacao_usuario_palestra (id_usuario, id_palestra)
) ENGINE=InnoDB;

-- =====================================================================
-- 10. TABELA: notificacao
-- Notificações recebidas ("recebe") por um usuário. `id_palestra` é
-- opcional (F19/D01): lembretes apontam para uma palestra, mas os
-- comunicados gerais do organizador (F09) valem para o evento todo.
-- =====================================================================
CREATE TABLE notificacao (
    id_notificacao  INT AUTO_INCREMENT PRIMARY KEY,
    mensagem        TEXT            NOT NULL,
    data_envio      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_notificacao VARCHAR(50),
    id_usuario      INT             NOT NULL,
    id_palestra     INT,
    CONSTRAINT fk_notificacao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_notificacao_palestra
        FOREIGN KEY (id_palestra) REFERENCES palestra(id_palestra)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 11. TABELA: planta_baixa
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
-- 12. TABELA: restaurante_evento
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

-- =====================================================================
-- 13. TABELA: favorito
-- A tabela oficial não possuía favoritos. A restrição UNIQUE impede que o
-- mesmo usuário favorite a mesma palestra duas vezes.
-- =====================================================================
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
-- 14. TABELA: patrocinador (F19/D01, usada na F10)
-- Empresas que patrocinam um evento. Se o evento for apagado, os
-- patrocinadores dele também são.
-- =====================================================================
CREATE TABLE patrocinador (
    id_patrocinador INT AUTO_INCREMENT PRIMARY KEY,
    nome_empresa    VARCHAR(150)    NOT NULL,
    logo            VARCHAR(255),
    site            VARCHAR(255),
    descricao       TEXT,
    id_evento       INT             NOT NULL,
    CONSTRAINT fk_patrocinador_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 15. TABELA: certificado (F19/D01, usada na F12)
-- Certificado de participação de um usuário em um evento, como no
-- diagrama (sem o campo genérico `Atributo_1`). Só a tabela por enquanto:
-- a emissão é a F12. O código de validação é único para que qualquer
-- pessoa confira se um certificado é verdadeiro, e cada usuário recebe
-- no máximo um certificado por evento.
-- =====================================================================
CREATE TABLE certificado (
    id_certificado   INT AUTO_INCREMENT PRIMARY KEY,
    codigo_validacao VARCHAR(64)    NOT NULL UNIQUE,
    data_emissao     DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario       INT            NOT NULL,
    id_evento        INT            NOT NULL,
    CONSTRAINT fk_certificado_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_certificado_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE,
    UNIQUE KEY uk_certificado_usuario_evento (id_usuario, id_evento)
) ENGINE=InnoDB;

-- =====================================================================
-- DADOS FICTÍCIOS PARA DEMONSTRAÇÃO
-- =====================================================================

-- Senha dos três usuários: Senha@123 (P02). O banco guarda só o hash
-- gerado pelo Werkzeug (`generate_password_hash`), nunca a senha em
-- texto puro. Cada hash é diferente, mesmo com a senha igual, porque
-- leva um "salt" aleatório (o trecho entre o primeiro e o segundo `$`).
INSERT INTO usuario (nome, email, senha, tipo_usuario) VALUES
('Ana Silva',    'ana.silva@email.com',    'scrypt:32768:8:1$uNDOTi1cboQkE7BG$400cf8c8dc332a823eb34a82938da6d3875f3bfc25490fac4c5c9e967d354bee4e0685c1010b79006ac034aa6b0d0441fa334bf9a94004b6d46404c6268d42bc', 'participante'),
('Bruno Costa',  'bruno.costa@email.com',  'scrypt:32768:8:1$Cvx9QzxMyqEDlutd$056cfbd646f51cf5de5360c2b6c600b95be9b880c99c2e169744bdf0cf88cfca1328116f96851e088264b9bf9a85a0a1d3cf20b866ced3519bd2e77558c8ee2f', 'organizador'),
('Carla Souza',  'carla.souza@email.com',  'scrypt:32768:8:1$gBNu7G9tWcg7wpCU$ca8422cd44a939077db0882d78b0205a00ff0c3d665cce3617bb40664e7b2e2aa79d4a32182ef88005109ac63cbce4e93a9a79d1dff2a918a933437d2fe1492a', 'participante');

INSERT INTO evento (nome, descricao, data_inicio, data_fim, local) VALUES
('Semana de Tecnologia', 'Evento acadêmico sobre inovação e TI', '2026-09-10', '2026-09-12', 'Centro de Convenções UFMG'),
('Feira de Ciências',    'Exposição de projetos escolares',      '2026-10-05', '2026-10-06', 'Ginásio Municipal');

INSERT INTO restaurante (nome, avaliacao, distancia, categoria, endereco) VALUES
('Sabor Mineiro',   4.5, 0.80, 'Comida Mineira', 'Rua das Flores, 100'),
('Cantina Italiana',4.2, 1.20, 'Italiana',       'Av. Central, 250');

INSERT INTO restaurante_evento (id_restaurante, id_evento) VALUES
(1, 1),
(2, 1);

-- Os palestrantes de exemplo (F05). Carla Souza era uma usuária do tipo
-- 'palestrante'; agora é palestrante aqui e participante em `usuario`.
INSERT INTO palestrante (nome, foto, descricao, rede_social) VALUES
('Carla Souza',   NULL, 'Pesquisadora em Inteligência Artificial.', 'https://www.linkedin.com/in/carla-souza'),
('Diego Martins', NULL, 'Administrador de banco de dados.',         'https://www.linkedin.com/in/diego-martins');

-- Os textos que antes ficavam em `palestra.sala` viraram locais (F04).
INSERT INTO localizacao (nome_local, descricao, id_evento) VALUES
('Auditório Principal', 'Local das palestras principais', 1),
('Sala A1',             'Sala do bloco A, primeiro andar', 1),
('Sala A2',             'Sala do bloco A, primeiro andar', 1);

INSERT INTO palestra (titulo, resumo, tema, horario_inicio, horario_fim, id_evento, id_localizacao, id_palestrante) VALUES
('Introdução à Inteligência Artificial', 'Panorama geral sobre IA', 'Tecnologia', '2026-09-10 09:00:00', '2026-09-10 10:30:00', 1, 2, 1),
('Banco de Dados na Prática',            'Modelagem e consultas SQL', 'Tecnologia', '2026-09-10 11:00:00', '2026-09-10 12:30:00', 1, 3, 2);

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

INSERT INTO avaliacao (nota_estrelas, comentario, id_usuario, id_palestra) VALUES
(5, 'Palestra muito esclarecedora!', 1, 1);

INSERT INTO notificacao (mensagem, tipo_notificacao, id_usuario, id_palestra) VALUES
('A palestra "Introdução à Inteligência Artificial" começa em 30 minutos.', 'lembrete', 1, 1);

INSERT INTO planta_baixa (imagem_mapa, descricao, id_evento) VALUES
('/mapas/semana_tecnologia.png', 'Mapa do centro de convenções', 1);

INSERT INTO patrocinador (nome_empresa, logo, site, descricao, id_evento) VALUES
('TechNova', NULL, 'https://www.technova.com.br', 'Empresa de software e serviços em nuvem.', 1);

