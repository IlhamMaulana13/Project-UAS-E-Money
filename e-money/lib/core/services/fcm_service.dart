import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler pesan background — harus top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Android menampilkan notifikasi secara otomatis saat app di background/terminated.
}

class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'transaction_channel';
  static const _channelName = 'Transaksi';

  Future<void> init() async {
    // Inisialisasi local notifications untuk foreground messages
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: android),
    );

    // Buat notification channel Android
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifikasi transaksi e-money',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Minta izin notifikasi (iOS & Android 13+)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Pastikan foreground messages tampil sebagai heads-up notification
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handler saat app di foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handler saat notifikasi di-tap dan app di background (tidak terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Handler saat notifikasi di-tap dan app terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Kirim FCM token ke backend (dipanggil setelah login berhasil).
  Future<void> uploadToken(Future<void> Function(String token) uploader) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await uploader(token);
    } catch (_) {
      // Gagal upload token tidak boleh crash app
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    const details = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifikasi transaksi e-money',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
    );

    await _localNotifications.show(
      message.hashCode,
      n.title ?? 'Notifikasi',
      n.body ?? '',
      const NotificationDetails(android: details),
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    // Navigasi ke halaman riwayat transaksi bisa ditambahkan di sini
  }
}
