import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme.dart';

import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/extensions.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  List<dynamic> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.token == null) return;

    try {
      final response = await _apiService.getTransactions(userProvider.token!);
      if (response.data['success']) {
        setState(() {
          // Laravel Pagination: actual data is in ['data']['data']
          _allTransactions = response.data['data']['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredTransactions {
    if (_tabController.index == 0) return _allTransactions;
    final type = _tabController.index == 1 ? 'deposit' : 'redeem';
    return _allTransactions.where((tx) => tx['type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'RIWAYAT AKTIVITAS',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Setoran'),
            Tab(text: 'Penukaran'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTransactions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) => _buildActivityItem(_filteredTransactions[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat aktivitas',
            style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> tx) {
    final isDeposit = tx['type'] == 'deposit';
    final points = num.tryParse(tx['points']?.toString() ?? '0') ?? 0;
    final date = DateTime.parse(tx['created_at']);
    final location = tx['smart_bin']?['name'] ?? tx['notes'] ?? (tx['ewallet_type'] != null ? 'Redeem to ${tx['ewallet_type']}' : 'Pamekasan');
    final status = tx['status'] ?? 'completed';

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
              color: (isDeposit ? AppColors.primary : Colors.orange).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isDeposit ? LucideIcons.package : LucideIcons.wallet,
              color: isDeposit ? AppColors.primary : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isDeposit ? 'Setoran Berhasil' : 'Penukaran Poin',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    if (!isDeposit) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'pending' ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: status == 'pending' ? Colors.blue : Colors.green),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  location,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date.toRelativeTime(),
                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Text(
            '${isDeposit ? '+' : '-'}${points.abs().toLocaleString()}',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              color: isDeposit ? AppColors.primary : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
