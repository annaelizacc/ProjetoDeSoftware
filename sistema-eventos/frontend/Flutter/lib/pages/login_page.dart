import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/marca_texto.dart';
import '../widgets/tela_acesso.dart';
import 'app_shell.dart';
import 'cadastro_page.dart';

/// Tela de login.
///
/// Envia email e senha para `POST /api/auth/login` através do
/// `ApiService.login`. Em caso de sucesso, navega (substituindo a tela
/// atual, para o usuário não poder "voltar" ao login com o botão do
/// celular) para o `AppShell`, levando o ID, o nome e o perfil do usuário
/// logado (se é organizador, para o Perfil mostrar a área do organizador).
/// Quem ainda não tem conta abre a `CadastroPage` pelo link "Criar conta"
/// (F01).
///
/// Visual: prancha "Login" do canvas, com o fundo compartilhado das telas
/// de acesso (`widgets/tela_acesso.dart`). O botão "Continuar com Google"
/// e o link "Esqueci minha senha" do canvas ainda não existem no backend,
/// por isso ficam de fora (o Google é a F18).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final senha = TextEditingController();
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
            ehOrganizador: usuario['tipo_usuario'] == 'organizador',
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
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final textoCorrido = tema.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    return FundoAcesso(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: LogoFluxo()),
          const SizedBox(height: 8),
          // Slogan com o marca-texto. O fundo da tela já é Céu, então o
          // grifo usa a cor dos cards, como no canvas.
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              text: 'Seu evento, ',
              style: textoCorrido,
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: MarcaTexto('sem desencontros', estilo: textoCorrido, cor: cores.surface),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Entrar', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 14),
          CampoAcesso(
            rotulo: 'E-MAIL',
            dica: 'seu@email.com',
            controller: email,
            teclado: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          CampoAcesso(
            rotulo: 'SENHA',
            dica: 'Sua senha',
            controller: senha,
            esconderTexto: !senhaVisivel,
            sufixo: IconButton(
              tooltip: senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
              icon: Icon(senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => senhaVisivel = !senhaVisivel),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: carregando ? null : entrar,
            child: carregando
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: cores.onPrimary, strokeWidth: 2),
                  )
                : const Text('Entrar'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ainda não tem conta?', style: tema.textTheme.bodySmall?.copyWith(color: cores.onSurface)),
              // `push` (e não `pushReplacement`): o login continua embaixo
              // do cadastro, e o "Entrar" do cadastro só precisa voltar.
              // Fica desativado durante o login: se o cadastro abrisse
              // nessa hora, o app trocaria o cadastro (e não o login) pelo
              // Início, e o "voltar" levaria ao login com a sessão aberta.
              TextButton(
                onPressed: carregando
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CadastroPage()),
                        ),
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }
}
