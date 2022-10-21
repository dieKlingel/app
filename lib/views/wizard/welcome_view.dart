import 'package:dieklingel_app/views/wizard/icon_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            children: [
              TextSpan(text: "Hello", style: TextStyle(fontSize: 32)),
              TextSpan(text: ",\r\n"),
              TextSpan(text: "we are happy that you are here!\r\n"),
              TextSpan(
                  text:
                      "we have to setup a few things, but now worry, we will guide your throug.\r\n"),
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: IconText(
                      icon: CupertinoIcons.arrow_left,
                      text: "swipe rigth, to start"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
