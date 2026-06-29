import 'dart:async';
import 'package:app_links/app_links.dart';

class OrderItem {
  final int qty;
  final String name;
  final String size;
  final double price;

  const OrderItem({
    required this.qty,
    required this.name,
    required this.size,
    required this.price,
  });
}

class DeeplinkPaymentData {
  final String merchantId;
  final String merchantName;
  final double amount;
  final String description;
  final String reference;
  final String callbackUrl;
  final List<OrderItem> items;

  DeeplinkPaymentData({
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.description,
    required this.reference,
    required this.callbackUrl,
    this.items = const [],
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

      // Parse structured items: "2|Jersey A|M|150000~1|Jersey B|L|200000"
      final itemsStr = params['items'] ?? '';
      final items = <OrderItem>[];
      if (itemsStr.isNotEmpty) {
        for (final raw in itemsStr.split('~')) {
          final parts = raw.split('|');
          if (parts.length >= 4) {
            items.add(OrderItem(
              qty: int.tryParse(parts[0]) ?? 1,
              name: parts[1],
              size: parts[2],
              price: double.tryParse(parts[3]) ?? 0,
            ));
          }
        }
      }

      if (merchantId.isNotEmpty && amount > 0) {
        final paymentData = DeeplinkPaymentData(
          merchantId: merchantId,
          merchantName: merchantName,
          amount: amount,
          description: description,
          reference: reference,
          callbackUrl: callbackUrl,
          items: items,
        );

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
