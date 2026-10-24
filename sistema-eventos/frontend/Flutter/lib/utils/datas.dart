/// Nomes curtos de dias e meses, no formato dos rótulos do canvas
/// (JetBrains Mono, maiúsculo): `QUA 10`, `SEX 23 OUT · 08:30`.
///
/// Ficam aqui, e não em uma tela, porque Início, Programação, Agenda e
/// Favoritos mostram datas no mesmo formato. O índice segue o `DateTime`
/// do Dart: `weekday` vai de 1 (segunda) a 7 (domingo) e `month` de 1 a
/// 12, por isso o `- 1` ao usar as listas.
const diasSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
const meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];

/// Hora no formato `09:00`.
String horaCurta(DateTime data) => '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';

/// Dia da semana e do mês, ex.: `QUA 10`.
String diaCurto(DateTime data) => '${diasSemana[data.weekday - 1]} ${data.day.toString().padLeft(2, '0')}';

/// Período do evento como no canvas, usado no Início e em Escolher
/// evento: `10—12 SET 2026` no mesmo mês, `30 SET—02 OUT 2026` em meses
/// diferentes e `30 DEZ 2026—02 JAN 2027` em anos diferentes.
String periodoEvento(String? inicioTexto, String? fimTexto) {
  final inicio = DateTime.tryParse(inicioTexto ?? '');
  final fim = DateTime.tryParse(fimTexto ?? '');
  if (inicio == null) return 'DATA A DEFINIR';
  String dia(DateTime d) => d.day.toString().padLeft(2, '0');
  final mesInicio = meses[inicio.month - 1];
  final mesmoDia = fim != null && inicio.year == fim.year && inicio.month == fim.month && inicio.day == fim.day;
  if (fim == null || mesmoDia) {
    return '${dia(inicio)} $mesInicio ${inicio.year}';
  }
  final mesFim = meses[fim.month - 1];
  final comeco = inicio.year != fim.year
      ? '${dia(inicio)} $mesInicio ${inicio.year}'
      : (inicio.month == fim.month ? dia(inicio) : '${dia(inicio)} $mesInicio');
  return '$comeco—${dia(fim)} $mesFim ${fim.year}';
}
