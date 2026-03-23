import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_bottom_tabbar.dart';

class CartaPage extends StatefulWidget {
  const CartaPage({super.key});

  @override
  State<CartaPage> createState() => _CartaPageState();
}

class _CartaPageState extends State<CartaPage> {
  int currentTab = 1;

  String categoriaSeleccionada = "Bebidas";

  final categorias = ["Bebidas", "Postres", "Toppings", "Promos"];

  final productos = [
    {"nombre": "Capuccino", "precio": "S/ 8.00"},
    {"nombre": "Latte", "precio": "S/ 9.00"},
    {"nombre": "Cheesecake", "precio": "S/ 12.00"},
    {"nombre": "Brownie", "precio": "S/ 10.00"},
    {"nombre": "Té Helado", "precio": "S/ 7.00"},
    {"nombre": "Muffin", "precio": "S/ 6.00"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0F1A), Color(0xFF111827), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const AppNavbar(),

              const SizedBox(height: 8),

              categorySection(),

              const SizedBox(height: 14),

              searchSection(),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    return productCard(
                      productos[index]["nombre"]!,
                      productos[index]["precio"]!,
                    );
                  },
                ),
              ),

              AppBottomTabBar(
                currentIndex: currentTab,
                onTap: (index) {
                  setState(() {
                    currentTab = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categorySection() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final selected = categoria == categoriaSeleccionada;

          return GestureDetector(
            onTap: () {
              setState(() {
                categoriaSeleccionada = categoria;
              });
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
                      )
                    : null,
                color: selected ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Center(
                child: Text(
                  categoria,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget searchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Buscar producto...",
          hintStyle: const TextStyle(color: Colors.white54),

          prefixIcon: const Icon(Icons.search, color: Colors.white54),

          filled: true,
          fillColor: Colors.white.withOpacity(0.05),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget productCard(String nombre, String precio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(precio, style: const TextStyle(color: Colors.white70)),
            ],
          ),

          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C8AA), Color(0xFF00A896)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),

            child: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
