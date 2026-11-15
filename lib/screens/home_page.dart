import 'package:donut_app/utils/my_tab.dart';
import 'package:flutter/material.dart';
import '../tab/donut_tab.dart';
import '../tab/burger_tab.dart';
import '../tab/pancake_tab.dart';
import '../tab/pizza_tab.dart';
import '../tab/smoothie_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'messages_screen.dart';
import 'package:provider/provider.dart';
import 'package:donut_app/models/cart_model.dart';
import 'cart_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Cerrar sesión de Firebase
  Future<void> cerrarSesion() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
        ),
      );
    }
  }

  void abrirMensajes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MessagesScreen(),
      ),
    );
  }

  //late TabController _tabController;
  List<Widget> myTabs = [
    //Donuts Tab
    const MyTab(
      iconPath: "assets/icons/donut.png",
      iconName: "Donuts",
    ),
    //Burger Tab
    const MyTab(
      iconPath: "assets/icons/burger.png",
      iconName: "Burger",
    ),
    //Smoothies Tab
    const MyTab(
      iconPath: "assets/icons/smoothie.png",
      iconName: "Smoothies",
    ),
    //Pancakes Tab
    const MyTab(
      iconPath: "assets/icons/pancakes.png",
      iconName: "Pancakes",
    ),
    //Pizza Tab
    const MyTab(
      iconPath: "assets/icons/pizza.png",
      iconName: "Pizzas",
    ),
  ];

//  Widget DonutTab(TabController? controller) =>
//      const Center(child: Text('Donuts'));

//  Widget BurgerTab(TabController? controller) =>
//      const Center(child: Text('Burger'));

//  Widget SmoothieTab(TabController? controller) =>
//      const Center(child: Text('Smoothies'));

//  Widget PancakeTab(TabController? controller) =>
//      const Center(child: Text('Pancakes'));

//  Widget PizzaTab(TabController? controller) =>
//      const Center(child: Text('Pizzas'));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          //Para el icono de la izquierda
          leading: Icon(
            Icons.menu,
            color: Colors.grey,
          ),
          //Icono de la derecha
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 28,
                ),
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onSelected: (value) async {
                  if (value == 'messages') {
                    abrirMensajes();
                  }

                  if (value == 'logout') {
                    await cerrarSesion();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'messages',
                    child: Row(
                      children: [
                        Icon(Icons.message, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Mis mensajes'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          //1 Texto pricipal
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Row(
                  children: [
                    Text(
                      "I want to ",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "Eat",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                )),
            //2 Pestañas (TabBar)
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              //indicatorColor: Colors.transparent,
              tabs: myTabs,
            ),

            //3 Contenido de pestañas(TabbarView)
            Expanded(
              child: TabBarView(children: [
                DonutTab(),
                BurgerTab(),
                SmoothieTab(),
                PancakeTab(),
                PizzaTab()
              ]),
            ),
            //4 Carrito(Cart)
            Consumer<CartModel>(
              builder: (context, cart, _) => Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cart.totalItems} items | \$${cart.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'Delivery charges included',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                      ),
                      child: const Text(
                        'View cart',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
