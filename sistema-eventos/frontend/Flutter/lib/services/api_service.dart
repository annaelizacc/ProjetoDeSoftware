import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Aviso de choque de horário (F16) devolvido pela inscrição (HTTP 409).
///
/// Não é um erro comum: a pessoa já tem inscrição em uma palestra no mesmo
/// horário, e o app precisa perguntar se ela quer se inscrever mesmo
/// assim. Por isso é uma exceção própria, separada da `Exception` comum:
/// a tela reconhece o tipo (`on ChoqueDeHorarioException`) e mostra o
/// aviso, em vez de só um SnackBar com a mensagem.
class ChoqueDeHorarioException implements Exception {
  final String mensagem;

  /// A palestra em que a pessoa já está inscrita (JSON da API).
  final Map<String, dynamic> palestraConflitante;

  ChoqueDeHorarioException(this.mensagem, this.palestraConflitante);

  @override
  String toString() => mensagem;
}

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
        response =
            await http.post(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'DELETE') {
        response =
            await http.delete(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'PUT') {
        response =
            await http.put(uri, headers: headers, body: jsonEncode(body));
      } else {
        response = await http.get(uri, headers: headers);
      }
    } catch (_) {
      throw Exception('Servidor indisponível. Verifique a API Flask.');
    }
    return _lerResposta(response);
  }

  /// Lê o JSON da resposta e lança uma exceção com a mensagem do backend
  /// quando o status é de erro. Usado pelo `request` e pelo envio de
  /// imagem, para os dois tratarem os erros do mesmo jeito.
  static dynamic _lerResposta(http.Response response) {
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {};
    }
    if (response.statusCode == 409 && data is Map && data['choque_horario'] == true) {
      throw ChoqueDeHorarioException(
        data['erro'].toString(),
        Map<String, dynamic>.from(data['palestra_conflitante']),
      );
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
  ///
  /// Se a pessoa já tem inscrição em outra palestra no mesmo horário, a
  /// API responde 409 e este método lança `ChoqueDeHorarioException`
  /// (F16). Depois que a pessoa confirma no aviso, a tela chama de novo
  /// com `confirmarChoque: true`, e a inscrição é feita.
  static Future<void> inscrever(int usuarioId, int palestraId, {bool confirmarChoque = false}) async {
    await request(
      '/api/inscricoes',
      method: 'POST',
      body: {
        'id_usuario': usuarioId,
        'id_palestra': palestraId,
        if (confirmarChoque) 'confirmar_choque': true,
      },
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

  /// Encerra a sessão (F17): apaga o token da memória. Não chama a API
  /// porque ela não guarda os tokens (o `POST /api/auth/logout` não faz
  /// nada no servidor): quem "sai" é o app. Limitação conhecida (P01): um
  /// token copiado antes continua valendo até vencer, em 8 horas.
  static void sair() => token = null;

  /// Eventos que o organizador logado gerencia (F08): os ligados a ele,
  /// ou todos, para o administrador (`GET /api/organizador/eventos`).
  static Future<List<dynamic>> meusEventos() async =>
      List<dynamic>.from(await request('/api/organizador/eventos'));

  /// Painel do organizador (F08): o evento, o resumo (palestras,
  /// inscrições, esgotadas, ocupação e média das avaliações) e o ranking
  /// das palestras (`GET /api/organizador/eventos/<id>/painel`).
  static Future<Map<String, dynamic>> painelOrganizador(int eventoId) async =>
      Map<String, dynamic>.from(
        await request('/api/organizador/eventos/$eventoId/painel'),
      );

  /// Lista quem está inscrito numa palestra, com nome e e-mail
  /// (`GET /api/organizador/palestras/<id>/inscritos`, só organizador).
  static Future<List<dynamic>> inscritosDaPalestra(int palestraId) async =>
      List<dynamic>.from(
        await request('/api/organizador/palestras/$palestraId/inscritos'),
      );

  /// O organizador remove a inscrição de uma pessoa, devolvendo a vaga
  /// (`DELETE /api/organizador/palestras/<id>/inscritos/<id_usuario>`).
  static Future<void> removerInscricao(int palestraId, int usuarioId) async {
    await request(
      '/api/organizador/palestras/$palestraId/inscritos/$usuarioId',
      method: 'DELETE',
    );
  }

  /// Envia um comunicado (F09,
  /// `POST /api/organizador/eventos/<id>/comunicados`): sem `palestraId`,
  /// para todos os inscritos no evento; com ele, só para os inscritos
  /// dessa palestra. Devolve quantas pessoas receberam.
  static Future<int> enviarComunicado(int eventoId, String mensagem, {int? palestraId}) async {
    final resposta = await request(
      '/api/organizador/eventos/$eventoId/comunicados',
      method: 'POST',
      body: {'mensagem': mensagem, 'id_palestra': palestraId},
    );
    return resposta['total_destinatarios'] as int;
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

  /// Lista os patrocinadores de um evento, em ordem alfabética
  /// (`GET /api/patrocinadores?id_evento=<id>`, F10).
  static Future<List<dynamic>> patrocinadores(int eventoId) async =>
      List<dynamic>.from(await request('/api/patrocinadores?id_evento=$eventoId'));

  // ---------------------------------------------------------------------
  // Cadastros do organizador (F14)
  // ---------------------------------------------------------------------

  /// Tipos e tamanho aceitos no envio de imagem. Os mesmos do backend
  /// (`SalvarImagemService`): o aviso aparece embaixo de cada campo de
  /// imagem, para o organizador saber antes de escolher o arquivo.
  static const tiposDeImagem = 'PNG, JPG OU WEBP · ATÉ 5 MB';

  /// Endereço para mostrar uma imagem enviada (`GET /uploads/<nome>`).
  static String urlImagem(String nome) => '$baseUrl/uploads/$nome';

  /// Envia uma imagem escolhida no aparelho (`POST /api/uploads`) e
  /// devolve o nome com que o backend a salvou. O cadastro grava depois
  /// esse nome (ex.: `imagem_mapa`, `foto`, `logo`).
  ///
  /// A imagem vai numa requisição "multipart", o formato usado para
  /// mandar arquivos. `fromBytes` lê o conteúdo do arquivo e funciona
  /// tanto no celular quanto na web (na web não existe caminho de
  /// arquivo, por isso não dá para usar `fromPath`).
  static Future<String> enviarImagem(XFile arquivo) async {
    final pedido = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/uploads'));
    if (token != null) pedido.headers['Authorization'] = 'Bearer $token';
    pedido.files.add(http.MultipartFile.fromBytes(
      'imagem',
      await arquivo.readAsBytes(),
      filename: arquivo.name,
    ));

    late http.Response response;
    try {
      response = await http.Response.fromStream(await pedido.send());
    } catch (_) {
      throw Exception('Servidor indisponível. Verifique a API Flask.');
    }
    return _lerResposta(response)['arquivo'] as String;
  }

  /// Cria um evento (`POST /api/eventos`). O responsável é o organizador
  /// do token. Devolve o evento criado, com o `id_evento`.
  static Future<Map<String, dynamic>> criarEvento(Map<String, dynamic> dados) async =>
      Map<String, dynamic>.from(await request('/api/eventos', method: 'POST', body: dados));

  /// Altera um evento (`PUT /api/eventos/<id>`).
  static Future<void> atualizarEvento(int eventoId, Map<String, dynamic> dados) async {
    await request('/api/eventos/$eventoId', method: 'PUT', body: dados);
  }

  /// Apaga um evento inteiro (`DELETE /api/eventos/<id>`). O backend pede
  /// a senha da pessoa logada para confirmar.
  static Future<void> removerEvento(int eventoId, String senha) async {
    await request('/api/eventos/$eventoId', method: 'DELETE', body: {'senha': senha});
  }

  /// Planta do evento (`GET /api/eventos/<id>/planta`), ou `null` se o
  /// evento ainda não tem planta.
  static Future<Map<String, dynamic>?> planta(int eventoId) async {
    final dados = await request('/api/eventos/$eventoId/planta');
    return dados is Map ? Map<String, dynamic>.from(dados) : null;
  }

  /// Cria ou atualiza a planta do evento (`PUT /api/eventos/<id>/planta`).
  static Future<void> salvarPlanta(int eventoId, String? imagem, String? descricao) async {
    await request(
      '/api/eventos/$eventoId/planta',
      method: 'PUT',
      body: {'imagem_mapa': imagem, 'descricao': descricao},
    );
  }

  /// Locais de um evento, com o passo a passo da rota
  /// (`GET /api/locais?id_evento=<id>`, F04).
  static Future<List<dynamic>> locais(int eventoId) async =>
      List<dynamic>.from(await request('/api/locais?id_evento=$eventoId'));

  /// Palestrantes de um evento (`GET /api/palestrantes?id_evento=<id>`,
  /// F05). Com `busca`, só os que têm o texto no nome (RF13).
  static Future<List<dynamic>> palestrantes(int eventoId, {String? busca}) async {
    final filtro = busca == null || busca.trim().isEmpty
        ? ''
        : '&busca=${Uri.encodeQueryComponent(busca.trim())}';
    return List<dynamic>.from(await request('/api/palestrantes?id_evento=$eventoId$filtro'));
  }

  /// Dados de um palestrante (`GET /api/palestrantes/<id>`, RF14): nome,
  /// foto, descrição e rede social. Usado no perfil aberto pelos detalhes
  /// da palestra.
  static Future<Map<String, dynamic>> palestrante(int id) async =>
      Map<String, dynamic>.from(await request('/api/palestrantes/$id'));

  /// Cria, altera ou remove um registro de um cadastro do organizador
  /// (F14). `recurso` é o caminho da API sem o `/api/` (ex.: `locais`,
  /// `palestrantes`, `palestras`, `patrocinadores`), porque as quatro
  /// rotas seguem o mesmo padrão:
  /// - sem `id`: `POST /api/<recurso>` (cria);
  /// - com `id`: `PUT /api/<recurso>/<id>` (altera).
  static Future<void> salvarCadastro(String recurso, int? id, Map<String, dynamic> dados) async {
    if (id == null) {
      await request('/api/$recurso', method: 'POST', body: dados);
    } else {
      await request('/api/$recurso/$id', method: 'PUT', body: dados);
    }
  }

  /// Remove um registro de um cadastro (`DELETE /api/<recurso>/<id>`).
  static Future<void> removerCadastro(String recurso, int id) async {
    await request('/api/$recurso/$id', method: 'DELETE');
  }
}
