import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  int _currentStep = 0;

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
                    const Icon(Icons.cloud_upload_outlined,
                        size: 70, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text("Rasm va 15 sekundgacha video yuklang",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Galereyadan tanlash'),
                    )
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
