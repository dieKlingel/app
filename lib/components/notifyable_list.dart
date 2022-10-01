import 'dart:math';

import 'package:flutter/material.dart';

class NotifyableList<T> extends ChangeNotifier implements List<T> {
  final List<T> _list = [];

  List<T> asList() {
    return List.from(_list);
  }

  @override
  void clear() {
    _list.clear();
    notifyListeners();
  }

  void replace(List<T> list) {
    _list.clear();
    _list.addAll(list);
    notifyListeners();
  }

  @override
  void add(T item) {
    _list.add(item);
    notifyListeners();
  }

  @override
  bool remove(Object? value) {
    bool result = _list.remove(value);
    notifyListeners();
    return result;
  }

  @override
  T removeAt(int index) {
    T removed = _list.removeAt(index);
    notifyListeners();
    return removed;
  }

  @override
  void removeWhere(bool Function(T) test) {
    _list.removeWhere(test);
    notifyListeners();
  }

  @override
  void removeRange(int start, int end) {
    _list.removeRange(start, end);
    notifyListeners();
  }

  @override
  T get first {
    return _list.first;
  }

  @override
  set first(T value) {
    _list.first = value;
    notifyListeners();
  }

  @override
  T get last {
    return _list.last;
  }

  @override
  set last(T value) {
    _list.last = value;
    notifyListeners();
  }

  @override
  int get length {
    return _list.length;
  }

  @override
  set length(int newLength) {
    _list.length = newLength;
    notifyListeners();
  }

  @override
  List<T> operator +(List<T> other) {
    return List.from(_list + other);
  }

  @override
  T operator [](int index) {
    return _list[index];
  }

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _list.addAll(iterable);
    notifyListeners();
  }

  @override
  bool any(bool Function(T element) test) {
    return _list.any(test);
  }

  @override
  Map<int, T> asMap() {
    return _list.asMap();
  }

  @override
  List<R> cast<R>() {
    return _list.cast<R>();
  }

  @override
  bool contains(Object? element) {
    return _list.contains(element);
  }

  @override
  T elementAt(int index) {
    return _list.elementAt(index);
  }

  @override
  bool every(bool Function(T element) test) {
    return _list.every(test);
  }

  @override
  Iterable<E> expand<E>(Iterable<E> Function(T element) toElements) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    _list.fillRange(start, end, fillValue);
    notifyListeners();
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _list.firstWhere(test, orElse: orElse);
  }

  @override
  E fold<E>(E initialValue, E Function(E previousValue, T element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  @override
  void forEach(void Function(T element) action) {
    _list.forEach(action);
  }

  @override
  Iterable<T> getRange(int start, int end) {
    return _list.getRange(start, end);
  }

  @override
  int indexOf(T element, [int start = 0]) {
    return _list.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    // TODO: implement indexWhere
    throw UnimplementedError();
  }

  @override
  void insert(int index, T element) {
    // TODO: implement insert
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    // TODO: implement insertAll
  }

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  // TODO: implement iterator
  Iterator<T> get iterator => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    // TODO: implement lastIndexOf
    throw UnimplementedError();
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    // TODO: implement lastIndexWhere
    throw UnimplementedError();
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  Iterable<E> map<E>(E Function(T e) toElement) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  T removeLast() {
    // TODO: implement removeLast
    throw UnimplementedError();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> replacements) {
    _list.replaceRange(start, end, replacements);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(T element) test) {
    _list.retainWhere(test);
    notifyListeners();
  }

  @override
  // TODO: implement reversed
  Iterable<T> get reversed => throw UnimplementedError();

  @override
  void setAll(int index, Iterable<T> iterable) {
    _list.setAll(index, iterable);
    notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
    notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    _list.shuffle(random);
    notifyListeners();
  }

  @override
  // TODO: implement single
  T get single => throw UnimplementedError();

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Iterable<T> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    _list.sort(compare);
    notifyListeners();
  }

  @override
  List<T> sublist(int start, [int? end]) {
    // TODO: implement sublist
    throw UnimplementedError();
  }

  @override
  Iterable<T> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List<T> toList({bool growable = true}) {
    // TODO: implement toList
    throw UnimplementedError();
  }

  @override
  Set<T> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<T> whereType<T>() {
    // TODO: implement whereType
    throw UnimplementedError();
  }
}
