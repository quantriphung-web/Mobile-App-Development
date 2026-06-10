import 'package:flutter/material.dart';

/// Bottom nav dùng chung cho toàn app.
/// [currentIndex]: tab đang active (0=Home, 1=Shop, 2=Bag, 3=Favorites, 4=Profile)
/// [onTap]: callback khi tap, truyền index vào
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _handleTap(context, i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFDB3022),
      unselectedItemColor: const Color(0xFF9B9B9B),
      backgroundColor: Colors.white,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Bag',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _handleTap(BuildContext context, int i) {
    // Nếu caller muốn tự xử lý thêm
    onTap?.call(i);

    // Logic navigate mặc định
    switch (i) {
      case 0:
        // Về Home — nếu đang ở màn hình khác thì pop về /main
        if (currentIndex != 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        }
        break;
      case 1:
        // Shop
        if (currentIndex != 1) {
          Navigator.pushNamed(context, '/shop');
        }
        break;
      case 2:
        break;
      case 3:
        if (currentIndex != 3) {
          Navigator.pushNamed(context, '/favorites');
        }
        break;
      case 4:
        break;
    }
  }
}
