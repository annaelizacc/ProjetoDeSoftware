import 'avaliacao.dart';

/// Model (do lado do Flutter): Palestra.
///
/// Representa os dados de uma palestra recebidos da API Flask
/// (`GET /api/palestras`, `GET /api/palestras/<id>`, agenda e favoritos).
/// Também carrega três informações que só a rota de detalhes devolve,
/// calculadas para o usuário do token de login: `inscrito`, `favorita` e
/// `lembreteAtivo` — usadas pela tela de detalhes para decidir o estado
/// inicial dos botões de ação.
///
/// Desde a F06/F07, traz também a nota da palestra (`mediaEstrelas` e
/// `totalAvaliacoes`, na listagem e nos detalhes) e, só nos detalhes, a
/// avaliação do próprio usuário (`minhaAvaliacao`) e se ele já pode
/// avaliar (`podeAvaliar`: inscrito e palestra já começada, regra
/// decidida no backend).
class Palestra {
  final int id;
  final String titulo;
  final String? resumo;
  final String? tema;
  final String? sala;
  final String? inicio;
  final String? fim;
  final int vagas;
  final int total;
  final bool inscrito;
  final bool favorita;
  final bool lembreteAtivo;
  final double? mediaEstrelas;
  final int totalAvaliacoes;
  final Avaliacao? minhaAvaliacao;
  final bool podeAvaliar;

  Palestra({
    required this.id,
    required this.titulo,
    this.resumo,
    this.tema,
    this.sala,
    this.inicio,
    this.fim,
    this.vagas = 0,
    this.total = 0,
    this.inscrito = false,
    this.favorita = false,
    this.lembreteAtivo = false,
    this.mediaEstrelas,
    this.totalAvaliacoes = 0,
    this.minhaAvaliacao,
    this.podeAvaliar = false,
  });

  /// Constrói uma Palestra a partir do JSON devolvido pela API.
  ///
  /// Os campos opcionais recebem valores padrão (`?? 0`, `?? false`)
  /// porque nem toda rota devolve todas as informações — por exemplo, a
  /// listagem de programação não inclui `inscrito`/`favorita` (que
  /// dependem de um usuário logado), só a rota de detalhes inclui.
  factory Palestra.fromJson(Map<String, dynamic> json) {
    return Palestra(
      id: json['id_palestra'] as int,
      titulo: json['titulo'] ?? '',
      resumo: json['resumo'],
      tema: json['tema'],
      sala: json['sala'],
      inicio: json['horario_inicio'],
      fim: json['horario_fim'],
      vagas: json['vagas_disponiveis'] ?? 0,
      total: json['vagas_total'] ?? 0,
      inscrito: json['inscrito'] ?? false,
      favorita: json['favorita'] ?? false,
      lembreteAtivo: json['lembrete_ativo'] ?? false,
      // `num` e não `double`: o JSON pode trazer `5` (int) em vez de `5.0`.
      mediaEstrelas: (json['media_estrelas'] as num?)?.toDouble(),
      totalAvaliacoes: json['total_avaliacoes'] ?? 0,
      minhaAvaliacao: json['minha_avaliacao'] == null
          ? null
          : Avaliacao.fromJson(Map<String, dynamic>.from(json['minha_avaliacao'])),
      podeAvaliar: json['pode_avaliar'] ?? false,
    );
  }

  /// Formata o horário de início/fim (ISO 8601) como "HH:mm - HH:mm",
  /// pronto para exibir nas telas, sem espalhar essa lógica de formatação
  /// pelas telas que mostram o horário da palestra.
  String get horario {
    if (inicio == null) return 'Horário a definir';
    final data = DateTime.tryParse(inicio!);
    if (data == null) return inicio!;
    final hora =
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    if (fim == null) return hora;
    final finalData = DateTime.tryParse(fim!);
    final finalHora = finalData == null
        ? ''
        : ' - ${finalData.hour.toString().padLeft(2, '0')}:${finalData.minute.toString().padLeft(2, '0')}';
    return '$hora$finalHora';
  }

  /// Média no formato brasileiro, com vírgula (ex.: `4,6`).
  String get mediaTexto =>
      mediaEstrelas == null ? '–' : mediaEstrelas!.toStringAsFixed(1).replaceAll('.', ',');
}
