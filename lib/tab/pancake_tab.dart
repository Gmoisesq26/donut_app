import 'package:donut_app/utils/donut_tile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PancakeTab extends StatelessWidget {
  PancakeTab({super.key});

  final storage = Supabase.instance.client.storage.from('productos');

  late final List pancakeOnsale = [
    //donutFlavor, donutPrice, donutColor, donutImagePath, donutProvider
    [
      'Classic',
      '100',
      Colors.brown,
      storage.getPublicUrl('original_pancake.png'),
      'IHOP',
    ],
    [
      'chocolate\nbanana',
      '89',
      Colors.red,
      storage.getPublicUrl('chocobanana_pancake.png'),
      'First Watch',
    ],
    [
      'Honey',
      '95',
      Colors.blue,
      storage.getPublicUrl('miel_pancake.png'),
      'Lalo!',
    ],
    [
      'chocolate\nblueberry',
      '70',
      Colors.purple,
      storage.getPublicUrl('chocoarandano_pancake.png'),
      "Mr. Pancake",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      //Se encarga de acomodar los elementos dentro del grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //Tamaño de cada columna
          childAspectRatio: 1 / 2.1,

          //Cantidad de columnas
          crossAxisCount: 2),
      //Cantidad de productos que se van a mostrar
      itemCount: pancakeOnsale.length,
      //lo que se va a construir
      itemBuilder: (context, index) {
        return DonutTile(
          donutFlavor: pancakeOnsale[index][0],
          donutPrice: pancakeOnsale[index][1],
          donutColor: pancakeOnsale[index][2],
          donutImagePath: pancakeOnsale[index][3],
          donutProvider: pancakeOnsale[index][4],
        );
      },
    );
  }
}
