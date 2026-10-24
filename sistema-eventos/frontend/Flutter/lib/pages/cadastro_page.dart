import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/tela_acesso.dart';
import 'app_shell.dart';

/// Mesmos números usados pelo backend (`TAMANHO_MINIMO_SENHA` e
/// `TAMANHO_MAXIMO_SENHA`, na Model `backend/models/usuario.py`). A tela
/// confere antes só para avisar mais rápido; quem garante a regra é o
/// backend.
const tamanhoMinimoSenha = 8;
const tamanhoMaximoSenha = 16;

/// Mesmo molde de email do backend (`FORMATO_EMAIL`, em
/// `backend/services/usuario/validacoes_usuario.py`): algo sem espaço e
/// sem "@", um "@", algo, um ponto e algo (ex.: ana@email.com).
final formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Tela de cadastro de usuário (F01, RF01).
///
/// Aberta pelo link "Criar conta" da tela de login. Confere os campos no
/// próprio app (preenchidos, formato do e-mail, senha mínima e as duas
/// senhas iguais) e envia nome, e-mail e senha para `POST /api/usuarios`
/// (`ApiService.cadastrar`). Em caso de sucesso, já faz o login com os
/// mesmos dados (`ApiService.login`) e abre o `AppShell`, para a pessoa
/// não precisar digitar tudo de novo.
///
/// Os erros do backend (ex.: "Já existe um usuário cadastrado com este
/// email.") aparecem num SnackBar, como no login.
///
/// Visual: prancha "Cadastro (RF01)" do canvas, com o mesmo fundo do
/// login (`widgets/tela_acesso.dart`).
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final confirmarSenha = TextEditingController();
  bool carregando = false;
  // Cada campo de senha tem o seu "olho" (mostrar/ocultar), como no login.
  bool senhaVisivel = false;
  bool confirmarSenhaVisivel = false;

  /// Confere os campos antes de enviar. Devolve a mensagem do primeiro
  /// problema encontrado, ou `null` se estiver tudo certo.
  String? validar() {
    if (nome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        senha.text.isEmpty ||
        confirmarSenha.text.isEmpty) {
      return 'Preencha todos os campos.';
    }
    if (!formatoEmail.hasMatch(email.text.trim())) return 'Digite um e-mail válido.';
    if (senha.text.length < tamanhoMinimoSenha || senha.text.length > tamanhoMaximoSenha) {
      return 'A senha precisa ter de $tamanhoMinimoSenha a $tamanhoMaximoSenha caracteres.';
    }
    if (senha.text != confirmarSenha.text) return 'As senhas não são iguais.';
    return null;
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> criarConta() async {
    final problema = validar();
    if (problema != null) {
      mostrarMensagem(problema);
      return;
    }

    setState(() => carregando = true);
    try {
      await ApiService.cadastrar(nome.text.trim(), email.text.trim(), senha.text);
    } catch (erro) {
      if (mounted) {
        mostrarMensagem(erro.toString().replaceFirst('Exception: ', ''));
        setState(() => carregando = false);
      }
      return;
    }

    // A conta já existe a partir daqui. Se o login falhar (ex.: a conexão
    // caiu), a pessoa volta para o login em vez de tentar cadastrar de
    // novo, o que daria "Já existe um usuário cadastrado com este email.".
    try {
      final usuario = await ApiService.login(email.text.trim(), senha.text);
      if (!mounted) return;
      // `pushAndRemoveUntil` tira o login e o cadastro da pilha de telas:
      // o botão "voltar" do celular não leva de volta para eles.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AppShell(
            usuarioId: usuario['id_usuario'],
            nomeUsuario: usuario['nome'],
            emailUsuario: usuario['email'] ?? '',
            ehOrganizador: usuario['tipo_usuario'] == 'organizador',
          ),
        ),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      mostrarMensagem('Conta criada. Não foi possível entrar agora: faça o login.');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return FundoAcesso(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: LogoFluxo(tamanho: 30)),
          const SizedBox(height: 16),
          Text('Criar conta', style: tema.textTheme.headlineSmall),
          const SizedBox(height: 14),
          CampoAcesso(rotulo: 'NOME', dica: 'Seu nome completo', controller: nome),
          const SizedBox(height: 12),
          CampoAcesso(
            rotulo: 'E-MAIL',
            dica: 'seu@email.com',
            controller: email,
            teclado: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          CampoAcesso(
            rotulo: 'SENHA',
            dica: 'Crie uma senha',
            controller: senha,
            esconderTexto: !senhaVisivel,
            sufixo: IconButton(
              tooltip: senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
              icon: Icon(senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => senhaVisivel = !senhaVisivel),
            ),
          ),
          const SizedBox(height: 12),
          CampoAcesso(
            rotulo: 'CONFIRMAR SENHA',
            dica: 'Repita a senha',
            controller: confirmarSenha,
            esconderTexto: !confirmarSenhaVisivel,
            sufixo: IconButton(
              tooltip: confirmarSenhaVisivel ? 'Esconder senha' : 'Mostrar senha',
              icon: Icon(
                confirmarSenhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => confirmarSenhaVisivel = !confirmarSenhaVisivel),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A senha precisa ter de $tamanhoMinimoSenha a $tamanhoMaximoSenha caracteres.',
            style: tema.textTheme.bodySmall?.copyWith(color: cores.onSurface),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: carregando ? null : criarConta,
            child: carregando
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: cores.onPrimary, strokeWidth: 2),
                  )
                : const Text('Criar conta'),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Já tem conta?', style: tema.textTheme.bodySmall?.copyWith(color: cores.onSurface)),
              // Volta para o login, que continua aberto embaixo do cadastro.
              // Fica desativado durante o envio: sair no meio deixaria a
              // conta criada e o login feito sem a pessoa ver.
              TextButton(
                onPressed: carregando ? null : () => Navigator.pop(context),
                child: const Text('Entrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    confirmarSenha.dispose();
    super.dispose();
  }
}
