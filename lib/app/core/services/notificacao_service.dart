
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/assinatura_model.dart';

class NotificacaoService {
  NotificacaoService._();

  static final NotificacaoService instance = NotificacaoService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    tz.initializeTimeZones();

    try {
      final String fusoHorario =
      await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(tz.getLocation(fusoHorario));
    } catch (e) {
      debugPrint('Erro ao identificar fuso horário: $e');

      tz.setLocalLocation(
        tz.getLocation('America/Sao_Paulo'),
      );
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint(
          'Notificação tocada: ${response.payload}',
        );
      },
    );

    _inicializado = true;

    await solicitarPermissao();
  }

  Future<bool> solicitarPermissao() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (android == null) return false;

      return await android.requestNotificationsPermission() ?? false;
    } catch (e) {
      debugPrint('Erro ao solicitar permissão: $e');
      return false;
    }
  }

  // Gera um identificador estável para cada assinatura.
  int _gerarIdNotificacao(String assinaturaId) {
    var hash = 0x811c9dc5;

    for (final caractere in assinaturaId.codeUnits) {
      hash ^= caractere;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }

  Future<void> agendarNotificacao(
      AssinaturaModel assinatura,
      ) async {
    await inicializar();

    final notifId = _gerarIdNotificacao(assinatura.id);

    // Se a notificação estiver desativada, cancela qualquer
    // agendamento anterior dessa assinatura.
    if (!assinatura.notificacaoAtivada) {
      await _plugin.cancel(notifId);

      debugPrint(
        'Notificação desativada para ${assinatura.nome}',
      );

      return;
    }

    int hora = 10;
    int minuto = 0;

    try {
      final partes = assinatura.horarioAlerta.split(':');

      if (partes.length >= 2) {
        hora = int.parse(partes[0]);
        minuto = int.parse(partes[1]);
      }

      if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) {
        throw FormatException('Horário inválido');
      }
    } catch (e) {
      debugPrint(
        'Horário inválido para ${assinatura.nome}. '
            'Será utilizado 10:00.',
      );

      hora = 10;
      minuto = 0;
    }

    final dataVencimento = assinatura.dataVencimento;

    final dataAgendada = DateTime(
      dataVencimento.year,
      dataVencimento.month,
      dataVencimento.day,
      hora,
      minuto,
    );

    final agora = DateTime.now();

    // Se o vencimento já passou, remove um possível
    // agendamento antigo para evitar notificações indevidas.
    if (!dataAgendada.isAfter(agora)) {
      await _plugin.cancel(notifId);

      debugPrint(
        'Não foi agendada notificação para ${assinatura.nome}: '
            'data de vencimento já passou.',
      );

      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'lembrete_assinaturas_channel',
      'Lembrete de Assinaturas',
      channelDescription:
      'Notificações sobre cobranças de assinaturas prestes a vencer',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzData = tz.TZDateTime.from(
      dataAgendada,
      tz.local,
    );

    try {
      await _plugin.zonedSchedule(
        notifId,
        'Lembrete: ${assinatura.nome}',
        'Sua assinatura de R\$ '
            '${assinatura.valor.toStringAsFixed(2)} vence hoje.',
        tzData,
        notificationDetails,
        androidScheduleMode:
        AndroidScheduleMode.inexactAllowWhileIdle,
        payload: assinatura.id,
      );

      debugPrint(
        'Notificação agendada para ${assinatura.nome} '
            'em $dataAgendada',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Erro ao agendar notificação: $e',
      );

      debugPrint('$stackTrace');

      // Não exibe a notificação imediatamente como alternativa,
      // pois isso poderia enviar um alerta fora do horário correto.
    }
  }

  Future<void> cancelarNotificacao(
      String assinaturaId,
      ) async {
    await inicializar();

    final notifId = _gerarIdNotificacao(assinaturaId);

    await _plugin.cancel(notifId);

    debugPrint(
      'Notificação cancelada para ID $assinaturaId',
    );
  }

  Future<void> sincronizarNotificacoes(
      List<AssinaturaModel> assinaturas,
      ) async {
    await inicializar();

    for (final item in assinaturas) {
      await agendarNotificacao(item);
    }
  }
}
