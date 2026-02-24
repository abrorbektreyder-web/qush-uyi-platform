import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showPhone = true;
  bool _allowTelegram = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _telegramController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _showPhone = prefs.getBool('show_phone') ?? true;
      _allowTelegram = prefs.getBool('allow_telegram') ?? true;
      _nameController.text = prefs.getString('user_name') ?? '';
      _phoneController.text = prefs.getString('user_phone') ?? '';
      _telegramController.text = prefs.getString('user_telegram') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showError('Iltimos ismingizni kiriting');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Iltimos telefon raqamingizni kiriting');
      return;
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_phone', _showPhone);
    await prefs.setBool('allow_telegram', _allowTelegram);
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_phone', _phoneController.text.trim());
    if (_telegramController.text.trim().isNotEmpty) {
      await prefs.setString(
          'user_telegram', _telegramController.text.trim().replaceAll('@', ''));
    }

    // Simulate brief save delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('✅ Sozlamalar saqlandi!',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sozlamalar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── PERSONAL INFO ───
            const Text("Shaxsiy ma'lumotlar",
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSettingsField(
                    label: 'Ismingiz',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: 'Ismingizni kiriting',
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsField(
                    label: 'Telefon raqam',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: '90 123 45 67',
                    prefix: '+998',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsField(
                    label: 'Telegram username',
                    controller: _telegramController,
                    icon: Icons.telegram,
                    hint: 'username',
                    prefix: '@',
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            // ─── PRIVACY ───
            const Text("Maxfiylik (Privacy)",
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Telefon raqamni ko'rsatish",
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    subtitle: const Text(
                        "Boshqalar sizga qo'ng'iroq qila oladi",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    value: _showPhone,
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryDark,
                    onChanged: (val) => setState(() => _showPhone = val),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.phone,
                          color: AppColors.primary, size: 22),
                    ),
                  ),
                  const Divider(
                      color: AppColors.glassBorder, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text("Telegram ruxsati",
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                    subtitle: const Text(
                        "Foydalanuvchilar telegramingizga yoza oladi",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    value: _allowTelegram,
                    activeColor: Colors.blueAccent,
                    activeTrackColor: Colors.blueAccent.withOpacity(0.5),
                    onChanged: (val) => setState(() => _allowTelegram = val),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.telegram,
                          color: Colors.blueAccent, size: 22),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1),

            const SizedBox(height: 32),

            // ─── TELEGRAM LINK ───
            const Text("Telegram Bog'lash",
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.telegram,
                            color: Colors.blueAccent, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Telegram akkauntingizni tizimga bog'lang. Xaridorlarga sizni topish oson bo'ladi va Admin bildirishnomalarini olasiz.",
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('https://t.me/qushuyibot');
                        try {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } catch (_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Telegram ilovasi ochilmadi")),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.telegram, color: Colors.white),
                      label: const Text("Telegram bilan bog'lash",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1),

            const SizedBox(height: 40),

            // ─── SAVE BUTTON ───
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Saqlash",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.glassBorder.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.background.withOpacity(0.5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
