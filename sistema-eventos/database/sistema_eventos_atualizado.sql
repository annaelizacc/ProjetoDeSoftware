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
-- Desde a F14, o palestrante pertence a um evento: o organizador o
-- cadastra uma vez no evento e o indica nas palestras. A mesma pessoa só
-- tem dois cadastros se falar em eventos diferentes. `foto` guarda o nome
-- do arquivo enviado (pasta `backend/uploads/`).
-- =====================================================================
CREATE TABLE palestrante (
    id_palestrante  INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(150)    NOT NULL,
    foto            VARCHAR(255),
    descricao       TEXT,
    rede_social     VARCHAR(255),
    id_evento       INT             NOT NULL,
    CONSTRAINT fk_palestrante_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON DELETE CASCADE
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

-- Organizador responsável pelo evento (F08): cada evento tem um só, e um
-- organizador pode ter vários eventos. Entra com ALTER TABLE porque a
-- tabela `organizador` é criada depois de `evento`. ON DELETE RESTRICT:
-- o banco não deixa apagar um organizador (nem o usuário dele) que ainda
-- tem eventos, para nenhum evento ficar sem responsável.
ALTER TABLE evento
    ADD COLUMN id_organizador INT NOT NULL,
    ADD CONSTRAINT fk_evento_organizador
        FOREIGN KEY (id_organizador) REFERENCES organizador(id_organizador)
        ON DELETE RESTRICT;

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
-- `id_evento` (F09) guarda de qual evento veio o comunicado, para a aba
-- Avisos mostrar o nome dele; os lembretes e os outros avisos o deixam
-- vazio.
-- =====================================================================
CREATE TABLE notificacao (
    id_notificacao  INT AUTO_INCREMENT PRIMARY KEY,
    mensagem        TEXT            NOT NULL,
    data_envio      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_notificacao VARCHAR(50),
    id_usuario      INT             NOT NULL,
    id_palestra     INT,
    id_evento       INT,
    CONSTRAINT fk_notificacao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_notificacao_palestra
        FOREIGN KEY (id_palestra) REFERENCES palestra(id_palestra)
        ON DELETE CASCADE,
    CONSTRAINT fk_notificacao_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
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

-- Senha dos quatro usuários: Senha@123 (P02). O banco guarda só o hash
-- gerado pelo Werkzeug (`generate_password_hash`), nunca a senha em
-- texto puro. Cada hash é diferente, mesmo com a senha igual, porque
-- leva um "salt" aleatório (o trecho entre o primeiro e o segundo `$`).
INSERT INTO usuario (nome, email, senha, tipo_usuario) VALUES
('Ana Silva',    'ana.silva@email.com',    'scrypt:32768:8:1$uNDOTi1cboQkE7BG$400cf8c8dc332a823eb34a82938da6d3875f3bfc25490fac4c5c9e967d354bee4e0685c1010b79006ac034aa6b0d0441fa334bf9a94004b6d46404c6268d42bc', 'participante'),
('Bruno Costa',  'bruno.costa@email.com',  'scrypt:32768:8:1$Cvx9QzxMyqEDlutd$056cfbd646f51cf5de5360c2b6c600b95be9b880c99c2e169744bdf0cf88cfca1328116f96851e088264b9bf9a85a0a1d3cf20b866ced3519bd2e77558c8ee2f', 'organizador'),
('Carla Souza',  'carla.souza@email.com',  'scrypt:32768:8:1$gBNu7G9tWcg7wpCU$ca8422cd44a939077db0882d78b0205a00ff0c3d665cce3617bb40664e7b2e2aa79d4a32182ef88005109ac63cbce4e93a9a79d1dff2a918a933437d2fe1492a', 'participante'),
('Elisa Prado',  'elisa.prado@email.com',  'scrypt:32768:8:1$wPEcM9DExZvXTtRT$68086f8578bcc74ab2d3f64b5f7e0bf412acb1f6d3c855c44cc30d16ac3155ccff929b82734893cf0d31d7942e1066316c04982c1ac9f1f1a602725b756f05a8', 'organizador');

-- Os organizadores vêm antes dos eventos, porque todo evento aponta para
-- o seu responsável (F08). Bruno é o administrador (vê todos os eventos)
-- e responde pela Semana de Tecnologia e pela Mostra de Projetos; Elisa é
-- organizadora da Feira de Ciências e só enxerga esse evento.
INSERT INTO organizador (id_usuario, nivel_acesso) VALUES
(2, 'administrador'),
(4, 'organizador');

-- ---------------------------------------------------------------------
-- Datas relativas (S05)
-- As datas dos eventos e das palestras são calculadas a partir do dia em
-- que o script roda, e não escritas à mão. Assim o banco sempre tem um
-- evento encerrado, um acontecendo e um futuro, em qualquer dia em que
-- for recriado (com datas fixas, os eventos de exemplo "envelheciam" e
-- as telas do app ficavam vazias).
--
-- - `@hoje` guarda a data de hoje (`CURDATE()`);
-- - `@hoje - INTERVAL 1 DAY` é ontem, `@hoje + INTERVAL 14 DAY` é daqui a
--   duas semanas;
-- - `TIMESTAMP(@hoje + INTERVAL 1 DAY, '09:00')` é amanhã às 09:00;
-- - `@hora_cheia` é hoje, na hora cheia atual (às 15:20, vale 15:00). A
--   palestra "acontecendo agora" começa uma hora antes dela e termina
--   três horas depois, então continua acontecendo por 2 a 3 horas
--   depois de o script rodar. Por isso, no dia da apresentação, o banco
--   deve ser recriado pouco antes de usar o app (e não perto da
--   meia-noite, quando essa palestra cairia em outro dia).
--
-- Os horários ficam na hora local, como os que o organizador cadastra
-- pelo app. `CURDATE()` e `NOW()` usam o fuso do MySQL, que precisa ser
-- o mesmo do computador onde roda o backend (o padrão de uma instalação
-- local, `time_zone = SYSTEM`).
-- ---------------------------------------------------------------------
SET @hoje = CURDATE();
SET @hora_cheia = TIMESTAMP(CURDATE(), MAKETIME(HOUR(NOW()), 0, 0));

-- Três eventos, um em cada situação:
-- 1. Semana de Tecnologia: acontecendo (de ontem até amanhã);
-- 2. Feira de Ciências: futuro (daqui a duas semanas);
-- 3. Mostra de Projetos: encerrado (há um mês).
-- O evento encerrado entra por último para os ids 1 e 2 continuarem os
-- mesmos dos exemplos do README.
INSERT INTO evento (nome, descricao, data_inicio, data_fim, local, id_organizador) VALUES
('Semana de Tecnologia', 'Evento acadêmico sobre inovação e TI',                        @hoje - INTERVAL 1 DAY,  @hoje + INTERVAL 1 DAY,  'Centro de Convenções UFMG', 1),
('Feira de Ciências',    'Exposição de projetos escolares',                             @hoje + INTERVAL 14 DAY, @hoje + INTERVAL 15 DAY, 'Ginásio Municipal',         2),
('Mostra de Projetos',   'Apresentação dos projetos finais dos alunos do curso técnico', @hoje - INTERVAL 30 DAY, @hoje - INTERVAL 29 DAY, 'Escola Técnica Estadual',   1);

INSERT INTO restaurante (nome, avaliacao, distancia, categoria, endereco) VALUES
('Sabor Mineiro',   4.5, 0.80, 'Comida Mineira', 'Rua das Flores, 100'),
('Cantina Italiana',4.2, 1.20, 'Italiana',       'Av. Central, 250');

INSERT INTO restaurante_evento (id_restaurante, id_evento) VALUES
(1, 1),
(2, 1);

-- Os palestrantes de exemplo (F05), cada um no seu evento. Carla Souza
-- era uma usuária do tipo 'palestrante'; agora é palestrante aqui e
-- participante em `usuario`.
INSERT INTO palestrante (nome, foto, descricao, rede_social, id_evento) VALUES
('Carla Souza',    NULL, 'Pesquisadora em Inteligência Artificial.',         'https://www.linkedin.com/in/carla-souza',    1),
('Diego Martins',  NULL, 'Administrador de banco de dados.',                 'https://www.linkedin.com/in/diego-martins',  1),
('Rafael Lima',    NULL, 'Especialista em segurança da informação.',         'https://www.linkedin.com/in/rafael-lima',    1),
('Juliana Alves',  NULL, 'Desenvolvedora mobile e designer de interfaces.',  'https://www.linkedin.com/in/juliana-alves',  1),
('Helena Duarte',  NULL, 'Professora de Química e divulgadora científica.',  'https://www.linkedin.com/in/helena-duarte',  2),
('Marcos Pereira', NULL, 'Professor de robótica educacional.',               'https://www.linkedin.com/in/marcos-pereira', 3);

-- Os textos que antes ficavam em `palestra.sala` viraram locais (F04).
INSERT INTO localizacao (nome_local, descricao, id_evento) VALUES
('Auditório Principal', '1. Entre pelo hall principal e passe pelo credenciamento.\n2. Siga reto até o fim do hall.\n3. O auditório fica nas portas duplas à frente.', 1),
('Sala A1',             '1. Entre pelo hall principal e passe pelo credenciamento.\n2. Suba a escada à direita até o 1º andar.\n3. A Sala A1 é a primeira porta à esquerda.', 1),
('Sala A2',             '1. Entre pelo hall principal e passe pelo credenciamento.\n2. Suba a escada à direita até o 1º andar.\n3. A Sala A2 é a segunda porta à esquerda, depois da A1.', 1),
('Quadra principal',    '1. Entre pelo portão principal do ginásio.\n2. Siga pelo corredor central.\n3. A quadra fica logo depois da arquibancada.', 2),
('Sala de Exposições',  '1. Entre pelo portão principal do ginásio.\n2. Vire à esquerda antes da quadra.\n3. A sala fica ao lado dos banheiros.', 2),
('Auditório da Escola', '1. Entre pelo portão da escola.\n2. Atravesse o pátio até o bloco central.\n3. O auditório fica no térreo, à direita.', 3);

-- Cada palestra mostra uma situação do app (o id está no comentário):
--  1 e 2: ontem, já aconteceram (dá para avaliar);
--  3: acontecendo agora (a "próxima palestra" do Início);
--  4: amanhã, esgotada (1 vaga, ocupada pela Carla);
--  5: amanhã, última vaga (2 vagas, 1 ocupada): quem se inscrever esgota;
--  6: amanhã, com vagas e sem avaliações (a Ana está inscrita);
--  7 e 8: Feira de Ciências, daqui a duas semanas;
--  9 e 10: Mostra de Projetos, encerrada (a 10 não tem palestrante);
--  11: amanhã, no mesmo horário da 6: ao se inscrever, a Ana vê o aviso
--      de choque de horário (F16). Fica no fim para os ids 1 a 10 não mudarem.
INSERT INTO palestra (titulo, resumo, tema, horario_inicio, horario_fim, id_evento, id_localizacao, id_palestrante, vagas_total) VALUES
('Introdução à Inteligência Artificial',  'Panorama geral sobre IA',                           'Tecnologia', TIMESTAMP(@hoje - INTERVAL 1 DAY, '09:00'),  TIMESTAMP(@hoje - INTERVAL 1 DAY, '10:30'),  1, 2, 1,    40),
('Banco de Dados na Prática',             'Modelagem e consultas SQL',                         'Tecnologia', TIMESTAMP(@hoje - INTERVAL 1 DAY, '11:00'),  TIMESTAMP(@hoje - INTERVAL 1 DAY, '12:30'),  1, 3, 2,    40),
('Segurança da Informação',               'Senhas, golpes e como proteger seus dados',         'Segurança',  @hora_cheia - INTERVAL 1 HOUR,               @hora_cheia + INTERVAL 3 HOUR,               1, 1, 3,    30),
('Apps com Flutter',                      'Do zero ao primeiro aplicativo no celular',         'Programação', TIMESTAMP(@hoje + INTERVAL 1 DAY, '09:00'), TIMESTAMP(@hoje + INTERVAL 1 DAY, '10:30'),  1, 2, 4,    1),
('APIs REST com Flask',                   'Como o app conversa com o servidor',                'Programação', TIMESTAMP(@hoje + INTERVAL 1 DAY, '11:00'), TIMESTAMP(@hoje + INTERVAL 1 DAY, '12:30'),  1, 3, 2,    2),
('Design de Interfaces',                  'Cores, fontes e telas fáceis de usar',              'Design',     TIMESTAMP(@hoje + INTERVAL 1 DAY, '14:00'),  TIMESTAMP(@hoje + INTERVAL 1 DAY, '15:30'),  1, 2, 4,    30),
('Experimentos de Química no Dia a Dia',  'Reações químicas com materiais de casa',            'Ciências',   TIMESTAMP(@hoje + INTERVAL 14 DAY, '09:00'), TIMESTAMP(@hoje + INTERVAL 14 DAY, '10:30'), 2, 4, 5,    25),
('Astronomia para Iniciantes',            'Como observar o céu sem telescópio',                'Ciências',   TIMESTAMP(@hoje + INTERVAL 14 DAY, '14:00'), TIMESTAMP(@hoje + INTERVAL 14 DAY, '15:30'), 2, 5, 5,    25),
('Robótica Educacional',                  'Projetos de robôs feitos pelos alunos',             'Robótica',   TIMESTAMP(@hoje - INTERVAL 30 DAY, '09:00'), TIMESTAMP(@hoje - INTERVAL 30 DAY, '10:30'), 3, 6, 6,    30),
('Roda de Conversa: Carreira em TI',      'Ex-alunos contam como entraram no mercado',         'Carreira',   TIMESTAMP(@hoje - INTERVAL 30 DAY, '11:00'), TIMESTAMP(@hoje - INTERVAL 30 DAY, '12:00'), 3, 6, NULL, 20),
('Acessibilidade em Aplicativos',         'Como fazer apps que todas as pessoas conseguem usar', 'Design',   TIMESTAMP(@hoje + INTERVAL 1 DAY, '14:30'),  TIMESTAMP(@hoje + INTERVAL 1 DAY, '15:30'),  1, 3, 4,    30);

-- Inscrições. Ana: palestras de ontem, a de agora, a 6 de amanhã (que
-- bate no horário com a 11, para o aviso de choque da F16), uma da
-- Feira e as duas da Mostra (a agenda tem passado, presente e futuro). Carla:
-- ocupa a vaga única da palestra 4 e uma das duas vagas da 5. Ela não se
-- inscreve na palestra 1, porque é a palestrante dela.
INSERT INTO participacao (id_usuario, id_palestra) VALUES
(1, 1), (1, 2), (1, 3), (1, 6), (1, 8), (1, 9), (1, 10),
(3, 2), (3, 4), (3, 5), (3, 9);

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

-- Avaliações só de quem está inscrito e de palestras que já começaram
-- (a mesma regra do `CriarAvaliacaoService`). A palestra 9 fica com
-- média 4,5. A palestra 2 tem só a nota da Carla (4): a Ana ainda não
-- avaliou, para demonstrar a tela Avaliar e ver a média mudar.
INSERT INTO avaliacao (nota_estrelas, comentario, id_usuario, id_palestra) VALUES
(5, 'Palestra muito esclarecedora!',                        1, 1),
(4, 'Gostei dos exemplos, mas faltou tempo para perguntas.', 3, 2),
(4, 'Muito bom ver os projetos funcionando.',               1, 9),
(5, NULL,                                                   3, 9);

-- Favoritos da Ana: uma palestra esgotada e uma com vagas.
INSERT INTO favorito (id_usuario, id_palestra) VALUES
(1, 4),
(1, 6);

-- Um aviso de cada tipo, com as mesmas mensagens que a API grava:
-- comunicado para todo o evento (Ana e Carla, as inscritas), comunicado
-- de uma palestra, inscrição removida pela organização (ATENÇÃO) e
-- lembrete. `data_envio` usa `UTC_TIMESTAMP()` porque a aba Avisos lê
-- esse campo em UTC, como os avisos criados pela API (ver P06).
INSERT INTO notificacao (mensagem, tipo_notificacao, id_usuario, id_palestra, id_evento, data_envio) VALUES
('Boas-vindas à Semana de Tecnologia! O credenciamento fica no hall de entrada.', 'comunicado', 1, NULL, 1, UTC_TIMESTAMP() - INTERVAL 1 DAY),
('Boas-vindas à Semana de Tecnologia! O credenciamento fica no hall de entrada.', 'comunicado', 3, NULL, 1, UTC_TIMESTAMP() - INTERVAL 1 DAY),
('Traga seu notebook: a palestra terá uma parte prática.',                         'comunicado', 1, 3,    1, UTC_TIMESTAMP() - INTERVAL 2 HOUR),
('Sua inscrição em Experimentos de Química no Dia a Dia foi removida pela organização.', 'atencao', 1, 7, NULL, UTC_TIMESTAMP() - INTERVAL 1 HOUR),
(CONCAT('Lembrete ativado: Design de Interfaces começa em ',
        DATE_FORMAT(TIMESTAMP(@hoje + INTERVAL 1 DAY, '14:00'), '%d/%m às %H:%i'), '.'),
                                                                                   'lembrete',   1, 6,    NULL, UTC_TIMESTAMP() - INTERVAL 10 MINUTE);

-- Sem imagem: a imagem da planta é enviada pelo organizador no app (F14).
INSERT INTO planta_baixa (imagem_mapa, descricao, id_evento) VALUES
(NULL, 'Mapa do centro de convenções', 1);

-- A Mostra de Projetos fica sem patrocinador, para mostrar a tela vazia.
INSERT INTO patrocinador (nome_empresa, logo, site, descricao, id_evento) VALUES
('TechNova',           NULL, 'https://www.technova.com.br',      'Empresa de software e serviços em nuvem.', 1),
('Laboratório Aurora', NULL, 'https://www.laboratorioaurora.com.br', 'Laboratório de análises e kits de ciências.', 2);
