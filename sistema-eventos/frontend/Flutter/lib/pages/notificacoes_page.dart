import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/datas.dart';
import '../widgets/cabecalho_aba.dart';
import '../widgets/rotulo_secao.dart';
import '../widgets/selo.dart';

/// Aba "Avisos" (RF09, RF18).
///
/// Lista as notificações do usuário, das mais recentes para as mais
/// antigas (`GET /api/notificacoes/usuario/<id>`, via
/// `ApiService.notificacoes`). Segue a prancha "Avisos" do canvas: cada
/// aviso numa linha, com o horário em JetBrains Mono à esquerda e, ao
/// lado, o selo do tipo e o texto, separados por linhas finas.
///
/// O selo depende de `tipo_notificacao`:
/// - `comunicado` (F09): `ORGANIZAÇÃO`, na cor Areia;
/// - `atencao` (ex.: inscrição removida pela organização): `ATENÇÃO`, na
///   cor de atenção;
/// - `lembrete`: `LEMBRETE`; os outros tipos: `INFO`. Os dois em contorno
///   discreto.
///
/// Embaixo do texto de um comunicado aparece de onde ele veio: o evento
/// (`SEMANA DE TECNOLOGIA`) ou, se foi só para os inscritos de uma
/// palestra, o evento e a palestra (`SEMANA DE TECNOLOGIA · BANCO DE
/// DADOS NA PRÁTICA`). Os outros avisos já citam a palestra no próprio
/// texto, então não repetem.
///
/// Puxar a lista para baixo busca de novo (para ver um comunicado que
/// acabou de chegar).
///
/// O cabeçalho é o das abas (`CabecalhoAba`). No canvas o rótulo é
/// `2 NOVOS · ATUALIZADO 08:30`; por enquanto só a hora da última busca
/// aparece (`ATUALIZADO 08:30`), porque o banco ainda não guarda se o
/// aviso foi lido. A contagem de novos entra na F21.
class NotificacoesPage extends StatefulWidget {
  final int usuarioId;

  const NotificacoesPage({super.key, required this.usuarioId});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  late Future<List<dynamic>> futuro;

  /// Quando a lista chegou do servidor pela última vez (rótulo
  /// `ATUALIZADO 08:30`). Fica `null` até a primeira busca dar certo.
  DateTime? atualizadoEm;

  @override
  void initState() {
    super.initState();
    futuro = buscar();
  }

  /// Busca os avisos e guarda a hora em que eles chegaram. O `then` roda
  /// antes de o `FutureBuilder` ser avisado, então quando a lista aparece
  /// a hora já está certa, sem precisar de outro `setState`.
  Future<List<dynamic>> buscar() {
    return ApiService.notificacoes(widget.usuarioId).then((lista) {
      atualizadoEm = DateTime.now();
      return lista;
    });
  }

  /// O `setState` usa chaves para não devolver o `Future` (veja o
  /// `recarregar` do painel do organizador).
  Future<void> recarregar() async {
    setState(() {
      futuro = buscar();
    });
    await futuro;
  }

  /// Rótulo acima do título: `CARREGANDO…` durante a busca, `SEM CONEXÃO`
  /// se ela falhou (para a hora antiga não parecer atualizada) e, depois,
  /// a hora da última busca que deu certo.
  String rotulo(bool carregando, bool falhou) {
    if (carregando) return 'Carregando…';
    if (falhou) return 'Sem conexão';
    final hora = atualizadoEm;
    return hora == null ? 'Seus avisos' : 'Atualizado ${horaCurta(hora)}';
  }

  @override
  Widget build(BuildContext context) {
    // O cabeçalho fica dentro do `FutureBuilder` porque o rótulo muda com
    // a busca (carregando ou a hora em que a lista chegou).
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: futuro,
        builder: (context, snapshot) {
          final carregando = snapshot.connectionState == ConnectionState.waiting;
          return Column(
            children: [
              CabecalhoAba(rotulo: rotulo(carregando, snapshot.hasError), titulo: 'Avisos'),
              const SizedBox(height: 8),
              Expanded(child: conteudo(snapshot, carregando)),
            ],
          );
        },
      ),
    );
  }

  /// A parte de baixo da tela: carregando, erro, lista vazia ou a lista.
  Widget conteudo(AsyncSnapshot<List<dynamic>> snapshot, bool carregando) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
            TextButton(onPressed: recarregar, child: const Text('Tentar de novo')),
          ],
        ),
      );
    }
    final lista = snapshot.data ?? [];
    // `AlwaysScrollableScrollPhysics`: com a lista vazia ou curta, ainda dá
    // para puxar para baixo e recarregar.
    return RefreshIndicator(
      onRefresh: recarregar,
      child: lista.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: const [Text('Nenhum aviso por enquanto.')],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                for (final item in lista) _ItemAviso(dados: Map<String, dynamic>.from(item)),
              ],
            ),
    );
  }
}

/// Um aviso da lista: horário, selo do tipo e texto.
class _ItemAviso extends StatelessWidget {
  final Map<String, dynamic> dados;

  const _ItemAviso({required this.dados});

  /// Texto e jeito do selo para cada `tipo_notificacao`.
  static (String, TipoSelo) _selo(String? tipo) => switch (tipo) {
        'comunicado' => ('Organização', TipoSelo.organizacao),
        'atencao' => ('Atenção', TipoSelo.alerta),
        'lembrete' => ('Lembrete', TipoSelo.neutro),
        _ => ('Info', TipoSelo.neutro),
      };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final (textoSelo, tipoSelo) = _selo(dados['tipo_notificacao']);
    final origem = dados['tipo_notificacao'] == 'comunicado'
        ? [dados['nome_evento'], dados['titulo_palestra']].whereType<String>().join(' · ')
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tema.colorScheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                quandoFoiEnviado(dados['data_envio']),
                style: TextStyle(
                  fontFamily: AppFontes.mono,
                  fontSize: 12,
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Selo(textoSelo, tipo: tipoSelo),
                const SizedBox(height: 6),
                Text(
                  dados['mensagem'] ?? '',
                  style: tema.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
                if (origem.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  RotuloSecao(origem),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mostra quando o aviso chegou, como no canvas: a hora (`08:00`) se foi
/// hoje, `ONTEM` se foi ontem e a data (`21/10`) nos outros dias. A
/// coluna tem 60px de largura: cabe até `21/10/25`.
///
/// O backend grava `data_envio` em UTC, sem dizer isso no texto (P06).
/// Por isso a data é lida como UTC (o `Z` no fim) e convertida para a
/// hora do celular com `toLocal()`; sem isso, o horário apareceria 3
/// horas adiantado no Brasil.
String quandoFoiEnviado(String? dataEnvio) {
  final data = dataEnvio == null ? null : DateTime.tryParse('${dataEnvio}Z')?.toLocal();
  if (data == null) return '';

  String doisDigitos(int n) => n.toString().padLeft(2, '0');
  final agora = DateTime.now();
  // Os dois dias são montados em UTC só para contar a diferença: em UTC
  // todo dia tem 24 horas, então o horário de verão não atrapalha a conta.
  final hoje = DateTime.utc(agora.year, agora.month, agora.day);
  final dia = DateTime.utc(data.year, data.month, data.day);
  final diasAtras = hoje.difference(dia).inDays;

  if (diasAtras == 0) return '${doisDigitos(data.hour)}:${doisDigitos(data.minute)}';
  if (diasAtras == 1) return 'ONTEM';
  final diaMes = '${doisDigitos(data.day)}/${doisDigitos(data.month)}';
  // De outro ano, mostra o ano também (`21/10/25`), para não parecer recente.
  return data.year == agora.year ? diaMes : '$diaMes/${doisDigitos(data.year % 100)}';
}
