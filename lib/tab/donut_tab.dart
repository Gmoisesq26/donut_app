import 'package:flutter/material.dart';

class DonutTab extends StatelessWidget {
  DonutTab({super.key});

  final List donutOnsale = [
    //donutFlavor, donutPrice, donutColor, donutImagePath, donutProvider
    [
      'Chocolate',
      '100',
      Colors.brown,
      "lib/images/chocolate_donut.png",
      'Starbucks',
    ],
    [
      'Strawberry',
      '89',
      Colors.red,
      "lib/images/strawberry_donut.png",
      'Krispy Kreme',
    ],
    [
      'Ice Cream',
      '95',
      Colors.blue,
      "lib/images/icecream_donut.png",
      "Dunkin' Donuts",
    ],
    ['Grape', '70', Colors.purple, "lib/images/grape_donut.png", 'Oxxo']
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      //Se encarga de acomodar los elementos dentro del grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //Tamaño de cada columna
          childAspectRatio: 1 / 1.5,

          //Cantidad de columnas
          crossAxisCount: 2),
      //Cantidad de productos que se van a mostrar
      itemCount: donutOnsale.length,
      //lo que se va a construir
      itemBuilder: DonutTitle(
        donutFlavor: donutOnsale[index][0],
        donutPrice: donutOnsale[index][1],
        donutColor: donutOnsale[index][2],
        donutImagePath: donutOnsale[index][3],
        donutProvider: donutOnsale[index][4],
      ),
    );
  }
}
