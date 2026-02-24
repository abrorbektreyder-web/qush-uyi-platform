import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  final List<_MediaItem> _mediaFiles = [];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _mediaFiles.add(_MediaItem(
            name: image.name,
            bytes: bytes,
            isVideo: false,
          ));
        });
      }
    } catch (e) {
      _showError('Rasm tanlashda xatolik: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 15),
      );
      if (video != null) {
        final bytes = await video.readAsBytes();
        setState(() {
          _mediaFiles.add(_MediaItem(
            name: video.name,
            bytes: bytes,
            isVideo: true,
          ));
        });
      }
    } catch (e) {
      _showError('Video tanlashda xatolik: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
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
      body: Theme(
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("E'lon muvaffaqiyatli saqlandi! (Mock)")),
              );
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
                      onPressed: details.onStepContinue,
                      child:
                          Text(_currentStep == 2 ? 'E\'LON QILISH' : 'KEYINGI'),
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
            Step(
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              title: const Text("Media"),
              content: GlassContainer(
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    // Show uploaded files
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
                                          color: AppColors.surface,
                                          child: const Center(
                                            child: Icon(Icons.videocam,
                                                size: 40,
                                                color: AppColors.primary),
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
                      const SizedBox(height: 16),
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
                              color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 24),
                    ],
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                            ),
                            onPressed: _pickImage,
                            icon:
                                const Icon(Icons.add_photo_alternate, size: 20),
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
                            icon: const Icon(Icons.videocam_outlined, size: 20),
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
            Step(
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              title: const Text("Tavsif"),
              content: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildTextField('Qush zoti (masalan: Tustovuq)'),
                  const SizedBox(height: 16),
                  _buildTextField('Narxi (UZS)', isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField('Qisqacha ta\'rif va hudud', maxLines: 3),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            ),
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
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.file_upload),
                      label: const Text("Hujjat yuklash"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
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

/// Helper class to store picked media bytes + metadata
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
