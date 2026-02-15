import 'package:flutter/material.dart';
import 'dart:async'; // For Debounce

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

    // Mock Data State
    List<Map<String, dynamic>> _birds = [];
    List<Map<String, dynamic>> _filteredBirds = [];
    bool _isLoading = true;
    Timer? _debounce;

    @override
    void initState() {
        super.initState();
        _fetchBirds();
    }
    
    @override
    void dispose() {
        _debounce?.cancel();
        _breedController.dispose();
        super.dispose();
    }

    void _onSearchChanged(String query) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
             _filterBirds();
        });
    }
    
    void _filterBirds() {
        setState(() {
             _filteredBirds = _birds.where((bird) {
                // 1. Category Filter
                if (_selectedCategory != "Hammasi" && bird["category"] != _selectedCategory) return false;
                
                // 2. Verified Filter
                if (_onlyVerified && bird["is_verified"] != true) return false;
                
                // 3. Search Query (Breed or Category)
                String query = _breedController.text.toLowerCase();
                if (query.isNotEmpty) {
                    bool matchesBreed = bird["breed"].toString().toLowerCase().contains(query);
                    bool matchesCategory = bird["category"].toString().toLowerCase().contains(query);
                    if (!matchesBreed && !matchesCategory) return false;
                }
                
                return true;
             }).toList();
        });
    }

    // Simulate API Call
    Future<void> _fetchBirds() async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(milliseconds: 800)); // Network delay

        // Mock Response (matching Backend structure)
        List<Map<String, dynamic>> mockResponse = [
            {
                "id": "bird_1",
                "category": "Kanareyka",
                "breed": "Sayroqi",
                "price": 500000,
                "region_name": "Toshkent shahri",
                "seller_name": "Ali V.",
                "is_verified": true,
                "image": null // Placeholder
            },
            {
                "id": "bird_2",
                "category": "Kabutar",
                "breed": "Oqbosh",
                "price": 250000,
                "region_name": "Samarqand",
                "seller_name": "Vali B.",
                "is_verified": false,
                "image": null
            },
             {
                "id": "bird_3",
                "category": "To'ti",
                "breed": "Korella",
                "price": 350000,
                "region_name": "Buxoro",
                "seller_name": "G'ani",
                "is_verified": true,
                "image": null
            },
             {
                "id": "bird_4",
                "category": "Tovuq",
                "breed": "Brama",
                "price": 1200000,
                "region_name": "Farg'ona",
                "seller_name": "Hoshim",
                "is_verified": false,
                "image": null
            }
        ];

        if (mounted) {
            setState(() {
                _birds = mockResponse;
                _isLoading = false;
                _filterBirds(); // Initial Filter
            });
        }
    }

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
                                                    _filterBirds();
                                                });
                                            },
                                        ),
                                    );
                                }).toList(),
                            ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                            children: [
                                Expanded(
                                    child: TextField(
                                        controller: _breedController,
                                        onChanged: _onSearchChanged, // Debounced Search
                                        decoration: const InputDecoration(
                                            labelText: "Qidiruv (Nomi, Parodasi)",
                                            prefixIcon: Icon(Icons.search),
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                            isDense: true,
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                    label: const Text("Tasdiqlangan"),
                                    selected: _onlyVerified,
                                    onSelected: (bool value) {
                                        setState(() {
                                            _onlyVerified = value;
                                            _filterBirds();
                                        });
                                    },
                                    avatar: const Icon(Icons.verified, color: Colors.white, size: 16),
                                    selectedColor: Colors.blue,
                                    checkmarkColor: Colors.white,
                                    labelStyle: TextStyle(color: _onlyVerified ? Colors.white : Colors.black),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
            
            Expanded(
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _filteredBirds.isEmpty 
                    ? const Center(child: Text("Qushlar topilmadi"))
                    : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.gridCount == 1 ? 1 : 4,
                    childAspectRatio: widget.gridCount == 1 ? 1.5 : 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: displayBirds.length, 
                  itemBuilder: (context, index) {
                    final bird = _filteredBirds[index];
                    
                    return GestureDetector(
                      onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BirdDetailPage(index: index, isVerified: bird["is_verified"])),
                          );
                      },
                      child: Card(
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
                                              child: Text(bird["region_name"] ?? "Noma'lum", style: const TextStyle(color: Colors.white, fontSize: 10)),
                                          ),
                                      ),
                                       Positioned(
                                          bottom: 8, left: 8,
                                          child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.8),
                                                  borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Text(bird["seller_name"] ?? "Sotuvchi", style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
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
                                  Row(
                                      children: [
                                          Expanded(
                                              child: Text(
                                                "${bird['category']} - ${bird['breed']}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ),
                                          if (bird["is_verified"]) 
                                              const Padding(
                                                  padding: EdgeInsets.only(left: 4),
                                                  child: Icon(Icons.verified, color: Colors.blue, size: 16),
                                              )
                                      ],
                                  ),
                                  Text("Zoti: ${bird['breed']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${bird['price']} UZS",
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                      ),
                    );
                  },
                ),
            ),
        ],
    );
  }
}

class BirdDetailPage extends StatelessWidget {
    final int index;
    final bool isVerified;
    
    const BirdDetailPage({super.key, required this.index, required this.isVerified});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text("Sayroqi Kanareyka #${index + 1}")),
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Text("500 000 UZS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700])),
                                            if (isVerified)
                                                Chip(
                                                    avatar: const Icon(Icons.verified, color: Colors.white, size: 16),
                                                    label: const Text("Tasdiqlangan", style: TextStyle(color: Colors.white)),
                                                    backgroundColor: Colors.blue,
                                                )
                                        ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text("Ma'lumotlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    _buildInfoRow("Kategoriya", "Kanareyka"),
                                    _buildInfoRow("Paroda (Zoti)", "Chinniso"),
                                    _buildInfoRow("Yosh", "6 oy"),
                                    _buildInfoRow("Hudud", "Toshkent shahri"),
                                    
                                    const SizedBox(height: 24),
                                    const Text("Ta'rif", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    const Text(
                                        "Juda chiroyli sayraydigan kanareyka. Zoti toza. Emlangan. Odamga tez o'rganadi. Qafas bilan birga beriladi.",
                                        style: TextStyle(color: Colors.black87, height: 1.5),
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    if (isVerified)
                                        SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton.icon(
                                                onPressed: () {
                                                    showModalBottomSheet(
                                                        context: context, 
                                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                                        builder: (context) => const PassportModal()
                                                    );
                                                },
                                                icon: const Icon(Icons.qr_code),
                                                label: const Text("RAQAMLI PASPORTNI KO'RISH"),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                                            ),
                                        ),
                                        
                                    const SizedBox(height: 16),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                            child: const Text("SOTUVCHI BILAN BOG'LANISH"),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
    
    Widget _buildInfoRow(String label, String value) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(label, style: const TextStyle(color: Colors.grey)),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
            ),
        );
    }
}

class PassportModal extends StatelessWidget {
    const PassportModal({super.key});

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                     const Text("QUSH PASPORTI", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                     const SizedBox(height: 4),
                     Text("ID: BIRDS-773823", style: TextStyle(color: Colors.grey[600])),
                     const SizedBox(height: 24),
                     Container(
                         width: 200,
                         height: 200,
                         decoration: BoxDecoration(
                             border: Border.all(color: Colors.black12),
                             borderRadius: BorderRadius.circular(16)
                         ),
                         child: const Center(
                             child: Icon(Icons.qr_code_2, size: 150, color: Colors.black), // Mock QR
                         ),
                     ),
                     const SizedBox(height: 24),
                     const Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                             Icon(Icons.verified, color: Colors.blue),
                             SizedBox(width: 8),
                             Text("RASMIY TASDIQLANGAN", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16))
                         ],
                     ),
                     const SizedBox(height: 8),
                     const Text("Ushbu qush Qush Uyi platformasi tomonidan tekshirilgan va ma'lumotlari to'g'ri deb topilgan.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                     const SizedBox(height: 24),
                ],
            ),
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
