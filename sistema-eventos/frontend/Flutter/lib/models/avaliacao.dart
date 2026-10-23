/// Model (do lado do Flutter): Avaliacao.
///
/// Representa uma avaliação de palestra recebida da API Flask (F06, F07):
/// a nota em estrelas (1 a 5) e o comentário opcional. Vem de duas rotas:
/// - `GET /api/avaliacoes/palestra/<id>`: a lista da palestra, já com o
///   nome de quem avaliou (`nome_usuario`);
/// - `GET /api/palestras/<id>`: a avaliação do próprio usuário, no campo
///   `minha_avaliacao` (sem o nome, que a tela não precisa).
class Avaliacao {
  final int id;
  final int nota;
  final String? comentario;
  final String? nomeUsuario;
  final String? data;

  Avaliacao({
    required this.id,
    required this.nota,
    this.comentario,
    this.nomeUsuario,
    this.data,
  });

  /// Constrói uma Avaliacao a partir do JSON devolvido pela API.
  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id_avaliacao'] as int,
      nota: json['nota_estrelas'] as int,
      comentario: json['comentario'],
      nomeUsuario: json['nome_usuario'],
      data: json['data'],
    );
  }

  /// Data da avaliação no formato `22/10`, para a lista de comentários.
  String get dataCurta {
    final valor = data == null ? null : DateTime.tryParse(data!);
    if (valor == null) return '';
    return '${valor.day.toString().padLeft(2, '0')}/${valor.month.toString().padLeft(2, '0')}';
  }
}
