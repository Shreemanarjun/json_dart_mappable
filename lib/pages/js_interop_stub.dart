typedef JSAny = dynamic;
typedef JSArray<T> = dynamic;

extension StringToJS on String {
  dynamic get toJS => this;
}

extension ListToJS on List {
  dynamic get toJS => this;
}
