import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

const _orange = Color(0xFFFF6A2B);

class MerchantCheckoutPage extends StatefulWidget {
  final DeeplinkPaymentData? deeplink;
  const MerchantCheckoutPage({super.key, this.deeplink});

  @override
  State<MerchantCheckoutPage> createState() => _MerchantCheckoutPageState();
}

class _MerchantCheckoutPageState extends State<MerchantCheckoutPage> {
  DeeplinkPaymentData? _deeplink;

  static const _items = [
    {'name': 'Kemeja Flanel Oversize', 'qty': 1, 'price': 159000.0},
    {'name': 'Tumbler Stainless 750ml', 'qty': 2, 'price': 45000.0},
  ];
  static const _ship = 12000.0;
  static final _subtotal = _items.fold(
      0.0, (s, i) => s + (i['price'] as double) * (i['qty'] as int));
  static final _cartTotal = _subtotal + _ship;

  @override
  void initState() {
    super.initState();
    _deeplink = widget.deeplink;
  }

  void _pay() {
    if (_deeplink != null) {
      context.go('/pin', extra: {
        'kind': 'deeplink',
        'amount': _deeplink!.amount,
        'description': _deeplink!.description,
        'callback_url': _deeplink!.callbackUrl,
        'merchant_name': _deeplink!.merchantName,
        'reference': _deeplink!.reference,
        'merchant_id': _deeplink!.merchantId,
      });
    } else {
      context.go('/pin', extra: {
        'kind': 'payment',
        'description': 'TokoBelanja #TB-2026-88142',
        'amount': _cartTotal,
      });
    }
  }

  Widget _buildPendingBanner() {
    final dl = _deeplink!;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowPrimary,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_outlined,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Permintaan Pembayaran',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          color: Colors.white70,
                        )),
                    Text(dl.merchantName,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _deeplink = null),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Tagihan',
                    style: TextStyle(fontSize: 11.5, color: Colors.white60)),
                const SizedBox(height: 2),
                Text(CurrencyFormatter.format(dl.amount),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                if (dl.reference.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Ref: ${dl.reference}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ],
              ],
            ),
          ),
          if (dl.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(dl.description,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  color: Colors.white70,
                )),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payAmount = _deeplink != null ? _deeplink!.amount : _cartTotal;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            color: _orange,
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 6, 16, 14),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => context.go('/home'),
                ),
                const Expanded(
                  child: Text('Pembayaran',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      )),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront_outlined,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _deeplink?.merchantName ?? 'TokoBelanja',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                children: [
                  if (_deeplink != null) _buildPendingBanner(),
                  // Order items
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('Pesanan #TB-2026-88142',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate400,
                              )),
                        ),
                        ..._items.asMap().entries.map((e) {
                          final i = e.key;
                          final item = e.value;
                          return Column(
                            children: [
                              if (i > 0)
                                const Divider(
                                    height: 1, color: AppColors.line2),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1E9),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                          child: Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 22,
                                              color: _orange)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'] as String,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.ink,
                                              )),
                                          Text(
                                              '${item['qty']} × ${CurrencyFormatter.format(item['price'] as double)}',
                                              style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: AppColors.slate400)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(
                                          (item['price'] as double) *
                                              (item['qty'] as int)),
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Payment method
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Metode pembayaran',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                          )),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                      border: Border.all(
                          color: AppColors.primaryLight, width: 1.8),
                    ),
                    child: Row(
                      children: [
                        const AppLogo(size: 40),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dompet Kampus Global',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  )),
                              Text('Saldo · pembayaran instan',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.slate400)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_rounded,
                            size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Totals
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      children: [
                        _TotalLine(
                            label: 'Subtotal',
                            value: CurrencyFormatter.format(_subtotal)),
                        const Divider(height: 1, color: AppColors.line2),
                        _TotalLine(
                            label: 'Ongkos kirim',
                            value: CurrencyFormatter.format(_ship)),
                        const Divider(height: 1, color: AppColors.line2),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate600,
                                  )),
                              Text(
                                CurrencyFormatter.format(payAmount),
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: _deeplink != null
                                      ? AppColors.primary
                                      : _orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pay bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
            child: AppButton(
              label: 'Bayar ${CurrencyFormatter.format(payAmount)}',
              onPressed: _pay,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  const _TotalLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.slate500,
                  fontFamily: 'PlusJakartaSans')),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  fontFamily: 'PlusJakartaSans')),
        ],
      ),
    );
  }
}
