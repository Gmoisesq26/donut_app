import 'package:donut_app/utils/my_tab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              padding: const EdgeInsets.only(right: 24.0),
              child: Icon(Icons.person, color: Colors.grey),
            )
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
              tabs: myTabs,
              isScrollable: true,
              indicatorColor: Colors.transparent,
            ),

            //3 Contenido de pestañas(TabbarView)

            //4 Carrito(Cart)
          ],
        ),
      ),
    );
  }
}
