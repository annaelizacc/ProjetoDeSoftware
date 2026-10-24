import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_dados;
import 'package:timezone/timezone.dart' as tz;

import '../models/palestra.dart';
import '../pages/palestra_details_page.dart';
import 'api_service.dart';

/// Service (do lado do Flutter): aviso real de início das palestras (F02,
/// RF09).
///
/// O backend só guarda QUEM ativou o lembrete (tabela `notificacao`). Quem
/// avisa na hora certa é o próprio celular: este service agenda uma
/// **notificação local** (pacote `flutter_local_notifications`), que
/// aparece na barra do celular 10 minutos antes do início, mesmo com o
/// app fechado. "Local" quer dizer que o aviso é criado e disparado pelo
/// próprio aparelho, sem o servidor mandar nada na hora.
///
/// Regras (decididas em 20/10/2026, ver `PENDENCIAS.md`):
/// - só para quem ativou o lembrete, sempre 10 minutos antes;
/// - faltando menos de 10 minutos, o aviso aparece na hora ("começa em 4
///   minutos"); palestra já começada não recebe aviso;
/// - desativar o lembrete ou cancelar a inscrição cancela o aviso;
/// - ao entrar no app, os avisos são refeitos a partir dos lembretes do
///   backend (`sincronizar`), para acompanhar mudanças de horário;
/// - tocar no aviso abre os detalhes da palestra.
///
/// Só funciona no Android. Na web (Chrome), os métodos não fazem nada: o
/// lembrete continua gravado e aparece na aba Avisos.
class LembreteService {
  LembreteService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Antecedência do aviso.
  static const antecedencia = Duration(minutes: 10);

  /// Chave do `Navigator` do app, passada ao `MaterialApp` em `main.dart`.
  /// Permite abrir os detalhes da palestra a partir do toque no aviso,
  /// que acontece fora de qualquer tela.
  static final navegador = GlobalKey<NavigatorState>();

  /// Pessoa logada (definida em `sincronizar`, depois do login).
  static int? _usuarioId;

  /// Palestra de um aviso tocado com o app fechado. Como o app abre na
  /// tela de login, os detalhes só abrem depois que a pessoa entra.
  static int? _palestraPendente;

  static bool get _suportado => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Prepara o plugin. Chamado uma vez, no `main`.
  static Future<void> iniciar() async {
    if (!_suportado) return;
    // Base de fusos horários do pacote `timezone`, que o agendamento usa.
    tz_dados.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (resposta) => _abrirPalestra(resposta.payload),
    );
    // O app foi aberto tocando num aviso (estava fechado)?
    final abertura = await _plugin.getNotificationAppLaunchDetails();
    if (abertura?.didNotificationLaunchApp ?? false) {
      _palestraPendente = int.tryParse(abertura!.notificationResponse?.payload ?? '');
    }
  }

  /// Depois do login: pede a permissão de notificação (Android 13 ou
  /// mais novo pergunta uma vez), refaz os avisos a partir dos lembretes
  /// do backend e abre a palestra de um aviso tocado com o app fechado.
  static Future<void> sincronizar(int usuarioId) async {
    _usuarioId = usuarioId;
    if (!_suportado) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Apaga todos os agendamentos e refaz: assim um horário que mudou
      // no backend também muda no aviso.
      await _plugin.cancelAll();
      final avisos = await ApiService.notificacoes(usuarioId);
      final ids = {
        for (final aviso in avisos)
          if (aviso['tipo_notificacao'] == 'lembrete' && aviso['id_palestra'] != null) aviso['id_palestra'] as int,
      };
      for (final id in ids) {
        final palestra = Palestra.fromJson(Map<String, dynamic>.from(await ApiService.palestra(id, usuarioId)));
        await agendar(palestra);
      }
    } catch (_) {
      // Sem conexão ou sem permissão: o app segue funcionando, só sem os
      // avisos no celular.
    }

    if (_palestraPendente != null) {
      final id = _palestraPendente;
      _palestraPendente = null;
      _abrirPalestra('$id');
    }
  }

  /// Agenda o aviso de uma palestra (ao ativar o lembrete).
  static Future<void> agendar(Palestra p) async {
    if (!_suportado) return;
    final inicio = p.inicio == null ? null : DateTime.tryParse(p.inicio!);
    if (inicio == null) return;
    final agora = DateTime.now();
    if (!inicio.isAfter(agora)) return; // Já começou: sem aviso.

    final detalhes = NotificationDetails(
      android: AndroidNotificationDetails(
        'inicio_palestras',
        'Início das palestras',
        channelDescription: 'Aviso 10 minutos antes das palestras com lembrete ativo.',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    final quando = inicio.subtract(antecedencia);

    if (!quando.isAfter(agora)) {
      // Faltam menos de 10 minutos: avisa agora, com o tempo que falta.
      // Arredonda para cima: 9 min e 30 s viram "10 minutos".
      final minutos = (inicio.difference(agora).inSeconds / 60).ceil();
      await _plugin.show(
        id: p.id,
        title: p.titulo,
        body: 'Começa em $minutos ${minutos == 1 ? 'minuto' : 'minutos'}${_onde(p)}',
        notificationDetails: detalhes,
        payload: '${p.id}',
      );
      return;
    }

    await _plugin.zonedSchedule(
      id: p.id,
      title: p.titulo,
      body: 'Começa em 10 minutos${_onde(p)}',
      // `TZDateTime.from` guarda o mesmo instante do `DateTime` local.
      scheduledDate: tz.TZDateTime.from(quando, tz.UTC),
      notificationDetails: detalhes,
      // Agendamento "aproximado": o Android pode atrasar 1 ou 2 minutos
      // para economizar bateria. O exato exige uma permissão especial,
      // que o Android 14 nega por padrão para apps comuns.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '${p.id}',
    );
  }

  /// Cancela o aviso de uma palestra (ao desativar o lembrete ou cancelar
  /// a inscrição).
  static Future<void> cancelar(int palestraId) async {
    if (!_suportado) return;
    await _plugin.cancel(id: palestraId);
  }

  /// Local no texto do aviso ("· Sala A1"), no estilo dos rótulos do app.
  static String _onde(Palestra p) => p.sala == null ? '' : ' · ${p.sala}';

  static void _abrirPalestra(String? payload) {
    final id = int.tryParse(payload ?? '');
    if (id == null) return;
    if (_usuarioId == null) {
      // Ainda na tela de login: abre depois de entrar.
      _palestraPendente = id;
      return;
    }
    navegador.currentState?.push(
      MaterialPageRoute(builder: (_) => PalestraDetailsPage(usuarioId: _usuarioId!, palestraId: id)),
    );
  }
}
