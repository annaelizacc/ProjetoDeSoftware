import 'dart:convert';

import 'package:http/http.dart' as http;

/// Centraliza todas as chamadas HTTP para a API Flask.
///
/// A URL base pode ser alterada sem editar o código:
/// `flutter run --dart-define=API_URL=http://10.0.2.2:5000`
/// (útil, por exemplo, ao rodar no emulador Android, que não enxerga
/// `127.0.0.1` da máquina host).
class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:5000',
  );

  /// Token de login devolvido pela API (P01). Fica só na memória: ao
  /// fechar o app, ele some e é preciso fazer login de novo. Enquanto
  /// existir, vai em toda requisição no cabeçalho `Authorization`, e é
  /// por ele que a API sabe quem está fazendo o pedido.
  static String? token;

  /// Executa uma requisição HTTP genérica e já trata os casos de erro.
  ///
  /// - Se o servidor estiver fora do ar, lança uma exceção amigável em vez
  ///   de deixar o erro de conexão "estourar" na tela.
  /// - Se a API responder com um status de erro (fora da faixa 200-299),
  ///   lança uma exceção com a mensagem vinda do backend (`data['erro']`),
  ///   que é exatamente a mensagem que os Services do Flask produzem
  ///   (ex.: "Não há vagas disponíveis para esta palestra.").
  static Future<dynamic> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    late http.Response response;

    try {
      if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'PUT') {
        response = await http.put(uri, headers: headers, body: jsonEncode(body));
      } else {
        response = await http.get(uri, headers: headers);
      }
    } catch (_) {
      throw Exception('Servidor indisponível. Verifique a API Flask.');
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {};
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data is Map && data['erro'] != null
          ? data['erro'].toString()
          : 'Não foi possível concluir a operação.');
    }
    return data;
  }

  /// Autentica o usuário (`POST /api/auth/login`) e devolve os dados do
  /// usuário autenticado, usados para iniciar a sessão local do app.
  /// Também guarda o token, que passa a ir nas próximas requisições.
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final data = await request(
      '/api/auth/login',
      method: 'POST',
      body: {'email': email, 'senha': senha},
    );
    token = data['token'];
    return Map<String, dynamic>.from(data['usuario']);
  }

  /// Cadastra uma nova conta (`POST /api/usuarios`, rota pública) e
  /// devolve os dados do usuário criado (F01, RF01).
  ///
  /// Não envia `tipo_usuario`: o backend cria sempre um participante
  /// (P01). Não faz login: depois do cadastro, a tela chama `login` com o
  /// mesmo e-mail e senha para receber o token.
  static Future<Map<String, dynamic>> cadastrar(
    String nome,
    String email,
    String senha,
  ) async {
    final data = await request(
      '/api/usuarios',
      method: 'POST',
      body: {'nome': nome, 'email': email, 'senha': senha},
    );
    return Map<String, dynamic>.from(data);
  }

  /// Lista todos os eventos disponíveis (`GET /api/eventos`).
  static Future<List<dynamic>> eventos() async =>
      List<dynamic>.from(await request('/api/eventos'));

  /// Lista a programação (palestras) de um evento, com filtro opcional por
  /// tema (`GET /api/palestras?id_evento=...&tema=...`).
  static Future<List<dynamic>> programacao(int eventoId, {String? tema}) async {
    final filtro = tema == null || tema.trim().isEmpty
        ? ''
        : '&tema=${Uri.encodeQueryComponent(tema)}';
    return List<dynamic>.from(
      await request('/api/palestras?id_evento=$eventoId$filtro'),
    );
  }

  /// Busca os detalhes de uma palestra, já com as flags do usuário logado
  /// (`GET /api/palestras/<id>`). Desde a P01, a API descobre o usuário
  /// pelo token; o `?id_usuario=` ainda enviado é ignorado por ela.
  static Future<Map<String, dynamic>> palestra(int id, int usuarioId) async =>
      Map<String, dynamic>.from(
        await request('/api/palestras/$id?id_usuario=$usuarioId'),
      );

  /// Lista a agenda pessoal do usuário: as palestras em que ele está
  /// inscrito (`GET /api/eventos/<id_usuario>/agenda`).
  static Future<List<dynamic>> agenda(int usuarioId) async =>
      List<dynamic>.from(await request('/api/eventos/$usuarioId/agenda'));

  /// Lista os favoritos do usuário, já com os dados da palestra embutidos
  /// (`GET /api/favoritos/usuario/<id>`).
  static Future<List<dynamic>> favoritos(int usuarioId) async =>
      List<dynamic>.from(await request('/api/favoritos/usuario/$usuarioId'));

  /// Lista as notificações/lembretes do usuário
  /// (`GET /api/notificacoes/usuario/<id>`).
  static Future<List<dynamic>> notificacoes(int usuarioId) async =>
      List<dynamic>.from(
        await request('/api/notificacoes/usuario/$usuarioId'),
      );

  /// Inscreve o usuário em uma palestra (`POST /api/inscricoes`).
  static Future<void> inscrever(int usuarioId, int palestraId) async {
    await request(
      '/api/inscricoes',
      method: 'POST',
      body: {'id_usuario': usuarioId, 'id_palestra': palestraId},
    );
  }

  /// Cancela a inscrição do usuário em uma palestra
  /// (`DELETE /api/inscricoes`), devolvendo a vaga.
  static Future<void> cancelarInscricao(int usuarioId, int palestraId) async {
    await request(
      '/api/inscricoes',
      method: 'DELETE',
      body: {'id_usuario': usuarioId, 'id_palestra': palestraId},
    );
  }

  /// Adiciona (`POST`) ou remove (`DELETE`) uma palestra dos favoritos do
  /// usuário em `/api/favoritos`, conforme o parâmetro `adicionar`.
  static Future<void> alterarFavorito(
    int usuarioId,
    int palestraId,
    bool adicionar,
  ) async {
    await request(
      '/api/favoritos',
      method: adicionar ? 'POST' : 'DELETE',
      body: {'id_usuario': usuarioId, 'id_palestra': palestraId},
    );
  }

  /// Ativa (`POST`) ou desativa (`DELETE`) o lembrete de uma palestra em
  /// `/api/lembretes`, conforme o parâmetro `ativar`.
  static Future<void> alterarLembrete(
    int usuarioId,
    int palestraId,
    bool ativar,
  ) async {
    await request(
      '/api/lembretes',
      method: ativar ? 'POST' : 'DELETE',
      body: {'id_usuario': usuarioId, 'id_palestra': palestraId},
    );
  }

  /// Lista as avaliações de uma palestra, da mais recente para a mais
  /// antiga, já com o nome de quem avaliou
  /// (`GET /api/avaliacoes/palestra/<id>`, F06).
  static Future<List<dynamic>> avaliacoes(int palestraId) async =>
      List<dynamic>.from(await request('/api/avaliacoes/palestra/$palestraId'));

  /// Avalia uma palestra (`POST /api/avaliacoes`, F06 e F07). O autor é
  /// o usuário do token. O backend recusa quem não está inscrito, quem
  /// avalia antes de a palestra começar e uma segunda avaliação.
  static Future<void> criarAvaliacao(int palestraId, int nota, String? comentario) async {
    await request(
      '/api/avaliacoes',
      method: 'POST',
      body: {'id_palestra': palestraId, 'nota_estrelas': nota, 'comentario': comentario},
    );
  }

  /// Muda a nota e o comentário de uma avaliação do próprio usuário
  /// (`PUT /api/avaliacoes/<id>`).
  static Future<void> atualizarAvaliacao(int avaliacaoId, int nota, String? comentario) async {
    await request(
      '/api/avaliacoes/$avaliacaoId',
      method: 'PUT',
      body: {'nota_estrelas': nota, 'comentario': comentario},
    );
  }

  /// Exclui uma avaliação do próprio usuário (`DELETE /api/avaliacoes/<id>`).
  static Future<void> excluirAvaliacao(int avaliacaoId) async {
    await request('/api/avaliacoes/$avaliacaoId', method: 'DELETE');
  }
}
