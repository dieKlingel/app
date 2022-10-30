import 'package:dieklingel_app/oss_licenses.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  void _inspect(BuildContext context, Package package, Key herokey) async {
    context.pushTransparentRoute(
      DismissiblePage(
        minRadius: 40,
        maxRadius: 50,
        onDismissed: () {
          Navigator.of(context).pop();
        },
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Hero(
              tag: herokey,
              child: Text(
                package.name,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text.rich(
                  TextSpan(
                    style:
                        CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                              fontSize: 14,
                            ),
                    children: [
                      TextSpan(
                        children: [
                          const TextSpan(text: "version\r\n"),
                          TextSpan(text: package.version),
                          const TextSpan(text: "\r\n\r\n"),
                        ],
                      ),
                      TextSpan(children: [
                        TextSpan(text: package.description),
                        const TextSpan(text: "\r\n\r\n"),
                      ]),
                      package.homepage == null
                          ? const TextSpan()
                          : TextSpan(
                              children: [
                                const TextSpan(text: "homepage:\r\n"),
                                TextSpan(text: package.homepage),
                                const TextSpan(text: "\r\n\r\n"),
                              ],
                            ),
                      package.license == null
                          ? const TextSpan()
                          : package.isMarkdown
                              ? WidgetSpan(
                                  child: Markdown(data: package.license!),
                                )
                              : TextSpan(
                                  children: [
                                    const TextSpan(text: "license:\r\n"),
                                    TextSpan(text: package.license),
                                  ],
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Licenses"),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: CupertinoFormSection(
              children: List.generate(
                ossLicenses
                    .where((element) => element.isDirectDependency)
                    .length,
                (index) {
                  Package package = ossLicenses
                      .where((element) => element.isDirectDependency)
                      .elementAt(index);
                  Key herokey = Key(package.hashCode.toString());

                  return CupertinoInkWell(
                    onTap: () {
                      _inspect(context, package, herokey);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 7,
                          bottom: 7,
                        ),
                        child: Hero(
                          tag: herokey,
                          child: Text(
                            "${package.name} ${package.version}",
                            textAlign: TextAlign.left,
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
