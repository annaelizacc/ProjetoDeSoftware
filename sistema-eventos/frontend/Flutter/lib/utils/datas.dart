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
String horaCurta(DateTime data) =>
    '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';

/// Dia da semana e do mês, ex.: `QUA 10`.
String diaCurto(DateTime data) => '${diasSemana[data.weekday - 1]} ${data.day.toString().padLeft(2, '0')}';
