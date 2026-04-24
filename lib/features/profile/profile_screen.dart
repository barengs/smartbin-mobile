import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                        image: const DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/300'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Eka',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Pahlawan Kebersihan Platinum',
                      style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              _buildMenuSection('PENGATURAN AKUN', [
                _buildMenuItem(LucideIcons.user, 'Edit Profil'),
                _buildMenuItem(LucideIcons.shieldCheck, 'Keamanan'),
                _buildMenuItem(LucideIcons.bell, 'Notifikasi'),
              ]),
              
              const SizedBox(height: 32),
              _buildMenuSection('DUKUNGAN', [
                _buildMenuItem(LucideIcons.info, 'Pusat Bantuan'),
                _buildMenuItem(LucideIcons.info, 'Tentang Aplikasi'),
              ]),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(LucideIcons.logOut, color: Colors.red),
                  label: Text(
                    'KELUAR AKUN',
                    style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.textMain),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
      onTap: () {},
    );
  }
}
