import 'package:flutter/foundation.dart';

typedef Validator<T> = Future<String?> Function(T? value);

class TalentFieldController<T> extends ChangeNotifier {
  T? _value;
  String? _errorText;
  bool _isValidating = false;
  final List<Validator<T>> validators;
  final T? initialValue;

  TalentFieldController({this.initialValue, this.validators = const []}) {
    _value = initialValue;
  }

  T? get value => _value;
  String? get errorText => _errorText;
  bool get isValidating => _isValidating;
  bool get isValid => _errorText == null;
  bool get hasError => _errorText != null;

  void setValue(T? newValue) {
    _value = newValue;
    _errorText = null; 
    notifyListeners();
  }

  Future<bool> validate() async {
    _isValidating = true;
    notifyListeners();

    _errorText = null;
    for (var validator in validators) {
      final error = await validator(_value);
      if (error != null) {
        _errorText = error;
        break;
      }
    }

    _isValidating = false;
    notifyListeners();
    return isValid;
  }
}
