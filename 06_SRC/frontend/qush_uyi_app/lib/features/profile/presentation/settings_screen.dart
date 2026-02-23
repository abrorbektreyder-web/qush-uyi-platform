import 'package:flutter/material.dart';
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

  void _saveSettings() async {
    setState(() => _isLoading = true);
    // Simulate API Call for updating preferences
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sozlamalar saqlandi',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primary),
      );
    }
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
            const Text("Maxfiylik (Privacy)",
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Telefon raqamni ko'rsatish",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    subtitle: const Text("Boshqalar sizga qong'iroq qila oladi",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    value: _showPhone,
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryDark,
                    onChanged: (val) => setState(() => _showPhone = val),
                    secondary: const Icon(Icons.phone, color: Colors.white70),
                  ),
                  const Divider(color: AppColors.glassBorder),
                  SwitchListTile(
                    title: const Text("Telegram ruxsati",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    subtitle: const Text(
                        "Foydalanuvchilar telegramingizga tuppa-to'gri yoza oladi",
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    value: _allowTelegram,
                    activeColor: Colors.blueAccent,
                    activeTrackColor: Colors.blueAccent.withOpacity(0.5),
                    onChanged: (val) => setState(() => _allowTelegram = val),
                    secondary:
                        const Icon(Icons.telegram, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text("Telegram Bog'lash",
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                      "Telegram akkauntingizni tizimga bog'lang. (Xaridorlarga sizni topish oson bo'ladi va Admin bildirishnomalarini olasiz)",
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Telegram bot ochilmoqda...")));
                      },
                      icon: const Icon(Icons.telegram, color: Colors.white),
                      label: const Text("Telegram bilan bog'lash @qushuyibot",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Saqlash",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
