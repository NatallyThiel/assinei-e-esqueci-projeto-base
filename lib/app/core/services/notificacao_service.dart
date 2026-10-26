
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacaoService {
  NotificacaoService._();

  static final NotificacaoService instance = NotificacaoService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;

    tz.initializeTimeZones();

    final String fusoHorario =
    await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(fusoHorario));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    _inicializado = true;
  }

  Future<bool> solicitarPermissao() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return false;

    return await android.requestNotificationsPermission() ?? false;
  }

  Future<void> mostrarNotificacaoDeTeste() async {
    const detalhes = NotificationDetails(
      android: AndroidNotificationDetails(
        'teste_gratis',
        'Alertas de teste grátis',
        channelDescription: 'Avisos sobre o vencimento de testes grátis',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      999,
      'Teste grátis chegando ao fim',
      'Esta é uma notificação de teste do Assinei & Esqueci.',
      detalhes,
    );
  }

  Future<void> agendarNotificacaoDeTeste() async {
    const detalhes = NotificationDetails(
      android: AndroidNotificationDetails(
        'teste_gratis',
        'Alertas de teste grátis',
        channelDescription: 'Avisos sobre o vencimento de testes grátis',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      1000,
      'Teste grátis chegando ao fim',
      'A notificação agendada funcionou!',
      tz.TZDateTime.now(tz.local).add(
        const Duration(minutes: 1),
      ),
      detalhes,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
