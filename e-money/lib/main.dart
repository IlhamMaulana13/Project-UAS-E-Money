import 'package:dompet_kampus_global/core/services/deeplink_service.dart';
import 'package:dompet_kampus_global/core/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_bloc_observer.dart';
import 'injection/injection_container.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AppBlocObserver();

  // Daftarkan background handler SEBELUM Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 1. Inisialisasi Service Deeplink sebelum aplikasi berjalan
  await DeeplinkService().init();

  // Initialize Firebase — pastikan google-services.json/GoogleService-Info.plist sudah ada
  await Firebase.initializeApp();

  // Initialize dependency injection
  await di.init();

  // Inisialisasi FCM (request permission + setup handlers)
  await FcmService().init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const dompetsyariahApp());
}

class dompetsyariahApp extends StatefulWidget {
  const dompetsyariahApp({super.key});

  @override
  State<dompetsyariahApp> createState() => _dompetsyariahAppState();
}

class _dompetsyariahAppState extends State<dompetsyariahApp> {
  @override
  void initState() {
    super.initState();

    // Warm-start: app sudah berjalan, deeplink masuk lewat stream
    DeeplinkService().onPaymentReceived.listen((paymentData) {
      AppRouter.router.push('/payment-deeplink', extra: paymentData);
    });

    // Cold-start: _pendingPayment disimpan oleh DeeplinkService.init().
    // Navigasi ke /payment-deeplink ditangani setelah auth selesai
    // (di splash_page, login_page, dan halaman 2FA).
  }

  @override
  void dispose() {
    DeeplinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Dompet Syari'ah",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
