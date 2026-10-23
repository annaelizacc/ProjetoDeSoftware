import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cabecalho_tela.dart';
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
class NotificacoesPage extends StatefulWidget {
  final int usuarioId;

  const NotificacoesPage({super.key, required this.usuarioId});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  late Future<List<dynamic>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = ApiService.notificacoes(widget.usuarioId);
  }

  /// O `setState` usa chaves para não devolver o `Future` (veja o
  /// `recarregar` do painel do organizador).
  Future<void> recarregar() async {
    setState(() {
      futuro = ApiService.notificacoes(widget.usuarioId);
    });
    await futuro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CabecalhoTela(titulo: 'Avisos'),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                // `AlwaysScrollableScrollPhysics`: com a lista vazia ou
                // curta, ainda dá para puxar para baixo e recarregar.
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
                            for (final item in lista)
                              _ItemAviso(dados: Map<String, dynamic>.from(item)),
                          ],
                        ),
                );
              },
            ),
          ),
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
