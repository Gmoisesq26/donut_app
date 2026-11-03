import 'package:flutter/material.dart';

class DonutTile extends StatelessWidget {
  final String donutFlavor;
  final String donutPrice;
  final dynamic donutColor;
  final String donutImagePath;
  final String donutProvider;

  const DonutTile(
      {super.key,
      required this.donutFlavor,
      required this.donutPrice,
      this.donutColor,
      required this.donutImagePath,
      required this.donutProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: donutColor[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            //Etiqueta del precio
            Row(
              //Alinear a la derecha
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                  decoration: BoxDecoration(
                    color: donutColor[200],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  child: Text(
                    "\$$donutPrice",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: donutColor[800],
                    ),
                  ),
                ),
              ],
            ),
            //Imagen de la dona
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
              child: Image.asset(donutImagePath),
            ),
            //Nombre de la dona
            Text(
              donutFlavor,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            //Espacios entre textos
            const SizedBox(
              height: 4,
            ),
            //Nombre del provedor
            Text(
              donutProvider,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            //Espacios entre textos
            //Iconos de favoritos y carrito de compras
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.favorite_border,
                    color: Colors.pink[400],
                  ),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
