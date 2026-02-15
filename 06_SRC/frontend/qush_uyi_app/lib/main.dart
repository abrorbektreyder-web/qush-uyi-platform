import 'package:flutter/material.dart';

void main() {
  runApp(const QushUyiApp());
}

class QushUyiApp extends StatelessWidget {
  const QushUyiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qush Uyi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ResponsiveHome()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "Qush Uyi",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("O'zbekistonning №1 Qush bozori"),
          ],
        ),
      ),
    );
  }
}

class ResponsiveHome extends StatefulWidget {
  const ResponsiveHome({super.key});

  @override
  State<ResponsiveHome> createState() => _ResponsiveHomeState();
}

class _ResponsiveHomeState extends State<ResponsiveHome> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false; // Mock login state

  void _onItemTapped(int index) {
    if (index > 0 && !_isLoggedIn) {
      _showAuthModal(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
    
  void triggerAuth() {
     if (!_isLoggedIn) {
       _showAuthModal(context);
     }
  }

  void _showAuthModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AuthModal(onLoginSuccess: () {
          setState(() {
              _isLoggedIn = true;
          });
          Navigator.pop(context);
          _showProfileFillModal(context);
      }),
    );
  }
  
  void _showProfileFillModal(BuildContext context) {
      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ProfileFillModal(),
    );
  }
  
  void _openAddListingPage(BuildContext context) {
      if (!_isLoggedIn) {
          _showAuthModal(context);
          return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddListingPage()),
      );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile Layout
          return Scaffold(
            appBar: AppBar(
              title: const Text("Qush Uyi Market"),
            ),
            body: HomeFeed(triggerAuth: triggerAuth),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _openAddListingPage(context),
              child: const Icon(Icons.add),
            ),
          );
        } else {
          // Web/Desktop Layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.pets, color: Colors.green),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat),
                      label: Text('Chat'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text("Qush Uyi Market"),
                      actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: ElevatedButton.icon(
                                onPressed: () => _openAddListingPage(context),
                                icon: const Icon(Icons.add),
                                label: const Text("E'lon Berish"),
                            ),
                          )
                      ],
                    ),
                    body: HomeFeed(gridCount: 3, triggerAuth: triggerAuth),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class HomeFeed extends StatefulWidget {
  final int gridCount;
  final VoidCallback triggerAuth;
  
  const HomeFeed({super.key, this.gridCount = 1, required this.triggerAuth});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
    final List<String> _categories = ["Hammasi", "Kabutar", "To'ti", "Kanareyka", "Bedana", "Tovuq"];
    String _selectedCategory = "Hammasi";
    final TextEditingController _breedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
            // Search & Filter Header
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        SingleChildScrollView( // Category Tabs
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: _categories.map((category) {
                                    final isSelected = _selectedCategory == category;
                                    return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: ChoiceChip(
                                            label: Text(category),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                                setState(() {
                                                    _selectedCategory = category;
                                                });
                                            },
                                        ),
                                    );
                                }).toList(),
                            ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            controller: _breedController,
                            decoration: const InputDecoration(
                                labelText: "Qush parodasi (Masalan: Chinniso)",
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                        ),
                    ],
                ),
            ),
            
            Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.gridCount == 1 ? 1 : 4,
                    childAspectRatio: widget.gridCount == 1 ? 1.5 : 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 8, // Mock count
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Stack(
                                children: [
                                    Center(child: Icon(Icons.image, size: 50, color: Colors.grey[400])),
                                    Positioned(
                                        top: 8, right: 8,
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: const Text("Toshkent", style: TextStyle(color: Colors.white, fontSize: 10)),
                                        ),
                                    )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sayroqi Kanareyka #${index + 1}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Text("Zoti: Chinniso", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                const Text(
                                  "500 000 UZS",
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                        onPressed: widget.triggerAuth,
                                        child: const Text("Sotib Olish"),
                                    ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ),
        ],
    );
  }
}

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
    final List<String> _categories = ["Kabutar", "To'ti", "Kanareyka", "Bedana", "Tovuq", "Boshqa"];
    String? _selectedCategory;
    final List<String> _regions = ["Toshkent shahri", "Toshkent viloyati", "Andijon viloyati", "Buxoro viloyati"];
    String? _selectedRegion;
    
    // Mock Media List
    final List<String> _mockSelectedFiles = []; 
    String? _attachedDocument; // Mock document path

    void _pickMedia() {
        // Mock Picker Logic
        setState(() {
             if (_mockSelectedFiles.length < 5) {
                 _mockSelectedFiles.add("image_${_mockSelectedFiles.length + 1}.jpg");
             } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Maksimal 5 ta fayl yuklash mumkin!"))
                 );
             }
        });
    }

    void _pickDocument() {
        // Mock Document Picker
        setState(() {
            _attachedDocument = "bird_passport_${DateTime.now().millisecondsSinceEpoch}.pdf";
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text("Yangi E'lon")),
            body: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                // MEDIA PICKER SECTION
                                Container(
                                    height: 120,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _mockSelectedFiles.length + 1,
                                        itemBuilder: (context, index) {
                                            if (index == 0) {
                                                return GestureDetector(
                                                    onTap: _pickMedia,
                                                    child: Container(
                                                        width: 100,
                                                        margin: const EdgeInsets.only(right: 8),
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey[200],
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(color: Colors.grey),
                                                        ),
                                                        child: const Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                                Icon(Icons.add_a_photo, color: Colors.grey),
                                                                SizedBox(height: 4),
                                                                Text("Rasm/Video", style: TextStyle(fontSize: 12)),
                                                            ],
                                                        ),
                                                    ),
                                                );
                                            }
                                            return Container(
                                                width: 100,
                                                margin: const EdgeInsets.only(right: 8),
                                                decoration: BoxDecoration(
                                                    color: Colors.black12,
                                                    borderRadius: BorderRadius.circular(8),
                                                    image: const DecorationImage(
                                                        image: NetworkImage("https://via.placeholder.com/100"), // Mock Preview
                                                        fit: BoxFit.cover
                                                    )
                                                ),
                                                child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: IconButton(
                                                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                                        onPressed: () {
                                                            setState(() {
                                                                _mockSelectedFiles.removeAt(index - 1);
                                                            });
                                                        },
                                                    ),
                                                ),
                                            );
                                        },
                                    ),
                                ),
                                DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: "Kategoriya", border: OutlineInputBorder()),
                                    value: _selectedCategory,
                                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                    onChanged: (v) => setState(() => _selectedCategory = v),
                                ),
                                const SizedBox(height: 16),
                                const TextField(
                                    decoration: InputDecoration(labelText: "Paroda (Zoti)", border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 16),
                                const TextField(
                                    decoration: InputDecoration(labelText: "Narx (UZS)", border: OutlineInputBorder(), suffixText: "UZS"),
                                    keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                const TextField(
                                    decoration: InputDecoration(labelText: "Batafsil ma'lumot", border: OutlineInputBorder()),
                                    maxLines: 4,
                                ),
                                 const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: "Sizning Hududingiz (Info uchun)", border: OutlineInputBorder()),
                                    value: _selectedRegion,
                                    items: _regions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                    onChanged: (v) => setState(() => _selectedRegion = v),
                                ),
                                const SizedBox(height: 16),

                                // DOCUMENT UPLOAD SECTION (Optional)
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.blue[50], // Light blue to highlight importance
                                    ),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text("Hujjat yuklash (Ixtiyoriy)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 4),
                                            const Text("Pasport yoki Vet-ma'lumotnoma yuklasangiz, 'Tasdiqlangan' belgisini olasiz.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            const SizedBox(height: 8),
                                            if (_attachedDocument != null)
                                                ListTile(
                                                    leading: const Icon(Icons.description, color: Colors.blue),
                                                    title: Text(_attachedDocument!, overflow: TextOverflow.ellipsis),
                                                    trailing: IconButton(
                                                        icon: const Icon(Icons.close, color: Colors.red),
                                                        onPressed: () => setState(() => _attachedDocument = null),
                                                    ),
                                                    contentPadding: EdgeInsets.zero,
                                                )
                                            else
                                                OutlinedButton.icon(
                                                    onPressed: _pickDocument,
                                                    icon: const Icon(Icons.upload_file),
                                                    label: const Text("Hujjatni tanlash (Rasm/PDF)"),
                                                ),
                                        ],
                                    ),
                                ),

                                const SizedBox(height: 24),
                                SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                        onPressed: () {
                                            if (_mockSelectedFiles.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kamida 1 ta rasm yuklang!")));
                                                return;
                                            }
                                            Navigator.pop(context);
                                            
                                            String msg = "E'lon va Media fayllar joylandi!";
                                            if (_attachedDocument != null) {
                                                msg += " Hujjat tekshiruvga yuborildi.";
                                            }
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                        child: const Text("E'LONNI JOYLASHTIRISH"),
                                    ),
                                )
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}

// Reuse AuthModal and ProfileFillModal from Task 1.2
class AuthModal extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AuthModal({super.key, required this.onLoginSuccess});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;

  void _sendCode() {
    setState(() {
      _codeSent = true;
    });
  }

  void _verifyCode() {
      // Logic: Verify Code -> If success -> Trigger Callback
      widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _codeSent ? "Kodni kiriting" : "Tizimga kirish",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _codeSent 
              ? "${_phoneController.text} raqamiga kod yuborildi" 
              : "Davom etish uchun telefon raqamingizni kiriting",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          
          if (!_codeSent)
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Telefon raqam",
                prefixText: "+998 ",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            )
          else
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "SMS Kod",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
            ),
            
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _codeSent ? _verifyCode : _sendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(_codeSent ? "TASDIQLASH" : "KOD OLISH"),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class ProfileFillModal extends StatefulWidget {
  const ProfileFillModal({super.key});

  @override
  State<ProfileFillModal> createState() => _ProfileFillModalState();
}

class _ProfileFillModalState extends State<ProfileFillModal> {
    final _nameController = TextEditingController();
    String? _selectedRegion;
    
    final List<String> _regions = [
        "Toshkent shahri",
        "Toshkent viloyati",
        "Andijon viloyati",
        "Buxoro viloyati",
        "Farg'ona viloyati",
        "Jizzax viloyati",
        "Xorazm viloyati",
        "Namangan viloyati",
        "Navoiy viloyati",
        "Qashqadaryo viloyati",
        "Samarqand viloyati",
        "Sirdaryo viloyati",
        "Surxondaryo viloyati",
        "Qoraqalpog'iston Respublikasi"
    ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profilni to'ldirish",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Ismingiz va hududingizni kiriting",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Ismingiz",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(
                  labelText: "Hududni tanlang",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
              ),
              items: _regions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRegion = newValue;
                });
              },
          ),
            
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                  if (_nameController.text.isNotEmpty && _selectedRegion != null) {
                      Navigator.pop(context); // Close Profile Modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profil saqlandi! Xush kelibsiz.")),
                      );
                  }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("SAQLASH VA DAVOM ETISH"),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
