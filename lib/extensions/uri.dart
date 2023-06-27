extension BetterUri on Uri {
  Uri append({String? path}) {
    return replace(
      pathSegments: [
        ...pathSegments,
        ...((path ?? "").split("/")..removeWhere((element) => element.isEmpty)),
      ],
    ).normalizePath();
  }
}
