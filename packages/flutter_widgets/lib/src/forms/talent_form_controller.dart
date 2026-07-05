import 'package:flutter/foundation.dart';
import 'talent_field_controller.dart';

class TalentFormController extends ChangeNotifier {
  final Map<String, TalentFieldController> _fields = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isValid => _fields.values.every((f) => f.isValid);
  bool get hasErrors => _fields.values.any((f) => f.hasError);

  void registerField(String name, TalentFieldController controller) {
    _fields[name] = controller;
    controller.addListener(notifyListeners);
  }

  void unregisterField(String name) {
    final controller = _fields.remove(name);
    controller?.removeListener(notifyListeners);
  }

  TalentFieldController? getField(String name) => _fields[name];

  Future<bool> validate() async {
    bool allValid = true;
    for (var field in _fields.values) {
      final valid = await field.validate();
      if (!valid) allValid = false;
    }
    notifyListeners();
    return allValid;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Map<String, dynamic> get values {
    return _fields.map((key, controller) => MapEntry(key, controller.value));
  }
}
