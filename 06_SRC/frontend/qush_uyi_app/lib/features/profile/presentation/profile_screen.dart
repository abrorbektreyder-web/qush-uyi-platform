import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = 'Foydalanuvchi';
  String _userPhone = '';
  String _userTelegram = '';
  int _listingsCount = 0;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Foydalanuvchi';
      _userPhone = prefs.getString('user_phone') ?? '';
      _userTelegram = prefs.getString('user_telegram') ?? '';
      _listingsCount = prefs.getInt('listing_count') ?? 0;
    });
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.bytes != null) {
        setState(() {
          _avatarBytes = result.files.first.bytes;
        });
        // Save to SharedPreferences as base64 would be needed for persistence
        // For now, it stays in memory during the session
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Rasm yangilandi!"),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rasm tanlashda xatolik: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.exit_to_app, color: AppColors.error),
            SizedBox(width: 12),
            Text('Tizimdan chiqish',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text(
            'Haqiqatan ham tizimdan chiqmoqchimisiz?\nBarcha saqlangan ma\'lumotlar o\'chiriladi.',
            style: TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                context.go('/splash');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Chiqish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSavedItems() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.favorite_border,
                size: 60, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              "Saqlanganlar ro'yxati bo'sh",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Yoqqan e'lonlarni ❤️ tugmasi bilan saqlang va ularni bu yerda ko'ring.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text("E'lonlarni ko'rish"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationCenter() {
    final hasPhone = _userPhone.isNotEmpty;
    final hasTelegram = _userTelegram.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.verified_user, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Verifikatsiya Markazi',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildVerifyItem(Icons.phone_android, 'Telefon raqam',
                      hasPhone ? 'Tasdiqlangan ✅' : 'Kiritilmagan', hasPhone),
                  const Divider(color: AppColors.glassBorder),
                  _buildVerifyItem(
                      Icons.telegram,
                      'Telegram',
                      hasTelegram ? 'Bog\'langan ✅' : 'Bog\'lanmagan',
                      hasTelegram),
                  const Divider(color: AppColors.glassBorder),
                  _buildVerifyItem(Icons.badge, 'Shaxs guvohnomasi',
                      'Tekshirilmagan', false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Verifikatsiyadan o'tish orqali e'lonlaringiz yuqori o'rinlarda ko'rsatiladi va xaridorlar ishonchi oshadi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyItem(
      IconData icon, String title, String status, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: isVerified ? AppColors.primary : Colors.white54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text(status,
                    style: TextStyle(
                        color: isVerified ? AppColors.primary : Colors.orange,
                        fontSize: 12)),
              ],
            ),
          ),
          Icon(
            isVerified ? Icons.check_circle : Icons.arrow_forward_ios,
            color: isVerified ? AppColors.primary : Colors.white24,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatPhoneDisplay(String phone) {
    if (phone.isEmpty) return "Raqam kiritilmagan";
    String clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!clean.startsWith('+')) clean = '+998$clean';
    if (clean.length >= 12) {
      // Format: +998 90 123 45 67
      return '${clean.substring(0, 4)} ${clean.substring(4, 6)} ${clean.substring(6, 9)} ${clean.substring(9, 11)} ${clean.substring(11)}';
    }
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _loadUserData,
            tooltip: 'Yangilash',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ─── AVATAR WITH CAMERA BUTTON ───
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.primaryDark.withOpacity(0.1)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                              width: 3),
                        ),
                        child: _avatarBytes != null
                            ? ClipOval(
                                child: Image.memory(
                                  _avatarBytes!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.person,
                                size: 55, color: AppColors.textSecondary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.background, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().scale(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 16),

              // ─── USER NAME ───
              Center(
                child: Text(_userName,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 6),

              // ─── PHONE NUMBER ───
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone,
                        size: 16,
                        color: _userPhone.isNotEmpty
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      _formatPhoneDisplay(_userPhone),
                      style: TextStyle(
                        color: _userPhone.isNotEmpty
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              // ─── TELEGRAM ───
              if (_userTelegram.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.telegram,
                          size: 16, color: Colors.blueAccent),
                      const SizedBox(width: 6),
                      Text(
                        '@${_userTelegram.replaceAll('@', '')}',
                        style: const TextStyle(
                            color: Colors.blueAccent, fontSize: 14),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms),
              ],

              const SizedBox(height: 24),

              // ─── STATS ───
              Row(
                children: [
                  Expanded(
                      child: _buildStatCard("E'lonlar", '$_listingsCount',
                          Icons.list_alt, AppColors.primary)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard("Muzlatilgan", "0 UZS",
                          Icons.account_balance_wallet, Colors.amber)),
                ],
              ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(),

              const SizedBox(height: 24),

              // ─── MENU ───
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(Icons.favorite_border, "Saqlanganlar",
                        onTap: _showSavedItems, badge: '0'),
                    _buildDivider(),
                    _buildListTile(Icons.shopping_bag_outlined,
                        "Mening xaridlarim (Escrow)",
                        onTap: () => context.push('/orders')),
                    _buildDivider(),
                    _buildListTile(Icons.storefront, "Mening buyurtmalarim",
                        onTap: () => context.push('/shop')),
                    _buildDivider(),
                    _buildListTile(
                        Icons.verified_user_outlined, "Verifikatsiya markazi",
                        onTap: _showVerificationCenter),
                    _buildDivider(),
                    _buildListTile(Icons.settings_outlined, "Sozlamalar",
                        onTap: () async {
                      await context.push('/profile/settings');
                      // Reload data when returning from settings
                      _loadUserData();
                    }),
                    _buildDivider(),
                    _buildListTile(Icons.exit_to_app, "Tizimdan chiqish",
                        isDestructive: true, onTap: _handleLogout),
                  ],
                ),
              )
                  .animate()
                  .slideY(begin: 0.2, delay: 200.ms, duration: 400.ms)
                  .fadeIn(),

              const SizedBox(height: 16),

              // ─── APP VERSION ───
              Center(
                child: Text(
                  'Qush Uyi v1.0.0 • Premium',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.2), fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color accentColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title,
      {bool isDestructive = false, VoidCallback? onTap, String? badge}) {
    return ListTile(
      leading:
          Icon(icon, color: isDestructive ? AppColors.error : Colors.white70),
      title: Text(title,
          style: TextStyle(
              color: isDestructive ? AppColors.error : Colors.white,
              fontWeight: FontWeight.w500)),
      trailing: isDestructive
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge,
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                  ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white30),
              ],
            ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
        height: 1, color: AppColors.glassBorder, indent: 16, endIndent: 16);
  }
}
