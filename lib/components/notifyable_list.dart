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
    return _list.expand(toElements);
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
    return _list.fold(initialValue, combine);
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    return _list.followedBy(other);
  }

  @override
  void forEach(void Function(T element) action) {
    _list.forEach(action);
    notifyListeners();
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
    return _list.indexWhere(test, start);
  }

  @override
  void insert(int index, T element) {
    _list.insert(index, element);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _list.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  Iterator<T> get iterator => _list.iterator;

  @override
  String join([String separator = ""]) {
    return _list.join(separator);
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    return _list.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    return _list.lastIndexWhere(test, start);
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _list.lastWhere(test, orElse: orElse);
  }

  @override
  Iterable<E> map<E>(E Function(T e) toElement) {
    return _list.map<E>(toElement);
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    return _list.reduce(combine);
  }

  @override
  T removeLast() {
    T last = _list.removeLast();
    notifyListeners();
    return last;
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
  Iterable<T> get reversed => _list.reversed;

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
  T get single => _list.single;

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    return _list.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> skip(int count) {
    return _list.skip(count);
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    return _list.skipWhile(test);
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    _list.sort(compare);
    notifyListeners();
  }

  @override
  List<T> sublist(int start, [int? end]) {
    return _list.sublist(start, end);
  }

  @override
  Iterable<T> take(int count) {
    return _list.take(count);
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    return _list.takeWhile(test);
  }

  @override
  List<T> toList({bool growable = true}) {
    return _list.toList(growable: growable);
  }

  @override
  Set<T> toSet() {
    return _list.toSet();
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    return _list.where(test);
  }

  @override
  Iterable<E> whereType<E>() {
    return _list.whereType<E>();
  }
}
