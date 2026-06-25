import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/account/account_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/success_check.dart';

class SuccessPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final double amount;
  final List<List<String>> lines;
  final String callbackUrl;
  final String merchantName;

  const SuccessPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.lines,
    this.callbackUrl = '',
    this.merchantName = '',
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(AccountRefreshRequested());
  }

  Future<void> _returnToMerchant(BuildContext context) async {
    final rawUrl = widget.callbackUrl;
    if (rawUrl.isEmpty) {
      context.go('/home');
      return;
    }
    final base = Uri.parse(rawUrl);
    final callbackUri = base.replace(queryParameters: {
      ...base.queryParameters,
      'status': 'success',
      'amount': widget.amount.toStringAsFixed(0),
    });
    if (await canLaunchUrl(callbackUri)) {
      await launchUrl(callbackUri, mode: LaunchMode.externalApplication);
    }
    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Column(
                  children: [
                    const Spacer(),
                    const SuccessCheck(),
                    const SizedBox(height: 24),
                    Text(widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        )),
                    if (widget.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(widget.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14.5,
                            color: AppColors.slate500,
                          )),
                    ],
                    const SizedBox(height: 20),
                    Text(CurrencyFormatter.format(widget.amount),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.6,
                        )),
                    if (widget.lines.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: widget.lines.asMap().entries.map((e) {
                            final i = e.key;
                            final l = e.value;
                            return Column(
                              children: [
                                if (i > 0) const Divider(height: 1, color: AppColors.line),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(l[0],
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13.5,
                                            color: AppColors.slate500,
                                          )),
                                      Text(l[1],
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  if (widget.callbackUrl.isNotEmpty) ...[
                    AppButton(
                      label: 'Kembali ke ${widget.merchantName}',
                      onPressed: () => _returnToMerchant(context),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Selesai',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/home'),
                    ),
                  ] else ...[
                    AppButton(
                      label: 'Selesai',
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Bagikan bukti transaksi',
                      variant: AppButtonVariant.soft,
                      icon: const Icon(Icons.copy_rounded,
                          size: 18, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
