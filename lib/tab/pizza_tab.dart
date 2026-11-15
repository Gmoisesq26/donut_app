import 'package:donut_app/utils/donut_tile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PizzaTab extends StatelessWidget {
  PizzaTab({super.key});

  final storage = Supabase.instance.client.storage.from('productos');

  late final List pizzaOnsale = [
    //donutFlavor, donutPrice, donutColor, donutImagePath, donutProvider
    [
      'Pepperoni',
      '100',
      Colors.brown,
      storage.getPublicUrl('peperoni_pizza.png'),
      'Pizza Hut',
    ],
    [
      'Mushroom',
      '89',
      Colors.red,
      storage.getPublicUrl('champinon_pizza.png'),
      'Little Caesars',
    ],
    [
      'Hawaiian',
      '95',
      Colors.blue,
      storage.getPublicUrl('hawaiana_pizza.png'),
      'Messinas',
    ],
    [
      'Tomato',
      '70',
      Colors.purple,
      storage.getPublicUrl('tomate_pizza.png'),
      "Domino’s",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      //Se encarga de acomodar los elementos dentro del grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //Tamaño de cada columna
          childAspectRatio: 1 / 1.95,

          //Cantidad de columnas
          crossAxisCount: 2),
      //Cantidad de productos que se van a mostrar
      itemCount: pizzaOnsale.length,
      //lo que se va a construir
      itemBuilder: (context, index) {
        return DonutTile(
          donutFlavor: pizzaOnsale[index][0],
          donutPrice: pizzaOnsale[index][1],
          donutColor: pizzaOnsale[index][2],
          donutImagePath: pizzaOnsale[index][3],
          donutProvider: pizzaOnsale[index][4],
        );
      },
    );
  }
}
