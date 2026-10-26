import 'package:flutter/material.dart';
import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import '../../data/services/biometria_service.dart';

class DetalhesCancelamentoPagina extends StatefulWidget {
final AssinaturaModel assinatura;

const DetalhesCancelamentoPagina({
super.key,
required this.assinatura,
});

@override
State<DetalhesCancelamentoPagina> createState() =>
_DetalhesCancelamentoPaginaState();
}

class _DetalhesCancelamentoPaginaState
extends State<DetalhesCancelamentoPagina> {
final BiometriaService _biometriaService = BiometriaService();

bool _cancelamentoEmAndamento = false;

Future<void> _confirmarCancelamento() async {
if (_cancelamentoEmAndamento) return;

// 1. Confirmação antes da biometria.
final confirmou = await showDialog<bool>(
context: context,
barrierDismissible: false,
builder: (dialogContext) => AlertDialog(
backgroundColor: const Color(0xFFC8CEDC),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
title: const Text(
'Cancelar assinatura?',
style: TextStyle(
color: Color(0xFF1B2A4A),
fontWeight: FontWeight.bold,
),
),
content: Text(
'Deseja realmente cancelar ${widget.assinatura.nome}?\n\n'
'Esta é uma simulação acadêmica. Nenhum cartão real '
'será acessado e nenhuma cobrança real será realizada.',
style: const TextStyle(
color: Color(0xFF1B2A4A),
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext, false),
child: const Text('VOLTAR'),
),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFF1B2A4A),
foregroundColor: Colors.white,
),
onPressed: () => Navigator.pop(dialogContext, true),
child: const Text('CONTINUAR'),
),
],
),
);

if (!mounted || confirmou != true) return;

setState(() => _cancelamentoEmAndamento = true);

// 2. Validação biométrica.
bool autenticado = false;

try {
autenticado = await _biometriaService.autenticar();
} catch (e) {
debugPrint('Erro ao autenticar com biometria: $e');
}

if (!mounted) return;

if (!autenticado) {
setState(() => _cancelamentoEmAndamento = false);

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Biometria não confirmada. A assinatura continua ativa.',
),
backgroundColor: Color(0xFFB71C1C),
),
);

return;
}

// 3. Cancela no backend somente após a biometria.
bool cancelado = false;

try {
cancelado = await AssinaturasRepository.instance
    .cancelarAssinatura(widget.assinatura.id);
} catch (e) {
debugPrint('Erro ao cancelar assinatura: $e');
}

if (!mounted) return;

setState(() => _cancelamentoEmAndamento = false);

// 4. Apresenta o resultado.
if (cancelado) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Assinatura de ${widget.assinatura.nome} cancelada com sucesso!',
),
backgroundColor: const Color(0xFF1B2A4A),
),
);

Navigator.pop(context, true);
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Não foi possível cancelar a assinatura. Tente novamente.',
),
backgroundColor: Color(0xFFB71C1C),
),
);
}
}

@override
Widget build(BuildContext context) {
final item = widget.assinatura;
final hoje = DateTime.now();
final dataVenc = item.dataVencimento;

final diferencaDias =
DateTime(dataVenc.year, dataVenc.month, dataVenc.day)
    .difference(DateTime(hoje.year, hoje.month, hoje.day))
    .inDays;

final String textoDias = diferencaDias < 0
? 'venceu há ${-diferencaDias} dia(s)'
    : diferencaDias == 0
? 'vence hoje'
    : 'vence em $diferencaDias dia(s)';

final dataVencFormatada =
'${dataVenc.day.toString().padLeft(2, '0')}/'
'${dataVenc.month.toString().padLeft(2, '0')}/'
'${dataVenc.year}';

final valorFormatado =
item.valor.toStringAsFixed(2).replaceAll('.', ',');

return Scaffold(
backgroundColor: const Color(0xFFD3D3D3),
body: SingleChildScrollView(
child: Column(
children: [
Container(
padding: const EdgeInsets.only(
top: 50,
left: 16,
right: 16,
bottom: 20,
),
decoration: const BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Color(0xFF2C436D),
Color(0xFF7E9BB8),
Color(0xFFD3D3D3),
],
stops: [0.0, 0.6, 1.0],
),
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
IconButton(
icon: const Icon(
Icons.arrow_back,
color: Color(0xFF1B2A4A),
size: 28,
),
onPressed: _cancelamentoEmAndamento
? null
    : () => Navigator.pop(context),
),
Image.asset(
'assets/images/logo.png',
height: 38,
errorBuilder: (context, error, stackTrace) =>
const Text(
'Assinei\n& Esqueci',
textAlign: TextAlign.end,
style: TextStyle(
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
fontSize: 11,
),
),
),
],
),
const SizedBox(height: 10),
const Text(
'DETALHES DO CANCELAMENTO',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
letterSpacing: 1.0,
),
),
],
),
),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20),
child: Column(
children: [
// Serviço a cancelar
_cardContainer(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'SERVIÇO A CANCELAR:',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
),
),
const SizedBox(height: 12),
Row(
children: [
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: item.corIcone.withAlpha(30),
shape: BoxShape.circle,
),
child: Icon(
item.icone,
color: item.corIcone,
size: 28,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
item.nome.toUpperCase(),
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
),
),
const SizedBox(height: 2),
Text(
'R\$ $valorFormatado/mês',
style: const TextStyle(
fontSize: 12,
color: Colors.black87,
),
),
],
),
),
],
),
const SizedBox(height: 12),
Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
vertical: 8,
horizontal: 12,
),
decoration: BoxDecoration(
color: Colors.white.withAlpha(150),
borderRadius: BorderRadius.circular(10),
),
child: Text(
'Seu teste grátis $textoDias '
'($dataVencFormatada)',
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 11,
color: Colors.black54,
),
),
),
],
),
),
const SizedBox(height: 14),

// Método de pagamento demonstrativo
_cardContainer(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'MÉTODO DE PAGAMENTO:',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
),
),
const SizedBox(height: 10),
Row(
children: [
const Icon(
Icons.credit_card,
color: Color(0xFF2C436D),
size: 32,
),
const SizedBox(width: 12),
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'CARTÃO DE CRÉDITO',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
),
),
SizedBox(height: 2),
Text(
'VISA   ••• 1162',
style: TextStyle(
fontSize: 11,
color: Colors.black87,
),
),
],
),
),
],
),
],
),
),
const SizedBox(height: 14),

// Aviso sobre o cancelamento
_cardContainer(
child: const Text(
'AVISO: Cancelar o teste agora interromperá '
'o acesso imediatamente. Após o cancelamento, '
'não haverá novas cobranças.',
style: TextStyle(
fontSize: 11,
color: Colors.black87,
height: 1.3,
),
),
),
const SizedBox(height: 14),

OutlinedButton(
onPressed: _cancelamentoEmAndamento
? null
    : () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Redirecionamento para alterar método '
'ainda não implementado.',
),
),
);
},
style: OutlinedButton.styleFrom(
side: const BorderSide(
color: Color(0xFF1B2A4A),
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(24),
),
minimumSize: const Size(double.infinity, 44),
),
child: const Text(
'ALTERAR MÉTODO DE PAGAMENTO',
style: TextStyle(
fontSize: 11,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
),
),
),
const SizedBox(height: 14),

// Ação final
_cardContainer(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'AÇÃO FINAL:',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
),
),
const SizedBox(height: 12),
Row(
children: [
Expanded(
child: OutlinedButton(
onPressed: _cancelamentoEmAndamento
? null
    : () => Navigator.pop(context),
style: OutlinedButton.styleFrom(
side: const BorderSide(
color: Color(0xFF1B2A4A),
),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
padding: const EdgeInsets.symmetric(
vertical: 10,
),
),
child: const Text(
'MANTER ASSINATURA\n'
'E LEMBRAR DEPOIS',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 9,
fontWeight: FontWeight.bold,
color: Color(0xFF1B2A4A),
),
),
),
),
const SizedBox(width: 10),
Expanded(
child: ElevatedButton(
onPressed: _cancelamentoEmAndamento
? null
    : _confirmarCancelamento,
style: ElevatedButton.styleFrom(
backgroundColor:
const Color(0xFF1B2A4A),
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
padding: const EdgeInsets.symmetric(
vertical: 10,
),
),
child: _cancelamentoEmAndamento
? const SizedBox(
height: 18,
width: 18,
child: CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : const Text(
'CONFIRMAR\n'
'CANCELAMENTO AGORA',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 9,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
),
),
],
),
const SizedBox(height: 12),
const Center(
child: Text(
'Uma mensagem de confirmação será enviada '
'para seu email',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 10,
fontStyle: FontStyle.italic,
color: Colors.black54,
),
),
),
],
),
),
const SizedBox(height: 30),
],
),
),
],
),
),
);
}

Widget _cardContainer({required Widget child}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: const Color(0xFFC8CEDC),
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withAlpha(12),
blurRadius: 8,
offset: const Offset(0, 2),
),
],
),
child: child,
);
}
}