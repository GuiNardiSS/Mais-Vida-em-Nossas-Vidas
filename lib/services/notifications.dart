
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(init);
  }

 static Future<void> scheduleEvery3Hours() async {
  await _plugin.periodicallyShow(
    100,
    'Mensagem Espiritual',
    'Confira sua espiritualidade do dia ✨',
    RepeatInterval.hourly, // aprox.: 1h. (o plugin não tem "a cada 3h")
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'maisvida',
        'Mensagens',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // <- substitui androidAllowWhileIdle
  );
}

  }

