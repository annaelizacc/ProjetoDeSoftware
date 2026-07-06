# Sistema de Gerenciamento de Eventos

Projeto acadêmico em Flask + SQLAlchemy + MySQL, seguindo arquitetura em camadas
(Model / Service / Controller).

## Como rodar

1. Crie e ative um ambiente virtual:
   ```
   python -m venv venv
   venv\Scripts\activate      # Windows
   source venv/bin/activate   # Linux/Mac
   ```

2. Instale as dependências:
   ```
   pip install -r requirements.txt
   ```

3. Copie `.env.example` para `.env` e ajuste usuário/senha do MySQL.

4. Crie o banco de dados executando o script:
   ```
   mysql -u root -p < sql/script.sql
   ```
   (o script completo de tabelas será adicionado na Etapa 7 do desenvolvimento)

5. Rode a aplicação:
   ```
   python app.py
   ```

6. Acesse: http://localhost:5000

## Estrutura do projeto

```
eventos_project/
├── app.py                 # Application factory do Flask
├── config.py               # Configurações (env vars, MySQL)
├── requirements.txt
├── database/
│   └── db.py                # Instância do SQLAlchemy
├── models/                  # Entidades (herdam de db.Model)
├── services/                 # Regras de negócio
├── controllers/              # Rotas REST (Blueprints)
├── templates/                # Páginas HTML
├── static/
│   ├── css/
│   └── js/
└── sql/
    └── script.sql             # Script de criação do banco MySQL
```

## Status do desenvolvimento

- [x] Etapa 1 — Análise do diagrama UML
- [x] Etapa 2 — Estrutura do projeto
- [x] Etapa 3 — Models
- [x] Etapa 4 — Services
- [x] Etapa 5 — Controllers
- [x] Etapa 6 — Rotas registradas no app.py
- [x] Etapa 7 — Script MySQL completo
- [x] Etapa 8 — Front-end
- [x] Etapa 9 — Revisão final

## Decisões de modelagem (resumo da Etapa 1)

- **Herança Usuario → Organizador**: Single Table Inheritance (coluna `tipo`).
- **Palestra ↔ Palestrante**: relação N:N via tabela `palestra_palestrante`.
- **Feedback** (comentário) e **Avaliacao** (nota 1-5): entidades separadas.
- **Evento → Patrocinador**: relação 1:N adicionada (não estava desenhada no UML, mas necessária para `listarPatrocinadores()`).
- **Usuario.senha**: campo adicionado fora do UML, necessário para `login()` funcionar de fato (hash via `werkzeug.security`).
- **Comunicado → Notificacao**: sem FK direta; ao publicar um Comunicado, o Service cria uma Notificacao para cada usuário.

## Revisão final (Etapa 9)

- Sintaxe de todos os arquivos `.py` validada com `py_compile`.
- Sintaxe de todos os arquivos `.js` (incluindo os inline nos templates) validada com `node --check`.
- Todas as 14 páginas do front-end testadas com o Flask test client (200 OK).
- Todas as chamadas `fetch()` do front-end conferidas uma a uma contra as rotas realmente registradas em `app.py` — nenhuma divergência encontrada.
- Colunas dos Models conferidas uma a uma contra `sql/script.sql` — tipos, nulabilidade e defaults consistentes.
- **Limitação do ambiente**: não foi possível instalar `Flask-SQLAlchemy`/`PyMySQL` neste sandbox (sem acesso à internet), então os testes de integração real com banco de dados MySQL não puderam ser executados aqui. Recomenda-se rodar `pip install -r requirements.txt` e testar localmente antes de considerar o projeto pronto para entrega/avaliação.
