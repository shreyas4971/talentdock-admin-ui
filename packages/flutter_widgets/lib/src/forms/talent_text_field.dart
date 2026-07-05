import 'package:flutter/material.dart';
import 'talent_field_controller.dart';

class TalentTextField extends StatefulWidget {
  final TalentFieldController<String> controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final bool enabled;

  const TalentTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.enabled = true,
  });

  @override
  State<TalentTextField> createState() => _TalentTextFieldState();
}

class _TalentTextFieldState extends State<TalentTextField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.value);
    _textController.addListener(() {
      widget.controller.setValue(_textController.text);
    });
    widget.controller.addListener(_onFieldControllerChanged);
  }

  void _onFieldControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    widget.controller.removeListener(_onFieldControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.controller.errorText,
        border: const OutlineInputBorder(),
        suffixIcon: widget.controller.isValidating 
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ) 
          : null,
      ),
      obscureText: widget.obscureText,
      enabled: widget.enabled,
    );
  }
}
