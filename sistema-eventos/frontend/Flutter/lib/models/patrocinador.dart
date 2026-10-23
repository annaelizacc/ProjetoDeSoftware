/// Model (do lado do Flutter): Patrocinador.
///
/// Representa uma empresa que patrocina o evento, recebida da API Flask
/// em `GET /api/patrocinadores?id_evento=<id>` (F10, RF19).
class Patrocinador {
  final int id;
  final String nome;
  final String? logo;
  final String? site;
  final String? descricao;

  Patrocinador({
    required this.id,
    required this.nome,
    this.logo,
    this.site,
    this.descricao,
  });

  /// Constrói um Patrocinador a partir do JSON devolvido pela API.
  factory Patrocinador.fromJson(Map<String, dynamic> json) {
    return Patrocinador(
      id: json['id_patrocinador'] as int,
      nome: json['nome_empresa'] ?? '',
      logo: json['logo'],
      site: json['site'],
      descricao: json['descricao'],
    );
  }

  /// Iniciais mostradas quando o patrocinador ainda não tem logo
  /// cadastrado pelo organizador (F14): a primeira letra das duas primeiras palavras ("Nuvem
  /// Azul" → "NA") ou, com uma palavra só, as duas primeiras letras
  /// ("TechNova" → "TE").
  String get iniciais {
    final palavras = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (palavras.isEmpty) return '?';
    if (palavras.length == 1) {
      final palavra = palavras.first;
      return palavra.substring(0, palavra.length < 2 ? palavra.length : 2).toUpperCase();
    }
    return (palavras[0][0] + palavras[1][0]).toUpperCase();
  }

  /// Site sem `https://` e `www.`, mais curto para caber no card
  /// (ex.: `technova.com.br`).
  String? get siteCurto {
    if (site == null || site!.trim().isEmpty) return null;
    return site!.trim().replaceFirst(RegExp(r'^https?://'), '').replaceFirst(RegExp(r'^www\.'), '').replaceFirst(RegExp(r'/$'), '');
  }
}
