import 'package:dieklingel_app/rtc/rtc_connection_state.dart';
import 'package:flutter/cupertino.dart';

import 'call_view.dart';

class CallViewFullScreen extends StatelessWidget {
  const CallViewFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(child: SafeArea(
        child: CallView(
          onCallStateChanged: (RtcConnectionState state) {
            if (state == RtcConnectionState.disconnected) {
              Navigator.of(context).pop();
            }
          },
        ),
      )),
    );
  }
}
