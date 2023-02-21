import 'package:audio_session/audio_session.dart';
import 'package:dieklingel_app/blocs/home_view_bloc.dart';
import 'package:dieklingel_app/blocs/homes_view_bloc.dart';
import 'package:dieklingel_core_shared/flutter_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import 'home_view.dart';
import 'settings_view.dart';

import '../models/home.dart';

class HomesView extends StatelessWidget {
  const HomesView({super.key});

  void _onSettingsBtnPressed(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: const Text("Homes"),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.settings),
        onPressed: () => _onSettingsBtnPressed(context),
      ),
    );
  }

  void _onHomePressed(BuildContext context, Home home) async {
    MqttClientBloc mqttbloc = GetIt.I<MqttClientBloc>();
    mqttbloc.usernanme.add(home.username ?? "");
    mqttbloc.password.add(home.password ?? "");
    mqttbloc.uri.add(home.uri);

    HomeViewBloc homebloc = HomeViewBloc();
    homebloc.home.add(home);

    /* TODO: Hotfix: AudioSession
    Do this, so the mic starts the first time we use navigator.mediaDevices
    caues by this issue: https://github.com/flutter-webrtc/flutter-webrtc/issues/1094
    */
    AudioSession.instance.then((session) {
      session.configure(const AudioSessionConfiguration.speech());
    });

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(
          blocs: [
            BlocProvider(bloc: homebloc),
          ],
          child: const HomeView(),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return SliverSafeArea(
      top: false,
      sliver: StreamBuilder(
        stream: context.bloc<HomesViewBloc>().homes,
        builder: (BuildContext contex, AsyncSnapshot<List<Home>> snapshot) {
          if (!snapshot.hasData) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          List<Home> homes = snapshot.data!;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: homes.length,
              (context, index) {
                Home home = homes[index];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () => _onHomePressed(context, home),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 14.0,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.secondarySystemBackground,
                          context,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            home.name,
                            style: TextStyle(
                              color: CupertinoDynamicColor.resolve(
                                CupertinoColors.label,
                                context,
                              ),
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_forward),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          _header(context),
          _body(context),
        ],
      ),
    );
  }
}
