import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan tempat Anda menaruh deeplink_service.dart
import 'package:dompet_kampus_global/core/services/deeplink_service.dart';

class PaymentDeeplinkPage extends StatelessWidget {
  final DeeplinkPaymentData paymentData;

  const PaymentDeeplinkPage({
    super.key, 
    required this.paymentData,
  });

  // Fungsi mengubah angka menjadi format Rupiah
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  void _onConfirmPayment(BuildContext context) {
    // Sesuai materi, fitur selanjutnya adalah mengarahkan ke halaman PIN.
    // Sementara kita beri notifikasi saja (placeholder).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akan dialihkan ke halaman Input PIN...')),
    );
  }

  void _onCancel(BuildContext context) {
    // Jika user menolak membayar, kembalikan ke beranda
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Konfirmasi Pembayaran'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghilangkan tombol back (user harus tekan batal)
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Anda akan melakukan pembayaran ke:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              paymentData.merchantName, // Menampilkan: Toko Jersey AppsMarketplace
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Tagihan',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp ${_formatCurrency(paymentData.amount)}",
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.blue,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail:', style: TextStyle(color: Colors.grey)),
                      Text(paymentData.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ID Trx:', style: TextStyle(color: Colors.grey)),
                      Text(paymentData.reference, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onCancel(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onConfirmPayment(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Konfirmasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}