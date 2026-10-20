import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';

/// Tela de login.
///
/// Envia email e senha para `POST /api/auth/login` através do
/// `ApiService.login`. Em caso de sucesso, navega (substituindo a tela
/// atual, para o usuário não poder "voltar" ao login com o botão do
/// celular) para o `AppShell`, levando o ID e o nome do usuário logado.
///
/// Visual: segue a versão clara do design de referência — fundo claro,
/// campos brancos com borda suave e botão de ação em azul-marinho sólido,
/// com os ícones sociais (Google/Facebook/GitHub) que já existiam como
/// assets do projeto, mantidos apenas como identidade visual (o login
/// social em si não foi solicitado nem implementado no backend).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(text: 'ana.silva@email.com');
  final senha = TextEditingController(text: 'hash123');
  bool carregando = false;
  bool senhaVisivel = false;

  Future<void> entrar() async {
    setState(() => carregando = true);
    try {
      final usuario = await ApiService.login(email.text, senha.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AppShell(
            usuarioId: usuario['id_usuario'],
            nomeUsuario: usuario['nome'],
          ),
        ),
      );
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.event_available, size: 56, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text(
                  'FLUXO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 30,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: senha,
                  obscureText: !senhaVisivel,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(senhaVisivel ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => senhaVisivel = !senhaVisivel),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FilledButton(
                  onPressed: carregando ? null : entrar,
                  child: carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ou entre com',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconeSocial('assets/images/faceIcon.png'),
                    const SizedBox(width: 18),
                    _iconeSocial('assets/images/googleIcon.png'),
                    const SizedBox(width: 18),
                    _iconeSocial('assets/images/gitIcon.png'),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Use os dados de Ana Silva do banco oficial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ícone social meramente decorativo (reaproveita os assets já existentes
  /// no projeto), reproduzindo a fileira de ícones da tela de login do
  /// design de referência.
  Widget _iconeSocial(String asset) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borda),
      ),
      child: Image.asset(asset, width: 22, height: 22),
    );
  }

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }
}
