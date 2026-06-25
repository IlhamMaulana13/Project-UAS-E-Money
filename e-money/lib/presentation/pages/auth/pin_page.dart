import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dompet_kampus_global/core/services/deeplink_service.dart';

class PinPage extends StatefulWidget {
  final DeeplinkPaymentData paymentData;

  const PinPage({super.key, required this.paymentData});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyPinAndPay() async {
    // Simulasi validasi PIN (misal PIN yang benar adalah '123456')
    if (_pinController.text != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN Salah. Coba lagi.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi jeda loading proses pembayaran & 2FA ke Backend
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Pembayaran Berhasil!
    if (!mounted) return;
    
    // Tampilkan pesan sukses sebentar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran Berhasil! Mengembalikan Anda ke Toko...'), backgroundColor: Colors.green),
    );

    // Proses memanggil kembali Toko Jersey (AppsMarketplace)
    _sendCallbackToMerchant();
  }

  Future<void> _sendCallbackToMerchant() async {
    // Merangkai URL kembalian dengan menambahkan status=success
    // Format: appsmarketplace://payment-callback?status=success&reference=INV-xxx
    final callbackUrl = Uri.parse(
      '${widget.paymentData.callbackUrl}?status=success&reference=${widget.paymentData.reference}'
    );

    // Luncurkan URL untuk memanggil Toko Jersey
    if (await canLaunchUrl(callbackUrl)) {
      await launchUrl(callbackUrl, mode: LaunchMode.externalApplication);
      
      // Tutup halaman PIN dan Konfirmasi di E-Money, kembali ke beranda E-Money
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal kembali ke aplikasi Toko.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masukkan PIN')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Total Tagihan: Rp ${widget.paymentData.amount.toInt()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Masukkan 6 Digit PIN (123456)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyPinAndPay,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Bayar Sekarang', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}