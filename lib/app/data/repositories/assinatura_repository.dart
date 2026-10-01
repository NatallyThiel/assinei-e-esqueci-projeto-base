import 'package:flutter/material.dart';
import '../models/assinatura_model.dart';

class AssinaturasRepository extends ChangeNotifier {
  AssinaturasRepository._();
  static final AssinaturasRepository instance = AssinaturasRepository._();

  final List<AssinaturaModel> _assinaturas = [];
  bool _carregando = false;

  List<AssinaturaModel> get assinaturas => List.unmodifiable(_assinaturas);
  bool get carregando => _carregando;

  double get totalGastoMensal {
    return _assinaturas.fold(0.0, (total, item) => total + item.valor);
  }

  void adicionarAssinatura(AssinaturaModel assinatura) {
    _assinaturas.add(assinatura);
    notifyListeners();
  }

  void removerAssinatura(String id) {
    _assinaturas.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}