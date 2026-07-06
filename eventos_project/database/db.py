from flask_sqlalchemy import SQLAlchemy

# Instância única do SQLAlchemy, compartilhada por toda a aplicação.
# Os Models importam este `db` para herdar de db.Model e usar db.session.
db = SQLAlchemy()
