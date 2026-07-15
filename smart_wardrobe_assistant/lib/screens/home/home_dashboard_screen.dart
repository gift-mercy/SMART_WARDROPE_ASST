import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/camera/camera_screen.dart';
import 'package:camera/camera.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedIndex = 0;
  
  // Mock data - Replace with actual data from database/API
  final String userName = 'Rodney';
  final bool isNewUser = true; // Set to false for existing user state
  final String temperature = '26°C';
  final String weatherCondition = 'Sunny';
  final String weatherDescription = 'Perfect weather for light clothing.';
  final String weatherIcon = '☀️';
  
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.of(context).pushNamed('/wardrobe');
        break;
      case 2:
        Navigator.of(context).pushNamed('/add-clothing');
        break;
      case 3:
        Navigator.of(context).pushNamed('/suggestions');
        break;
      case 4:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }
  Future<void> _navigateToCamera() async {
    // 1. Fetch available cameras on the device dynamically
    WidgetsFlutterBinding.ensureInitialized();
    final List<CameraDescription> availableDeviceCameras = await availableCameras();

    // 2. Safely jump to your camera screen, passing the device cameras along
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(cameras: availableDeviceCameras),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Greeting and Profile
                    _buildHeader(),
                    
                    const SizedBox(height: 20),
                    
                    // Search Bar
                    _buildSearchBar(),
                    
                    const SizedBox(height: 20),
                    
                    // Weather Card
                    _buildWeatherCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Conditional Content based on user state
                    if (isNewUser) ...[
                      _buildNewUserContent(),
                    ] else ...[
                      _buildExistingUserContent(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// ============================================
  /// HEADER SECTION
  /// ============================================
  Widget _buildHeader() {
    // Get time-based greeting
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning 👋';
    } else if (hour < 17) {
      greeting = 'Good Afternoon 👋';
    } else {
      greeting = 'Good Evening 👋';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        // Profile Photo
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE5E7EB),
          child: const Icon(
            Icons.person,
            size: 32,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// SEARCH BAR
  /// ============================================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your wardrobe...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onTap: () {
          // Navigate to search screen
          Navigator.of(context).pushNamed('/search');
        },
      ),
    );
  }

  /// ============================================
  /// WEATHER CARD
  /// ============================================
  Widget _buildWeatherCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFFFEF3C7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Weather Icon
            Text(
              weatherIcon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            // Weather Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temperature,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    weatherCondition,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weatherDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
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

  /// ============================================
  /// QUICK ACTIONS
  /// ============================================
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildQuickActionButton(
          icon: Icons.add_a_photo,
          label: 'Add clothes',
          onTap: _navigateToCamera,
        ),
        _buildQuickActionButton(
          icon: Icons.checkroom,
          label: 'Wardrobe',
          onTap: () => Navigator.of(context).pushNamed('/wardrobe'),
        ),
        _buildQuickActionButton(
          icon: Icons.lightbulb_outline,
          label: 'Suggestions',
          onTap: () => Navigator.of(context).pushNamed('/suggestions'),
        ),
        _buildQuickActionButton(
          icon: Icons.history,
          label: 'History',
          onTap: () => Navigator.of(context).pushNamed('/history'),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 28,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// NEW USER CONTENT (State 1)
  /// ============================================
  Widget _buildNewUserContent() {
    return Column(
      children: [
        // Wardrobe Summary
        _buildSectionCard(
          title: 'Wardrobe Summary',
          child: Column(
            children: [
              const Icon(
                Icons.checkroom_outlined,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your wardrobe is empty. Start',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'by adding your first clothing',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'item.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Add Your First Clothing',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Today's Outfit
        _buildSectionCard(
          title: "Today's Outfit",
          child: Column(
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 12),
              const Text(
                'No outfit recommendations yet. Add',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'clothes to receive personalized',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'suggestions.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// EXISTING USER CONTENT (State 2)
  /// ============================================
  Widget _buildExistingUserContent() {
    return Column(
      children: [
        // Wardrobe Summary
        _buildSectionCard(
          title: 'Wardrobe Summary',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('15', 'Tops'),
              _buildStatItem('8', 'Bottoms'),
              _buildStatItem('5', 'Shoes'),
              _buildStatItem('3', 'Accessories'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Today's Outfit Recommendation
        _buildSectionCard(
          title: "Today's Outfit",
          child: Column(
            children: [
              // Outfit preview images would go here
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Outfit Preview',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Blue Shirt + Black Jeans + White Sneakers',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Perfect for today\'s weather',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recent Outfit History
        _buildSectionCard(
          title: 'Recent Outfit History',
          child: Column(
            children: [
              _buildHistoryItem('Yesterday', 'Black T-Shirt + Jeans'),
              const Divider(height: 20),
              _buildHistoryItem('2 days ago', 'White Shirt + Chinos'),
              const Divider(height: 20),
              _buildHistoryItem('3 days ago', 'Hoodie + Joggers'),
            ],
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// HELPER WIDGETS
  /// ============================================
  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String date, String outfit) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.checkroom,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                outfit,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF9CA3AF),
        ),
      ],
    );
  }

  /// ============================================
  /// BOTTOM NAVIGATION BAR
  /// ============================================
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: const Color(0xFF6B7280),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checkroom),
          label: 'Wardrobe',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          label: 'Suggestions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
