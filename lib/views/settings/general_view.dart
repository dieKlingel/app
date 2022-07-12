import 'package:flutter/cupertino.dart';

class GeneralView extends StatelessWidget {
  const GeneralView({Key? key}) : super(key: key);
  final String text = """
  Diese App gehört zum dieKlingel Projekt.
  Weitere Informationen zu der App oder
  dem Projekt, können der Webseite
  https://dieklingel.de/ entnohmen
  werden.
  
  Bei Fragen oder Anregungne können Sie
  sich gerne per email an 
  kai.mayer@dieklingel.com
  wenden.

  Die App wird unter der GPLv3 Lizenz vergeben.
  Copyright © Kai Mayer, Heilbronn 2022
  """;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const CupertinoDynamicColor.withBrightness(
                    color: CupertinoColors.black,
                    darkColor: CupertinoColors.white,
                  ).resolveFrom(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
