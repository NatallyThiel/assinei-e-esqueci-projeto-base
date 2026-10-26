import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometriaService {
  final LocalAuthentication _autenticacao = LocalAuthentication();

  /// Verifica se o dispositivo oferece suporte e possui biometria configurada.
  Future<bool> biometriaDisponivel() async {
    try {
      final dispositivoSuportado =
      await _autenticacao.isDeviceSupported();

      final biometriaConfigurada =
      await _autenticacao.canCheckBiometrics;

      debugPrint(
        'BIOMETRIA: dispositivo suportado = $dispositivoSuportado',
      );
      debugPrint(
        'BIOMETRIA: biometria configurada = $biometriaConfigurada',
      );

      return dispositivoSuportado && biometriaConfigurada;
    } catch (e) {
      debugPrint('ERRO AO VERIFICAR BIOMETRIA: $e');
      return false;
    }
  }

  /// Solicita confirmação biométrica.
  /// Retorna true apenas se a autenticação for aprovada.
  /// Em caso de indisponibilidade, cancelamento ou erro, retorna false.
  Future<bool> autenticar() async {
    try {
      final disponivel = await biometriaDisponivel();

      if (!disponivel) {
        debugPrint('BIOMETRIA: recurso indisponível');
        return false;
      }

      final resultado = await _autenticacao.authenticate(
        localizedReason:
        'Confirme sua identidade para cancelar esta assinatura.',
        biometricOnly: true,
      );

      debugPrint('RESULTADO DA AUTENTICAÇÃO BIOMÉTRICA: $resultado');
      return resultado;
    } catch (e, stackTrace) {
      debugPrint('ERRO NA AUTENTICAÇÃO BIOMÉTRICA: $e');
      debugPrint('$stackTrace');
      return false;
    }
  }
}
