import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../core/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();
  final _ktpController = TextEditingController();
  
  bool _isNfcScanning = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscurePin = true;
  bool _passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordMatch);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    final match = _passwordController.text == _confirmPasswordController.text;
    if (_passwordsMatch != match) {
      setState(() => _passwordsMatch = match);
    }
  }

  void _handleRegister() async {
    if (_isLoading) return;

    // Simple validation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.register(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        pin: _pinController.text,
        ktpId: _ktpController.text,
      );

      if (response.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Berhasil! Silakan tunggu verifikasi admin.')),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      String message = 'Terjadi kesalahan';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          message = errors.values.expand((e) => e as List).join('\n');
        } else if (data['message'] != null) {
          message = data['message'];
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startNfcSession() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC tidak tersedia di perangkat ini')),
      );
      return;
    }

    setState(() => _isNfcScanning = true);
    
    // Show a modal for NFC tap instruction
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        height: 300,
        child: Column(
          children: [
            const Icon(LucideIcons.contact, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Tempelkan E-KTP Anda',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Dekatkan E-KTP ke bagian belakang smartphone Anda'),
            const Spacer(),
            TextButton(
              onPressed: () {
                NfcManager.instance.stopSession();
                Navigator.pop(context);
                setState(() => _isNfcScanning = false);
              },
              child: const Text('BATAL'),
            )
          ],
        ),
      ),
    );

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      String? id;
      if (tag.data.containsKey('mifare')) {
         id = (tag.data['mifare']['identifier'] as List<int>).map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
      } else {
         id = (tag.data['nfca']['identifier'] as List<int>).map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
      }

      setState(() {
        _ktpController.text = id!;
        _isNfcScanning = false;
      });
      
      NfcManager.instance.stopSession();
      Navigator.pop(context); // Close bottom sheet
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-KTP Berhasil Terdeteksi')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buat Akun Baru',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bergabung dengan ribuan pahlawan kebersihan di Pamekasan',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildInputLabel('E-KTP (TAP NFC)'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ktpController,
                      hint: 'Tap tombol NFC untuk scan', 
                      icon: LucideIcons.contact,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _startNfcSession,
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.nfc, color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),

              _buildInputLabel('NAMA LENGKAP'),
              _buildTextField(controller: _nameController, hint: 'Sesuai KTP', icon: LucideIcons.user),
              const SizedBox(height: 24),
              
              _buildInputLabel('EMAIL'),
              _buildTextField(controller: _emailController, hint: 'email@contoh.com', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),

              _buildInputLabel('NOMOR HANDPHONE'),
              _buildTextField(controller: _phoneController, hint: '0812xxxx', icon: LucideIcons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              
              _buildInputLabel('ALAMAT DOMISILI'),
              _buildTextField(controller: _addressController, hint: 'Kecamatan/Desa', icon: LucideIcons.mapPin),
              const SizedBox(height: 24),
              
              _buildInputLabel('KATA SANDI'),
              _buildTextField(
                controller: _passwordController, 
                hint: 'Minimal 8 Karakter', 
                icon: LucideIcons.lock, 
                isPassword: true,
                obscureText: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 24),
              
              _buildInputLabel('KONFIRMASI KATA SANDI'),
              _buildTextField(
                controller: _confirmPasswordController, 
                hint: 'Ulangi kata sandi', 
                icon: LucideIcons.shieldCheck, 
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                error: !_passwordsMatch && _confirmPasswordController.text.isNotEmpty,
              ),
              if (!_passwordsMatch && _confirmPasswordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    '* Kata sandi tidak cocok',
                    style: GoogleFonts.outfit(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 24),

              _buildInputLabel('PIN KEAMANAN (6 DIGIT)'),
              _buildTextField(
                controller: _pinController, 
                hint: '6 Digit angka rahasia', 
                icon: LucideIcons.key, 
                keyboardType: TextInputType.number,
                isPassword: true,
                obscureText: _obscurePin,
                onToggle: () => setState(() => _obscurePin = !_obscurePin),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_passwordsMatch) ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Text(
                        'DAFTAR SEKARANG',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    bool readOnly = false,
    bool error = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: error ? Colors.red : null),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(
                obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 20,
                color: error ? Colors.red : Colors.grey,
              ),
              onPressed: onToggle,
            )
          : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: error ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: error ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: error ? Colors.red : AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
