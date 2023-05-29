import 'package:dieklingel_app/components/map_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconBuilder<T_ID, T_ICON extends Icon> extends MapBuilder<T_ID, Icon> {
  IconBuilder({super.id, super.fallback, super.values});

  @override
  IconBuilder<T_ID, Icon> withValues(Map<T_ID, Icon> map) {
    return IconBuilder(id: super.id, values: map, fallback: super.fallback);
  }

  @override
  IconBuilder<T_ID, Icon> withFallback(Icon fallback) {
    return IconBuilder(id: super.id, values: super.values, fallback: fallback);
  }

  @override
  IconBuilder<T_ID, Icon> from(T_ID? id) {
    return IconBuilder(id: id, values: super.values, fallback: super.fallback);
  }

  @override
  Icon build({
    IconData? icon,
    Key? key,
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    String? semanticLabel,
    TextDirection? textDirection,
  }) {
    Icon build = super.build();

    return Icon(
      icon ?? build.icon,
      key: key ?? build.key,
      size: size ?? build.size,
      fill: fill ?? build.fill,
      weight: weight ?? build.weight,
      grade: grade ?? build.grade,
      opticalSize: opticalSize ?? build.opticalSize,
      color: color ?? build.color,
      shadows: shadows ?? build.shadows,
      semanticLabel: semanticLabel ?? build.semanticLabel,
      textDirection: textDirection ?? build.textDirection,
    );
  }
}

/* class IconBuilder<T_ID, T_ICON extends Icon> {
  final T_ID? _id;
  final Map<T_ID, T_ICON> _values;
  final T_ICON? _fallback;

  IconBuilder()
      : _id = null,
        _fallback = null,
        _values = {};

  IconBuilder._(this._id, this._values, this._fallback);

  IconBuilder<T_ID, T_ICON> values(Map<T_ID, T_ICON> map) {
    return IconBuilder._(_id, map, _fallback);
  }

  IconBuilder<T_ID, T_ICON> fallback(T_ICON fallback) {
    return IconBuilder._(_id, _values, fallback);
  }

  IconBuilder<T_ID, T_ICON> from(T_ID? id) {
    return IconBuilder._(id, _values, _fallback);
  }

  Icon build({
    IconData? iconData,
    Key? key,
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    String? semanticLabel,
    TextDirection? textDirection,
  }) {
    if (_id == null) {
      throw BuilderException(
        "Cannot build an Icon without a source; Call Builder().from(id).",
      );
    }

    Icon? icon = _values[_id];
    if (icon == null) {
      Icon? fallback = _fallback;

      if (fallback == null) {
        throw BuilderException(
          "The given source was not found in values, and no fallback was set.",
        );
      }

      icon = fallback;
    }

    return Icon(
      iconData ?? icon.icon,
      key: key ?? icon.key,
      size: size ?? icon.size,
      fill: fill ?? icon.fill,
      weight: weight ?? icon.weight,
      grade: grade ?? icon.grade,
      opticalSize: opticalSize ?? icon.opticalSize,
      color: color ?? icon.color,
      shadows: shadows ?? icon.shadows,
      semanticLabel: semanticLabel ?? icon.semanticLabel,
      textDirection: textDirection ?? icon.textDirection,
    );
  }
}*/


