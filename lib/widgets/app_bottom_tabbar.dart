//lib/widgets/app_bottom_tabbar.dart
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/carta_page.dart';
import '../pages/caja_page.dart';

class AppBottomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": Icons.table_restaurant, "label": "Mesas"},
      {"icon": Icons.receipt_long, "label": "Orden"},
      {"icon": Icons.point_of_sale, "label": "Caja"},
    ];

    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;

          return GestureDetector(
            onTap: () {
              onTap(index);

              if (index == currentIndex) return;

              Widget destino;

              if (index == 0) {
                destino = const HomePage();
              } else if (index == 1) {
                destino = const CartaPage();
              } else {
                destino = const CajaPage();
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => destino),
              );
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Row(
                children: [
                  Icon(
                    items[index]["icon"] as IconData,
                    color: selected ? Colors.black : Colors.white70,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    items[index]["label"] as String,
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
