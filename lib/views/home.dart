import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  bool mytext = false;
  final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse("ws://dieklingel.com:8889/wsrs/room?key=dev-rtc"));

  RTCVideoRenderer localView = RTCVideoRenderer();

  @override
  void initState() {
    channel.stream.listen((event) {
      print(event);
    });
    localView.initialize();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("dieKlingel"),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / (16 / 9),
                  child: RTCVideoView(localView),
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      child: Text(mytext ? "true1" : "false1"),
                      onPressed: () async {
                        localView.srcObject =
                            await navigator.mediaDevices.getUserMedia({
                          'video': true,
                          'audio': true,
                        });
                      },
                    ),
                    CupertinoButton(
                      child: const Text("hang up"),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    localView.dispose();
    super.dispose();
  }
}
