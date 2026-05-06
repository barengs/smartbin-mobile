import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/theme.dart';
import '../../core/utils/extensions.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _accountController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _items = [
    {'name': 'Saldo GoPay Rp 10.000', 'points': 1000, 'type': 'gopay', 'icon': LucideIcons.wallet},
    {'name': 'Saldo OVO Rp 20.000', 'points': 2000, 'type': 'ovo', 'icon': LucideIcons.wallet},
    {'name': 'Saldo DANA Rp 5.000', 'points': 500, 'type': 'dana', 'icon': LucideIcons.wallet},
    {'name': 'Saldo ShopeePay Rp 50.000', 'points': 5000, 'type': 'shopeepay', 'icon': LucideIcons.shoppingBag},
  ];

  void _handleRedeem(Map<String, dynamic> item) async {
    final userProvider = context.read<UserProvider>();
    final account = _accountController.text.trim();

    if (account.isEmpty) {
      _showError('Nomor akun harus diisi');
      return;
    }

    setState(() => _isLoading = true);
    Navigator.pop(context); // Close sheet

    try {
      final response = await _apiService.redeemPoints(
        userProvider.token!,
        item['points'],
        item['type'],
        account,
      );

      if (response.data['success']) {
        await userProvider.fetchProfile(); // Refresh points
        _showSuccess('Penukaran Berhasil! Saldo akan segera diproses ke nomor $account.');
        _accountController.clear();
      }
    } on DioException catch (e) {
      String msg = 'Terjadi kesalahan saat penukaran';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        msg = e.response?.data['message'];
      }
      _showError(msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRedeemSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konfirmasi Penukaran',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda akan menukarkan ${(item['points'] as num).toLocaleString()} poin untuk ${item['name']}.',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              'NOMOR HP AKUN ${item['type'].toString().toUpperCase()}',
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _accountController,
              keyboardType: TextInputType.phone,
              autofocus: true,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Contoh: 081234567890',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _handleRedeem(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text('KONFIRMASI SEKARANG', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final points = num.tryParse(userProvider.user?['total_points']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'TUKAR POIN',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  'Saldo Poin Saat Ini',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.coins, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      points.toLocaleString(),
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textMain),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final canAfford = points >= item['points'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(item['icon'], color: Colors.orange),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  '${(item['points'] as num).toLocaleString()} Poin',
                                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: canAfford ? () => _showRedeemSheet(item) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('TUKAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
