import 'dart:async';
import 'package:app_links/app_links.dart';

class DeeplinkPaymentData {
  final String merchantId;
  final String merchantName;
  final double amount;
  final String description;
  final String reference;
  final String callbackUrl;

  DeeplinkPaymentData({
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.description,
    required this.reference,
    required this.callbackUrl,
  });
}

class DeeplinkService {
  static final DeeplinkService _instance = DeeplinkService._internal();
  factory DeeplinkService() => _instance;
  DeeplinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  final _paymentDataController =
      StreamController<DeeplinkPaymentData>.broadcast();
  Stream<DeeplinkPaymentData> get onPaymentReceived =>
      _paymentDataController.stream;

  // Buffer untuk cold-start: deeplink tiba sebelum listener terpasang
  DeeplinkPaymentData? _pendingPayment;
  DeeplinkPaymentData? get pendingPayment => _pendingPayment;
  void consumePendingPayment() => _pendingPayment = null;

  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleUri(initialUri);
    } catch (e) {}

    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'dompetsyariah' && uri.host == 'pay') {
      final params = uri.queryParameters;

      final merchantId = params['merchant_id'] ?? '';
      final merchantName = params['merchant_name'] ?? 'Merchant Tidak Dikenal';
      final amountStr = params['amount'] ?? '0';
      final description = params['description'] ?? 'Pembayaran';
      final reference = params['reference'] ?? '';
      final callbackUrl = params['callback'] ?? '';

      final amount = double.tryParse(amountStr) ?? 0.0;

      if (merchantId.isNotEmpty && amount > 0) {
        final paymentData = DeeplinkPaymentData(
          merchantId: merchantId,
          merchantName: merchantName,
          amount: amount,
          description: description,
          reference: reference,
          callbackUrl: callbackUrl,
        );

        // Simpan untuk cold-start (sebelum listener terpasang)
        _pendingPayment = paymentData;
        _paymentDataController.add(paymentData);
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
    _paymentDataController.close();
  }
}
