import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/network/api_client.dart';
import '../../home/presentation/providers/home_provider.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  int _currentStep = 0;
  final List<_MediaItem> _mediaFiles = [];
  bool _isSubmitting = false;
  PlatformFile? _documentFile;

  // Form controllers
  final _breedController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Selected category & region
  int _selectedCategoryId = 1;
  int _selectedRegionId = 1;

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Kabutar'},
    {'id': 2, 'name': "To'ti"},
    {'id': 3, 'name': 'Kanareyka'},
    {'id': 4, 'name': 'Bedana'},
    {'id': 5, 'name': 'Tovuq'},
    {'id': 6, 'name': "O'rdak"},
    {'id': 7, 'name': "G'oz"},
    {'id': 8, 'name': 'Boshqa'},
  ];

  final List<Map<String, dynamic>> _regions = [
    {'id': 1, 'name': 'Toshkent shahri'},
    {'id': 2, 'name': 'Toshkent viloyati'},
    {'id': 3, 'name': 'Andijon'},
    {'id': 4, 'name': 'Buxoro'},
    {'id': 5, 'name': 'Jizzax'},
    {'id': 6, 'name': 'Qashqadaryo'},
    {'id': 7, 'name': 'Navoiy'},
    {'id': 8, 'name': 'Namangan'},
    {'id': 9, 'name': 'Samarqand'},
    {'id': 10, 'name': 'Surxondaryo'},
    {'id': 11, 'name': 'Sirdaryo'},
    {'id': 12, 'name': 'Xorazm'},
    {'id': 13, 'name': "Farg'ona"},
    {'id': 14, 'name': "Qoraqalpog'iston"},
  ];

  @override
  void dispose() {
    _breedController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Pick images from gallery
  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (final file in result.files) {
            if (file.bytes != null) {
              _mediaFiles.add(_MediaItem(
                name: file.name,
                bytes: file.bytes!,
                isVideo: false,
              ));
            }
          }
        });
      }
    } catch (e) {
      _showError('Rasm tanlashda xatolik: $e');
    }
  }

  /// Pick video from gallery
  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _mediaFiles.add(_MediaItem(
              name: file.name,
              bytes: file.bytes!,
              isVideo: true,
            ));
          });
        }
      }
    } catch (e) {
      _showError('Video tanlashda xatolik: $e');
    }
  }

  /// Pick document file (PDF, image, etc.)
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _documentFile = result.files.first;
        });
      }
    } catch (e) {
      _showError('Hujjat tanlashda xatolik: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  /// Submit listing to real backend API
  Future<void> _submitListing() async {
    // Validation
    if (_mediaFiles.isEmpty) {
      _showError('Iltimos kamida 1 ta rasm yoki video yuklang');
      return;
    }
    if (_breedController.text.trim().isEmpty) {
      _showError('Iltimos qush zotini kiriting');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('Iltimos narxni kiriting');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = ref.read(dioProvider);

      // Build multipart files from bytes
      final List<MultipartFile> multipartFiles = [];
      for (final media in _mediaFiles) {
        final contentType = media.isVideo ? 'video/mp4' : 'image/jpeg';
        multipartFiles.add(
          MultipartFile.fromBytes(
            media.bytes,
            filename: media.name,
            contentType: DioMediaType.parse(contentType),
          ),
        );
      }

      final formData = FormData.fromMap({
        'category_id': _selectedCategoryId,
        'breed': _breedController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'description': _descriptionController.text.trim(),
        'region_id': _selectedRegionId,
        'user_id': 'telegram_user', // MVP: mock user ID
        'files': multipartFiles,
      });

      final response = await dio.post(
        '/birds/create-with-media',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        if (mounted) {
          // Refresh the birds list
          ref.read(birdsNotifierProvider.notifier).fetchInitial();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ E'lon muvaffaqiyatli joylandi!"),
              backgroundColor: Colors.green,
            ),
          );

          // Clear form
          setState(() {
            _mediaFiles.clear();
            _breedController.clear();
            _priceController.clear();
            _descriptionController.clear();
            _currentStep = 0;
          });
        }
      } else {
        _showError("E'lon yuborishda xatolik yuz berdi");
      }
    } catch (e) {
      _showError("Server bilan bog'lanishda xatolik: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Yangi E'lon"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary,
                  ),
            ),
            child: Stepper(
              currentStep: _currentStep,
              elevation: 0,
              type: StepperType.horizontal,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _submitListing();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isSubmitting ? null : details.onStepContinue,
                          child: _isSubmitting && _currentStep == 2
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background,
                                  ),
                                )
                              : Text(_currentStep == 2
                                  ? 'E\'LON QILISH'
                                  : 'KEYINGI'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            onPressed: details.onStepCancel,
                            child: const Text('ORQAGA',
                                style: TextStyle(color: AppColors.primary)),
                          ),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                // ─── STEP 1: MEDIA ───
                Step(
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                  title: const Text("Media"),
                  content: GlassContainer(
                    margin: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        if (_mediaFiles.isNotEmpty) ...[
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _mediaFiles.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (ctx, i) {
                                final item = _mediaFiles[i];
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: item.isVideo
                                          ? Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.videocam,
                                                      size: 36,
                                                      color: AppColors.primary),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item.name.length > 10
                                                        ? '${item.name.substring(0, 10)}...'
                                                        : item.name,
                                                    style: const TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Image.memory(
                                              item.bytes,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeMedia(i),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_mediaFiles.length} ta fayl tanlandi',
                            style: const TextStyle(
                                color: AppColors.primary, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          const Icon(Icons.cloud_upload_outlined,
                              size: 70, color: AppColors.primary),
                          const SizedBox(height: 16),
                          const Text("Rasm va 15 sekundgacha video yuklang",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16)),
                          const SizedBox(height: 24),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 12),
                                ),
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate,
                                    size: 20),
                                label: const Text('Rasm',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 12),
                                ),
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.videocam_outlined,
                                    size: 20),
                                label: const Text('Video',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                ),

                // ─── STEP 2: TAVSIF (DETAILS) ───
                Step(
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                  title: const Text("Tavsif"),
                  content: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Category dropdown
                      _buildDropdown(
                        label: 'Qush turkumi',
                        value: _selectedCategoryId,
                        items: _categories,
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v!),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Qush zoti (masalan: Tustovuq)',
                          controller: _breedController),
                      const SizedBox(height: 16),
                      _buildTextField('Narxi (UZS)',
                          isNumber: true, controller: _priceController),
                      const SizedBox(height: 16),
                      _buildTextField('Qisqacha ta\'rif',
                          maxLines: 3, controller: _descriptionController),
                      const SizedBox(height: 16),
                      // Region dropdown
                      _buildDropdown(
                        label: 'Hudud',
                        value: _selectedRegionId,
                        items: _regions,
                        onChanged: (v) =>
                            setState(() => _selectedRegionId = v!),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                ),

                // ─── STEP 3: ISHONCH (VERIFICATION) ───
                Step(
                  isActive: _currentStep >= 2,
                  title: const Text("Ishonch"),
                  content: GlassContainer(
                    margin: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Qush pasporti yoki Vet-ko'rik",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text(
                            "Bu majburiy emas, lekin yuklash orqali e'loningizni platformada yashil 'Tasdiqlangan' belgi bilan ko'paytirasiz.",
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 24),
                        if (_documentFile != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description,
                                    color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _documentFile!.name,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white54, size: 20),
                                  onPressed: () =>
                                      setState(() => _documentFile = null),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: _pickDocument,
                          icon: const Icon(Icons.file_upload),
                          label: Text(_documentFile != null
                              ? "Boshqa hujjat tanlash"
                              : "Hujjat yuklash"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.5)),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                ),
              ],
            ),
          ),
          // Loading overlay
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text("E'lon yuklanmoqda...",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: items
          .map((item) => DropdownMenuItem<int>(
                value: item['id'],
                child: Text(item['name']),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label,
      {bool isNumber = false,
      int maxLines = 1,
      TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}

/// Helper class to hold picked media bytes + metadata
class _MediaItem {
  final String name;
  final Uint8List bytes;
  final bool isVideo;

  _MediaItem({
    required this.name,
    required this.bytes,
    required this.isVideo,
  });
}
