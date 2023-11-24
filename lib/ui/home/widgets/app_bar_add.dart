import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../repositories/home_repository.dart';
import '../../../views/ice_server_add_view.dart';
import '../../settings/homes/editor/home_editor_view.dart';
import '../../settings/homes/editor/home_editor_view_model.dart';

class AppBarAdd extends StatelessWidget {
  const AppBarAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return CupertinoPopupSurface(
                  child: ChangeNotifierProvider(
                    create: (_) => HomeEditorViewModel(
                      context.read<HomeRepository>(),
                    ),
                    child: const HomeEditorView(),
                  ),
                );
              },
            );
          },
          title: "add Home",
          icon: CupertinoIcons.home,
        ),
        PullDownMenuItem(
          onTap: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return const CupertinoPopupSurface(
                  child: IceServerAddView(),
                );
              },
            );
          },
          title: "add ICE Server",
          icon: CupertinoIcons.cloud,
        )
      ],
      buttonBuilder: (context, showMenu) {
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: showMenu,
          child: const Icon(CupertinoIcons.plus),
        );
      },
    );
  }
}
