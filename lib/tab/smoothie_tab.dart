import 'package:donut_app/utils/donut_tile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SmoothieTab extends StatelessWidget {
  SmoothieTab({super.key});

  final storage = Supabase.instance.client.storage.from('productos');

  late final List smoothieOnsale = [
    //donutFlavor, donutPrice, donutColor, donutImagePath, donutProvider
    [
      'Strawberry',
      '100',
      Colors.brown,
      storage.getPublicUrl('fresa_smoothie.png'),
      'Detox Verde',
    ],
    [
      'Orange',
      '89',
      Colors.red,
      storage.getPublicUrl('naranja_smoothie.png'),
      'Smoothie King',
    ],
    [
      'Blueberries',
      '95',
      Colors.blue,
      storage.getPublicUrl('arandanos_smoothie.png'),
      'Planet Smoothie',
    ],
    [
      'Banana',
      '70',
      Colors.purple,
      storage.getPublicUrl('banana_smoothie.png'),
      "Happy Planet",
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
      itemCount: smoothieOnsale.length,
      //lo que se va a construir
      itemBuilder: (context, index) {
        return DonutTile(
          donutFlavor: smoothieOnsale[index][0],
          donutPrice: smoothieOnsale[index][1],
          donutColor: smoothieOnsale[index][2],
          donutImagePath: smoothieOnsale[index][3],
          donutProvider: smoothieOnsale[index][4],
        );
      },
    );
  }
}
