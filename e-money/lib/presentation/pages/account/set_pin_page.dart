import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/pin_pad.dart';

enum _Step { enterNew, confirm }

class SetPinPage extends StatefulWidget {
  const SetPinPage({super.key});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final _storage = const FlutterSecureStorage();

  _Step _step = _Step.enterNew;
  String _pin = '';
  String _firstPin = '';
  bool _hasError = false;
  bool _saving = false;

  Future<void> _onComplete(String pin) async {
    if (_step == _Step.enterNew) {
      setState(() {
        _firstPin = pin;
        _step = _Step.confirm;
        _pin = '';
      });
      return;
    }

    // Confirm step
    if (pin != _firstPin) {
      setState(() {
        _hasError = true;
        _pin = '';
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _hasError = false;
            _step = _Step.enterNew;
            _firstPin = '';
          });
        }
      });
      return;
    }

    // PINs match — save
    setState(() => _saving = true);
    await _storage.write(key: AppConstants.kPin, value: pin);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN berhasil disimpan'),
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 2),
      ),
    );
    // pop kembali ke halaman pemanggil (PIN page atau Account page)
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isConfirm = _step == _Step.confirm;
    final title = isConfirm ? 'Konfirmasi PIN' : 'Buat PIN Baru';
    final subtitle = isConfirm
        ? 'Masukkan PIN yang sama untuk konfirmasi'
        : 'Buat 6 digit PIN untuk keamanan transaksi';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _saving
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 18),
                    Text('Menyimpan PIN…',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate600,
                        )),
                  ],
                ),
              )
            : Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
                      onPressed: () {
                        if (_step == _Step.confirm) {
                          setState(() {
                            _step = _Step.enterNew;
                            _pin = '';
                            _firstPin = '';
                          });
                        } else {
                          context.pop();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        children: [
                          // Step indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StepDot(active: true, done: isConfirm),
                              const SizedBox(width: 8),
                              _StepDot(active: isConfirm, done: false),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Icon
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Icon(
                                isConfirm
                                    ? Icons.lock_outline_rounded
                                    : Icons.lock_open_outlined,
                                size: 30,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(title,
                                key: ValueKey(title),
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                )),
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(subtitle,
                                key: ValueKey(subtitle),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13.5, color: AppColors.slate500)),
                          ),
                          if (_hasError) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('PIN tidak cocok. Silakan coba lagi.',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ],
                          const SizedBox(height: 28),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            transform: _hasError
                                ? Matrix4.translationValues(10.0, 0, 0)
                                : Matrix4.identity(),
                            child: PinPad(
                              value: _pin,
                              onChanged: (v) => setState(() => _pin = v),
                              onComplete: _onComplete,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;
  const _StepDot({required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: done ? 10 : (active ? 28 : 10),
      height: 10,
      decoration: BoxDecoration(
        color: active || done ? AppColors.primary : AppColors.line,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
