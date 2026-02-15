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
    
  // Public triggering method
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
          Navigator.pop(context); // Close Auth Modal
          _showProfileFillModal(context); // Open Profile Fill
      }),
    );
  }
  
  void _showProfileFillModal(BuildContext context) {
      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Force fill
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ProfileFillModal(),
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
              onPressed: () {
                  if (!_isLoggedIn) {
                      _showAuthModal(context);
                  } else {
                      // Navigate to Add Bird
                  }
              },
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
                                onPressed: () {
                                    if (!_isLoggedIn) {
                                      _showAuthModal(context);
                                    }
                                },
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

class HomeFeed extends StatelessWidget {
  final int gridCount;
  final VoidCallback triggerAuth;
  
  const HomeFeed({super.key, this.gridCount = 1, required this.triggerAuth});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCount == 1 ? 1 : 4, // Responsive Grid
        childAspectRatio: gridCount == 1 ? 1.5 : 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
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
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey[500]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Qush E'lon #${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "500 000 UZS",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            onPressed: triggerAuth,
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
    );
  }
}

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
