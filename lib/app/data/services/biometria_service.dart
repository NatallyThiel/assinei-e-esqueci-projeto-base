
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometriaService {
  final LocalAuthentication _autenticacao = LocalAuthentication();

  /// Verifica se o dispositivo possui biometria cadastrada.
  Future<bool> biometriaDisponivel() async {
    try {
      final dispositivoSuportado =
      await _autenticacao.isDeviceSupported();

      final biometriasDisponiveis =
      await _autenticacao.getAvailableBiometrics();

      debugPrint(
        'BIOMETRIA: dispositivo suportado = $dispositivoSuportado',
      );

      debugPrint(
        'BIOMETRIA: biometrias cadastradas = $biometriasDisponiveis',
      );

      return dispositivoSuportado && biometriasDisponiveis.isNotEmpty;
    } catch (e) {
      debugPrint('ERRO AO VERIFICAR BIOMETRIA: $e');
      return false;
    }
  }

  /// Solicita confirmação biométrica.
  Future<bool> autenticar({
    String motivo = 'Confirme sua identidade para continuar.',
  }) async {
    try {
      final disponivel = await biometriaDisponivel();

      if (!disponivel) {
        debugPrint('BIOMETRIA: recurso indisponível');
        return false;
      }

      final resultado = await _autenticacao.authenticate(
        localizedReason: motivo,
        biometricOnly: true,
      );

      debugPrint(
        'RESULTADO DA AUTENTICAÇÃO BIOMÉTRICA: $resultado',
      );

      return resultado;
    } catch (e, stackTrace) {
      debugPrint('ERRO NA AUTENTICAÇÃO BIOMÉTRICA: $e');
      debugPrint('$stackTrace');
      return false;
    }
  }
}
