import 'dart:convert';
import 'package:hive/hive.dart';
import 'draft_model.dart';
import 'draft_repository.dart';

class HiveDraftRepository implements DraftRepository {
  static const String _boxName = 'talent_drafts';

  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box<String>(_boxName);
    return await Hive.openBox<String>(_boxName);
  }

  @override
  Future<void> saveDraft(DraftModel draft) async {
    final box = await _getBox();
    await box.put(draft.positionId, jsonEncode(draft.toJson()));
  }

  @override
  Future<DraftModel?> getDraft(String positionId) async {
    final box = await _getBox();
    final data = box.get(positionId);
    if (data == null) return null;
    return DraftModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDraft(String positionId) async {
    final box = await _getBox();
    await box.delete(positionId);
  }

  @override
  Future<List<DraftModel>> getAllDrafts() async {
    final box = await _getBox();
    return box.values.map((data) {
      return DraftModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    }).toList();
  }
}
