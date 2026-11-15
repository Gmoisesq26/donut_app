import 'package:donut_app/utils/donut_tile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BurgerTab extends StatelessWidget {
  BurgerTab({super.key});

  final storage = Supabase.instance.client.storage.from('productos');

  late final List burgertOnsale = [
    //donutFlavor, donutPrice, donutColor, donutImagePath, donutProvider
    [
      'Classic',
      '100',
      Colors.brown,
      storage.getPublicUrl('queso_burger.png'),
      'Burger King',
    ],
    [
      'Fries',
      '89',
      Colors.red,
      storage.getPublicUrl('frie_burger.png'),
      'MCDonalds',
    ],
    [
      'Chicken',
      '95',
      Colors.blue,
      storage.getPublicUrl('pollo_burger.png'),
      'KFC',
    ],
    [
      'Vegetarian',
      '70',
      Colors.purple,
      storage.getPublicUrl('vegetariana_burger.png'),
      "Carl’s Jr",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      //Se encarga de acomodar los elementos dentro del grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //Tamaño de cada columna
          childAspectRatio: 1 / 1.9,

          //Cantidad de columnas
          crossAxisCount: 2),
      //Cantidad de productos que se van a mostrar
      itemCount: burgertOnsale.length,
      //lo que se va a construir
      itemBuilder: (context, index) {
        return DonutTile(
          donutFlavor: burgertOnsale[index][0],
          donutPrice: burgertOnsale[index][1],
          donutColor: burgertOnsale[index][2],
          donutImagePath: burgertOnsale[index][3],
          donutProvider: burgertOnsale[index][4],
        );
      },
    );
  }
}
