import 'dart:math';
import 'dart:ui';

import 'package:dieklingel_app/components/fade_page_route.dart';
import 'package:dieklingel_app/repositories/ice_server_repository.dart';
import 'package:dieklingel_app/ui/call/outgoing/call_outgoing_view.dart';
import 'package:dieklingel_app/ui/call/outgoing/call_outgoing_view_model.dart';
import 'package:dieklingel_app/ui/home/home_view_model.dart';
import 'package:dieklingel_app/ui/home/widgets/home_connection_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt/mqtt.dart' as mqtt;
import 'package:provider/provider.dart';

import '../../../models/home.dart';

class HomeBody extends StatelessWidget {
  final Home home;

  const HomeBody({
    super.key,
    required this.home,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.select((HomeViewModel vm) => vm.state(home));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(
                children: [
                  Hero(
                    tag: "background-image",
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Image.asset(
                        "assets/images/house.png",
                        color: Colors.grey,
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CupertinoButton(
                      onPressed: state != mqtt.ConnectionState.connected
                          ? null
                          : () {
                              final connection =
                                  context.read<HomeViewModel>().client(home);

                              Navigator.push(
                                context,
                                FadePageRoute(
                                  builder: (_) {
                                    return ChangeNotifierProvider(
                                      create: (_) => CallOutgoingViewModel(
                                        home: home,
                                        connection: connection,
                                        iceServerRepository:
                                            context.read<IceServerRepository>(),
                                      ),
                                      child: const CallOutgoingView(),
                                    );
                                  },
                                ),
                              );
                            },
                      child: const Icon(
                        CupertinoIcons.play_fill,
                        size: 45.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HomeConnectionState(state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
