import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controle do modo claro/escuro do app (F11, RF20).
///
/// FINALIDADE DESTE ARQUIVO:
/// Guardar qual tema está em uso, avisar o app quando ele muda e salvar a
/// escolha no próprio celular, para ela continuar valendo quando o app
/// for aberto de novo. Pela decisão D01, essa preferência NÃO vai para o
/// banco de dados.
///
/// COMO FUNCIONA:
/// - `modo` é um `ValueNotifier`, uma "caixinha" do Flutter que guarda um
///   valor e avisa quem estiver ouvindo quando ele muda. O `MaterialApp`
///   (em `main.dart`) ouve essa caixinha e se redesenha com o tema novo;
/// - a escolha é salva com o pacote `shared_preferences`, que guarda
///   pares chave → valor no armazenamento do aparelho.
class ControleTema {
  ControleTema._();

  /// Nome com que a escolha fica salva no celular.
  static const _chave = 'tema_escuro';

  /// Tema em uso agora. Começa no claro até `carregar()` ler a escolha
  /// salva.
  static final modo = ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Lê a escolha salva no celular. Chamado uma vez, ao abrir o app.
  static Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final escuroSalvo = prefs.getBool(_chave) ?? false;
    modo.value = escuroSalvo ? ThemeMode.dark : ThemeMode.light;
  }

  /// Liga ou desliga o modo escuro e salva a escolha no celular.
  static Future<void> definirEscuro(bool ligado) async {
    modo.value = ligado ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, ligado);
  }
}
